AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

DEFINE_BASECLASS("acf_explosive")

ENT.DoNotDuplicate		= true
ENT.DisableDuplicator	= true

-------------------------------[[ Local Functions ]]-------------------------------

local Gravity = GetConVar("sv_gravity")

local function SetGuidance(Missile, Guidance)
	Missile.Guidance = Guidance
	Guidance:Configure(Missile)

	return Guidance
end

local function SetFuse(Missile, Fuse)
	Missile.Fuse = Fuse
	Fuse:Configure(Missile, Missile.Guidance or SetGuidance(Missile, ACF.Guidance.Dumb()))

	return Fuse
end

local function ApplyBodySubgroup(Missile, Group, Target)
	local TargetLower = string.lower(Target) .. ".smd"
	if not Group.submodels then return end

	for K, V in pairs(Group.submodels) do
		if string.lower(V) == TargetLower then
			Missile:SetBodygroup(Group.id, K)

			return
		end
	end
end

local function UpdateBodygroups(Missile)
	for _, V in pairs(Missile:GetBodyGroups()) do
		local GroupName = string.lower(V.name)

		if GroupName == "guidance" and Missile.Guidance then
			ApplyBodySubgroup(Missile, V, Missile.Guidance.Name)
		elseif GroupName == "warhead" and Missile.BulletData then
			ApplyBodySubgroup(Missile, V, Missile.BulletData.Type)
		end
	end
end

local function UpdateSkin(Missile)
	local BulletData = Missile.BulletData

	if not BulletData then return end

	local Skins = ACF_GetGunValue(BulletData, "skinindex")

	if not Skins then return end

	Missile:SetSkin(Skins[BulletData.Type] or 0)
end

local function ParseBulletData(Missile, BulletData)
	local BulletGuidance = BulletData.Data7
	local BulletFuse = BulletData.Data8

	if BulletGuidance then
		local Guidance = ACFM_CreateConfigurable(BulletGuidance, ACF.Guidance, BulletData, "guidance")

		if Guidance then
			SetGuidance(Missile, Guidance)
		end
	end

	if BulletFuse then
		local Fuse = ACFM_CreateConfigurable(BulletFuse, ACF.Fuse, BulletData, "fuses")

		if Fuse then
			SetFuse(Missile, Fuse)
		end
	end
end

local function ConfigureFlight(Missile)
	local BulletData = Missile.BulletData
	local GunData = list.Get("ACFEnts").Guns[BulletData.Id]
	local Round = GunData.round
	local Length = GunData.length

	if ACF_GetGunValue(BulletData, "nothrust") then
		Missile.MotorLength = 0
		Missile.Motor = 0
	else
		Missile.MotorLength = BulletData.PropMass / (Round.burnrate / 1000) * (1 - Round.starterpct)
		Missile.Motor = Round.thrust
	end

	Missile.DragCoef = Round.dragcoef
	Missile.DragCoefFlight = (Round.dragcoefflight or Round.dragcoef)
	Missile.MinimumSpeed = Round.minspeed
	Missile.FlightTime = 0
	Missile.FinMultiplier = Round.finmul
	Missile.Agility = GunData.agility or 1
	Missile.CutoutTime = CurTime() + Missile.MotorLength
	Missile.CurPos = BulletData.Pos
	Missile.CurDir = BulletData.Flight:GetNormalized()
	Missile.LastPos = Missile.CurPos
	Missile.Hit = nil
	Missile.HitNorm = Vector()
	Missile.FirstThink = true
	Missile.MinArmingDelay = math.max(Round.armdelay or GunData.armdelay, GunData.armdelay)
	Missile.Inertia = 0.08333 * GunData.weight * (3.1416 * (GunData.caliber / 2) ^ 2 + Length)
	Missile.TorqueMul = Length * 25
	Missile.RotAxis = Vector()

	UpdateBodygroups(Missile)
	UpdateSkin(Missile)
end

local function LaunchEffect(Missile)
	local BulletData = Missile.BulletData
	local SoundString = BulletData.Sound or ACF_GetGunValue(BulletData, "sound")

	if SoundString then
		if ACF_SOUND_EXT then
			hook.Call("ACF_SOUND_MISSILE", nil, Missile, SoundString)
		else
			Missile:EmitSound(SoundString, 511, 100)
		end
	end
end

local function Dud(Missile)
	local PhysObj = Missile:GetPhysicsObject()
	local LastVel = Missile.LastVel
	local CurDir = Missile.CurDir
	local HitNorm = Missile.HitNorm

	if HitNorm ~= Vector() then
		local Dot = CurDir:Dot(HitNorm)
		local NewDir = CurDir - 2 * Dot * HitNorm
		local VelMul = (0.8 + Dot * 0.7) * LastVel:Length()

		LastVel = NewDir * VelMul
	end

	if IsValid(PhysObj) then
		PhysObj:EnableGravity(true)
		PhysObj:EnableMotion(true)
		PhysObj:SetVelocity(LastVel)
	end

	timer.Simple(30, function()
		if IsValid(Missile) then
			Missile:Remove()
		end
	end)
end

local function CalcFlight(Missile)
	if Missile.Exploded then return end

	local Time = CurTime()
	local DeltaTime = Time - Missile.LastThink

	if DeltaTime <= 0 then return end

	local Pos = Missile.CurPos
	local Dir = Missile.CurDir
	local Flight = Missile.FlightTime + DeltaTime
	local LastVel = Missile.LastVel
	local LastSpeed = LastVel:Length()

	if LastSpeed == 0 then
		LastVel = Dir
		LastSpeed = 1
	end

	Missile.LastThink = Time

	--Guidance calculations
	local Guidance = Missile.Guidance:GetGuidance(Missile)
	local TargetPos = Guidance.TargetPos

	if TargetPos then
		local Dist = Pos:Distance(TargetPos)

		TargetPos = TargetPos + Vector(0, 0, Gravity:GetFloat() * Dist / 100000)

		local LOS = (TargetPos - Pos):GetNormalized()
		local LastLOS = Missile.LastLOS
		local NewDir = Dir
		local DirDiff = 0

		if LastLOS then
			local SpeedMul = math.min(LastSpeed / DeltaTime / Missile.MinimumSpeed, 1)
			local LOSDiff = math.deg(math.acos(LastLOS:Dot(LOS))) * 20
			local MaxTurn = Missile.Agility * SpeedMul

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

		DirAng:RotateAroundAxis(Missile.RotAxis, Missile.RotAxis:Length())

		Dir = DirAng:Forward()
	end

	--Motor cutout
	local CutoutTime = Time > Missile.CutoutTime
	local DragCoef = CutoutTime and Missile.DragCoef or Missile.DragCoefFlight

	if CutoutTime and Missile.Motor ~= 0 then
		Missile.Motor = 0
		Missile:StopParticles()
		Missile:SetNWFloat("LightSize", 0)
	end

	--Physics calculations
	local Vel = LastVel + (Dir * Missile.Motor - Vector(0, 0, Gravity:GetFloat())) * ACF.VelScale * DeltaTime ^ 2
	local Up = Dir:Cross(Vel):Cross(Dir):GetNormalized()
	local Speed = Vel:Length()
	local VelNorm = Vel / Speed
	local DotSimple = Up.x * VelNorm.x + Up.y * VelNorm.y + Up.z * VelNorm.z

	Vel = Vel - Up * Speed * DotSimple * Missile.FinMultiplier

	local SpeedSq = Vel:LengthSqr()
	local Drag = Vel:GetNormalized() * (DragCoef * SpeedSq) / ACF.DragDiv * ACF.VelScale

	Vel = Vel - Drag

	local EndPos = Pos + Vel

	--Hit detection
	local TraceData = {
		start = Pos,
		endpos = EndPos,
		filter = Missile.Filter
	}

	local Trace = util.TraceLine(TraceData)

	if Trace.Hit and Time >= Missile.GhostPeriod then
		Missile.HitNorm = Trace.HitNormal
		Missile.LastVel = Vel / DeltaTime

		Missile:DoFlight(Trace.HitPos)
		Missile:Detonate()

		return
	end

	if Missile.Fuse:GetDetonate(Missile, Missile.Guidance) then
		Missile.LastVel = Vel / DeltaTime
		Missile:Detonate()

		return
	end

	Missile.LastVel = Vel
	Missile.LastPos = Pos
	Missile.CurPos = EndPos
	Missile.CurDir = Dir
	Missile.FlightTime = Flight

	--Missile trajectory debugging
	debugoverlay.Line(Pos, EndPos, 10, Color(0, 255, 0))

	Missile:DoFlight()
end

hook.Add("CanDrive", "acf_missile_CanDrive", function(_, Entity)
	if Entity:GetClass() == "acf_missile" then return false end
end)

-------------------------------[[ Global Functions ]]-------------------------------

function ENT:Initialize()
	self.BaseClass.Initialize(self)

	self.SpecialDamage = true --If true needs a special ACF_OnDamage function
	self.SpecialHealth = true --If true needs a special ACF_Activate function

	self:SetNWFloat("LightSize", 0)

	if CPPI then
		self:CPPISetOwner(self.Owner)
	end

	local PhysObj = self:GetPhysicsObject()

	if IsValid(PhysObj) then
		PhysObj:EnableGravity(false)
		PhysObj:EnableMotion(false)
	end
end

function ENT:SetBulletData(BulletData)
	self.BaseClass.SetBulletData(self, BulletData)

	local Gun = list.Get("ACFEnts").Guns[BulletData.Id]
	local PhysObj = self:GetPhysicsObject()

	self:SetModelEasy(Gun.round.model or Gun.model or "models/missiles/aim9.mdl")

	ParseBulletData(self, BulletData)

	self.RoundWeight = ACF_GetGunValue(BulletData, "weight") or 10

	if IsValid(PhysObj) then
		PhysObj:SetMass(self.RoundWeight)
	end

	ConfigureFlight(self)
end

function ENT:Launch()
	if not self.Guidance then
		SetGuidance(self, ACF.Guidance.Dumb())
	end

	if not self.Fuse then
		SetFuse(self, ACF.Fuse.Contact())
	end

	self.Guidance:Configure(self)
	self.Fuse:Configure(self, self.Guidance)
	self.Launched = true
	self.ThinkDelay = engine.TickInterval()
	self.GhostPeriod = CurTime() + ACFM_GhostPeriod:GetFloat()
	self.DisableDamage = nil

	ConfigureFlight(self)

	if self.Motor > 0 or self.MotorLength > 0.1 then
		self.CacheParticleEffect = CurTime() + 0.01
		self:SetNWFloat("LightSize", self.BulletData.Caliber)
	end

	LaunchEffect(self)

	ACF_ActiveMissiles[self] = true

	self:Think()
end

function ENT:DoFlight(ToPos, ToDir)
	local NewPos = ToPos or self.CurPos
	local NewDir = ToDir or self.CurDir

	self:SetPos(NewPos)
	self:SetAngles(NewDir:Angle())

	self.BulletData.Pos = NewPos
end

function ENT:Detonate()
	self.Motor = 0
	self.Exploded = true
	self.Disabled = self.Disabled or self.Fuse and (CurTime() - self.Fuse.TimeStarted < self.MinArmingDelay or not self.Fuse:IsArmed())

	self:StopParticles()
	self:SetNWFloat("LightSize", 0)

	ACF_ActiveMissiles[self] = nil

	if self.Disabled then
		Dud(self)
		return
	end

	self.BulletData.Flight = self:GetForward() * (self.BulletData.MuzzleVel or 10)
	self.DetonateOffset = self.LastVel and -self.LastVel:GetNormalized()

	self.BaseClass.Detonate(self, self.BulletData)
end

function ENT:Think()
	if self.Launched and not self.Exploded then
		if self.Hit then
			self:Detonate()
			return false
		end

		local Time = CurTime()

		if self.FirstThink then
			self.FirstThink = nil
			self.LastThink = Time - self.ThinkDelay
			self.LastVel = self.Launcher.Physical:GetVelocity() * self.ThinkDelay
		end

		CalcFlight(self)

		if self.CacheParticleEffect and self.CacheParticleEffect <= Time and Time < self.CutoutTime then
			local Effect = ACF_GetGunValue(self.BulletData, "effect")

			if Effect then
				ParticleEffectAttach(Effect, PATTACH_POINT_FOLLOW, self, self:LookupAttachment("exhaust") or 0)
			end

			self.CacheParticleEffect = nil
		end
	end

	return self.BaseClass.Think(self)
end

function ENT:PhysicsCollide(Data)
	if not self.Disabled and not self.Launched then
		self.Disabled = true
		self.LastVel = Data.OurOldVelocity

		self:Detonate()
	end
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)

	ACF_ActiveMissiles[self] = nil

	if IsValid(self.Launcher) and not self.Launched then
		self.Launcher:UpdateAmmoCount(self.Attachment)
	end
end

function ENT:ACF_Activate(Recalc)
	local ForceArmour = ACF_GetGunValue(self.BulletData, "armour")
	local EmptyMass = self.RoundWeight or self.Mass or 10
	local PhysObj = self:GetPhysicsObject()
	self.ACF = self.ACF or {}

	if not self.ACF.Area then
		self.ACF.Area = PhysObj:GetSurfaceArea() * 6.45
	end

	if not self.ACF.Volume then
		self.ACF.Volume = PhysObj:GetVolume() * 16.38
	end

	local Armour = ForceArmour or EmptyMass * 1000 / self.ACF.Area / 0.78	--So we get the equivalent thickness of that prop in mm if all it's weight was a steel plate
	local Health = self.ACF.Volume / ACF.Threshold							--Setting the threshold of the prop aera gone
	local Percent = 1

	if Recalc and self.ACF.Health and self.ACF.MaxHealth then
		Percent = self.ACF.Health / self.ACF.MaxHealth
	end

	self.ACF.Health = Health * Percent
	self.ACF.MaxHealth = Health
	self.ACF.Armour = Armour * (0.5 + Percent / 2)
	self.ACF.MaxArmour = Armour
	self.ACF.Type = nil
	self.ACF.Mass = self.Mass
	self.ACF.Density = PhysObj:GetMass() * 1000 / self.ACF.Volume
	self.ACF.Type = "Prop"
end

function ENT:ACF_OnDamage(Entity, Energy, FrArea, Angle, Inflictor)
	if self.Detonated or self.DisableDamage then
		return {
			Damage = 0,
			Overkill = 1,
			Loss = 0,
			Kill = false
		}
	end

	local HitRes = ACF_PropDamage(Entity, Energy, FrArea, Angle, Inflictor) --Calling the standard damage prop function

	-- Detonate if the shot penetrates the casing or destroys the missile.
	if HitRes.Kill or HitRes.Overkill > 0 then
		if hook.Run("ACF_AmmoExplode", self, self.BulletData) == false then return HitRes end

		if IsValid(Inflictor) and Inflictor:IsPlayer() then
			self.Inflictor = Inflictor
		end

		self:Detonate()
	end

	return HitRes -- This function needs to return HitRes
end
