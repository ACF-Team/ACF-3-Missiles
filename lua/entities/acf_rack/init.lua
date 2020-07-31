AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

-- Local Vars -----------------------------------

local EMPTY = { Type = "Empty", PropMass = 0, ProjMass = 0, Tracer = 0 }

do -- Spawning and Updating --------------------
	local UnlinkSound = "physics/metal/metal_box_impact_bullet%s.wav"
	local MaxDistance = ACF.RefillDistance * ACF.RefillDistance
	local CheckLegal  = ACF_CheckLegal
	local Racks       = ACF.Classes.Racks

	local function VerifyData(Data)
		if Data.Rack then -- Entity was created via menu tool
			Data.Id = Data.Rack
		elseif not Data.Id then
			Data.Id = "1xRK"
		end

		if not Racks[Data.Id] then
			Data.Id = "1xRK"
		end
	end

	local function UpdateRack(Entity, Data, Rack)
		Entity:SetModel(Rack.Model)

		Entity:PhysicsInit(SOLID_VPHYSICS)
		Entity:SetMoveType(MOVETYPE_VPHYSICS)

		-- Storing all the relevant information on the entity for duping
		for _, V in ipairs(Entity.DataStore) do
			Entity[V] = Data[V]
		end

		Entity.Name				= Rack.Name
		Entity.ShortName		= Data.Id
		Entity.Class			= "Rack"
		Entity.EntType			= "Rack"
		Entity.Caliber			= Rack.Caliber
		Entity.MagSize			= Rack.MagSize or 1
		Entity.ForcedIndex		= Entity.ForcedIndex and math.max(Entity.ForcedIndex, Entity.MagSize)
		Entity.PointIndex		= 1
		Entity.SoundPath		= Rack.Sound
		Entity.HideMissile		= Rack.HideMissile
		Entity.ProtectMissile	= Rack.ProtectMissile
		Entity.WhitelistOnly	= Rack.WhitelistOnly
		Entity.MissileModel		= Rack.RackModel
		Entity.ReloadTime		= 1
		Entity.CurrentShot		= 0

		Entity:SetNWString("WireName", "ACF " .. Entity.Name)

		local Phys = Entity:GetPhysicsObject()
		if IsValid(Phys) then Phys:SetMass(Rack.Mass) end

		ACF_Activate(Entity, true)

		Entity.ACF.Model		= Rack.Model
		Entity.ACF.LegalMass	= Rack.Mass

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
					Position = V.Offset,
					BulletData = EMPTY,
					Scale = V.ScaleDir,
					Angle = V.Angle or Angle(),
					State = "Empty",
					Name = V.Name,
					Index = K,
				}
			end

			Entity:UpdatePoint()
		end

		Entity:UpdateOverlay(true)
	end

	local function CheckDistantLinks(Entity, Source)
		local Position = Entity:GetPos()

		for Link in pairs(Entity[Source]) do
			if Position:DistToSqr(Link:GetPos()) > MaxDistance then
				Entity:EmitSound(UnlinkSound:format(math.random(1, 3)), 500, math.random(98, 102))
				Link:EmitSound(UnlinkSound:format(math.random(1, 3)), 500, math.random(98, 102))

				Entity:Unlink(Link)
			end
		end
	end

	-------------------------------------------------------------------------------

	function MakeACF_Rack(Player, Pos, Ang, Data)
		VerifyData(Data)

		local RackData = Racks[Data.Id]
		local Limit = RackData.LimitConVar.Name

		if not Player:CheckLimit(Limit) then return end

		local Rack = ents.Create("acf_rack")

		if not IsValid(Rack) then return end

		Rack:SetPlayer(Player)
		Rack:SetAngles(Ang)
		Rack:SetPos(Pos)
		Rack:Spawn()

		Player:AddCleanup("acfmenu", Rack)
		Player:AddCount(Limit, Rack)

		Rack.Owner				= Player -- MUST be stored on ent for PP
		Rack.Firing				= false
		Rack.Spread				= 1 -- GunClass.spread
		Rack.ReloadTime			= 1
		Rack.FireDelay			= 1
		Rack.LastSend			= ACF.CurTime
		Rack.MountPoints		= {}
		Rack.Missiles			= {}
		Rack.Crates				= {}
		Rack.Inputs				= WireLib.CreateInputs(Rack, { "Fire", "Reload", "Unload", "Missile Index", "Fire Delay", "Launch Delay" })
		Rack.Outputs			= WireLib.CreateOutputs(Rack, { "Ready", "Shots Left", "Current Index", "Status [STRING]", "Missile [ENTITY]", "Entity [ENTITY]" })
		Rack.DataStore			= ACF.GetEntClassVars("acf_rack")

		UpdateRack(Rack, Data, RackData)

		WireLib.TriggerOutput(Rack, "Entity", Rack)

		CheckLegal(Rack)

		timer.Create("ACF Rack Clock " .. Rack:EntIndex(), 3, 0, function()
			if not IsValid(Rack) then return end

			CheckDistantLinks(Rack, "Crates")
		end)

		return Rack
	end

	ACF.RegisterEntityClass("acf_rack", MakeACF_Rack, "Id")
	ACF.RegisterLinkSource("acf_rack", "Crates")
	ACF.RegisterLinkSource("acf_rack", "Computer", true)
	ACF.RegisterLinkSource("acf_rack", "Radar", true)

	------------------- Updating ---------------------

	function ENT:Update(Data)
		if self.Firing then return false, "Stop firing before updating the rack!" end
		if self.Reloading then return false, "Stop reloading before updating the rack!" end

		VerifyData(Data)

		local Rack = Racks[Data.Id]

		ACF.SaveEntity(self)

		UpdateRack(self, Data, Rack)

		ACF.RestoreEntity(self)

		return true, "Rack updated successfully!"
	end
end ---------------------------------------------

do -- Custom ACF damage ------------------------
	function ENT:ACF_OnDamage(Entity, Energy, FrArea, Ang, Inflictor)
		if self.Exploded then
			return {
				Damage = 0,
				Overkill = 1,
				Loss = 0,
				Kill = false
			}
		end

		local HitRes = ACF.PropDamage(Entity, Energy, FrArea, Ang, Inflictor) --Calling the standard damage prop function

		-- If the rack gets destroyed, we just blow up all the missiles it carries
		-- TODO: Implement mountpoint damage
		if HitRes.Kill then
			self.Exploded = true

			if hook.Run("ACF_AmmoExplode", self, self.BulletData) == false then return HitRes end

			if IsValid(Inflictor) and Inflictor:IsPlayer() then
				self.Inflictor = Inflictor
			end

			if next(self.Missiles) then
				for _, Missile in pairs(self.Missiles) do
					Missile:SetParent(nil)
					Missile:Detonate(true)
				end
			end
		end

		return HitRes -- This function needs to return HitRes
	end
end ---------------------------------------------

do -- Entity Link/Unlink -----------------------
	local ClassLink	  = ACF.GetClassLink
	local ClassUnlink = ACF.GetClassUnlink

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

	ACF.RegisterClassLink("acf_rack", "acf_ammo", function(Weapon, Target)
		if Target.RoundType == "Refill" then return false, "Refill crates cannot be linked!" end
		if Weapon.Crates[Target] then return false, "This rack is already linked to this crate." end
		if Target.Weapons[Weapon] then return false, "This rack is already linked to this crate." end

		local BulletData = Target.BulletData
		local GunClass = ACF_GetGunValue(BulletData, "ClassID")
		local Blacklist = ACF.AmmoBlacklist[Target.RoundType]

		if not GunClass or table.HasValue(Blacklist, GunClass) then return false, "That round type cannot be used with this rack!" end

		local Result, Message = ACF_CanLinkRack(Weapon.Id, BulletData.Id, BulletData, Weapon)

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
				Weapon.CurrentCrate = next(Weapon.Crates, Target) or next(Weapon.Crates)
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

do -- Entity User ------------------------------
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

	local function FindUser(Entity, Input, Checked)
		local Function = WireTable[Input:GetClass()]

		return Function and Function(Entity, Input, Checked or {})
	end

	WireTable.gmod_wire_adv_pod			= WireTable.gmod_wire_pod
	WireTable.gmod_wire_joystick		= WireTable.gmod_wire_pod
	WireTable.gmod_wire_joystick_multi	= WireTable.gmod_wire_pod
	WireTable.gmod_wire_expression2		= function(This, Input, Checked)
		for _, V in pairs(Input.Inputs) do
			if V.Src and not Checked[V.Src] and WireTable[V.Src:GetClass()] then
				Checked[V.Src] = true -- We don't want to start an infinite loop

				return FindUser(This, V.Src, Checked)
			end
		end
	end

	function ENT:GetUser(Input)
		if not Input then return self.Owner end

		return FindUser(self, Input) or self.Owner
	end
end ---------------------------------------------

do -- Entity Inputs ----------------------------
	local Inputs = ACF.GetInputActions("acf_rack")

	function ENT:TriggerInput(Name, Value)
		if self.Disabled then return end

		local Action = Inputs[Name]

		if Action then
			Action(self, Value)

			self:UpdateOverlay()
		end
	end

	ACF.AddInputAction("acf_rack", "Fire", function(Entity, Value)
		Entity.Firing = tobool(Value)

		if Entity:CanShoot() then
			Entity:Shoot()
		end
	end)

	ACF.AddInputAction("acf_rack", "Reload", function(Entity, Value)
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
		Entity.ForcedIndex = Value > 0 and math.max(Value, Entity.MagSize) or nil

		Entity:UpdatePoint()

		if Entity.ForcedIndex then
			Entity:EmitSound("buttons/blip2.wav", 500, math.random(98, 102))
		end
	end)

	ACF.AddInputAction("acf_rack", "Fire Delay", function(Entity, Value)
		Entity.FireDelay = math.Clamp(Value, 0.1, 1)
	end)

	-- TODO: Implement launch delay
	ACF.AddInputAction("acf_rack", "Launch Delay", function(Entity, Value)
		Entity.LaunchDelay = Value > 0 and math.max(Value, 1) or nil
	end)
end ---------------------------------------------

do -- Entity Overlay ---------------------------
	local Text = "%s\n\nLoaded ammo: %s\nRounds remaining: %s\nReload time: %s second(s)\nFire delay: %s second(s)"

	local function Overlay(Ent)
		if Ent.Disabled then
			Ent:SetOverlayText("Disabled: " .. Ent.DisableReason .. "\n" .. Ent.DisableDescription)
		else
			local Delay = math.Round(Ent.FireDelay, 2)
			local Reload = math.Round(Ent.ReloadTime, 2)
			local Bullet = Ent.BulletData
			local Ammo = (Bullet.Id and (Bullet.Id .. " ") or "") .. Bullet.Type
			local Status = Ent.State

			if not next(Ent.Crates) then
				Status = "Not linked to an ammo crate!"
			end

			Ent:SetOverlayText(Text:format(Status, Ammo, Ent.CurrentShot, Reload, Delay))
		end
	end

	function ENT:UpdateOverlay(Instant)
		if Instant then
			return Overlay(self)
		end

		if timer.Exists("ACF Overlay Buffer" .. self:EntIndex()) then return end

		timer.Create("ACF Overlay Buffer" .. self:EntIndex(), 0.5, 1, function()
			if not IsValid(self) then return end

			Overlay(self)
		end)
	end
end ---------------------------------------------

do -- Firing -----------------------------------
	local function ShootMissile(Rack, Point)
		local Pos = Rack:LocalToWorld(Point.Position)
		local Ang = Rack:LocalToWorldAngles(Point.Angle)
		local Cone = math.tan(math.rad(Rack:GetSpread()))
		local RandDir = (Rack:GetUp() * math.Rand(-1, 1) + Rack:GetRight() * math.Rand(-1, 1)):GetNormalized()
		local Spread = Cone * RandDir * (math.random() ^ (1 / ACF.GunInaccuracyBias))
		local ShootDir = (Ang:Forward() + Spread):GetNormalized()

		local Missile = Point.Missile
		local BulletData = Missile.BulletData
		local Speed = BulletData.MuzzleVel or Missile.MinimumSpeed or 1

		BulletData.Owner = Rack:GetUser(Rack.Inputs.Fire.Src)
		BulletData.Flight = ShootDir * Speed

		if Rack.SoundPath and Rack.SoundPath ~= "" then
			BulletData.Sound = Rack.SoundPath
		end

		for _, Load in pairs(Rack.Missiles) do
			Missile.Filter[#Missile.Filter + 1] = Load
		end

		if Missile.RackModelApplied then
			Missile:SetModelEasy(Missile.RealModel)
			Missile.RackModelApplied = nil
		end

		Missile:SetNoDraw(false)
		Missile:SetParent()

		Missile:DoFlight(Pos, ShootDir)
		Missile:Launch()

		Rack:UpdateLoad(Point)
	end

	-------------------------------------------------------------------------------

	function ENT:CanShoot()
		if not self.Firing then return false end
		if self.Disabled then return false end
		if not ACF.GunfireEnabled then return false end
		if self.RetryShoot then return false end

		return true
	end

	function ENT:GetSpread()
		return self.Spread * ACF.GunInaccuracyScale
	end

	function ENT:Shoot()
		local Index, Point = self:GetNextMountPoint("Loaded", self.PointIndex)
		local Delay = self.FireDelay

		if Index and hook.Run("ACF_FireShell", self) ~= false then
			ShootMissile(self, Point)

			self.PointIndex = self:GetNextMountPoint("Loaded", Index) or 1

			self:UpdatePoint()
		else
			self:EmitSound("weapons/pistol/pistol_empty.wav", 500, math.random(98, 102))

			self.RetryShoot = true

			Delay = 1
		end

		timer.Simple(Delay, function()
			if not IsValid(self) then return end

			self.RetryShoot = nil

			if self:CanShoot() then
				self:Shoot()
			end
		end)
	end
end ---------------------------------------------

do -- Loading ----------------------------------
	local Missiles = ACF.Classes.Missiles

	local function GetMissileAngPos(BulletData, Point)
		local Class = ACF.GetClassGroup(Missiles, BulletData.Id) --ACF.Weapons.Guns[BulletData.Id]
		local Position = Point.Position

		if Class then
			local Data = Class.Lookup[BulletData.Id]
			local Offset = (Data.Diameter or Data.Caliber) / (25.4 * 2)

			Position = Position + Point.Scale * Offset
		end

		return Position, Point.Angle
	end

	local function GetNextCrate(Rack)
		if not next(Rack.Crates) then return end -- No crates linked to this gun

		local Select = next(Rack.Crates, Rack.CurrentCrate) or next(Rack.Crates)
		local Start = Select

		repeat
			if Select.Load then return Select end

			Select = next(Rack.Crates, Select) or next(Rack.Crates)
		until Select == Start -- If we've looped back around to the start then there's nothing to use
	end

	local function AddMissile(Rack, Point, Crate)
		local BulletData = ACFM_CompactBulletData(Crate)
		local Pos, Ang = GetMissileAngPos(BulletData, Point)
		local Missile = MakeACF_Missile(Rack.Owner, Pos, Ang, Rack, Point, BulletData)

		Rack:EmitSound("acf_missiles/fx/bomb_reload.mp3", 500, math.random(98, 102))
		Rack:UpdateLoad(Point, Missile)

		return Missile
	end

	-------------------------------------------------------------------------------

	function ENT:CanReload()
		if not self.Reloading then return false end
		if self.Disabled then return false end
		if not ACF.GunfireEnabled then return false end
		if self.RetryReload then return false end

		return true
	end

	function ENT:Reload()
		local Index, Point = self:GetNextMountPoint("Empty")
		local Crate = GetNextCrate(self)

		if Index and Crate then
			local Bullet = Crate.BulletData
			local Time = ACF.BaseReload + 2 + (Bullet.ProjMass + Bullet.PropMass) * ACF.MassToTime * 3 -- TODO: Not final, keep tweaking this

			Point.NextFire = ACF.CurTime + Time
			Point.State = "Loading"

			local Missile = AddMissile(self, Point, Crate)

			self.CurrentCrate = Crate
			self.ReloadTime = Time

			Crate:Consume()

			timer.Simple(Time, function()
				if not IsValid(self) or Point.Removed then
					if IsValid(Crate) then Crate:Consume(-1) end

					return
				end

				if not IsValid(Missile) then
					if IsValid(Crate) then Crate:Consume(-1) end

					Missile = nil
				else
					self:EmitSound("acf_missiles/fx/weapon_select.mp3", 500, math.random(98, 102))

					Point.State = "Loaded"
					Point.NextFire = nil
				end

				self:UpdateLoad(Point, Missile)
			end)
		else
			self.RetryReload = true
		end

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

			if Data.State == State then
				return Index, Data
			end
		else
			local Index = CustomStart or next(MountPoints)
			local Data = MountPoints[Index]
			local Start = Index

			repeat
				if Data.State == State then
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
		self.CurPoint = Point

		self:SetState(Point.State)

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

	function ENT:OnRemove()
		for Crate in pairs(self.Crates) do
			self:Unlink(Crate)
		end

		self:Unlink(self.Radar)
		self:Unlink(self.Computer)

		timer.Remove("ACF Rack Clock " .. self:EntIndex())

		WireLib.Remove(self)
	end
end ---------------------------------------------
