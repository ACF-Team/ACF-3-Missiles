AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

-- Local Vars -----------------------------------

local EMPTY     = { Type = "Empty", PropMass = 0, ProjMass = 0, Tracer = 0 }
local HookRun   = hook.Run
local ACF       = ACF
local Classes   = ACF.Classes
local Utilities = ACF.Utilities
local Clock     = Utilities.Clock

do -- Spawning and Updating --------------------
	local UnlinkSound = "physics/metal/metal_box_impact_bullet%s.wav"
	local MaxDistance = ACF.LinkDistance * ACF.LinkDistance
	local CheckLegal  = ACF_CheckLegal
	local WireIO      = Utilities.WireIO
	local Entities    = Classes.Entities
	local Racks       = Classes.Racks

	local Inputs = {
		"Fire (Attempts to fire the next missile in line, or the selected one.)",
		"Reload (Attempts to load another missile into the rack.)",
		"Unload (Does nothing.)",
		"Missile Index (Selects a specific slot on the rack to be fired next.)",
		"Fire Delay (Sets the delay at which missiles will be fired.)"
	}
	local Outputs = {
		"Ready (Returns 1 if the rack can fire a missile.)",
		"Status (Returns the current state of the rack.) [STRING]",
		"Shots Left (Returns the amount of missiles left in the rack.)",
		"Current Index (Returns the currently selected missile index.)",
		"Missile (Returns the next missile to be fired.) [ENTITY]",
		"Entity (The rack itself.) [ENTITY]"
	}

	local function VerifyData(Data)
		if not Data.Rack then
			Data.Rack = Data.Id or "1xRK"
		end

		local Rack = Racks.Get(Data.Rack)

		if not Rack then
			Data.Rack = "1xRK"

			Rack = Racks.Get("1xRK")
		end

		do -- External verifications
			if Rack.VerifyData then
				Rack.VerifyData(Data, Rack)
			end

			HookRun("ACF_VerifyData", "acf_rack", Data, Rack)
		end
	end

	local function UpdateRack(Entity, Data, Rack)
		Entity.ACF = Entity.ACF or {}
		Entity.ACF.Model = Rack.Model -- Must be set before changing model

		Entity:SetModel(Rack.Model)

		Entity:PhysicsInit(SOLID_VPHYSICS)
		Entity:SetMoveType(MOVETYPE_VPHYSICS)

		-- Storing all the relevant information on the entity for duping
		for _, V in ipairs(Entity.DataStore) do
			Entity[V] = Data[V]
		end

		Entity.Name           = Rack.Name
		Entity.ShortName      = Rack.ID
		Entity.EntType        = Rack.EntType
		Entity.RackData       = Rack
		Entity.Caliber        = Rack.Caliber
		Entity.MagSize        = Rack.MagSize or 1
		Entity.ForcedIndex    = Entity.ForcedIndex and math.max(Entity.ForcedIndex, Entity.MagSize)
		Entity.PointIndex     = 1
		Entity.SoundPath      = Rack.Sound
		Entity.DefaultSound   = Rack.Sound
		Entity.HideMissile    = Rack.HideMissile
		Entity.ProtectMissile = Rack.ProtectMissile
		Entity.MissileModel   = Rack.RackModel
		Entity.ReloadTime     = 1
		Entity.CurrentShot    = 0
		Entity.Spread         = Rack.Spread or 1

		WireIO.SetupInputs(Entity, Inputs, Data, Rack)
		WireIO.SetupOutputs(Entity, Outputs, Data, Rack)

		Entity:SetNWString("WireName", "ACF " .. Entity.Name)

		ACF.Activate(Entity, true)

		Entity.ACF.Model		= Rack.Model
		Entity.ACF.LegalMass	= Rack.Mass

		local Phys = Entity:GetPhysicsObject()
		if IsValid(Phys) then Phys:SetMass(Rack.Mass) end

		do -- Removing old missiles
			local Missiles = Entity.Missiles

			for _, V in pairs(Missiles) do
				V:Remove()
			end
		end

		do -- Updating attachpoints
			local Points = Entity.MountPoints

			for K, V in pairs(Points) do
				V.Removed = true

				Points[K] = nil
			end

			for K, V in pairs(Rack.MountPoints) do
				Points[K] = {
					Index = K,
					Position = V.Position,
					Angle = V.Angle or Angle(),
					Direction = V.Direction,
					BulletData = EMPTY,
					State = "Empty",
				}
			end

			Entity:UpdatePoint()
		end
	end

	local function CheckDistantLinks(Entity, Source)
		local Position = Entity:GetPos()

		for Link in pairs(Entity[Source]) do
			if Position:DistToSqr(Link:GetPos()) > MaxDistance then
				local Sound = UnlinkSound:format(math.random(1, 3))

				Entity:EmitSound(Sound, 70, math.random(99, 109), ACF.Volume)
				Link:EmitSound(Sound, 70, math.random(99, 109), ACF.Volume)

				Entity:Unlink(Link)
			end
		end
	end

	hook.Add("ACF_OnSetupInputs", "ACF Rack Motor Delay", function(Entity, List, _, Rack)
		if Entity:GetClass() ~= "acf_rack" then return end
		if Rack.EntType ~= "Rack" then return end

		List[#List + 1] = "Motor Delay (A forced delay before igniting the thruster)"
	end)

	-------------------------------------------------------------------------------

	function MakeACF_Rack(Player, Pos, Ang, Data)
		VerifyData(Data)

		local RackData = Racks.Get(Data.Rack)
		local Limit = RackData.LimitConVar.Name

		if not Player:CheckLimit(Limit) then return end

		local Rack = ents.Create("acf_rack")

		if not IsValid(Rack) then return end

		Rack:SetPlayer(Player)
		Rack:SetAngles(Ang)
		Rack:SetPos(Pos)
		Rack:Spawn()

		Player:AddCleanup("acf_rack", Rack)
		Player:AddCount(Limit, Rack)

		Rack.Owner       = Player -- MUST be stored on ent for PP
		Rack.Firing      = false
		Rack.Reloading   = false
		Rack.Spread      = 1 -- GunClass.spread
		Rack.ReloadTime  = 1
		Rack.FireDelay   = 1
		Rack.MountPoints = {}
		Rack.Missiles    = {}
		Rack.Crates      = {}
		Rack.DataStore   = Entities.GetArguments("acf_rack")

		UpdateRack(Rack, Data, RackData)

		if RackData.OnSpawn then
			RackData.OnSpawn(Rack, Data, RackData)
		end

		HookRun("ACF_OnEntitySpawn", "acf_rack", Rack, Data, RackData)

		WireLib.TriggerOutput(Rack, "Entity", Rack)

		Rack:UpdateOverlay(true)

		do -- Mass entity mod removal
			local EntMods = Data and Data.EntityMods

			if EntMods and EntMods.mass then
				EntMods.mass = nil
			end
		end

		CheckLegal(Rack)

		timer.Create("ACF Rack Clock " .. Rack:EntIndex(), 3, 0, function()
			if not IsValid(Rack) then return end

			CheckDistantLinks(Rack, "Crates")
		end)

		return Rack
	end

	Entities.Register("acf_rack", MakeACF_Rack, "Rack")

	ACF.RegisterLinkSource("acf_rack", "Crates")
	ACF.RegisterLinkSource("acf_rack", "Computer", true)
	ACF.RegisterLinkSource("acf_rack", "Radar", true)

	------------------- Updating ---------------------

	function ENT:Update(Data)
		if self.Firing then return false, "Stop firing before updating the rack!" end

		VerifyData(Data)

		local Rack    = Racks[Data.Rack]
		local OldData = self.RackData

		if OldData.OnLast then
			OldData.OnLast(self, OldData)
		end

		HookRun("ACF_OnEntityLast", "acf_rack", self, OldData)

		ACF.SaveEntity(self)

		UpdateRack(self, Data, Rack)

		ACF.RestoreEntity(self)

		if Rack.OnUpdate then
			Rack.OnUpdate(self, Data, Rack)
		end

		HookRun("ACF_OnEntityUpdate", "acf_rack", self, Data, Rack)

		self:UpdateOverlay(true)

		net.Start("ACF_UpdateEntity")
			net.WriteEntity(self)
		net.Broadcast()

		return true, "Rack updated successfully!"
	end
end ---------------------------------------------

do -- Custom ACF damage ------------------------
	local SparkSound = "ambient/energy/spark%s.wav"

	local function ShowDamage(Rack, Point)
		local Position = Rack:LocalToWorld(Point.Position)

		local Effect = EffectData()
			Effect:SetMagnitude(math.Rand(0.5, 1))
			Effect:SetRadius(1)
			Effect:SetScale(1)
			Effect:SetStart(Position)
			Effect:SetOrigin(Position)
			Effect:SetNormal(VectorRand())

		util.Effect("Sparks", Effect, true, true)

		Rack:EmitSound(SparkSound:format(math.random(6)), math.random(55, 65), math.random(99, 101), ACF.Volume)

		timer.Simple(math.Rand(0.5, 2), function()
			if not IsValid(Rack) then return end
			if not Point.Disabled then return end
			if Point.Removed then return end

			ShowDamage(Rack, Point)
		end)
	end

	function ENT:ACF_OnDamage(Bullet, Trace)
		local HitRes = ACF.PropDamage(Bullet, Trace) --Calling the standard damage prop function

		if not HitRes.Kill then
			local Ratio = self.ACF.Health / self.ACF.MaxHealth
			local Index = math.random(1, self.MagSize) -- Since we don't receive an impact position, we have to rely on RNG
			local Point = self.MountPoints[Index]
			local Affected

			-- Missile dropping
			if not self.ProtectMissile then
				local Missile = Point.Missile

				if Missile and math.random() > 0.9 * Ratio then
					Missile:Launch(nil, true)

					self:UpdateLoad(Point)

					Affected = true
				end
			end

			-- Mountpoint jamming
			if not Point.Disabled and math.random() > 0.9 * Ratio then
				Point.Disabled = true

				Affected = true
			end

			if Affected then
				if Index == self.PointIndex then
					self.PointIndex = self:GetNextMountPoint("Loaded", Index) or 1
				end

				self:UpdatePoint()

				ShowDamage(self, Point)
			end
		end

		return HitRes -- This function needs to return HitRes
	end

	function ENT:ACF_OnRepaired(_, _, _, NewHealth)
		local Ratio = NewHealth / self.ACF.MaxHealth

		if Ratio >= 1 then
			for _, Point in pairs(self.MountPoints) do
				if Point.Disabled then
					Point.Disabled = nil
				end
			end

			self:UpdatePoint()
		end
	end
end ---------------------------------------------

do -- Entity Link/Unlink -----------------------
	ACF.RegisterClassLink("acf_rack", "acf_ammo", function(Weapon, Target)
		if Weapon.Crates[Target] then return false, "This rack is already linked to this crate." end
		if Target.Weapons[Weapon] then return false, "This rack is already linked to this crate." end
		if Target.IsRefill then return false, "Refill crates cannot be linked!" end

		local Blacklist = Target.RoundData.Blacklist

		if Blacklist[Target.Class] then
			return false, "That round type cannot be used with this missile!"
		end

		local Result, Message = ACF.CanLinkRack(Weapon.RackData, Target.WeaponData)

		if not Result then return Result, Message end

		Target.Weapons[Weapon] = true
		Weapon.Crates[Target] = true

		Weapon:UpdateOverlay()
		Target:UpdateOverlay()

		return true, "Rack linked successfully."
	end)

	ACF.RegisterClassUnlink("acf_rack", "acf_ammo", function(Weapon, Target)
		if Weapon.Crates[Target] or Target.Weapons[Weapon] then
			if Weapon.CurrentCrate == Target then
				Weapon.CurrentCrate = next(Weapon.Crates, Target)
			end

			Target.Weapons[Weapon] = nil
			Weapon.Crates[Target] = nil

			Weapon:UpdateOverlay()
			Target:UpdateOverlay()

			return true, "Weapon unlinked successfully."
		end

		return false, "This rack is not linked to this crate."
	end)
end ---------------------------------------------

do -- Entity Inputs ----------------------------
	WireLib.AddInputAlias("Launch Delay", "Motor Delay")

	ACF.AddInputAction("acf_rack", "Fire", function(Entity, Value)
		if Entity.Firing == tobool(Value) then return end

		Entity.Firing = tobool(Value)

		if Entity:CanShoot() then
			Entity:Shoot()
		end
	end)

	ACF.AddInputAction("acf_rack", "Reload", function(Entity, Value)
		if Entity.Reloading == tobool(Value) then return end

		Entity.Reloading = tobool(Value)

		if Entity:CanReload() then
			Entity:Reload()
		end
	end)

	ACF.AddInputAction("acf_rack", "Unload", function(Entity, Value)
		if tobool(Value) then
			Entity:Unload()
		end
	end)

	ACF.AddInputAction("acf_rack", "Missile Index", function(Entity, Value)
		Entity.ForcedIndex = Value > 0 and math.min(Value, Entity.MagSize) or nil

		Entity:UpdatePoint()

		if Entity.ForcedIndex then
			Entity:EmitSound("buttons/blip2.wav", 70, math.random(99, 101), ACF.Volume)
		end
	end)

	ACF.AddInputAction("acf_rack", "Fire Delay", function(Entity, Value)
		Entity.FireDelay = math.Clamp(Value, 0.1, 1)
	end)

	ACF.AddInputAction("acf_rack", "Motor Delay", function(Entity, Value)
		Entity.LaunchDelay = Value > 0 and math.min(Value, 1) or nil
	end)
end ---------------------------------------------

do -- Entity Overlay ----------------------------
	local Text = "%s\n\nLoaded ammo: %s\nRounds remaining: %s\nReload time: %s second(s)\nFire delay: %s second(s)"

	function ENT:UpdateOverlayText()
		local Delay  = math.Round(self.FireDelay, 2)
		local Reload = math.Round(self.ReloadTime, 2)
		local Bullet = self.BulletData
		local Ammo   = (Bullet.Id and (Bullet.Id .. " ") or "") .. Bullet.Type
		local Status = self.State

		if self.Jammed then
			Status = "Jammed!\nRepair this rack to be able to use it again."
		elseif not next(self.Crates) then
			Status = "Not linked to an ammo crate!"
		end

		return Text:format(Status, Ammo, self.CurrentShot, Reload, Delay)
	end
end ---------------------------------------------

do -- Firing -----------------------------------
	local function ShootMissile(Rack, Point)
		local Ang = Rack:LocalToWorldAngles(Point.Angle)
		local Cone = math.tan(math.rad(Rack:GetSpread()))
		local RandDir = (Rack:GetUp() * math.Rand(-1, 1) + Rack:GetRight() * math.Rand(-1, 1)):GetNormalized()
		local Spread = Cone * RandDir * (math.random() ^ (1 / ACF.GunInaccuracyBias))
		local ShootDir = (Ang:Forward() + Spread):GetNormalized()

		local Missile = Point.Missile
		local BulletData = Missile.BulletData

		BulletData.Flight = ShootDir

		Missile:Launch(Rack.LaunchDelay)

		Rack.LastFired = Missile
		Rack:UpdateLoad(Point)
	end

	-------------------------------------------------------------------------------

	function ENT:CanShoot()
		if self.RetryShoot then return false end
		if not self.Firing then return false end
		if not ACF.RacksCanFire then return false end

		return true
	end

	function ENT:GetSpread()
		return self.Spread * ACF.GunInaccuracyScale
	end

	function ENT:Shoot()
		local Index, Point = self:GetNextMountPoint("Loaded", self.PointIndex)
		local Delay = self.FireDelay

		if Index and HookRun("ACF_FireShell", self) ~= false then
			ShootMissile(self, Point)

			self.PointIndex = self:GetNextMountPoint("Loaded", Index) or 1

			self:UpdatePoint()
		else
			self:EmitSound("weapons/pistol/pistol_empty.wav", 70, math.random(99, 101), ACF.Volume)

			Delay = 1
		end

		if not self.RetryShoot then
			self.RetryShoot = true

			timer.Simple(Delay, function()
				if not IsValid(self) then return end

				self.RetryShoot = nil

				if self:CanShoot() then
					self:Shoot()
				end
			end)
		end
	end
end ---------------------------------------------

do -- Loading ----------------------------------
	local Missiles  = Classes.Missiles
	local NO_OFFSET = Vector()

	local function GetMissileAngPos(BulletData, Point)
		local Class    = Classes.GetGroup(Missiles, BulletData.Id)
		local Data     = Class and Class.Lookup[BulletData.Id]
		local Offset   = Data and Data.Offset or NO_OFFSET
		local Position = Point.Position

		if Data and Point.Direction then -- If no Direction is given then the point is centered
			local Radius = (Data.Diameter or Data.Caliber) * 0.03937 * 0.5 -- Getting the radius on inches

			Position = Position + Point.Direction * Radius
		end

		Position = Position + Offset

		return Position, Point.Angle
	end

	local function GetNextCrate(Rack)
		if not next(Rack.Crates) then return end -- No crates linked to this gun

		local Select = next(Rack.Crates, Rack.CurrentCrate) or next(Rack.Crates)
		local Start = Select

		repeat
			if Select:CanConsume() then return Select end

			Select = next(Rack.Crates, Select) or next(Rack.Crates)
		until Select == Start -- If we've looped back around to the start then there's nothing to use
	end

	local function AddMissile(Rack, Point, Crate)
		local Pos, Ang = GetMissileAngPos(Crate.BulletData, Point)
		local Missile = MakeACF_Missile(Rack.Owner, Pos, Ang, Rack, Point, Crate)

		Rack:EmitSound("acf_missiles/fx/bomb_reload.mp3", 70, math.random(99, 101), ACF.Volume)

		return Missile
	end

	-------------------------------------------------------------------------------

	function ENT:CanReload()
		if self.RetryReload then return false end
		if not self.Reloading then return false end
		if not ACF.RacksCanFire then return false end

		return true
	end

	-- TODO: Once Unloading gets implemented, racks have to unload missiles if no empty mountpoint is found.
	function ENT:Reload()
		local Index, Point = self:GetNextMountPoint("Empty")
		local Crate = GetNextCrate(self)

		if not self.Firing and Index and Crate then
			local Missile = AddMissile(self, Point, Crate)
			local Bullet  = Missile.BulletData
			local Percent = math.max(0.5, (Bullet.ProjLength + Bullet.PropLength) / Missile.MaxLength)
			local Time    = Missile.ReloadTime * Percent

			Point.NextFire = Clock.CurTime + Time
			Point.State    = "Loading"

			self:UpdateLoad(Point, Missile)

			self.CurrentCrate = Crate
			self.ReloadTime   = Time

			Crate:Consume()

			timer.Simple(Time, function()
				if not IsValid(self) or Point.Removed then
					if IsValid(Crate) then Crate:Consume(-1) end

					return
				end

				if not IsValid(Missile) then
					Missile = nil
				else
					self:EmitSound("acf_missiles/fx/weapon_select.mp3", 70, math.random(99, 101), ACF.Volume)

					Point.State = "Loaded"
					Point.NextFire = nil
				end

				self:UpdateLoad(Point, Missile)
			end)
		end

		self.RetryReload = true

		timer.Simple(1, function()
			if not IsValid(self) then return end

			self.RetryReload = nil

			if self:CanReload() then
				self:Reload()
			end
		end)
	end
end ---------------------------------------------

do -- Unloading --------------------------------
	function ENT:Unload()
		-- TODO: Implement missile unloading
	end
end ---------------------------------------------

do -- Duplicator Support -----------------------
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
end ---------------------------------------------

do -- Misc -------------------------------------
	local function GetPosition(Entity)
		local PhysObj = Entity:GetPhysicsObject()

		if not IsValid(PhysObj) then return Entity:GetPos() end

		return Entity:LocalToWorld(PhysObj:GetMassCenter())
	end

	function ENT:Enable()
		self.Firing = tobool(self.Inputs.Fire.Value)
		self.Reloading = tobool(self.Inputs.Reload.Value)

		if self:CanShoot() then
			self:Shoot()
		end

		if self:CanReload() then
			self:Reload()
		end
	end

	function ENT:Disable()
		self.Firing = false
		self.Reloading = false
	end

	function ENT:SetState(State)
		self.State = State

		self:UpdateOverlay()

		WireLib.TriggerOutput(self, "Status", State)
		WireLib.TriggerOutput(self, "Ready", State == "Loaded" and 1 or 0)
	end

	function ENT:GetNextMountPoint(State, CustomStart)
		local MountPoints = self.MountPoints

		if self.ForcedIndex then
			local Index = self.ForcedIndex
			local Data = MountPoints[Index]

			if not Data.Disabled and Data.State == State then
				return Index, Data
			end
		else
			local Index = CustomStart or next(MountPoints)
			local Data = MountPoints[Index]
			local Start = Index

			repeat
				if not Data.Disabled and Data.State == State then
					return Index, Data
				end

				Index = next(MountPoints, Index) or next(MountPoints)
				Data = MountPoints[Index]
			until Index == Start
		end
	end

	function ENT:UpdatePoint()
		local Index = self.ForcedIndex or self.PointIndex
		local Point = self.MountPoints[Index]

		self.BulletData = Point.BulletData
		self.NextFire = Point.NextFire
		self.Jammed = Point.Disabled

		self:SetState(self.Jammed and "Jammed" or Point.State)

		WireLib.TriggerOutput(self, "Current Index", Index)
		WireLib.TriggerOutput(self, "Missile", Point.Missile)
	end

	function ENT:UpdateLoad(Point, Missile)
		if Point.Removed then return end

		local Index = Point.Index

		Point.BulletData = Missile and Missile.BulletData or EMPTY
		Point.NextFire = Missile and Point.NextFire or nil
		Point.State = Missile and Point.State or "Empty"
		Point.Missile = Missile

		if self.Missiles[Index] ~= Missile then
			self.CurrentShot = self.CurrentShot + (Missile and 1 or -1)
			self.Missiles[Index] = Missile

			WireLib.TriggerOutput(self, "Shots Left", self.CurrentShot)
		end

		self:UpdatePoint()
	end

	function ENT:Think()
		local Time     = Clock.CurTime
		local Previous = self.Position
		local Current  = GetPosition(self)

		self.Position = Current

		if Previous then
			local DeltaTime = Time - self.LastThink

			self.Velocity = (Current - Previous) / DeltaTime
		else
			self.Velocity = Vector()
		end

		self:NextThink(Time)

		self.LastThink = Time

		return true
	end

	function ENT:OnRemove()
		local OldData = self.RackData

		if OldData.OnLast then
			OldData.OnLast(self, OldData)
		end

		HookRun("ACF_OnEntityLast", "acf_rack", self, OldData)

		for Crate in pairs(self.Crates) do
			self:Unlink(Crate)
		end

		self:Unlink(self.Radar)
		self:Unlink(self.Computer)

		for _, Point in pairs(self.MountPoints) do
			local Missile = Point.Missile

			if Missile then
				Missile:Remove()
			end

			Point.Removed = true
		end

		timer.Remove("ACF Rack Clock " .. self:EntIndex())

		WireLib.Remove(self)
	end
end ---------------------------------------------
