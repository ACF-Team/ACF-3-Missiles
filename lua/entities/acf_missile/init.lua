AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

-------------------------------[[ Local Functions ]]-------------------------------

local ACF = ACF
local TraceData = { start = true, endpos = true, filter = true }
local Gravity = GetConVar("sv_gravity")
local GhostPeriod = GetConVar("ACFM_GhostPeriod")
local ActiveMissiles = ACF.ActiveMissiles
local Missiles = ACF.Classes.Missiles
local HookRun = hook.Run

local function ApplyBodySubgroup(Missile, Group, Source, Phase)
	local Target = Source.DataSource(Missile)

	if not Group.submodels then return end
	if not Target then return end
	if not Source[Target] then return end
	if not Source[Target][Phase] then return end

	Target = Source[Target][Phase]

	for K, V in pairs(Group.submodels) do
		if Target == V then
			Missile:SetBodygroup(Group.id, K)

			return
		end
	end
end

local function UpdateBodygroups(Missile, Phase)
	local Sources = Missile.Bodygroups

	if Sources then
		for _, V in pairs(Missile:GetBodyGroups()) do
			local Source = Sources[string.lower(V.name)]

			if Source then
				ApplyBodySubgroup(Missile, V, Source, Phase)
			end
		end
	end
end

local function UpdateSkin(Missile)
	local BulletData = Missile.BulletData
	local Skins = Missile.SkinIndex

	if not BulletData then return end
	if not Skins then return end

	Missile:SetSkin(Skins[BulletData.Type] or 0)
end

local function LaunchEffect(Missile)
	local Sound = Missile.Sound

	if ACF_SOUND_EXT then
		hook.Run("ACF_SOUND_MISSILE", Missile, Sound)
	else
		Missile:EmitSound(Sound, 511, math.random(99, 101))
	end
end

local function SetMotorState(Missile, Enabled)
	if Missile.MotorEnabled == Enabled then return end

	if Enabled then
		if Missile.NoThrust then return end
		if Missile.Detonated then return end

		Missile.Thrust = Missile.MaxThrust

		Missile:SetNW2Float("LightSize", Missile.BulletData.Caliber)

		LaunchEffect(Missile)

		if Missile.Effect then
			timer.Simple(0, function()
				if not IsValid(Missile) then return end
				if not Missile.MotorEnabled then return end

				ParticleEffectAttach(Missile.Effect, PATTACH_POINT_FOLLOW, Missile, Missile:LookupAttachment("exhaust") or 0)
			end)
		end
	else
		Missile.Thrust = 0
		Missile:StopParticles()
		Missile:SetNW2Float("LightSize", 0)
	end

	Missile.MotorEnabled = Enabled
end

-- TODO: Hitting players with the Dud should hurt/kill them
local function Dud(Missile)
	local PhysObj   = Missile:GetPhysicsObject()
	local HitNormal = Missile.HitNormal
	local Velocity  = Missile.Velocity
	local CurDir    = Missile.CurDir

	if HitNormal then
		local Dot = CurDir:Dot(HitNormal)
		local NewDir = CurDir - 2 * Dot * HitNormal
		local VelMul = (0.8 + Dot * 0.7) * Velocity:Length()

		Velocity = NewDir * VelMul
	end

	if IsValid(PhysObj) then
		PhysObj:EnableGravity(true)
		PhysObj:EnableMotion(true)
		PhysObj:SetVelocity(Velocity)
	end

	timer.Simple(30, function()
		if IsValid(Missile) then
			Missile:Remove()
		end
	end)
end

-- TODO: Missiles must base their movement off an ACF bullet
local function CalcFlight(Missile)
	if not Missile.Launched then return end
	if Missile.Detonated then return end

	local Time = ACF.CurTime
	local DeltaTime = Time - Missile.LastThink

	if DeltaTime <= 0 then return end

	local Pos = Missile.Position
	local Dir = Missile.CurDir
	local LastVel = Missile.LastVel
	local LastSpeed = LastVel:Length()

	Missile.LastThink = Time

	--Guidance calculations
	local Guidance = Missile.UseGuidance and Missile.GuidanceData:GetGuidance(Missile)
	local TargetPos = Guidance and Guidance.TargetPos

	if TargetPos then
		local Dist = Pos:Distance(TargetPos)

		TargetPos = TargetPos + Vector(0, 0, Gravity:GetFloat() * Dist / 100000)

		local LOS = (TargetPos - Pos):GetNormalized()
		local LastLOS = Missile.LastLOS
		local NewDir = Dir
		local DirDiff = 0

		if LastLOS then
			local SpeedMul = math.min((LastSpeed / DeltaTime / Missile.MinimumSpeed) ^ 3, 1)
			local LOSDiff = math.deg(math.acos(LastLOS:Dot(LOS))) * 20
			local MaxTurn = Missile.Agility * SpeedMul * 3

			if LOSDiff > 0.01 and MaxTurn > 0.1 then
				local LOSNormal = LastLOS:Cross(LOS):GetNormalized()
				local Ang = NewDir:Angle()

				Ang:RotateAroundAxis(LOSNormal, math.min(LOSDiff, MaxTurn))

				NewDir = Ang:Forward()
			end

			DirDiff = math.deg(math.acos(NewDir:Dot(LOS)))

			if DirDiff > 0.01 then
				local DirNormal = NewDir:Cross(LOS):GetNormalized()
				local TurnAng = math.min(DirDiff, MaxTurn) / 10
				local Ang = NewDir:Angle()

				Ang:RotateAroundAxis(DirNormal, TurnAng)

				NewDir = Ang:Forward()
				DirDiff = DirDiff - TurnAng
			end
		end

		-- FOV check
		-- ViewCone is active-seeker specific
		if not Guidance.ViewCone or DirDiff <= Guidance.ViewCone then
			Dir = NewDir
		end

		Missile.LastLOS = LOS
	else
		local DirAng = Dir:Angle()
		local AimDiff = Dir - (LastVel / LastSpeed)
		local DiffLength = AimDiff:Length()

		if DiffLength >= 0.001 then
			local Torque = DiffLength * Missile.TorqueMul
			local AngVelDiff = Torque / Missile.Inertia * DeltaTime
			local DiffAxis = AimDiff:Cross(Dir):GetNormalized()

			Missile.RotAxis = Missile.RotAxis + DiffAxis * AngVelDiff
		end

		Missile.RotAxis = Missile.RotAxis * 0.99
		Missile.LastLOS = nil

		DirAng:RotateAroundAxis(Missile.RotAxis:GetNormalized(), Missile.RotAxis:Length())

		Dir = DirAng:Forward()
	end

	--Motor cutout
	if Missile.MotorEnabled then
		Missile.MotorLength = Missile.MotorLength - DeltaTime

		if Missile.MotorLength <= 0 then
			SetMotorState(Missile, false)
		end
	end

	--Physics calculations
	local Vel = LastVel + (Dir * Missile.Thrust - Vector(0, 0, Gravity:GetFloat())) * ACF.Scale * DeltaTime ^ 2
	local Up = Dir:Cross(Vel):Cross(Dir):GetNormalized()
	local Speed = Vel:Length()
	local VelNorm = Vel / Speed
	local DotSimple = Up.x * VelNorm.x + Up.y * VelNorm.y + Up.z * VelNorm.z

	Vel = Vel - Up * Speed * DotSimple * Missile.FinMultiplier

	local DragCoef = Missile.MotorEnabled and Missile.DragCoefFlight or Missile.DragCoef
	local Drag = Vel:GetNormalized() * (DragCoef * Vel:LengthSqr()) / ACF.DragDiv * ACF.Scale

	Vel = Vel - Drag

	local EndPos = Pos + Vel

	Missile.Velocity = Vel / DeltaTime

	--Hit detection
	TraceData.start = Pos
	TraceData.endpos = EndPos
	TraceData.filter = Missile.Filter

	local Result = ACF.Trace(TraceData)
	local Ghosted = Time < Missile.GhostPeriod
	local GhostHit = Ghosted and Result.HitWorld

	-- TODO: Missiles must be able to leave the map
	if Result.Hit and (GhostHit or not Ghosted) then
		Missile.HitNormal = Result.HitNormal
		Missile.Disabled = GhostHit

		Missile:DoFlight(Result.HitPos)
		Missile:Detonate()

		return
	end

	if Missile.FuzeData:GetDetonate(Missile, Missile.GuidanceData) then
		Missile:Detonate()

		return
	end

	Missile.LastVel = Vel
	Missile.LastPos = Pos
	Missile.Position = EndPos
	Missile.CurDir = Dir

	--Missile trajectory debugging
	debugoverlay.Line(Pos, EndPos, 10, Color(0, 255, 0))

	Missile:DoFlight()
end

local function DetonateMissile(Missile, Inflictor)
	if HookRun("ACF_AmmoExplode", Missile, Missile.BulletData) == false then return end

	if IsValid(Inflictor) and Inflictor:IsPlayer() then
		Missile.Inflictor = Inflictor
	end

	Missile:Detonate(true)
end

hook.Add("CanDrive", "acf_missile_CanDrive", function(_, Entity)
	if ActiveMissiles[Entity] then return false end
end)

hook.Add("OnMissileLaunched", "ACF Missile Rack Filter", function(Missile)
	local Count = #Missile.Filter

	for K in pairs(ActiveMissiles) do
		if Missile ~= K and Missile.Launcher == K.Launcher then
			Count = Count + 1

			K.Filter[#K.Filter + 1] = Missile
			Missile.Filter[Count] = K
		end
	end
end)

-------------------------------[[ Global Functions ]]-------------------------------

-- TODO: Make ACF Missiles compliant with ACF legal checks. How to deal with SetNoDraw and SetNotSolid tho
function MakeACF_Missile(Player, Pos, Ang, Rack, MountPoint, Crate)
	local Missile = ents.Create("acf_missile")

	if not IsValid(Missile) then return end

	local BulletData = Crate.BulletData
	local Class = ACF.GetClassGroup(Missiles, BulletData.Id)
	local Data = Class.Lookup[BulletData.Id]
	local Round = Data.Round
	local Length = Data.Length

	Missile:SetAngles(Rack:LocalToWorldAngles(Ang))
	Missile:SetPos(Rack:LocalToWorld(Pos))
	Missile:SetColor(Crate:GetColor())
	Missile:SetPlayer(Player)
	Missile:SetParent(Rack)
	Missile:Spawn()

	Missile.Owner          = Player
	Missile.Launcher       = Rack
	Missile.MountPoint     = MountPoint
	Missile.Filter         = { Rack }
	Missile.SeekCone       = Data.SeekCone
	Missile.ViewCone       = Data.ViewCone
	Missile.SkinIndex      = Data.SkinIndex
	Missile.NoThrust       = Data.NoThrust or Class.NoThrust
	Missile.Sound          = Data.Sound or Class.Sound or "acf_missiles/missiles/missile_rocket.mp3"
	Missile.ReloadTime     = Data.ReloadTime or 10
	Missile.ForcedMass     = Data.Mass or 10
	Missile.ForcedArmor    = Round.Armor
	Missile.ForcedHealth   = Data.Caliber * 2
	Missile.Effect         = Data.Effect or Class.Effect
	Missile.NoDamage       = Rack.ProtectMissile or Data.NoDamage
	Missile.ExhaustOffset  = Data.ExhaustOffset
	Missile.Bodygroups     = Data.Bodygroups
	Missile.RackModel      = Rack.MissileModel or Round.RackModel
	Missile.RealModel      = Round.Model
	Missile.DragCoef       = Round.DragCoef
	Missile.DragCoefFlight = Round.DragCoefFlight or Round.DragCoef
	Missile.MinimumSpeed   = Round.MinSpeed
	Missile.MaxThrust      = Round.Thrust
	Missile.BurnRate       = Round.BurnRate * 0.001
	Missile.StarterPercent = Round.StarterPercent
	Missile.FinMultiplier  = Round.FinMul
	Missile.CanDelay       = Round.CanDelayLaunch
	Missile.MaxLength      = Round.MaxLength
	Missile.Agility        = Data.Agility or 1
	Missile.Inertia        = 0.08333 * Data.Mass * (3.1416 * (Data.Caliber * 0.05) ^ 2 + Length)
	Missile.Length         = Length
	Missile.TorqueMul      = Length * 25
	Missile.RotAxis        = Vector()
	Missile.UseGuidance    = true
	Missile.MotorEnabled   = false
	Missile.Thrust         = 0
	Missile.ThinkDelay     = 0.1

	Missile:UpdateModel(Missile.RackModel or Missile.RealModel)
	Missile:CreateBulletData(Crate)

	if Rack.HideMissile then
		Missile:SetNotSolid(true)
		Missile:SetNoDraw(true)
	end

	do -- Exhaust pos
		local Attachment = Missile:GetAttachment(Missile:LookupAttachment("exhaust"))
		local Offset = Missile.ExhaustOffset or (Attachment and Attachment.Pos) or Vector()

		Missile.ExhaustPos = Missile:WorldToLocal(Offset)
	end

	local PhysObj = Missile:GetPhysicsObject()

	if IsValid(PhysObj) then
		PhysObj:SetMass(Missile.ForcedMass)
		PhysObj:EnableGravity(false)
		PhysObj:EnableMotion(false)
	end

	UpdateBodygroups(Missile, "OnRack")
	UpdateSkin(Missile)

	return Missile
end

function ENT:CreateBulletData(Crate)
	local Ammo = Crate.RoundData
	local Data = {}

	-- Creating a copy of the basic data stored on the crate
	for _, V in ipairs(Crate.DataStore) do
		Data[V] = Crate[V]
	end

	Data.Destiny = ACF.FindWeaponrySource(Data.Weapon)

	self.RoundData        = Ammo
	self.BulletData       = Ammo:ServerConvert(Data)
	self.BulletData.Crate = self:EntIndex()
	self.BulletData.Owner = self.Owner
	self.BulletData.Gun   = self

	if Ammo.OnFirst then
		Ammo:OnFirst(self)
	end

	HookRun("ACF_OnAmmoFirst", Ammo, self, Data)

	Ammo:Network(self, self.BulletData)
end

function ENT:UpdateModel(Model)
	self:SetModel(Model)

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
end

function ENT:Launch(Delay, IsMisfire)
	if self.Launched then return end

	local BulletData = self.BulletData
	local Point      = self.MountPoint
	local Rack       = self.Launcher
	local Velocity   = ACF_GetAncestor(Rack):GetVelocity()
	local Flight     = BulletData.Flight or self:LocalToWorldAngles(Point.Angle):Forward()
	local DeltaTime  = engine.TickInterval()

	if Rack.SoundPath and Rack.SoundPath ~= "" then
		self.Sound = Rack.SoundPath
	end

	BulletData.Flight = Flight
	BulletData.Pos    = Rack:LocalToWorld(Point.Position)

	self.Launched    = true
	self.ThinkDelay  = DeltaTime
	self.GhostPeriod = ACF.CurTime + GhostPeriod:GetFloat()
	self.NoDamage    = nil
	self.LastThink   = ACF.CurTime - DeltaTime
	self.LastVel     = Flight
	self.Position    = BulletData.Pos
	self.CurDir      = Flight
	self.Velocity    = Flight * Velocity
	self.LastPos     = self.Position

	if self.NoThrust then
		self.MotorLength = 0
	else
		self.MotorLength = BulletData.PropMass / self.BurnRate * (1 - self.StarterPercent)
	end

	if self.RackModel then
		self:UpdateModel(self.RealModel)
	end

	for _, Missile in pairs(Rack.Missiles) do
		self.Filter[#self.Filter + 1] = Missile
	end

	self:EmitSound("phx/epicmetal_hard.wav", 500, math.random(99, 101))
	self:SetNotSolid(false)
	self:SetNoDraw(false)
	self:SetParent()

	self:DoFlight()

	if IsMisfire then
		self.Disabled = true

		return self:Detonate()
	end

	ActiveMissiles[self] = true

	if Delay and self.CanDelay then
		timer.Simple(Delay, function()
			if not IsValid(self) then return end

			SetMotorState(self, true)
		end)
	else
		SetMotorState(self, true)
	end

	self.GuidanceData:Configure(self)
	self.GuidanceData:OnLaunched(self)

	self.FuzeData:Configure()

	UpdateBodygroups(self, "OnLaunch")
	UpdateSkin(self)

	HookRun("OnMissileLaunched", self)
end

function ENT:DoFlight(ToPos, ToDir)
	local NewPos = ToPos or self.Position
	local NewDir = ToDir or self.CurDir

	self:SetPos(NewPos)
	self:SetAngles(NewDir:Angle())

	self.BulletData.Pos = NewPos
end

function ENT:Detonate(Destroyed)
	if self.Detonated then return end

	local PhysObj = self:GetPhysicsObject()
	local BulletData = self.BulletData
	local Filter = BulletData.Filter
	local Fuze = self.FuzeData

	self:SetNotSolid(true)
	self:SetNoDraw(true)

	self.Detonated = true

	SetMotorState(self, false)

	ActiveMissiles[self] = nil

	if not Destroyed then
		self.Disabled = self.Disabled or self.FuzeData and not self.FuzeData:IsArmed()

		if self.Disabled then
			return Dud(self)
		end
	end

	-- Workaround for HEAT jets that can travel the entire map on destroyed missiles
	if Destroyed and BulletData.Type == "HEAT" then
		BulletData.Type = "HE"

		self:SetNW2String("AmmoType", "HE")
	end

	BulletData.Flight = self.Velocity

	if Filter then
		Filter[#Filter + 1] = self
	else
		BulletData.Filter = { self }
	end

	if IsValid(PhysObj) then
		PhysObj:EnableMotion(false)
	end

	timer.Simple(1, function()
		if not IsValid(self) then return end

		self:Remove()
	end)

	if Fuze.HandleDetonation then
		return Fuze:HandleDetonation(self, BulletData)
	end

	debugoverlay.Line(BulletData.Pos, BulletData.Pos + BulletData.Flight, 10, Color(255, 128, 0))

	function BulletData.OnPenetrated(_, Bullet)
		ACF.ResetBulletVelocity(Bullet)

		-- We only need to do either just once
		Bullet.OnPenetrated = nil
		Bullet.OnRicocheted = nil
	end

	function BulletData.OnRicocheted(_, Bullet)
		ACF.ResetBulletVelocity(Bullet)

		-- We only need to do either just once
		Bullet.OnPenetrated = nil
		Bullet.OnRicocheted = nil
	end

	local Bullet = ACF.CreateBullet(BulletData)

	ACF.DoReplicatedPropHit(self, Bullet)
end

function ENT:Think()
	self:NextThink(ACF.CurTime + self.ThinkDelay)

	CalcFlight(self)

	return true
end

local Properties = { bodygroups = true, skin = true }

function ENT:CanProperty(_, Property)
	if Properties[Property] then return false end

	return true
end

function ENT:OnRemove()
	ActiveMissiles[self] = nil

	if self.GuidanceData then
		self.GuidanceData:OnRemoved(self)
	end

	if IsValid(self.Launcher) and not self.Launched then
		self.Launcher:UpdateLoad(self.MountPoint)
	end

	WireLib.Remove(self)
end

function ENT:ACF_Activate(Recalc)
	local PhysObj = self.ACF.PhysObj
	local Area    = PhysObj:GetSurfaceArea()
	local Armor   = self.ForcedArmor
	local Health  = self.ForcedHealth
	local Percent = 1

	if Recalc and self.ACF.Health and self.ACF.MaxHealth then
		Percent = self.ACF.Health / self.ACF.MaxHealth
	end

	self.ACF.Area      = Area
	self.ACF.Ductility = 0
	self.ACF.Health    = Health * Percent
	self.ACF.MaxHealth = Health
	self.ACF.Armour    = Armor * (0.5 + Percent * 0.5)
	self.ACF.MaxArmour = Armor * ACF.ArmorMod
	self.ACF.Mass      = self.ForcedMass
	self.ACF.Type      = "Prop"
end

function ENT:ACF_OnDamage(Entity, Energy, FrArea, Angle, Inflictor)
	if self.Detonated or self.NoDamage then
		return {
			Damage = 0,
			Overkill = 1,
			Loss = 0,
			Kill = false
		}
	end

	local HitRes = ACF.PropDamage(Entity, Energy, FrArea, Angle, Inflictor) --Calling the standard damage prop function

	-- If the missile was destroyed, then we detonate it.
	if HitRes.Kill then
		DetonateMissile(Missile, Inflictor)

		return HitRes
	elseif HitRes.Overkill > 0 then
		local Ratio      = self.ACF.Health / self.ACF.MaxHealth
		local BulletData = self.BulletData

		-- We give it a chance to explode when it gets penetrated aswell.
		if math.random() > 0.75 * Ratio then
			DetonateMissile(Missile, Inflictor)

			return HitRes
		end

		-- Turning off the missile's motor.
		if self.MotorLength > 0 and math.random() > 0.75 * Ratio then
			self.MotorLength = 0

			SetMotorState(self, false)
		end

		-- Turning off the missile's guidance.
		if self.UseGuidance and math.random() > 0.5 * Ratio then
			self.UseGuidance = nil
		end

		-- Damaged the liner.
		if BulletData.Type == "HEAT" and math.random() > 0.9 * Ratio then
			BulletData.Type = "HE"

			self:SetNW2String("AmmoType", "HE")
		end
	end

	return HitRes -- This function needs to return HitRes
end
