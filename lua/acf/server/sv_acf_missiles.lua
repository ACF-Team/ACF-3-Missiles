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

hook.Add("InitPostEntity", "ACFMissiles_AddSoundSupport", function()
	timer.Simple(1, function()
		ACF.SoundToolSupport.acf_rack = {
			GetSound = function(ent) return { Sound = ent.SoundPath } end,

			SetSound = function(ent, soundData)
				ent.SoundPath = soundData.Sound
				ent:SetNWString("Sound", soundData.Sound)
			end,

			ResetSound = function(ent)
				local setSound = ACF.SoundToolSupport.acf_rack.SetSound

				setSound(ent, { Sound = ent.DefaultSound })
			end
		}

		ACF.SoundToolSupport.acf_radar = {
			GetSound = function(ent) return {Sound = ent.Sound} end,

			SetSound = function(ent, soundData)
				ent.Sound = soundData.Sound
				ent:SetNWString( "Sound", soundData.Sound )
			end,

			ResetSound = function(ent)
				local soundData = { Sound = ACFM.DefaultRadarSound }

				local setSound = ACF.SoundToolSupport.acf_radar.SetSound
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