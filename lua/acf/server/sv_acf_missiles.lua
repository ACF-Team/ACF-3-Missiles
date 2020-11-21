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

ACF.MaxDamageInaccuracy = 1000

ACFM.DefaultRadarSound = "buttons/button16.wav"

resource.AddWorkshop("403587498")

local AmmoTypes = ACF.Classes.AmmoTypes

local function ResetDefault(BulletData)
	if not BulletData.MuzzleVel then return end

	BulletData.Flight:Normalize()
	BulletData.Flight = BulletData.Flight * (BulletData.MuzzleVel * 39.37)
end

local function ResetHEAT(BulletData)
	if not BulletData.Detonated then return ResetDefault(BulletData) end
	if not BulletData.MuzzleVel then return end

	local PenMul = BulletData.PenMul or ACF_GetGunValue(BulletData, "PenMul") or 1

	if not BulletData.SlugMV then -- heat needs to calculate slug mv on the fly
		BulletData.SlugMV = AmmoTypes.HEAT:CalcSlugMV(BulletData, BulletData.FillerMass)
	end

	BulletData.Flight:Normalize()
	BulletData.Flight = BulletData.Flight * (BulletData.SlugMV * PenMul) * 39.37
	BulletData.NotFirstPen = false
end

-- Resets the velocity of the bullet based on its current state on the serverside only.
-- This will de-sync the clientside effect!
function ACF.ResetBulletVelocity(BulletData)
	if BulletData.Type == "HEAT" then
		return ResetHEAT(BulletData)
	end

	ResetDefault(BulletData)
end

ACFM_ResetVelocity = ACF.ResetBulletVelocity

function ACF.DoReplicatedPropHit(Entity, Bullet)
	local FlightRes = { Entity = Entity, HitNormal = Bullet.Flight, HitPos = Bullet.Pos }
	local Ammo  = AmmoTypes[Bullet.Type]
	local Index = Bullet.Index
	local Retry = Ammo:PropImpact(Index, Bullet, FlightRes.Entity, FlightRes.HitNormal, FlightRes.HitPos, FlightRes.HitGroup)				--If we hit stuff then send the resolution to the damage function

	if Retry == "Penetrated" then
		if Bullet.OnPenetrated then Bullet.OnPenetrated(Index, Bullet, FlightRes) end

		ACF.BulletClient(Index, Bullet, "Update", 2, FlightRes.HitPos)
		ACF.CalcBulletFlight(Index, Bullet, true)
	elseif Retry == "Ricochet" then
		if Bullet.OnRicocheted then Bullet.OnRicocheted(Index, Bullet, FlightRes) end

		ACF.BulletClient(Index, Bullet, "Update", 3, FlightRes.HitPos)
		ACF.CalcBulletFlight(Index, Bullet, true)
	else
		if Bullet.OnEndFlight then Bullet.OnEndFlight(Index, Bullet, FlightRes) end

		ACF.BulletClient(Index, Bullet, "Update", 1, FlightRes.HitPos)

		Ammo:OnFlightEnd(Index, Bullet, FlightRes.HitPos, FlightRes.HitNormal)
	end
end

timer.Simple(1, function()
	local Sounds = ACF.SoundToolSupport

	Sounds.acf_rack = {
			GetSound = function(ent) return { Sound = ent.SoundPath } end,

		SetSound = function(ent, soundData)
			ent.SoundPath = soundData.Sound
			ent:SetNWString("Sound", soundData.Sound)
		end,

		ResetSound = function(ent)
			local setSound = Sounds.acf_rack.SetSound

			setSound(ent, { Sound = ent.DefaultSound })
		end
	}

	Sounds.acf_radar = {
		GetSound = function(ent) return { Sound = ent.SoundPath } end,

		SetSound = function(ent, soundData)
			ent.SoundPath = soundData.Sound
			ent:SetNWString( "Sound", soundData.Sound )
		end,

		ResetSound = function(ent)
			local setSound = Sounds.acf_radar.SetSound

			setSound(ent, { Sound = ent.DefaultSound })
		end
	}
end)

do -- Entity find
	local LastThink = 0
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
				Ancestors[Entity] = nil
				Entities[Entity] = nil
			end)
		end
	end)

	hook.Add("Think", "ACF Entity Tracking", function()
		if not ACF.CurTime then return end -- ACF.CurTime undefined, aborting.

		local DeltaTime = ACF.CurTime - LastThink

		for K in pairs(Ancestors) do
			local Data = K.TrackData
			local Previous = Data.Position
			local PhysObj = K:GetPhysicsObject()
			local Current = IsValid(PhysObj) and K:LocalToWorld(PhysObj:GetMassCenter()) or K:GetPos()

			K.Position = Current
			K.Velocity = (Current - Previous) / DeltaTime

			Data.Previous = Previous
			Data.Position = Current
		end

		LastThink = ACF.CurTime
	end)

	local function GetAncestorEntities()
		if ACF.CurTime < NextUpdate then return Ancestors end

		local Checked = {}
		local Previous = {}

		-- Cleanup
		for K in pairs(Ancestors) do
			Ancestors[K] = nil
			Previous[K] = true
		end

		for K in pairs(Entities) do
			local Ancestor = ACF_GetAncestor(K)

			if IsValid(Ancestor) and Ancestor ~= K and not Checked[Ancestor] then
				Ancestors[Ancestor] = true
				Checked[Ancestor] = true

				if not Ancestor.TrackData then
					local PhysObj = Ancestor:GetPhysicsObject()
					local Position = IsValid(PhysObj) and PhysObj:GetMassCenter()

					Ancestor.TrackData = {
						Position = Position or Ancestor:GetPos()
					}
				end

				Previous[Ancestor] = nil
			end
		end

		for K in pairs(Previous) do K.TrackData = nil end

		NextUpdate = ACF.CurTime + math.Rand(3, 5)

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