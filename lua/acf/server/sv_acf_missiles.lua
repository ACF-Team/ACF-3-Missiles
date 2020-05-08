--[[
			  _____ ______   __  __ _         _ _
		/\   / ____|  ____| |  \/  (_)       (_) |
	   /  \ | |    | |__    | \  / |_ ___ ___ _| | ___  ___
	  / /\ \| |    |  __|   | |\/| | / __/ __| | |/ _ \/ __|
	 / ____ \ |____| |      | |  | | \__ \__ \ | |  __/\__ \
	/_/    \_\_____|_|      |_|  |_|_|___/___/_|_|\___||___/

	By Bubbus + Cre8or

	A reimplementation of XCF missiles and bombs, with guidance and more.

]]

ACF.ActiveMissiles = ACF.ActiveMissiles or {}
ACF.ActiveRadars = ACF.ActiveRadars or {}

ACF.MaxDamageInaccuracy = 250

ACFM.DefaultRadarSound = "buttons/button16.wav"

local cvarGrav = GetConVar("sv_gravity")

function ACFM_BulletLaunch(BData)
	ACF.CurBulletIndex = ACF.CurBulletIndex + 1        --Increment the index
	if ACF.CurBulletIndex > ACF.BulletIndexLimit then
		ACF.CurBulletIndex = 1
	end

	BData.Accel = Vector(0, 0, cvarGrav:GetInt() * -1)            --Those are BData settings that are global and shouldn't change round to round
	BData.LastThink = BData.LastThink or CurTime()
	BData["FlightTime"] = 0

	if BData["FuzeLength"] then
		BData["InitTime"] = CurTime()
	end

	if not BData.TraceBackComp then                                            --Check the Gun's velocity and add a modifier to the flighttime so the traceback system doesn't hit the originating contraption if it's moving along the shell path
		if IsValid(BData.Gun) then
			BData["TraceBackComp"] = BData.Gun:GetPhysicsObject():GetVelocity():Dot(BData.Flight:GetNormalized())
		else
			BData["TraceBackComp"] = 0
		end
	end

	BData.Filter = BData.Filter or { BData["Gun"] }

	if XCF and XCF.Ballistics then
		BData = XCF.Ballistics.Launch(BData)
		--XCF.Ballistics.CalcFlight( BulletData.Index, BulletData )
	else
		BData.Index = ACF.CurBulletIndex
		ACF.Bullet[ACF.CurBulletIndex] = BData        --Place the bullet at the current index pos
		ACF_BulletClient( ACF.CurBulletIndex, ACF.Bullet[ACF.CurBulletIndex], "Init" , 0 )
		--ACF_CalcBulletFlight( ACF.CurBulletIndex, ACF.Bullet[ACF.CurBulletIndex] )
	end

end




function ACFM_ExpandBulletData(bullet)

	-- print("==== ACFM_ExpandBulletData")
	-- pbn(bullet)


	local toconvert = {}
	toconvert["Id"] =             bullet["Id"] or "12.7mmMG"
	toconvert["Type"] =         bullet["Type"] or "AP"
	toconvert["PropLength"] =     bullet["PropLength"] or 0
	toconvert["ProjLength"] =     bullet["ProjLength"] or 0
	toconvert["Data5"] =         bullet["FillerVol"] or bullet["Flechettes"] or bullet["Data5"] or 0
	toconvert["Data6"] =         bullet["ConeAng"] or bullet["FlechetteSpread"] or bullet["Data6"] or 0
	toconvert["Data7"] =         bullet["Data7"] or 0
	toconvert["Data8"] =         bullet["Data8"] or 0
	toconvert["Data9"] =         bullet["Data9"] or 0
	toconvert["Data10"] =         bullet["Tracer"] or bullet["Data10"] or 0
	toconvert["Colour"] =         bullet["Colour"] or Color(255, 255, 255)


	local rounddef = ACF.RoundTypes[bullet.Type] or error("No definition for the shell-type", bullet.Type)
	local conversion = rounddef.convert

	if not conversion then error("No conversion available for this shell!") end
	local ret = conversion( nil, toconvert )

	ret.Pos = bullet.Pos or Vector()
	ret.Flight = bullet.Flight or Vector()
	ret.Type = ret.Type or bullet.Type

	ret.Accel = Vector(0, 0, cvarGrav:GetInt() * -1)
	if ret.Tracer == 0 and bullet["Tracer"] and bullet["Tracer"] > 0 then ret.Tracer = bullet["Tracer"] end
	ret.Colour = toconvert["Colour"]

	ret.Sound = bullet.Sound

	return ret
end

function ACFM_MakeCrateForBullet(self, bullet)
	if not istable(bullet) and bullet.BulletData then
		self:SetNWString("Sound", bullet.Sound or (bullet.Primary and bullet.Primary.Sound))
		self.Owner = bullet:GetOwner()
		self:SetOwner(bullet:GetOwner())
		bullet = bullet.BulletData
	end

	self:SetNWInt( "Caliber", bullet.Caliber or 10)
	self:SetNWInt( "ProjMass", bullet.ProjMass or 10)
	self:SetNWInt( "FillerMass", bullet.FillerMass or 0)
	self:SetNWInt( "DragCoef", bullet.DragCoef or 1)
	self:SetNWString( "AmmoType", bullet.Type or "AP")
	self:SetNWInt( "Tracer" , bullet.Tracer or 0)
	local col = bullet.Colour or self:GetColor()
	self:SetNWVector( "Color" , Vector(col.r, col.g, col.b))
	self:SetNWVector( "TracerColour" , Vector(col.r, col.g, col.b))
	self:SetColor(col)
end

-- TODO: modify ACF to use this global table, so any future tweaks won't break anything here.
ACF.FillerDensity = {
	SM =    2000,
	HE =    1000,
	HP =    1,
	HEAT =  1450,
	APHE =  1000
}

function ACFM_CompactBulletData(crate)
	local compact = {
		Id = crate.RoundId or crate.Id,
		Type = crate.RoundType or crate.Type,
		PropLength = crate.PropLength or crate.RoundPropellant,
		ProjLength = crate.ProjLength or crate.RoundProjectile,
		Data5 = crate.Data5 or crate.RoundData5 or crate.FillerVol or crate.CavVol or crate.Flechettes,
		Data6 = crate.Data6 or crate.RoundData6 or crate.ConeAng or crate.FlechetteSpread,
		Data7 = crate.Data7 or crate.RoundData7,
		Data8 = crate.Data8 or crate.RoundData8,
		Data9 = crate.Data9 or crate.RoundData9,
		Data10 = crate.Data10 or crate.RoundData10 or crate.Tracer,
		Colour = crate.GetColor and crate:GetColor() or crate.Colour,
		Sound = crate.Sound,
	}

	if not compact.Data5 and crate.FillerMass then
		local Filler = ACF.FillerDensity[compact.Type]

		if Filler then
			compact.Data5 = crate.FillerMass / ACF.HEDensity * Filler
		end
	end

	return compact
end

local ResetVelocity = {}

function ResetVelocity.AP(bdata)
	if not bdata.MuzzleVel then return end

	bdata.Flight:Normalize()
	bdata.Flight = bdata.Flight * (bdata.MuzzleVel * 39.37)
end

ResetVelocity.HE = ResetVelocity.AP
ResetVelocity.HP = ResetVelocity.AP
ResetVelocity.FL = ResetVelocity.AP
ResetVelocity.SM = ResetVelocity.AP
ResetVelocity.APHE = ResetVelocity.AP

function ResetVelocity.HEAT(bdata)
	if not bdata.Detonated then return ResetVelocity.AP(bdata) end
	if not bdata.MuzzleVel then return end

	if not bdata.SlugMV then -- heat needs to calculate slug mv on the fly
		bdata.SlugMV = ACF.RoundTypes["HEAT"].CalcSlugMV( bdata, bdata.FillerMass )
	end

	bdata.Flight:Normalize()

	local penmul = bdata.penmul or ACF_GetGunValue(bdata, "penmul") or 1

	bdata.Flight = bdata.Flight * (bdata.SlugMV * penmul) * 39.37
	bdata.NotFirstPen = false
end

-- Resets the velocity of the bullet based on its current state on the serverside only.
-- This will de-sync the clientside effect!
function ACFM_ResetVelocity(bdata)
	local resetFunc = ResetVelocity[bdata.Type]

	if not resetFunc then return end

	return resetFunc(bdata)
end

hook.Add("InitPostEntity", "ACFMissiles_AddSoundSupport", function()
	timer.Simple(1, function()

		ACF.SoundToolSupport["acf_rack"] = {
			GetSound = function(ent) return { Sound = ent.SoundPath } end,

			SetSound = function(ent, soundData)
				ent.SoundPath = soundData.Sound
				ent:SetNWString("Sound", soundData.Sound)
			end,

			ResetSound = function(ent)
				local Class = ent.Class
				local Classes = ACF.Classes

				local soundData = { Sound = Classes.GunClass[Class].sound }

				local setSound = ACF.SoundToolSupport["acf_gun"].SetSound

				setSound(ent, soundData)
			end
		}

		ACF.SoundToolSupport["acf_radar"] = {
			GetSound = function(ent) return {Sound = ent.Sound} end,

			SetSound = function(ent, soundData)
				ent.Sound = soundData.Sound
				ent:SetNWString( "Sound", soundData.Sound )
			end,

			ResetSound = function(ent)
				local soundData = { Sound = ACFM.DefaultRadarSound }

				local setSound = ACF.SoundToolSupport["acf_gun"].SetSound
				setSound( ent, soundData )
			end
		}
	end)
end)

do -- Entity find
	local NextUpdate = 0
	local Entities = {}
	local Ancestors = {}
	local Whitelist = {
		prop_physics                = true,
		gmod_wheel                  = true,
		gmod_hoverball              = true,
		gmod_wire_expression2       = true,
		gmod_wire_thruster          = true,
		gmod_thruster               = true,
		gmod_wire_light             = true,
		gmod_light                  = true,
		gmod_emitter                = true,
		gmod_button                 = true,
		phys_magnet                 = true,
		prop_vehicle_jeep           = true,
		prop_vehicle_airboat        = true,
		prop_vehicle_prisoner_pod   = true,
		acf_engine                  = true,
		acf_ammo                    = true,
		acf_gun                     = true,
		acf_gearbox                 = true,
		acf_opticalcomputer			= true,
	}

	hook.Add("OnEntityCreated", "ACF Entity Tracking", function(Entity)
		if IsValid(Entity) and Whitelist[Entity:GetClass()] then
			Entities[Entity] = true

			Entity:CallOnRemove("ACF Entity Tracking", function()
				Entities[Entity] = nil
			end)
		end
	end)

	local function GetAncestorEntities()
		if CurTime() < NextUpdate then return Ancestors end

		local Checked = {}
		local Ancestor

		-- Cleanup
		for K in pairs(Ancestors) do Ancestors[K] = nil end

		for K in pairs(Entities) do
			Ancestor = ACF_GetAncestor(K)

			if IsValid(Ancestor) and Ancestor ~= K and not Checked[Ancestor] then
				Ancestors[Ancestor] = true
				Checked[Ancestor] = true
			end
		end

		NextUpdate = CurTime() + 2

		return Ancestors
	end

	function ACF.GetEntitiesInCone(Position, Direction, Degrees)
		local Result = {}

		for Entity in pairs(GetAncestorEntities()) do
			if not IsValid(Entity) then continue end

			if ACFM_ConeContainsPos(Position, Direction, Degrees, Entity:GetPos()) then
				Result[Entity] = true
			end
		end

		return Result
	end

	function ACF.GetEntitiesInSphere(Position, Radius)
		local Result = {}
		local RadiusSqr = Radius * Radius

		for Entity in pairs(GetAncestorEntities()) do
			if not IsValid(Entity) then continue end

			if Position:DistToSqr(Entity:GetPos()) <= RadiusSqr then
				Result[Entity] = true
			end
		end

		return Result
	end
end