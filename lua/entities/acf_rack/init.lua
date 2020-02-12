-- init.lua

AddCSLuaFile("shared.lua")
include("shared.lua")

DEFINE_BASECLASS("acf_explosive")

ACF.RegisterClassLink("acf_rack", "acf_ammo", function(Weapon, Target)
	if Target.RoundType == "Refill" then return false, "Refill crates cannot be linked!" end
	if Weapon.Crates[Target] then return false, "This rack is already linked to this crate." end
	if Target.Weapons[Weapon] then return false, "This rack is already linked to this crate." end
	if Weapon.MissileId ~= Target.BulletData.Id then return false, "Wrong ammo type for this rack." end

	local BulletData = Target.BulletData
	local GunClass = ACF_GetGunValue(BulletData, "gunclass")
	local Blacklist = ACF.AmmoBlacklist[Target.RoundType]

	if not GunClass or table.HasValue(Blacklist, GunClass) then return false, "That round type cannot be used with this rack!" end

	local Result, Message = ACF_CanLinkRack(Weapon.Id, BulletData.Id, BulletData, Weapon)

	if not Result then return Result, Message end

	Weapon.Crates[Target]  = true
	Target.Weapons[Weapon] = true

	Weapon:UpdateOverlay()
	Target:UpdateOverlay()

	return true, "Rack linked successfully."
end)

ACF.RegisterClassUnlink("acf_rack", "acf_ammo", function(Weapon, Target)
	if Weapon.Crates[Target] or Target.Weapons[Weapon] then
		Weapon.Crates[Target]  = nil
		Target.Weapons[Weapon] = nil

		Weapon:UpdateOverlay()
		Target:UpdateOverlay()

		return true, "Weapon unlinked successfully."
	end

	return false, "This rack is not linked to this crate."
end)

-------------------------------[[ Local Functions ]]-------------------------------

local CheckLegal  = ACF_CheckLegal
local ClassLink	  = ACF.GetClassLink
local ClassUnlink = ACF.GetClassUnlink
local UnlinkSound = "physics/metal/metal_box_impact_bullet%s.wav"

local WireTable = {
	gmod_wire_adv_pod = true,
	gmod_wire_joystick = true,
	gmod_wire_expression2 = true,
	gmod_wire_joystick_multi = true,
	gmod_wire_pod = function(Input)
		if Input.Pod then
			return Input.Pod:GetDriver()
		end
	end,
	gmod_wire_keyboard = function(Input)
		if Input.ply then
			return Input.ply
		end
	end
}

WireTable.gmod_wire_adv_pod = WireTable.gmod_wire_pod
WireTable.gmod_wire_joystick = WireTable.gmod_wire_pod
WireTable.gmod_wire_joystick_multi = WireTable.gmod_wire_pod
WireTable.gmod_wire_expression2 = function(Input, This)
	if Input.Inputs.Fire then
		return This:GetUser(Input.Inputs.Fire.Src)
	elseif Input.Inputs.Shoot then
		return This:GetUser(Input.Inputs.Shoot.Src)
	elseif Input.Inputs then
		for _, V in pairs(Input.Inputs) do
			if not IsValid(V.Src) then
				return Input.Owner or Input:GetOwner()
			end

			if WireTable[V.Src:GetClass()] then
				return This:GetUser(V.Src)
			end
		end
	end
end

local Inputs = {
	Fire = function(Rack, Value)
		Rack.Firing = ACF.GunfireEnabled and tobool(Value)

		if Rack.Firing and Rack.NextFire >= 1 then
			Rack.User = Rack:GetUser(Rack.Inputs.Fire.Src)

			if not IsValid(Rack.User) then
				Rack.User = Rack.Owner
			end

			Rack:FireMissile()
		end
	end,
	["Fire Delay"] = function(Rack, Value)
		Rack.FireDelay = math.Clamp(Value, 0, 1)
	end,
	Reload = function(Rack, Value)
		if tobool(Value) then
			Rack:Reload()
		end
	end,
	["Target Pos"] = function(Rack, Value)
		Rack.TargetPos = Vector(Value[1], Value[2], Value[3])

		WireLib.TriggerOutput(Rack, "Position", Value)
	end,
	Elevation = function(Rack, Value)
		Rack.Elevation = -Value
	end,
	Azimuth = function(Rack, Value)
		Rack.Azimuth = -Value
	end,
}

local function CheckRackID(ID, MissileID)
	local Weapons = ACF.Weapons

	if not (ID and Weapons.Rack[ID]) then
		local GunClass = Weapons.Guns[MissileID]

		if not GunClass then
			error("Couldn't spawn the missile rack: can't find the gun-class '" .. tostring(MissileID) .. "'.")
		end

		if not GunClass.rack then
			error("Couldn't spawn the missile rack: '" .. tostring(MissileID) .. "' doesn't have a preferred missile rack.")
		end

		ID = GunClass.rack
	end

	return ID
end

local function GetNextCrate(Rack)
	if not next(Rack.Crates) then return end -- No crates linked to this gun

	local Current = Rack.CurrentCrate
	local NextKey = (IsValid(Current) and Rack.Crates[Current]) and Current or nil
	local Select = next(Rack.Crates, NextKey) or next(Rack.Crates) -- Next crate from Start or, if at last crate, first crate
	local Start = Select

	repeat
		if Select.Load and Select.Ammo > 0 then return Select end

		Select = next(Rack.Crates, Select) or next(Rack.Crates)
	until Select == Start -- If we've looped back around to the start then there's nothing to use

	return (Select.Load and Select.Ammo > 0) and Select
end

local function GetNextAttachName(Rack)
	if not next(Rack.AttachPoints) then return end

	local Name = next(Rack.AttachPoints)
	local Start = Name

	repeat
		if not Rack.Missiles[Name] then
			return Name
		end

		Name = next(Rack.AttachPoints, Name) or next(Rack.AttachPoints)
	until Name == Start
end

local function GetMissileAngPos(Rack, Missile, AttachName)
	local GunData = ACF.Weapons.Guns[Missile.BulletData.Id]
	local RackData = ACF.Weapons.Rack[Rack.Id]
	local Position = Rack.AttachPoints[AttachName]

	if GunData and RackData then
		local Offset = (GunData.modeldiameter or GunData.caliber) / (2.54 * 2)
		local MountPoint = RackData.mountpoints[AttachName]

		Position = Position + MountPoint.offset + MountPoint.scaledir * Offset
	end

	return Position, Rack:GetAngles()
end

local function AddMissile(Rack, Crate)
	if not IsValid(Crate) then return end

	local Attach = GetNextAttachName(Rack)

	if not Attach then return end

	local BulletData = ACFM_CompactBulletData(Crate)
	local Missile = ents.Create("acf_missile")

	BulletData.IsShortForm = true
	BulletData.Owner = Rack.Owner

	Missile.Owner = Rack.Owner
	Missile.Launcher = Rack
	Missile.DisableDamage = Rack.ProtectMissile
	Missile.Attachment = Attach

	Missile.Bodygroups = ACF_GetGunValue(BulletData.Id, "bodygroups")
	Missile.RackModel = Rack.MissileModel or ACF_GetGunValue(BulletData.Id, "rackmdl")
	Missile.RealModel = ACF_GetGunValue(BulletData.Id, "model")
	Missile.RackModelApplied = Missile.RackModel and true

	Missile:SetModelEasy(Missile.RackModel or Missile.RealModel)
	Missile:SetBulletData(BulletData)

	local Pos, Angles = GetMissileAngPos(Rack, Missile, Attach)

	Missile.AttachPos = Pos

	Missile:Spawn()
	Missile:SetParent(Rack)
	Missile:SetParentPhysNum(0)
	Missile:SetAngles(Angles)
	Missile:SetPos(Pos)
	Missile:SetOwner(Rack.Owner)

	if Rack.HideMissile then
		Missile:SetNoDraw(true)
	end

	Rack:EmitSound("acf_extra/tankfx/resupply_single.mp3", 500, 100)
	Rack:UpdateAmmoCount(Attach, Missile)

	Rack.CurrentCrate = Crate

	Crate:Consume()

	return Missile
end

local function TrimDistantCrates(Rack)
	if not next(Rack.Crates) then return end

	for Crate in pairs(Rack.Crates) do
		if Rack:GetPos():DistToSqr(Crate:GetPos()) >= 262144 then
			Rack:EmitSound(UnlinkSound:format(math.random(1, 3)), 500, 100)
			Rack:Unlink(Crate)
		end
	end
end

local function UpdateRefillBonus(Rack)
	local SelfPos = Rack:GetPos()
	local Efficiency = 0.11 * ACF.AmmoMod -- Copied from acf_ammo, beware of changes!
	local MinFullEfficiency = 50000 * Efficiency -- The minimum crate volume to provide full efficiency bonus all by itself.
	local MaxDist = ACF.RefillDistance
	local TotalBonus = 0

	for Crate in pairs(ACF.AmmoCrates) do
		if Crate.RoundType == "Refill" and Crate.Ammo > 0 and Crate.Load then
			local CrateDist = SelfPos:Distance(Crate:GetPos())

			if CrateDist <= MaxDist then
				CrateDist = math.max(0, CrateDist * 2 - MaxDist)

				local Bonus = (Crate.Volume / MinFullEfficiency) * (MaxDist - CrateDist) / MaxDist

				TotalBonus = TotalBonus + Bonus
			end
		end
	end

	Rack.ReloadMultiplierBonus = math.min(TotalBonus, 1)

	return Rack.ReloadMultiplierBonus
end

-------------------------------[[ Global Functions ]]-------------------------------

function MakeACF_Rack(Owner, Pos, Angle, Id, MissileId)
	if not Owner:CheckLimit("_acf_gun") then return end

	Id = CheckRackID(Id, MissileId)

	local List = ACF.Weapons.Rack
	local Classes = ACF.Classes.Rack
	local GunData = List[Id] or error("Couldn't find the " .. tostring(Id) .. " gun-definition!")
	local GunClass = Classes[GunData.gunclass] or error("Couldn't find the " .. tostring(GunData.gunclass) .. " gun-class!")

	local Rack = ents.Create("acf_rack")

	if not IsValid(Rack) then return end

	Rack:SetModel(GunData.model)
	Rack:SetPlayer(Owner)
	Rack:SetAngles(Angle)
	Rack:SetPos(Pos)
	Rack:Spawn()

	Rack:PhysicsInit(SOLID_VPHYSICS)
	Rack:SetMoveType(MOVETYPE_VPHYSICS)

	Owner:AddCount("_acf_gun", Rack)
	Owner:AddCleanup("acfmenu", Rack)

	Rack.Id					= Id
	Rack.MissileId			= MissileId
	Rack.MinCaliber			= GunData.mincaliber
	Rack.MaxCaliber			= GunData.maxcaliber
	Rack.Caliber			= GunData.caliber
	Rack.Model				= GunData.model
	Rack.Mass				= GunData.weight
	Rack.LegalMass			= Rack.Mass
	Rack.Class				= GunData.gunclass
	Rack.Owner				= Owner
	Rack.EntType			= MissileId or Id

	-- Custom BS for karbine: Per Rack ROF, Magazine Size, Mag reload Time
	Rack.PGRoFmod			= GunData.rofmod and math.max(0, GunData.rofmod) or 1
	Rack.MagSize			= GunData.magsize and math.max(1, GunData.magsize) or 1
	Rack.MagReload 			= GunData.magreload and math.max(Rack.MagReload, GunData.magreload) or  0

	Rack.Muzzleflash		= GunData.muzzleflash or GunClass.muzzleflash or ""
	Rack.RoFmod				= GunClass.rofmod
	Rack.SoundPath			= GunData.sound or GunClass.sound
	Rack.Spread				= GunClass.spread

	Rack.HideMissile		= GunData.hidemissile
	Rack.ProtectMissile		= GunData.protectmissile
	Rack.CustomArmour		= GunData.armour or GunClass.armour
	Rack.MissileModel		= GunData.rackmdl

	Rack.ReloadMultiplier   = ACF_GetRackValue(Id, "reloadmul")
	Rack.WhitelistOnly      = ACF_GetRackValue(Id, "whitelistonly")

	Rack.ReloadTime			= 1
	Rack.Ready				= true
	Rack.NextFire			= 1
	Rack.PostReloadWait		= CurTime()
	Rack.WaitFunction		= Rack.GetFireDelay
	Rack.LastSend			= 0
	Rack.TargetPos			= Vector()
	Rack.Elevation			= 0
	Rack.Azimuth			= 0

	Rack.AmmoCount			= 0
	Rack.LastThink			= CurTime()

	Rack.Missiles			= {}
	Rack.Crates				= {}
	Rack.AttachPoints		= {}

	Rack.Inputs = WireLib.CreateInputs(Rack, { "Fire", "Reload", "Elevation", "Azimuth", "Target Pos [VECTOR]" })
	Rack.Outputs = WireLib.CreateOutputs(Rack, { "Ready", "Entity [ENTITY]", "Shots Left", "Position [VECTOR]", "Target [ENTITY]" })

	Rack.BulletData	= {
		Type = "Empty",
		PropMass = 0,
		ProjMass = 0,
	}

	Rack:SetNWString("Class", Rack.Class)
	Rack:SetNWString("Sound", Rack.SoundPath)
	Rack:SetNWString("WireName", GunData.name)

	WireLib.TriggerOutput(Rack, "Entity", Rack)
	WireLib.TriggerOutput(Rack, "Ready", 1)

	local PhysObj = Rack:GetPhysicsObject()

	if IsValid(PhysObj) then
		PhysObj:SetMass(Rack.Mass)
	end

	local MountPoints = ACF.Weapons.Rack[Rack.Id].mountpoints

	for _, Data in pairs(Rack:GetAttachments()) do
		local Attachment = Rack:GetAttachment(Data.id)

		if MountPoints[Data.name] then
			Rack.AttachPoints[Data.name] = Rack:WorldToLocal(Attachment.Pos)
		end
	end

	ACF_Activate(Rack)

	Rack:UpdateOverlay()

	CheckLegal(Rack)

	return Rack
end

list.Set("ACFCvars", "acf_rack" , {"data9", "id"})
duplicator.RegisterEntityClass("acf_rack", MakeACF_Rack, "Pos", "Angle", "Id", "MissileId")
ACF.RegisterLinkSource("acf_rack", "Crates")
ACF.RegisterLinkSource("acf_rack", "Computer", true)
ACF.RegisterLinkSource("acf_rack", "Radar", true)

function ENT:Enable()
	if not CheckLegal(self) then return end

	self.Disabled	   = nil
	self.DisableReason = nil

	if self.Inputs["Target Pos"].Path then
		self:TriggerInput("Target Pos", self.Inputs["Target Pos"].Value)
	end

	if self.Inputs.Elevation.Path then
		self:TriggerInput("Elevation", self.Inputs.Elevation.Value)
	end

	if self.Inputs.Azimuth.Path then
		self:TriggerInput("Azimuth", self.Inputs.Azimuth.Value)
	end

	self:UpdateOverlay()
end

function ENT:Disable()
	self:TriggerInput("Target Pos", Vector())
	self:TriggerInput("Elevation", 0)
	self:TriggerInput("Azimuth", 0)

	self.Disabled = true

	self:UpdateOverlay()
end

function ENT:GetReloadTime(Missile)
	local ReloadMult = self.ReloadMultiplier
	local ReloadBonus = self.ReloadMultiplierBonus or 0
	local MagSize = self.MagSize ^ 1.1
	local DelayMult = (ReloadMult - (ReloadMult - 1) * ReloadBonus) / MagSize
	local ReloadTime = self:GetFireDelay(Missile) * DelayMult

	return ReloadTime
end

function ENT:GetFireDelay(Missile)
	if not IsValid(Missile) then
		return self.LastValidFireDelay or 1
	end

	local BulletData = Missile.BulletData
	local GunData = ACF.Weapons.Guns[BulletData.Id]

	if not GunData then
		return self.LastValidFireDelay or 1
	end

	local Class = ACF.Classes.GunClass[GunData.gunclass]
	local Interval = ((BulletData.RoundVolume / 500) ^ 0.60) * (GunData.rofmod or 1) * (Class.rofmod or 1)

	self.LastValidFireDelay = Interval

	return Interval
end

function ENT:ACF_Activate( Recalc )
	local PhysObj = self.ACF.PhysObj

	if not self.ACF.Area then
		self.ACF.Area = PhysObj:GetSurfaceArea() * 6.45
	end

	if not self.ACF.Volume then
		self.ACF.Volume = PhysObj:GetVolume() * 16.38
	end

	local ForceArmour = self.CustomArmour
	local Armour = ForceArmour or (self.Mass * 1000 / self.ACF.Area / 0.78) --So we get the equivalent thickness of that prop in mm if all it's weight was a steel plate
	local Health = self.ACF.Volume / ACF.Threshold							--Setting the threshold of the prop area gone
	local Percent = 1

	if Recalc and self.ACF.Health and self.ACF.MaxHealth then
		Percent = self.ACF.Health / self.ACF.MaxHealth
	end

	self.ACF.Health = Health * Percent
	self.ACF.MaxHealth = Health
	self.ACF.Armour = Armour * (0.5 + Percent / 2)
	self.ACF.MaxArmour = Armour
	self.ACF.Mass = self.Mass
	self.ACF.Density = PhysObj:GetMass() * 1000 / self.ACF.Volume
	self.ACF.Type = "Prop"
	self.ACF.LegalMass = self.Mass
	self.ACF.Model = self.Model
end

function ENT:ACF_OnDamage(Entity, Energy, FrArea, Angle, Inflictor)
	if self.Exploded then
		return {
			Damage = 0,
			Overkill = 1,
			Loss = 0,
			Kill = false
		}
	end

	local HitRes = ACF.PropDamage(Entity, Energy, FrArea, Angle, Inflictor) --Calling the standard damage prop function

	-- If the rack gets destroyed, we just blow up all the missiles it carries
	if HitRes.Kill then
		if hook.Run("ACF_AmmoExplode", self, nil) == false then return HitRes end

		self.Exploded = true

		if IsValid(Inflictor) and Inflictor:IsPlayer() then
			self.Inflictor = Inflictor
		end

		if next(self.Missiles) then
			for _, Missile in pairs(self.Missiles) do
				Missile:SetParent()
				Missile:Detonate()
			end
		end
	end

	return HitRes -- This function needs to return HitRes
end

function ENT:CanLoadCaliber(Caliber)
	return ACF_RackCanLoadCaliber(self.Id, Caliber)
end

function ENT:Link(Target)
	if not IsValid(Target) then return false, "Attempted to link an invalid entity." end
	if self == Target then return false, "Can't link a rack to itself." end

	local Function = ClassLink("acf_rack", Target:GetClass())

	if Function then
		return Function(self, Target)
	end

	return false, "Racks can't be linked to '" .. Target:GetClass() .. "'."
end

function ENT:Unlink(Target)
	if not IsValid(Target) then return false, "Attempted to unlink an invalid entity." end
	if self == Target then return false, "Can't unlink a rack from itself." end

	local Function = ClassUnlink("acf_rack", Target:GetClass())

	if Function then
		return Function(self, Target)
	end

	return false, "Racks can't be unlinked from '" .. Target:GetClass() .. "'."
end

function ENT:UpdateOverlay()
	if timer.Exists("ACF Overlay Buffer" .. self:EntIndex()) then return end

	timer.Create("ACF Overlay Buffer" .. self:EntIndex(), 1, 1, function()
		if not IsValid(self) then return end

		local Text = "%s\n\nAmmo type: %s\nRounds remaining: %s\nFire delay: %s second(s)\nReload time: %s second(s)"
		local FireRate = math.Round(self.LastValidFireDelay or 1, 2)
		local Reload = math.Round(self.ReloadTime or 0, 2)
		local Status

		if self.DisableReason then
			Status = "Disabled: " .. self.DisableReason
		elseif not next(self.Crates) then
			Status = "Not linked to an ammo crate!"
		else
			Status = self.State or "Ok"
		end

		self:SetOverlayText(string.format(Text, Status, self.EntType, self.AmmoCount, FireRate, Reload))
	end)
end

function ENT:Unload()
	-- we're ok with mixed munitions.
end

function ENT:GetUser(Input)
	if not Input then return end

	if WireTable[Input:GetClass()] then
		WireTable[Input:GetClass()](Input, self)
	end

	return Input.Owner or Input:GetOwner()
end

function ENT:TriggerInput(Input, Value)
	if self.Disabled then return end

	if Inputs[Input] then
		Inputs[Input](self, Value)

		self:UpdateOverlay()
	end
end

function ENT:FireMissile()
	if not self.Disabled and self.Ready and self.PostReloadWait < CurTime() then
		local Attachment, Missile = next(self.Missiles)
		local ReloadTime = 0.5

		if IsValid(Missile) then
			if hook.Run("ACF_FireShell", self, Missile.BulletData) == false then return end

			ReloadTime = self:GetFireDelay(Missile)

			local Pos, Angles = GetMissileAngPos(self, Missile, Attachment)
			local MuzzleVec = Angles:Forward()
			local ConeAng = math.tan(math.rad(self.Spread * ACF.GunInaccuracyScale))
			local RandDirection = (self:GetUp() * math.Rand(-1, 1) + self:GetRight() * math.Rand(-1, 1)):GetNormalized()
			local Spread = RandDirection * ConeAng * (math.random() ^ (1 / math.Clamp(ACF.GunInaccuracyBias, 0.5, 4)))
			local ShootVec = (MuzzleVec + Spread):GetNormalized()
			local BulletData = Missile.BulletData
			local BulletSpeed = BulletData.MuzzleVel or Missile.MinimumSpeed or 1

			BulletData.Flight = ShootVec * BulletSpeed

			Missile:SetNoDraw(false)
			Missile:SetParent()

			Missile.Filter = { self }

			for _, Load in pairs(self.Missiles) do
				Missile.Filter[#Missile.Filter + 1] = Load
			end

			if Missile.RackModelApplied then
				Missile:SetModelEasy(Missile.RealModel)
				Missile.RackModelApplied = nil
			end

			local PhysMissile = Missile:GetPhysicsObject()

			if IsValid(PhysMissile) then
				PhysMissile:SetMass(Missile.RoundWeight)
			end

			Missile:DoFlight(self:LocalToWorld(Pos), ShootVec)
			Missile:Launch()

			if self.SoundPath and self.SoundPath ~= "" then
				Missile.BulletData.Sound = self.SoundPath
			end

			self:UpdateAmmoCount(Attachment)

			Missile:EmitSound("phx/epicmetal_hard.wav", 500, 100)
		else
			self:EmitSound("weapons/pistol/pistol_empty.wav", 500, 100)
		end

		WireLib.TriggerOutput(self, "Ready", 0)
		self.Ready = false
		self.NextFire = 0
		self.WaitFunction = self.GetFireDelay
		self.ReloadTime = ReloadTime
	else
		self:EmitSound("weapons/pistol/pistol_empty.wav", 500, 100)
	end
end

function ENT:Reload()
	if not self.Ready and not GetNextAttachName(self) then return end
	if self.AmmoCount >= self.MagSize then return end
	if self.NextFire < 1 then return end

	local Missile = AddMissile(self, GetNextCrate(self))

	self.NextFire = 0
	self.PostReloadWait = CurTime() + 5
	self.WaitFunction = self.GetReloadTime
	self.Ready = false
	self.ReloadTime = IsValid(Missile) and self:GetReloadTime(Missile) or 1

	WireLib.TriggerOutput(self, "Ready", 0)
end

function ENT:UpdateAmmoCount(Attachment, Missile)
	self.Missiles[Attachment] = Missile
	self.AmmoCount = self.AmmoCount + (Missile and 1 or -1)

	self:UpdateOverlay()

	WireLib.TriggerOutput(self, "Shots Left", self.AmmoCount)
end

function ENT:Think()
	local _, Missile = next(self.Missiles)
	local Time = CurTime()

	if self.LastSend + 1 <= Time then
		TrimDistantCrates(self)
		UpdateRefillBonus(self)

		self:GetReloadTime(Missile)

		self.LastSend = Time
	end

	self.NextFire = math.min(self.NextFire + (Time - self.LastThink) / self:WaitFunction(Missile), 1)

	if self.NextFire >= 1 then
		if Missile then
			self.Ready = true

			WireLib.TriggerOutput(self, "Ready", 1)

			if self.Firing then
				self:FireMissile()
			elseif self.Inputs.Reload and self.Inputs.Reload.Value ~= 0 then
				self:Reload()
			elseif self.ReloadTime and self.ReloadTime > 1 then
				self:EmitSound("acf_extra/airfx/weapon_select.mp3", 500, 100)
				self.ReloadTime = nil
			end
		else
			if self.Inputs.Reload and self.Inputs.Reload.Value ~= 0 then
				self:Reload()
			end
		end
	end

	self:NextThink(Time + 0.5)
	self.LastThink = Time

	return true
end

function ENT:PreEntityCopy()
	if IsValid(self.Radar) then
		duplicator.StoreEntityModifier(self, "ACFRadar", { self.Radar:EntIndex() })
	end

	if IsValid(self.Computer) then
		duplicator.StoreEntityModifier(self, "ACFComputer", { self.Computer:EntIndex() })
	end

	if next(self.Crates) then
		local Entities = {}

		for Crate in pairs(self.Crates) do
			Entities[#Entities + 1] = Crate:EntIndex()
		end

		duplicator.StoreEntityModifier(self, "ACFCrates", Entities)
	end

	-- Wire dupe info
	self.BaseClass.PreEntityCopy(self)
end

function ENT:PostEntityPaste(Player, Ent, CreatedEntities)
	local EntMods = Ent.EntityMods

	if EntMods.ACFRadar then
		local _, EntIndex = next(EntMods.ACFRadar)

		self:Link(CreatedEntities[EntIndex])

		EntMods.ACFRadar = nil
	end

	if EntMods.ACFComputer then
		local _, EntIndex = next(EntMods.ACFComputer)

		self:Link(CreatedEntities[EntIndex])

		EntMods.ACFComputer = nil
	end

	-- Backwards compatibility
	if EntMods.ACFAmmoLink then
		local Entities = EntMods.ACFAmmoLink.entities
		local Entity

		for _, EntID in pairs(Entities) do
			Entity = CreatedEntities[EntID]

			-- Old racks don't have this
			if not self.MissileId and IsValid(Entity) then
				self.MissileId = Entity.RoundId
			end

			self:Link(Entity)
		end

		EntMods.ACFAmmoLink = nil
	end

	if EntMods.ACFCrates then
		for _, EntID in pairs(EntMods.ACFCrates) do
			self:Link(CreatedEntities[EntID])
		end

		EntMods.ACFCrates = nil
	end

	-- Wire dupe info
	self.BaseClass.PostEntityPaste(self, Player, Ent, CreatedEntities)
end

function ENT:OnRemove()
	for Crate in pairs(self.Crates) do
		self:Unlink(Crate)
	end

	self:Unlink(self.Radar)
	self:Unlink(self.Computer)

	WireLib.Remove(self)
end
