AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local ACF        = ACF
local Missiles   = ACF.ActiveMissiles
local Ballistics = ACF.Ballistics
local AmmoTypes  = ACF.Classes.AmmoTypes
local Clock      = ACF.Utilities.Clock
local TraceData  = { start = true, endpos = true, filter = true }
local ZERO       = Vector()

local function CheckViewCone(Missile, HitPos)
	local Position = Missile.Position
	local Forward = Missile:GetForward()
	local Direction = (HitPos - Position):GetNormalized()

	return Direction:Dot(Forward) >= Missile.ViewCone
end

local function DetonateMissile(Missile, Inflictor)
	if HookRun("ACF_AmmoExplode", Missile, Missile.BulletData) == false then return end

	if IsValid(Inflictor) and Inflictor:IsPlayer() then
		Missile.Inflictor = Inflictor
	end

	Missile:Detonate()
end

function MakeACF_GLATGM(Gun, BulletData)
	local Entity = ents.Create("acf_glatgm")

	if not IsValid(Entity) then return end

	local Velocity = math.Clamp(BulletData.MuzzleVel / ACF.Scale, 200, 1600)
	local Caliber  = BulletData.Caliber * 10
	local Owner    = Gun.Owner

	Entity:SetAngles(Gun:GetAngles())
	Entity:SetPos(BulletData.Pos)
	Entity:CPPISetOwner(Owner)
	Entity:SetPlayer(Owner)
	Entity:Spawn()

	if Caliber >= 140 then
		Entity:SetModel("models/missiles/glatgm/mgm51.mdl")
		Entity:SetModelScale(Caliber / 150, 0)
	elseif Caliber >= 120 then
		Entity:SetModel("models/missiles/glatgm/9m112.mdl")
		Entity:SetModelScale(Caliber / 125, 0)
	else
		Entity:SetModel("models/missiles/glatgm/9m117.mdl")
		Entity:SetModelScale(Caliber * 0.01, 0)
	end

	Entity:PhysicsInit(SOLID_VPHYSICS)
	Entity:SetMoveType(MOVETYPE_VPHYSICS)

	ParticleEffectAttach("Rocket Motor GLATGM", 4, Entity, 1)

	Entity.Owner        = Gun.Owner
	Entity.Name         = Caliber .. "mm Gun Launched Missile"
	Entity.ShortName    = Caliber .. "mmGLATGM"
	Entity.EntType      = "Gun Launched Anti-Tank Guided Missile"
	Entity.Caliber      = Caliber
	Entity.Weapon       = Gun
	Entity.BulletData   = table.Copy(BulletData)
	Entity.ForcedArmor  = 5 -- All missiles should get 5mm
	Entity.ForcedMass   = BulletData.CartMass
	Entity.UseGuidance  = true
	Entity.ViewCone     = math.cos(math.rad(50)) -- Number inside is on degrees
	Entity.KillTime     = Clock.CurTime + 20
	Entity.GuideDelay   = Clock.CurTime + 0.25 -- Missile won't be guided for the first quarter of a second
	Entity.LastThink    = Clock.CurTime
	Entity.Filter       = Entity.BulletData.Filter
	Entity.Agility      = 50 -- Magic multiplier that controls the agility of the missile
	Entity.IsSubcaliber = Caliber < 100
	Entity.LaunchVel    = math.Round(Velocity * 0.2, 2) * 39.37
	Entity.DiffVel      = math.Round(Velocity * 0.5, 2) * 39.37 - Entity.LaunchVel
	Entity.AccelLength  = math.Round(math.Clamp(BulletData.ProjMass / BulletData.PropMass + BulletData.Caliber / 7, 0.2, 10), 2)
	Entity.AccelTime    = Entity.LastThink + Entity.AccelLength
	Entity.Speed        = Entity.LaunchVel
	Entity.SpiralRadius = Entity.IsSubcaliber and 3.5 or nil
	Entity.SpiralSpeed  = Entity.IsSubcaliber and 15 or nil
	Entity.SpiralAngle  = Entity.IsSubcaliber and 0 or nil
	Entity.Position     = BulletData.Pos
	Entity.Innacuracy   = 0

	Entity.Filter[#Entity.Filter + 1] = Entity

	local PhysObj = Entity:GetPhysicsObject()

	if IsValid(PhysObj) then
		PhysObj:EnableGravity(false)
		PhysObj:EnableMotion(false)
		PhysObj:SetMass(Entity.ForcedMass)
	end

	ACF.Activate(Entity)

	Missiles[Entity] = true

	hook.Run("OnMissileLaunched", Entity)

	return Entity
end

function ENT:ACF_Activate(Recalc)
	local PhysObj = self.ACF.PhysObj
	local Area    = PhysObj:GetSurfaceArea()
	local Armor   = self.ForcedArmor
	local Health  = self.Caliber * 2
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

function ENT:ACF_OnDamage(Bullet, Trace)
	if self.Detonated then
		return {
			Damage = 0,
			Overkill = 1,
			Loss = 0,
			Kill = false
		}
	end

	local HitRes = ACF.PropDamage(Bullet, Trace) --Calling the standard damage prop function
	local Owner  = Bullet.Owner

	-- If the missile was destroyed, then we detonate it.
	if HitRes.Kill then
		DetonateMissile(self, Owner)

		return HitRes
	elseif HitRes.Overkill > 0 then
		local Ratio = self.ACF.Health / self.ACF.MaxHealth

		-- We give it a chance to explode when it gets penetrated aswell.
		if math.random() > 0.75 * Ratio then
			DetonateMissile(self, Owner)

			return HitRes
		end

		-- Turning off the missile's guidance.
		if self.UseGuidance and math.random() > 0.5 * Ratio then
			self.UseGuidance = nil
		end
	end

	return HitRes -- This function needs to return HitRes
end

function ENT:GetComputer()
	if not self.UseGuidance then return end

	local Weapon = self.Weapon

	if not IsValid(Weapon) then return end

	local Computer = Weapon.Computer

	if not IsValid(Computer) then return end
	if Computer.Disabled then return end
	if not Computer.IsComputer then return end
	if Computer.HitPos == ZERO then return end

	return Computer
end

local function ClampAng(Ang, Min, Max)
	local Pitch, Yaw, Roll = Ang:Unpack()

	return Angle(
		math.Clamp(Pitch, Min, Max),
		math.Clamp(Yaw, Min, Max),
		math.Clamp(Roll, Min, Max)
	)
end

local function ClampVec(Vec, VMin, VMax)

	return Vector(
		math.Clamp(Vec[1], VMin[1], VMax[1]),
		math.Clamp(Vec[2], VMin[2], VMax[2]),
		math.Clamp(Vec[3], VMin[3], VMax[3])
	)
end

function ENT:Think()
	if self.Detonated then return end

	local Time = Clock.CurTime

	if Time >= self.KillTime then
		return self:Detonate()
	end

	local IsGuided, Direction, Correction
	local DeltaTime = Clock.CurTime - self.LastThink
	local IsDelayed = self.GuideDelay > Time
	local Computer  = self:GetComputer()
	local CanSee    = IsValid(Computer) and CheckViewCone(self, Computer.HitPos)
	local Position  = self.Position

	self.Speed = self.LaunchVel + self.DiffVel * math.Clamp(1 - (self.AccelTime - Time) / self.AccelLength, 0, 1)

	if not IsDelayed and CanSee then
		local Agility            = self.Agility * DeltaTime
		local AgilityVector      = Vector(self.Speed, Agility, Agility)
		local ComputerCorrection = Computer:WorldToLocal(Position)
		local Desired            = AngleRand() * 0.005

		ComputerCorrection = Computer:LocalToWorld(Vector(ComputerCorrection.X + self.Speed * 0.27))
		Correction         = ClampVec(self:WorldToLocal(ComputerCorrection), -AgilityVector, AgilityVector)

		if math.abs(Correction.y) + math.abs(Correction.z) >= 0.2 then
			Desired = self:WorldToLocalAngles((ComputerCorrection - Position):Angle()) + Desired
		else
			Desired = self:WorldToLocalAngles(Computer.TraceDir:Angle()) + Desired
		end

		Direction = ClampAng(Desired, -Agility, Agility)
		IsGuided  = true

		self.Innacuracy = 0
	end

	if not IsGuided then
		local Innacuracy = self.Innacuracy * DeltaTime

		Direction  = AngleRand() * 0.0002 * Innacuracy
		Correction = VectorRand() * 0.0007 * Innacuracy

		self.Innacuracy = self.Innacuracy + 100 * DeltaTime
	end

	if self.IsSubcaliber then
		local Radius = self.SpiralRadius
		local CurAng = self.SpiralAngle

		Correction.y = Correction.y + Radius * math.cos(CurAng)
		Correction.z = Correction.z + Radius * math.sin(CurAng)

		self.SpiralAngle = (CurAng + self.SpiralSpeed * DeltaTime) % 360
	end

	self:SetAngles(self:LocalToWorldAngles(Direction))

	self.Position = self:LocalToWorld(Vector(self.Speed * DeltaTime, Correction.y, Correction.z))
	self.Velocity = (self.Position - Position) / DeltaTime

	TraceData.start  = Position
	TraceData.endpos = self.Position
	TraceData.filter = self.Filter

	local Result = ACF.Trace(TraceData)

	if Result.Hit then
		self.Position = Result.HitPos

		return self:Detonate()
	end

	self:SetPos(self.Position)
	self:NextThink(Time)

	self.LastThink = Time

	return true
end

function ENT:Detonate()
	if self.Detonated then return end

	self.Detonated = true

	local BulletData  = self.BulletData

	BulletData.Filter = self.Filter
	BulletData.Flight = self:GetForward() * self.Speed
	BulletData.Pos    = self.Position

	local Bullet = Ballistics.CreateBullet(BulletData)
	local Ammo   = AmmoTypes.Get(BulletData.Type)

	Ammo:Detonate(Bullet, self.Position)

	self:Remove()
end

function ENT:OnRemove()
	Missiles[self] = nil

	WireLib.Remove(self)
end
