AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


function ENT:Initialize()
	if self.BulletData.Caliber == 12.0 then
		self:SetModel( "models/missiles/glatgm/9m112.mdl" )
	elseif self.BulletData.Caliber > 12.0 then
		self:SetModel( "models/missiles/glatgm/mgm51.mdl" )
	else
		self:SetModel( "models/missiles/glatgm/9m117.mdl" )
		self:SetModelScale(self.BulletData.Caliber * 10 / 100, 0)
	end

	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetUseType(SIMPLE_USE);
	self:SetSolid(SOLID_VPHYSICS);
	self:SetCollisionGroup( COLLISION_GROUP_WORLD ) -- DISABLES collisions with players/props

	self.PhysObj = self:GetPhysicsObject()
	self.PhysObj:EnableGravity( false )
	self.PhysObj:EnableMotion( false )

	timer.Simple(0.1,function()
		self:SetCollisionGroup( COLLISION_GROUP_NONE ) -- ENABLES collisions with players/props

		ParticleEffectAttach("Rocket Motor GLATGM",4, self,1)
	end )

	self.KillTime = CurTime() + 20
	self.Time = CurTime()
	self.Filter = {self, self.Guidance}

	for _, v in pairs( ents.FindInSphere( self.Guidance:GetPos(), 250 )   ) do
		if v:GetClass() == "acf_opticalcomputer" and (not v.CPPIGetOwner or v:CPPIGetOwner() == self.Owner) then
			self.Guidance = v
			self.Optic = true
			break
		end
	end

	self.velocity = 170 		--velocity of missile per second in ACF meters (Hu/39.37)
	self.secondsOffset = 0.08	--seconds of forward flight to aim towards, to affect the beam-riding simulation
	self.InnacV = 0
	local Caliber = self.BulletData.Caliber
	self.Sub = Caliber < 10 -- is it a small glatgm?
	self.SpiralC = 0
	self.SpiralAm = (10-Caliber) * 0.2 -- amount of artifical spiraling for <100 shells, caliber in acf is in cm
	if self.Sub then
		self.velocity = 72
		self.secondsOffset = 0.1
	end
	self.velocity = self.velocity * 39.37
	self.offsetLength = self.velocity * self.secondsOffset	--how far off the forward offset is for the targeting position
	self.GuideDelay = CurTime() + self.secondsOffset * 3.2
end

function ENT:Think()
	if IsValid(self) then
		if self.KillTime < CurTime() then
			self:Detonate()
		end
		local dt = CurTime() - self.Time --timestep
		self.Time = CurTime()
		local InnacDT = self.InnacV * dt
		local dir = AngleRand() * 0.0002 * InnacDT
		local Correction = VectorRand()  * 0.0007 * InnacDT
		local GD = self.GuideDelay < self.Time
		if GD then
			self.InnacV = self.InnacV + 1 --inaccuracy when not guided bloom
			if IsValid(self.Guidance) and self.Guidance:GetPos():Distance(self:GetPos()) < self.Distance then
				local acosc = math.acos((self:GetPos() - self.Guidance:GetPos()):GetNormalized():Dot(self.Guidance:GetForward())) --switch to acos as it's cheaper than comparing 4 angle values

				if acosc < 0.785398 then
					local glpos = self.Guidance:GetPos() + self.Guidance:GetForward()
					if not self.Optic then
						glpos = self.Guidance:GetAttachment(1).Pos + self.Guidance:GetForward() * 20
					end
					local tr = util.QuickTrace( glpos, self.Guidance:GetForward() * 68000, {self.Guidance,self})
					local thp = tr.HitPos
					if thp:Distance(self:GetPos()) > (self.offsetLength * 2) then --Missile will beam ride until it is close enough, then it will use hitpos of the guidance trace.
						tr = util.QuickTrace( glpos, self.Guidance:GetForward() * (self.Guidance:GetPos():Distance(self:GetPos()) + self.offsetLength), {self.Guidance, self})
						thp = tr.HitPos
					end
					acosc = math.acos((thp - self:GetPos()):GetNormalized():Dot(self:GetForward())) --acos also added to missile so it doesn't have 360 vision
					if acosc < 0.41179 then
						self.InnacV = 0
						dir = self:WorldToLocalAngles(self.Guidance:GetAngles() ) * dt * self.velocity * 0.007
						Correction = self:WorldToLocal(self.Guidance:GetPos()) * dt
					end
				end
			end
		end
		local Spiral = 0
		if self.Sub or self.InnacV > 0 and GD then
			Spiral = self.SpiralAm + math.random(-self.SpiralAm * 0.25, self.SpiralAm) --Spaghett
			self.SpiralC = self.SpiralC + Spiral * dt * 411
			self:SetAngles(self:LocalToWorldAngles(dir + Angle(0, 0, self.SpiralC)))
			Correction = Vector(0,(self:WorldToLocal(self.Guidance:GetPos()) * dt * 0.5).y,Correction.z)
		else
			self:SetAngles(self:LocalToWorldAngles(dir))
		end
		local tr = util.TraceHull( {
			start = self:GetPos(),
			endpos = self:LocalToWorld(Vector(self.velocity * dt + 200,Correction.y,Correction.z)),
			filter = self.Filter,
			mins = Vector(),
			maxs = Vector(),
			mask = MASK_SOLID
		} )
		self:SetPos(tr.HitPos - self:GetForward() * 200)
		if tr.Hit then
			self:Detonate()
		end
		self:NextThink( CurTime() + 0.01 )
		return true
	end
end

function ENT:Detonate()
	if IsValid(self) and not self.Detonated then
		self.Detonated = true

		BulletData = table.Copy(self.BulletData)
		BulletData.Type			= "HEAT"
		BulletData.Filter		= { self }
		BulletData.FlightTime	= 0
		BulletData.Gun			= self
		BulletData.LimitVel		= 100
		BulletData.Flight		= self:GetForward():GetNormalized() * self.velocity -- initial vel from glatgm
		BulletData.FuseLength	= 0
		BulletData.Pos			= self:GetPos()

		-- manual detonation
		BulletData.Detonated	= true
		BulletData.InitTime		= CurTime()
		BulletData.Flight		= BulletData.Flight + BulletData.Flight:GetNormalized() * BulletData.SlugMV * 39.37
		BulletData.FuseLength	= 0.005 + 40 / ((BulletData.Flight + BulletData.Flight:GetNormalized() * BulletData.SlugMV * 39.37):Length() * 0.0254)
		BulletData.DragCoef		= BulletData.SlugDragCoef
		BulletData.ProjMass		= BulletData.SlugMass
		BulletData.Caliber		= BulletData.SlugCaliber
		BulletData.PenArea		= BulletData.SlugPenArea
		BulletData.Ricochet		= BulletData.SlugRicochet

		self.FakeCrate = ents.Create("acf_fakecrate2")
		self.FakeCrate:RegisterTo(BulletData)
		self:DeleteOnRemove(self.FakeCrate)

		BulletData.Crate = self.FakeCrate:EntIndex()

		ACF.RoundTypes[BulletData.Type].create(self, BulletData)

		local _, _, BoomFillerMass = ACF.RoundTypes.HEAT.CrushCalc(self.velocity * 0.0254, self.BulletData.FillerMass)
		local Effect = EffectData()
		Effect:SetOrigin(self:GetPos())
		Effect:SetNormal(self:GetForward())
		Effect:SetScale(math.max(BoomFillerMass ^ 0.33 * 3 * 39.37, 1))
		Effect:SetRadius(self.BulletData.Caliber)

		util.Effect("acf_glatgmexplosion", Effect)

		ACF_HE(BulletData.Pos, BulletData.BoomFillerMass , BulletData.CasingMass , BulletData.Owner, BulletData.Filter, BulletData.Gun)

		self:Remove()
	end
end
