AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local Missiles = ACF.ActiveMissiles
local TraceData = { start = true, endpos = true, filter = true }
local Trace = ACF.Trace

local function CheckViewCone(Missile, HitPos)
	local Position = Missile:GetPos()
	local Forward = Missile:GetForward()
	local Direction = (HitPos - Position):GetNormalized()

	return Direction:Dot(Forward) >= Missile.ViewCone
end

function MakeACF_GLATGM(Gun, BulletData)
	local Entity = ents.Create("acf_glatgm")

	if not IsValid(Entity) then return end

	Entity:SetPos(Gun:LocalToWorld(Gun.Muzzle))
	Entity:SetAngles(Gun:GetAngles())
	Entity:Spawn()

	if BulletData.Caliber == 12.0 then
		Entity:SetModel("models/missiles/glatgm/9m112.mdl")
	elseif BulletData.Caliber > 12.0 then
		Entity:SetModel("models/missiles/glatgm/mgm51.mdl")
	else
		Entity:SetModel("models/missiles/glatgm/9m117.mdl")
		Entity:SetModelScale(BulletData.Caliber * 0.1, 0)
	end

	Entity:PhysicsInit(SOLID_VPHYSICS)
	Entity:SetMoveType(MOVETYPE_VPHYSICS)

	ParticleEffectAttach("Rocket Motor GLATGM", 4, Entity, 1)

	Entity.Owner			= Gun.Owner
	Entity.Weapon			= Gun
	Entity.BulletData		= BulletData
	Entity.ViewCone			= math.cos(math.rad(15)) -- Number inside is on degrees
	Entity.Distance			= BulletData.MuzzleVel * 4 * 39.37 -- optical fuze distance
	Entity.KillTime			= ACF.CurTime + 20
	Entity.Time				= ACF.CurTime
	Entity.Filter			= { Entity }
	Entity.Sub				= BulletData.Caliber < 10 -- is it a small glatgm?
	Entity.Velocity			= Entity.Sub and 2500 or 50 --self.Velocity of the missile per second
	Entity.secondsOffset	= Entity.Sub and 0.25 or 0.5 --seconds of forward flight to aim towards, to affect the beam-riding simulation
	Entity.SpiralAm			= Entity.Sub and (10 - BulletData.Caliber) * 0.5 -- amount of artifical spiraling for <100 shells, caliber in acf is in cm
	Entity.offsetLength		= Entity.Velocity * Entity.secondsOffset --how far off the forward offset is for the targeting position

	local Mass = BulletData.ProjMass + BulletData.PropMass
	local Phys = Entity:GetPhysicsObject()
	if IsValid(Phys) then
		Phys:EnableGravity(false)
		Phys:EnableMotion(false)
		Phys:SetMass(Mass)
	end

	ACF_Activate(Entity)

	Missiles[Entity] = true

	hook.Run("OnMissileLaunched", Entity)

	return Entity
end

function ENT:ACF_OnDamage(Entity, Energy, FrArea, Angle, Inflictor)
	if self.Detonated then
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

		self:Detonate()
	end

	return HitRes -- This function needs to return HitRes
end

function ENT:GetComputer()
	local Weapon = self.Weapon

	if not IsValid(Weapon) then return end

	local Computer = Weapon.Computer

	if not IsValid(Computer) then return end
	if Computer.Disabled then return end
	if not Computer.IsComputer then return end
	if Computer.HitPos == Vector() then return end

	return Computer
end

function ENT:Think()
	if self.Detonated then return end

	local Time = ACF.CurTime

	if Time >= self.KillTime then
		return self:Detonate()
	end

	local Computer = self:GetComputer()
	local Delta = Time - self.Time
	local d = Vector()
	local dir = AngleRand() * 0.01
	local Dist = 0.01 --100/10000

	if IsValid(Computer) then
		local Range = self:GetPos():Distance(Computer:GetPos())

		if Range <= self.Distance and CheckViewCone(self, Computer.HitPos) then
			d = Computer.HitPos - self:GetPos()
			dir = self:WorldToLocalAngles(d:Angle()) * 0.02 --0.01 controls agility but is not scaled to timestep; bug poly
			Dist = Range / 39.37 / 10000
		end
	end

	local Spiral = d:Length() / 39370

	if self.Sub then
		Spiral = self.SpiralAm + math.Rand(-self.SpiralAm, self.SpiralAm)
	end

	local Inacc = math.Rand(-1, 1) * Dist

	self:SetAngles(self:LocalToWorldAngles(dir + Angle(Inacc, -Inacc, 5)))
	self:SetPos(self:LocalToWorld(Vector(self.Velocity * Delta, Spiral, 0)))

	TraceData.start = self:GetPos()
	TraceData.endpos = self:LocalToWorld(self:GetForward() * self.Velocity * Delta)
	TraceData.filter = self.Filter

	local Result = Trace(TraceData, true)

	if Result.Hit then
		return self:Detonate()
	end

	self.Time = Time

	self:NextThink(Time)

	return true
end

function ENT:Detonate()
	if self.Detonated then return end

	self.Detonated = true

	Missiles[self] = nil

	local BulletData	= table.Copy(self.BulletData)
	BulletData.Type		= "HEAT"
	BulletData.Filter	= { self }
	BulletData.Flight	= self:GetForward() * self.Velocity
	BulletData.Pos		= self:GetPos()

	ACF.RoundTypes.HEAT.create(self, BulletData)

	self:Remove()
end

function ENT:OnRemove()
	Missiles[self] = nil
end
