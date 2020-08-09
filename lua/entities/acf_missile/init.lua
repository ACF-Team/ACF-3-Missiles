AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

DEFINE_BASECLASS("acf_explosive")

ENT.DoNotDuplicate		= true
ENT.DisableDuplicator	= true

-------------------------------[[ Local Functions ]]-------------------------------

local Trace = ACF.Trace
local TraceData = { start = true, endpos = true, filter = true }
local Gravity = GetConVar("sv_gravity")
local GhostPeriod = GetConVar("ACFM_GhostPeriod")
local ActiveMissiles = ACF.ActiveMissiles
local Missiles = ACF.Classes.Missiles
local Guidances = ACF.Classes.Guidances
local Fuzes = ACF.Classes.Fuzes

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
	local BulletData = Missile.BulletData
	local SoundString = BulletData.Sound or Missile.Sound

	if SoundString then
		if ACF_SOUND_EXT then
			hook.Call("ACF_SOUND_MISSILE", nil, Missile, SoundString)
		else
			Missile:EmitSound(SoundString, 511, math.random(98, 102))
		end
	end
end

local function SetMotorState(Missile, Enabled)
	if Missile.MotorEnabled == Enabled then return end

	if Enabled then
		if Missile.NoThrust then return end
		if Missile.Exploded then return end

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

local function ConfigureFlight(Missile, Phase)
	local BulletData = Missile.BulletData

	if Missile.NoThrust then
		Missile.MotorLength = 0
	else
		Missile.MotorLength = BulletData.PropMass / Missile.BurnRate * (1 - Missile.StarterPercent)
	end

	Missile.CurPos = BulletData.Pos
	Missile.CurDir = BulletData.Flight:GetNormalized()
	Missile.LastPos = Missile.CurPos

	local PhysObj = Missile:GetPhysicsObject()

	if IsValid(PhysObj) then
		PhysObj:SetMass(Missile.ForcedMass)
		PhysObj:EnableGravity(false)
		PhysObj:EnableMotion(false)
	end

	UpdateBodygroups(Missile, Phase)
	UpdateSkin(Missile)
end

local function Dud(Missile)
	local PhysObj = Missile:GetPhysicsObject()
	local HitNormal = Missile.HitNormal
	local LastVel = Missile.LastVel
	local CurDir = Missile.CurDir

	if HitNormal then
		local Dot = CurDir:Dot(HitNormal)
		local NewDir = CurDir - 2 * Dot * HitNormal
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
	if not Missile.Launched then return end
	if Missile.Exploded then return end

	local Time = ACF.CurTime
	local DeltaTime = Time - Missile.LastThink

	if DeltaTime <= 0 then return end

	local Pos = Missile.CurPos
	local Dir = Missile.CurDir
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

		DirAng:RotateAroundAxis(Missile.RotAxis, Missile.RotAxis:Length())

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

	--Hit detection
	TraceData.start = Pos
	TraceData.endpos = EndPos
	TraceData.filter = Missile.Filter

	local Result = Trace(TraceData, true)
	local Ghosted = Time < Missile.GhostPeriod
	local GhostHit = Ghosted and Result.HitWorld

	if Result.Hit and (GhostHit or not Ghosted) then
		Missile.HitNormal = Result.HitNormal
		Missile.LastVel = Vel / DeltaTime
		Missile.Disabled = GhostHit

		Missile:DoFlight(Result.HitPos)
		Missile:Detonate()

		return
	end

	if Missile.Fuze:GetDetonate(Missile, Missile.Guidance) then
		Missile.LastVel = Vel / DeltaTime
		Missile:Detonate()

		return
	end

	Missile.LastVel = Vel
	Missile.LastPos = Pos
	Missile.CurPos = EndPos
	Missile.CurDir = Dir

	--Missile trajectory debugging
	debugoverlay.Line(Pos, EndPos, 10, Color(0, 255, 0))

	Missile:DoFlight()
end

hook.Add("CanDrive", "acf_missile_CanDrive", function(_, Entity)
	if Entity:GetClass() == "acf_missile" then return false end
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
function MakeACF_Missile(Player, Pos, Ang, Rack, MountPoint, BulletData)
	local Missile = ents.Create("acf_missile")

	if not IsValid(Missile) then return end

	local Class = ACF.GetClassGroup(Missiles, BulletData.Id)
	local Data = Class.Lookup[BulletData.Id]
	local Round = Data.Round
	local Length = Round.MaxLength

	Missile:SetAngles(Rack:LocalToWorldAngles(Ang))
	Missile:SetPos(Rack:LocalToWorld(Pos))
	Missile:SetPlayer(Player)
	Missile:SetParent(Rack)
	Missile:Spawn()

	Missile.Owner				= Player
	Missile.Launcher			= Rack
	Missile.MountPoint			= MountPoint
	Missile.Filter				= { Rack }
	Missile.SeekCone			= Data.SeekCone
	Missile.ViewCone			= Data.ViewCone
	Missile.SkinIndex			= Data.SkinIndex
	Missile.NoThrust			= Data.NoThrust or Class.NoThrust
	Missile.Sound				= Data.Sound or Class.Sound or "acf_missiles/missiles/missile_rocket.mp3"
	Missile.ForcedMass			= Data.Mass or 10
	Missile.ForcedArmor			= Round.Armor
	Missile.Effect				= Data.Effect or Class.Effect
	Missile.DisableDamage		= Rack.ProtectMissile
	Missile.ExhaustOffset		= Data.ExhaustOffset
	Missile.Bodygroups			= Data.Bodygroups
	Missile.RackModel			= Rack.MissileModel or Round.RackModel
	Missile.RealModel			= Round.Model
	Missile.DragCoef			= Round.DragCoef
	Missile.DragCoefFlight		= Round.DragCoefFlight or Round.DragCoef
	Missile.MinimumSpeed		= Round.MinSpeed
	Missile.MaxThrust			= Round.Thrust
	Missile.BurnRate			= Round.BurnRate * 0.001
	Missile.StarterPercent		= Round.StarterPercent
	Missile.FinMultiplier		= Round.FinMul
	Missile.CanDelay			= Round.CanDelayLaunch
	Missile.Agility				= Data.Agility or 1
	Missile.Inertia				= 0.08333 * Data.Mass * (3.1416 * (Data.Caliber * 0.05) ^ 2 + Length)
	Missile.TorqueMul			= Length * 25
	Missile.RotAxis				= Vector()
	Missile.MotorEnabled		= false
	Missile.Thrust				= 0

	Missile:SetModelEasy(Missile.RackModel or Missile.RealModel)
	Missile:SetBulletData(BulletData)

	if Rack.HideMissile then
		Missile:SetNoDraw(true)
	end

	do -- Exhaust pos
		local Attachment = Missile:GetAttachment(Missile:LookupAttachment("exhaust"))
		local Offset = Missile.ExhaustOffset or (Attachment and Attachment.Pos) or Vector()

		Missile.ExhaustPos = Missile:WorldToLocal(Offset)
	end

	return Missile
end

function ENT:SetBulletData(BulletData)
	self.BaseClass.SetBulletData(self, BulletData)

	local GuidanceData = BulletData.Data7 or "Dumb"
	local FuzeData = BulletData.Data8 or "Contact"

	local Guidance = ACFM_CreateConfigurable(GuidanceData, Guidances, BulletData, "Guidance")
	local Fuze = ACFM_CreateConfigurable(FuzeData, Fuzes, BulletData, "Fuzes")

	self.Guidance = Guidance or Guidances.Dumb()
	self.Guidance:Configure(self)

	self.Fuze = Fuze or Fuzes.Contact()
	self.Fuze:Configure()

	ConfigureFlight(self, "OnRack")
end

function ENT:Launch(Delay)
	self.Launched = true
	self.ThinkDelay = engine.TickInterval()
	self.GhostPeriod = ACF.CurTime + GhostPeriod:GetFloat()
	self.DisableDamage = nil
	self.LastThink = ACF.CurTime - self.ThinkDelay
	self.LastVel = ACF_GetAncestor(self.Launcher):GetVelocity() * self.ThinkDelay

	self:EmitSound("phx/epicmetal_hard.wav", 500, math.random(98, 102))

	ActiveMissiles[self] = true

	if Delay and self.CanDelay then
		timer.Simple(Delay, function()
			if not IsValid(self) then return end

			SetMotorState(self, true)
		end)
	else
		SetMotorState(self, true)
	end

	self.Guidance:Configure(self)
	self.Guidance:OnLaunched(self)

	self.Fuze:Configure()

	ConfigureFlight(self, "OnLaunch")

	hook.Run("OnMissileLaunched", self)
end

function ENT:DoFlight(ToPos, ToDir)
	local NewPos = ToPos or self.CurPos
	local NewDir = ToDir or self.CurDir

	self:SetPos(NewPos)
	self:SetAngles(NewDir:Angle())

	self.BulletData.Pos = NewPos
end

function ENT:Detonate(Destroyed)
	self.Exploded = true

	SetMotorState(self, false)

	ActiveMissiles[self] = nil

	if not Destroyed then
		self.Disabled = self.Disabled or self.Fuze and not self.Fuze:IsArmed()

		if self.Disabled then
			return Dud(self)
		end
	end

	-- Workaround for HEAT jets that can travel the entire map on destroyed missiles
	if Destroyed and self.BulletData.Type == "HEAT" then
		self.BulletData.Type = "HE"

		self:SetNWString("AmmoType", "HE")
	end

	self.BulletData.Flight = self:GetForward() * (self.BulletData.MuzzleVel or 10)
	self.DetonateOffset = self.LastVel and -self.LastVel:GetNormalized()

	self.BaseClass.Detonate(self, self.BulletData)
end

function ENT:Think()
	CalcFlight(self)

	return self.BaseClass.Think(self)
end

local Properties = { bodygroups = true, skin = true }

function ENT:CanProperty(_, Property)
	if Properties[Property] then return false end

	return true
end

function ENT:OnRemove()
	ActiveMissiles[self] = nil

	if self.Guidance then
		self.Guidance:OnRemoved(self)
	end

	if IsValid(self.Launcher) and not self.Launched then
		self.Launcher:UpdateLoad(self.MountPoint)
	end

	WireLib.Remove(self)
end

function ENT:ACF_Activate(Recalc)
	local PhysObj = self:GetPhysicsObject()

	if not self.ACF.Area then
		self.ACF.Area = PhysObj:GetSurfaceArea() * 6.45
	end

	if not self.ACF.Volume then
		self.ACF.Volume = PhysObj:GetVolume() * 16.38
	end

	local Armour = self.ForcedArmor or self.ForcedMass * 1000 / self.ACF.Area / 0.78	--So we get the equivalent thickness of that prop in mm if all it's weight was a steel plate
	local Health = self.ACF.Volume / ACF.Threshold							--Setting the threshold of the prop aera gone
	local Percent = 1

	if Recalc and self.ACF.Health and self.ACF.MaxHealth then
		Percent = self.ACF.Health / self.ACF.MaxHealth
	end

	self.ACF.Health = Health * Percent
	self.ACF.MaxHealth = Health
	self.ACF.Armour = Armour * (0.5 + Percent / 2)
	self.ACF.MaxArmour = Armour
	self.ACF.Mass = self.ForcedMass
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

	local HitRes = ACF.PropDamage(Entity, Energy, FrArea, Angle, Inflictor) --Calling the standard damage prop function

	-- Detonate if the shot penetrates the casing or destroys the missile.
	if HitRes.Kill or HitRes.Overkill > 0 then
		if hook.Run("ACF_AmmoExplode", self, self.BulletData) == false then return HitRes end

		if IsValid(Inflictor) and Inflictor:IsPlayer() then
			self.Inflictor = Inflictor
		end

		self:Detonate(true)
	end

	return HitRes -- This function needs to return HitRes
end
