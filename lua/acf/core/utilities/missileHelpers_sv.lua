local ACF       = ACF
local Classes   = ACF.Classes
local AmmoTypes = Classes.AmmoTypes

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
		local Ammo = AmmoTypes.Get("HEAT")

		BulletData.SlugMV = Ammo:CalcSlugMV(BulletData, BulletData.FillerMass)
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

function ACF.DoReplicatedPropHit(Entity, Bullet)
	local FlightRes = { Entity = Entity, HitNormal = Bullet.Flight, HitPos = Bullet.Pos, HitGroup = 0 }
	local Ammo  = AmmoTypes.Get(Bullet.Type)
	local Retry = Ammo:PropImpact(Bullet, FlightRes)

	if Retry == "Penetrated" then
		if Bullet.OnPenetrated then Bullet.OnPenetrated(Bullet, FlightRes) end

		ACF.BulletClient(Bullet, "Update", 2, FlightRes.HitPos)
		ACF.CalcBulletFlight(Bullet)
	elseif Retry == "Ricochet" then
		if Bullet.OnRicocheted then Bullet.OnRicocheted(Bullet, FlightRes) end

		ACF.BulletClient(Bullet, "Update", 3, FlightRes.HitPos)
		ACF.CalcBulletFlight(Bullet)
	else
		if Bullet.OnEndFlight then Bullet.OnEndFlight(Bullet, FlightRes) end

		ACF.BulletClient(Bullet, "Update", 1, FlightRes.HitPos)

		Ammo:OnFlightEnd(Bullet, FlightRes)
	end
end

ACFM_ResetVelocity = ACF.ResetBulletVelocity
