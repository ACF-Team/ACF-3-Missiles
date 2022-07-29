local ACF             = ACF
local Countermeasures = ACF.Classes.Countermeasures
local Bullets         = ACF.Bullets
local Missiles        = ACF.ActiveMissiles

ACFM_Flares = {}
ACFM_FlareUID = 0

function ACFM_RegisterFlare(BulletData)
	local Flare    = Countermeasures.Get("Flare")
	local FlareObj = Flare()

	BulletData.FlareUID = ACFM_FlareUID

	ACFM_Flares[BulletData.Index] = ACFM_FlareUID
	ACFM_FlareUID = ACFM_FlareUID + 1

	FlareObj:Configure(BulletData)

	BulletData.FlareObj = FlareObj

	ACFM_OnFlareSpawn(BulletData)
end

function ACFM_UnregisterFlare(BulletData)
	local FlareObj = BulletData.FlareObj

	if FlareObj then
		FlareObj.Flare = nil
	end

	ACFM_Flares[BulletData.Index] = nil
end

function ACFM_OnFlareSpawn(BulletData)
	local FlareObj = BulletData.FlareObj
	local Affected = FlareObj:ApplyToAll()

	for Missile in pairs(Affected) do
		Missile.GuidanceData.Override = FlareObj
	end
end

function ACFM_GetFlaresInCone(Position, Direction, Degrees)
	local Result = {}

	for Index, UID in pairs(ACFM_Flares) do
		local Flare = Bullets[Index]

		if not (Flare and Flare.FlareUID and Flare.FlareUID == UID) then
			continue
		end

		if ACFM_ConeContainsPos(Position, Direction, Degrees, Flare.Pos) then
			Result[Flare] = true
		end
	end

	return Result
end

function ACFM_GetAnyFlareInCone(Position, Direction, Degrees)
	for Index, UID in pairs(ACFM_Flares) do
		local Flare = Bullets[Index]

		if not (Flare and Flare.FlareUID and Flare.FlareUID == UID) then
			continue
		end

		if ACFM_ConeContainsPos(Position, Direction, Degrees, Flare.Pos) then
			return Flare
		end
	end
end

function ACFM_GetMissilesInCone(Position, Direction, Degrees)
	local Result = {}

	for Missile in pairs(Missiles) do
		if not IsValid(Missile) then
			continue
		end

		if ACFM_ConeContainsPos(Position, Direction, Degrees, Missile:GetPos()) then
			Result[Missile] = true
		end

	end

	return Result
end

function ACFM_GetMissilesInSphere(Position, Radius)
	local Result = {}
	local RadiusSqr = Radius * Radius

	for Missile in pairs(Missiles) do
		if not IsValid(Missile) then
			continue
		end

		if Position:DistToSqr(Missile:GetPos()) <= RadiusSqr then
			Result[Missile] = true
		end
	end

	return Result
end

-- Tests flare distraction effect upon all undistracted missiles, but does not perform the effect itself.  Returns a list of potentially affected missiles.
-- argument is the bullet in the acf bullet table which represents the flare - not the cm_flare object!
function ACFM_GetAllMissilesWhichCanSee(Position)
	local Result = {}

	for Missile in pairs(Missiles) do
		local Guidance = Missile.GuidanceData

		if not Guidance or Guidance.Override or not Guidance.ViewCone then
			continue
		end

		if ACFM_ConeContainsPos(Missile:GetPos(), Missile:GetForward(), Guidance.ViewCone, Position) then
			Result[Missile] = true
		end
	end

	return Result
end

function ACFM_ConeContainsPos(ConePos, ConeDir, Degrees, Position)
	local MinimumDot = math.cos(math.rad(Degrees))
	local Direction = (Position - ConePos):GetNormalized()

	return ConeDir:Dot(Direction) >= MinimumDot
end

function ACFM_ApplyCountermeasures(Missile, Guidance)
	if Guidance.Override then return end

	local List = Countermeasures.GetList()

	for _, CounterMeasure in ipairs(List) do
		if not CounterMeasure.ApplyContinuous then
			continue
		end

		if ACFM_ApplyCountermeasure(Missile, Guidance, CounterMeasure) then
			break
		end
	end
end

function ACFM_ApplySpawnCountermeasures(Missile, Guidance)
	if Guidance.Override then return end

	local List = Countermeasures.GetList()

	for _, CounterMeasure in ipairs(List) do
		if CounterMeasure.ApplyContinuous then
			continue
		end

		if ACFM_ApplyCountermeasure(Missile, Guidance, CounterMeasure) then
			break
		end
	end
end

function ACFM_ApplyCountermeasure(Missile, Guidance, CounterMeasure)
	if not CounterMeasure.AppliesTo[Guidance.Name] then return end

	local Override = CounterMeasure.ApplyAll(Missile, Guidance)

	if Override then
		Guidance.Override = Override
		return true
	end
end
