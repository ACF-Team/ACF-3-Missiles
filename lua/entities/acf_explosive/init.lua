
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include("shared.lua")

function ENT:Initialize()
	self.BulletData = self.BulletData or {}
	self.ShouldTrace = false

	self.Inputs = WireLib.CreateInputs( self, { "Detonate" } )
	self.Outputs = WireLib.CreateOutputs( self, {} )

	self.ThinkDelay = 0.1

	self.TraceFilter = {self}
end

local nullhit = {Damage = 0, Overkill = 1, Loss = 0, Kill = false}

function ENT:ACF_OnDamage( Entity , Energy , FrArea , Angle , Inflictor )
	self.ACF.Armour = 0.1

	local HitRes = ACF.PropDamage( Entity , Energy , FrArea , Angle , Inflictor )	--Calling the standard damage prop function

	if self.Detonated or self.DisableDamage then return table.Copy(nullhit) end

	local CanDo = hook.Run("ACF_AmmoExplode", self, self.BulletData )
	if CanDo == false then return table.Copy(nullhit) end

	HitRes.Kill = false
	self:Detonate()

	return table.Copy(nullhit) --This function needs to return HitRes
end

function ENT:TriggerInput( inp, value )
	if inp == "Detonate" and value ~= 0 then
		self:Detonate()
	end
end

function MakeACF_Explosive(Owner, Pos, Angle, Data1, Data2, Data3, Data4, Data5, Data6, Data7, Data8, Data9, Data10, Mdl)
	if not Owner:CheckLimit("_acf_explosive") then return false end

	local Bomb = ents.Create("acf_explosive")

	if not IsValid(Bomb) then return false end

	Bomb:SetAngles(Angle)
	Bomb:SetPos(Pos)
	Bomb:Spawn()
	Bomb:SetPlayer(Owner)

	if CPPI then
		Bomb:CPPISetOwner(Owner)
	end

	Bomb.Owner = Owner

	Mdl = Mdl or ACF.Weapons.Guns[Id].model

	Bomb.Id = Id
	Bomb:CreateBomb(Data1, Data2, Data3, Data4, Data5, Data6, Data7, Data8, Data9, Data10, Mdl)

	Owner:AddCount( "_acf_explosive", Bomb )
	Owner:AddCleanup( "acfmenu", Bomb )

	return Bomb
end

list.Set( "ACFCvars", "acf_explosive", {"id", "data1", "data2", "data3", "data4", "data5", "data6", "data7", "data8", "data9", "data10", "mdl"} )
duplicator.RegisterEntityClass("acf_explosive", MakeACF_Explosive, "Pos", "Angle", "RoundId", "RoundType", "RoundPropellant", "RoundProjectile", "RoundData5", "RoundData6", "RoundData7", "RoundData8", "RoundData9", "RoundData10", "Model" )

function ENT:CreateBomb(Data1, Data2, Data3, Data4, Data5, Data6, Data7, Data8, Data9, Data10, Mdl, bdata)
	self:SetModelEasy(Mdl)
	--Data 1 to 4 are should always be Round ID, Round Type, Propellant lenght, Projectile lenght
	self.RoundId 	= Data1		--Weapon this round loads into, ie 140mmC, 105mmH ...
	self.RoundType 	= Data2		--Type of round, IE AP, HE, HEAT ...
	self.RoundPropellant = Data3--Lenght of propellant
	self.RoundProjectile = Data4--Lenght of the projectile
	self.RoundData5 = ( Data5 or 0 )
	self.RoundData6 = ( Data6 or 0 )
	self.RoundData7 = ( Data7 or 0 )
	self.RoundData8 = ( Data8 or 0 )
	self.RoundData9 = ( Data9 or 0 )
	self.RoundData10 = ( Data10 or 0 )

	local PlayerData = bdata or ACFM_CompactBulletData(self)

	self:ConfigBulletDataShortForm(PlayerData)
end

function ENT:SetModelEasy(mdl)
	local curMdl = self:GetModel()

	if not mdl or curMdl == mdl then
		self.Model = self:GetModel()
		return
	end

	self:SetModel( mdl )
	self.Model = mdl

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup( COLLISION_GROUP_WORLD )

	local phys = self:GetPhysicsObject()

	if IsValid(phys) then
		phys:Wake()
		phys:EnableMotion(true)
		phys:SetMass( 10 )
	end
end

function ENT:SetBulletData(bdata)
	if not (bdata.IsShortForm or bdata.Data5) then error("acf_explosive requires short-form bullet-data but was given expanded bullet-data.") end

	bdata = ACFM_CompactBulletData(bdata)

	self:CreateBomb(
		bdata.Data1 or bdata.Id,
		bdata.Type or bdata.Data2,
		bdata.PropLength or bdata.Data3,
		bdata.ProjLength or bdata.Data4,
		bdata.Data5,
		bdata.Data6,
		bdata.Data7,
		bdata.Data8,
		bdata.Data9,
		bdata.Data10,
		nil,
		bdata
	)

	self:ConfigBulletDataShortForm(bdata)
end

function ENT:ConfigBulletDataShortForm(bdata)
	bdata = ACFM_ExpandBulletData(bdata)

	self.BulletData = bdata
	self.BulletData.Entity = self
	self.BulletData.Crate = self:EntIndex()
	self.BulletData.Owner = self.BulletData.Owner or self.Owner

	local phys = self:GetPhysicsObject()

	if IsValid(phys) then
		phys:SetMass( bdata.ProjMass or bdata.RoundMass or bdata.Mass or 10 )
	end

	self:RefreshClientInfo()
end

function ENT:TraceFunction()
	local pos = self:GetPos()

	local trace = {
		start = pos,
		endpos = pos + self:GetVelocity() * self.ThinkDelay,
		filter = self.TraceFilter,
	}

	local res = util.TraceEntity(trace, self)

	if res.Hit then
		self:OnTraceContact(res)
	end
end

function ENT:Think()
	if self.ShouldTrace then
		self:TraceFunction()
	end

	self:NextThink(CurTime() + self.ThinkDelay)

	return true
end

function ENT:Detonate(BulletData)
	if self.Detonated then return end

	self.Detonated = true

	if not BulletData then BulletData = self.BulletData end

	local PhysObj = self:GetPhysicsObject()

	if not BulletData.Flight then
		BulletData.Flight = IsValid(PhysObj) and PhysObj:GetVelocity() or Vector(0, 0, 1000)
	end

	timer.Simple(3, function()
		if not IsValid(self) then return end

		if IsValid(self.FakeCrate) then
			self.FakeCrate:Remove()
		end

		self:Remove()
	end)

	self:SetNoDraw(true)

	if not BulletData.Entity.Fuze.Cluster then
		BulletData.Owner = BulletData.Owner or self.Owner
		BulletData.Pos   = self:GetPos() + (self.DetonateOffset or BulletData.Flight:GetNormalized())
		BulletData.NoOcc = self
		BulletData.Gun	 = self

		debugoverlay.Line(BulletData.Pos, BulletData.Pos + BulletData.Flight, 10, Color(255, 128, 0))

		if BulletData.Filter then BulletData.Filter[#BulletData.Filter + 1] = self
		else BulletData.Filter = {self} end

		BulletData.RoundMass = BulletData.RoundMass or BulletData.ProjMass
		BulletData.ProjMass = BulletData.ProjMass or BulletData.RoundMass

		function BulletData.OnPenetrated(_, Bullet)
			ACFM_ResetVelocity(Bullet)
		end

		function BulletData.OnRicocheted(_, Bullet)
			ACFM_ResetVelocity(Bullet)
		end

		local Bullet = ACF_CreateBullet(BulletData)

		self:SetNotSolid(true)

		if IsValid(PhysObj) then
			PhysObj:EnableMotion(false)
		end

		self:DoReplicatedPropHit(Bullet)
	else
		self:ClusterNew(BulletData)
	end
end

function ENT:ClusterNew(bdata)
	local Bomblets = math.Clamp(math.Round(bdata.FillerMass * 0.5),3,30)
	local MuzzleVec = self:GetForward()

	if bdata.Type == "HEAT" then
		Bomblets = math.Clamp(Bomblets,3,25)
	end

	self.BulletData = {}

	self.BulletData["Accel"]			= Vector(0,0,-600)
	self.BulletData["Caliber"]			= math.Clamp(bdata.Caliber / Bomblets * 10,0.05,bdata.Caliber * 0.8) --Controls visual size, does nothing else
	self.BulletData["Crate"]			= bdata.Crate
	self.BulletData["DragCoef"]			= bdata.DragCoef / Bomblets / 2
	self.BulletData["FillerMass"]		= bdata.FillerMass / Bomblets --/2
	self.BulletData["Filter"]			= self
	self.BulletData["Flight"]			= bdata.Flight
	self.BulletData["FlightTime"]		= 0
	self.BulletData["FrArea"]			= bdata.FrArea
	self.BulletData["FuzeLength"]		= 0
	self.BulletData["Gun"]				= self
	self.BulletData["Id"]				= bdata.Id
	--self.BulletData["Index"]			=
	self.BulletData["KETransfert"]		= bdata.KETransfert
	self.BulletData["LimitVel"]			= 700
	self.BulletData["MuzzleVel"]		= bdata.MuzzleVel * 20
	self.BulletData["Owner"]			= bdata.Owner
	self.BulletData["PenArea"]			= bdata.PenArea
	self.BulletData["Pos"]				= bdata.Pos
	self.BulletData["ProjLength"]		= bdata.ProjLength / Bomblets / 2
	self.BulletData["ProjMass"]			= bdata.ProjMass / Bomblets / 2
	self.BulletData["PropLength"]		= bdata.PropLength
	self.BulletData["PropMass"]			= bdata.PropMass
	self.BulletData["Ricochet"]			= bdata.Ricochet
	self.BulletData["RoundVolume"]		= bdata.RoundVolume
	self.BulletData["ShovePower"]		= bdata.ShovePower
	self.BulletData["Tracer"]			= 0

	if bdata.Type ~= "HEAT" and bdata.Type ~= "AP" and bdata.Type ~= "SM" and bdata.Type ~= "HE" and bdata.Type ~= "APHE" then
		self.BulletData["Type"]			= "AP"
	else
		self.BulletData["Type"]			= bdata.Type
	end

	if self.BulletData.Type == "HEAT" then
		self.BulletData["SlugMass"]			= bdata.SlugMass / (Bomblets / 6)
		self.BulletData["SlugCaliber"]		= bdata.SlugCaliber / (Bomblets / 6)
		self.BulletData["SlugDragCoef"]		= bdata.SlugDragCoef / (Bomblets / 6)
		self.BulletData["SlugMV"]			= bdata.SlugMV / (Bomblets / 6)
		self.BulletData["SlugPenArea"]		= bdata.SlugPenArea / (Bomblets / 6)
		self.BulletData["SlugRicochet"]		= bdata.SlugRicochet
		self.BulletData["ConeVol"] 			= bdata.SlugMass * 1000 / 7.9 / (Bomblets / 6)
		self.BulletData["CasingMass"] 		= self.BulletData.ProjMass + self.BulletData.FillerMass + (self.BulletData.ConeVol * 1000 / 7.9)
		self.BulletData["BoomFillerMass"]	= self.BulletData.FillerMass / 1.5
	end

	self.FakeCrate = ents.Create("acf_fakecrate2")
	self.FakeCrate:RegisterTo(self.BulletData)

	self.BulletData["Crate"] = self.FakeCrate:EntIndex()

	local Effect = EffectData()
	Effect:SetOrigin(self:GetPos())
	Effect:SetNormal(self:GetForward())
	Effect:SetScale(math.max(self.BulletData.FillerMass ^ 0.33 * 8 * 39.37 * 2, 1))
	Effect:SetRadius(self.BulletData.Caliber)

	util.Effect("ACF_Explosion", Effect)

	for I = 1,Bomblets do
		timer.Simple(0.01 * I,function()
			if IsValid(self) then
				local Spread = ((self:GetUp() * (2 * math.random() - 1)) + (self:GetRight() * (2 * math.random() - 1))) * (I - 1) / 40
				local MuzzlePos = self:LocalToWorld(Vector(100-(I * 20),((Bomblets / 2) - I) * 2, 0) * 0.5)

				self.BulletData["Flight"] = (MuzzleVec + (Spread * 2)):GetNormalized() * self.BulletData["MuzzleVel"] * 39.37 + bdata.Flight
				self.BulletData.Pos = MuzzlePos
				self.CreateShell = ACF.RoundTypes[self.BulletData.Type].create
				self:CreateShell( self.BulletData )
			end
		end)
	end
end

function ENT:CreateShell()
	--You overwrite this with your own function, defined in the ammo definition file
end

function ENT:DoReplicatedPropHit(Bullet)
	local FlightRes = { Entity = self, HitNormal = Bullet.Flight, HitPos = Bullet.Pos, HitGroup = HITGROUP_GENERIC }
	local Index = Bullet.Index

	local BulletPropImpact = ACF.RoundTypes[Bullet.Type].propimpact
	local Retry = BulletPropImpact(Index, Bullet, FlightRes.Entity, FlightRes.HitNormal, FlightRes.HitPos, FlightRes.HitGroup)				--If we hit stuff then send the resolution to the damage function

	if Retry == "Penetrated" then
		if Bullet.OnPenetrated then Bullet.OnPenetrated(Index, Bullet, FlightRes) end

		ACF_BulletClient(Index, Bullet, "Update", 2, FlightRes.HitPos)
		ACF_CalcBulletFlight(Index, Bullet, true)
	elseif Retry == "Ricochet" then
		if Bullet.OnRicocheted then Bullet.OnRicocheted(Index, Bullet, FlightRes) end

		ACF_BulletClient(Index, Bullet, "Update", 3, FlightRes.HitPos)
		ACF_CalcBulletFlight(Index, Bullet, true)
	else
		if Bullet.OnEndFlight then Bullet.OnEndFlight(Index, Bullet, FlightRes) end

		local BulletEndFlight = ACF.RoundTypes[Bullet.Type].endflight

		ACF_BulletClient(Index, Bullet, "Update", 1, FlightRes.HitPos)
		BulletEndFlight(Index, Bullet, FlightRes.HitPos, FlightRes.HitNormal)
	end
end

function ENT:OnTraceContact() end

function ENT:SetShouldTrace(bool)
	self.ShouldTrace = bool and true

	self:NextThink(CurTime())
end

function ENT:EnableClientInfo(bool)
	self.ClientInfo = bool
	self:SetNWBool("VisInfo", bool)

	if bool then
		self:RefreshClientInfo()
	end
end

function ENT:RefreshClientInfo()
	ACFM_MakeCrateForBullet(self, self.BulletData)
end
