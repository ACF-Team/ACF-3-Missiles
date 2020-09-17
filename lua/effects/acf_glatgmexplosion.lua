local TraceData = { start = true, endpos = true, mask = true }
local TraceLine = util.TraceLine
local GetIndex = ACF.GetAmmoDecalIndex
local GetDecal = ACF.GetRicochetDecal

local Colors = {
	[MAT_GRATE] = Vector(170, 170, 170),
	[MAT_CLIP] = Vector(170, 170, 170),
	[MAT_METAL] = Vector(170, 170, 170),
	[MAT_COMPUTER] = Vector(170, 170, 170),
	[MAT_DIRT] = Vector(100, 80, 50),
	[MAT_FOLIAGE] = Vector(100, 80, 50),
	[MAT_SAND] = Vector(100, 80, 50),
}

function EFFECT:Init(Data)
	self.Origin = Data:GetOrigin()
	self.DirVec = Data:GetNormal()
	self.Radius = math.max(Data:GetScale() * 0.02, 1)
	self.Emitter = ParticleEmitter(self.Origin)
	self.ParticleMul = LocalPlayer():GetInfoNum("acf_cl_particlemul", 1)

	TraceData.start = self.Origin - self.DirVec
	TraceData.endpos = self.Origin + self.DirVec * 100
	TraceData.mask = MASK_SOLID

	local Impact = TraceLine(TraceData)

	self.Normal = Impact.HitNormal
	self.Color = Colors[Impact.MatType] or Vector(102, 93, 77)

	self:Airburst()

	self.Emitter:Finish()
end

function EFFECT:Core(Direction)
	local Radius = self.Radius
	local Mult = self.ParticleMul

	for _ = 0, 2 * Radius * Mult do
		local Flame = self.Emitter:Add("particles/flamelet" .. math.random(1, 5), self.Origin)

		if Flame then
			Flame:SetVelocity((Direction + VectorRand()) * 150 * Radius)
			Flame:SetLifeTime(0)
			Flame:SetDieTime(0.15)
			Flame:SetStartAlpha(math.Rand(100, 200))
			Flame:SetEndAlpha(0)
			Flame:SetStartSize(Radius)
			Flame:SetEndSize(Radius * 15)
			Flame:SetRoll(math.random(120, 360))
			Flame:SetRollDelta(math.Rand(-1, 1))
			Flame:SetAirResistance(300)
			Flame:SetGravity(Vector(0, 0, 4))
			Flame:SetColor(255, 255, 255)
		end
	end

	for _ = 0, 5 * Radius * Mult do
		local Debris = self.Emitter:Add("effects/fleck_tile" .. math.random(1, 2), self.Origin)

		if Debris then
			Debris:SetVelocity((Direction + VectorRand()) * 150 * Radius)
			Debris:SetLifeTime(0)
			Debris:SetDieTime(math.Rand(0.5, 1) * Radius)
			Debris:SetStartAlpha(150)
			Debris:SetEndAlpha(0)
			Debris:SetStartSize(Radius)
			Debris:SetEndSize(Radius)
			Debris:SetRoll(math.Rand(0, 360))
			Debris:SetRollDelta(math.Rand(-3, 3))
			Debris:SetAirResistance(30)
			Debris:SetGravity(Vector(0, 0, -650))
			Debris:SetColor(120, 120, 120)
		end
	end

	for _ = 0, 20 * Radius * Mult do
		local Embers = self.Emitter:Add("particles/flamelet" .. math.random(1, 5), self.Origin)

		if Embers then
			Embers:SetVelocity((Direction + VectorRand()) * 150 * Radius)
			Embers:SetLifeTime(0)
			Embers:SetDieTime(math.Rand(0.1, 0.2) * Radius)
			Embers:SetStartAlpha(255)
			Embers:SetEndAlpha(0)
			Embers:SetStartSize(Radius * 0.5)
			Embers:SetEndSize(0)
			Embers:SetStartLength(Radius * 4)
			Embers:SetEndLength(0)
			Embers:SetRoll(math.Rand(0, 360))
			Embers:SetRollDelta(math.Rand(-0.2, 0.2))
			Embers:SetAirResistance(20)
			Embers:SetColor(200, 200, 200)
		end
	end

	sound.Play("ambient/explosions/explode_9.wav", self.Origin, math.Clamp(Radius * 25, 75, 165), math.Clamp(300 - Radius * 22, 15, 255))
	sound.Play("ambient/explosions/explode_4.wav", self.Origin, math.Clamp(Radius * 20, 75, 165), math.Clamp(300 - Radius * 25, 15, 255))
end



function EFFECT:Airburst()
	local SmokeColor = self.Color
	local Emitter = self.Emitter
	local Origin = self.Origin
	local Radius = self.Radius
	local Mult = self.ParticleMul

	self:Core(self.DirVec)
	for _ = 0, 3 * Radius * Mult do
	local EF = self.Emitter:Add("effects/muzzleflash" .. math.random(1, 4), Origin )
		if (EF) then
			EF:SetVelocity( self.DirVec * 100 )
			EF:SetAirResistance( 200 )
			EF:SetDieTime(0.2 * Radius)
			EF:SetStartAlpha( 255 )
			EF:SetEndAlpha( 0 )
			EF:SetStartSize(50 * Radius)
			EF:SetEndSize( 0 )
			EF:SetRoll(800)
			EF:SetRollDelta( math.random(-1, 1) )
			EF:SetColor(255,255,255)
		end
	end
	local EI = 20 * Radius * Mult
	for E = 0, EI do
	local EF = self.Emitter:Add("effects/muzzleflash" .. math.random(1, 4), Origin )
		if (EF) then
			EF:SetVelocity( self.DirVec * (EI - E) * 60)
			EF:SetAirResistance(100)
			EF:SetDieTime(0.2)
			EF:SetStartAlpha( 255 )
			EF:SetEndAlpha( 0 )
			EF:SetStartSize(E * 2)
			EF:SetEndSize( 0 )
			EF:SetRoll(800)
			EF:SetRollDelta( math.random(-1, 1) )
			EF:SetColor(255,255,255)
		end
	end
	EI = 10 * Radius * Mult
	for E = 0, EI do
	local EF = self.Emitter:Add("effects/muzzleflash" .. math.random(1, 4), Origin )
		if (EF) then
			EF:SetVelocity( self.DirVec * (EI - E) * -40)
			EF:SetAirResistance(400)
			EF:SetDieTime(0.2)
			EF:SetStartAlpha( 255 )
			EF:SetEndAlpha( 0 )
			EF:SetStartSize(E * 4)
			EF:SetEndSize( 0 )
			EF:SetRoll(800)
			EF:SetRollDelta( math.random(-1, 1) )
			EF:SetColor(255,255,255)
		end
	end
	local Angle = self.DirVec:Angle()
	for _ = 0, 50 * Radius * Mult do
		Angle:RotateAroundAxis(Angle:Forward(), 360 / 30)
		local EF = self.Emitter:Add( "particle/smokesprites_000" .. math.random(1, 9), Origin )
		if (EF) then
		EF:SetVelocity( Angle:Up() * 300 * Radius )
		EF:SetDieTime(0.2 * Radius)
		EF:SetStartAlpha( 50)
		EF:SetEndAlpha( 0 )
		EF:SetStartSize( 20 * Radius )
		EF:SetEndSize( 10 * Radius )
		EF:SetRoll( math.random(0, 360) )
		EF:SetRollDelta( math.random(-1, 1) )	
		EF:SetAirResistance( 400 )
		EF:SetGravity(Vector(math.random(-10, 10) * Radius, math.random(-10, 10) * Radius, 20))
		EF:SetColor(SmokeColor.x, SmokeColor.y, SmokeColor.z)
		end
	end

	for _ = 0, 5 * Radius * Mult do
		local AirBurst = Emitter:Add("particle/smokesprites_000" .. math.random(1, 9), Origin)
		if AirBurst then
			AirBurst:SetVelocity(VectorRand(-100, 100) * Radius)
			AirBurst:SetLifeTime(0)
			AirBurst:SetDieTime(math.Rand(0.1, 0.5) * Radius)
			AirBurst:SetStartAlpha(math.Rand(100, 255))
			AirBurst:SetEndAlpha(0)
			AirBurst:SetStartSize(6 * Radius)
			AirBurst:SetEndSize(35 * Radius)
			AirBurst:SetRoll(math.Rand(150, 360))
			AirBurst:SetRollDelta(math.Rand(-0.2, 0.2))
			AirBurst:SetAirResistance(200)
			AirBurst:SetGravity(Vector(math.random(-10, 10) * Radius, math.random(-10, 10) * Radius, 20))
			AirBurst:SetColor(SmokeColor.x, SmokeColor.y, SmokeColor.z)
		end
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
