
ACFM_Flares = {}
ACFM_FlareUID = 0

function ACFM_RegisterFlare(BulletData)
	BulletData.FlareUID = ACFM_FlareUID

	ACFM_Flares[BulletData.Index] = ACFM_FlareUID
	ACFM_FlareUID = ACFM_FlareUID + 1

	local FlareObj = ACF.Countermeasure.Flare()
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
	local Missiles = FlareObj:ApplyToAll()

	for _, Missile in pairs(Missiles) do
		Missile.Guidance.Override = FlareObj
	end
end

function ACFM_GetFlaresInCone(Position, Direction, Degrees)
	local Result = {}
	local Bullets = ACF.Bullet

	for Index, UID in pairs(ACFM_Flares) do
		local Flare = Bullets[Index]

		if not (Flare and Flare.FlareUID and Flare.FlareUID == UID) then
			continue
		end

		if ACFM_ConeContainsPos(Position, Direction, Degrees, Flare.Pos) then
			Result[#Result + 1] = Flare
		end
	end

	return Result
end

function ACFM_GetAnyFlareInCone(Position, Direction, Degrees)
	local Bullets = ACF.Bullet

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

	for Missile in pairs(ACF_ActiveMissiles) do
		if not IsValid(Missile) then
			continue
		end

		if ACFM_ConeContainsPos(Position, Direction, Degrees, Missile:GetPos()) then
			Result[#Result + 1] = Missile
		end

	end

	return Result
end

function ACFM_GetMissilesInSphere(Position, Radius)
	local Result = {}
	local RadiusSqr = Radius * Radius

	for Missile in pairs(ACF_ActiveMissiles) do
		if not IsValid(Missile) then
			continue
		end

		if Position:DistToSqr(Missile:GetPos()) <= RadiusSqr then
			Result[#Result + 1] = Missile
		end
	end

	return Result
end

-- Tests flare distraction effect upon all undistracted missiles, but does not perform the effect itself.  Returns a list of potentially affected missiles.
-- argument is the bullet in the acf bullet table which represents the flare - not the cm_flare object!
function ACFM_GetAllMissilesWhichCanSee(Position)
	local Result = {}

	for Missile in pairs(ACF_ActiveMissiles) do
		local Guidance = Missile.Guidance

		if not Guidance or Guidance.Override or not Guidance.ViewCone then
			continue
		end

		if ACFM_ConeContainsPos(Missile:GetPos(), Missile:GetForward(), Guidance.ViewCone, Position) then
			Result[#Result + 1] = Missile
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

	for _, CounterMeasure in pairs(ACF.Countermeasure) do
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

	for _, CounterMeasure in pairs(ACF.Countermeasure) do
		if CounterMeasure.ApplyContinuous then
			continue
		end

		if ACFM_ApplyCountermeasure(Missile, Guidance, CounterMeasure) then
			break
		end
	end
end

function ACFM_ApplyCountermeasure(Missile, Guidance, CounterMeasure)
	if not CounterMeasure.AppliesTo[Guidance.Name] then
		return false
	end

	local Override = CounterMeasure.ApplyAll(Missile, Guidance)

	if Override then
		Guidance.Override = Override
		return true
	end
end
