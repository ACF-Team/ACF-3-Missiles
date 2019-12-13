
local ClassName = "Antimissile"

ACF = ACF or {}
ACF.Guidance = ACF.Guidance or {}

local this = ACF.Guidance[ClassName] or inherit.NewSubOf(ACF.Guidance.Wire)
ACF.Guidance[ClassName] = this

---

this.Name = ClassName

--Currently acquired target.
this.Target = nil

-- Cone to acquire targets within.
this.SeekCone = 20

-- Cone to retain targets within.
this.ViewCone = 25

-- Targets this close to the front are good enough.
this.SeekTolerance = math.cos( math.rad( 2 ) )

-- This instance must wait this long between target seeks.
this.SeekDelay = 100000 -- The re-seek cycle is expensive, let's disable it until we figure out some optimization.
--note that we halved this, making anti-missiles expensive relatively

-- Delay between re-seeks if an entity is provided via wiremod.
this.WireSeekDelay = 0.1

-- Minimum distance for a target to be considered
this.MinimumDistance = 196.85	--a scant 5m

-- Entity class whitelist
-- thanks to Sestze for the listing.
this.DefaultFilter = {
	acf_missile	= true
}

this.desc = "This guidance package detects a missile in front of itself, and guides the munition towards it."

function this:Init()
	self.LastSeek = CurTime() - self.SeekDelay - 0.000001
	self.Filter = table.Copy(self.DefaultFilter)
	self.LastTargetPos = Vector()
end

function this:Configure(Missile)
	self:super().Configure(self, Missile)

	self.ViewCone = ACF_GetGunValue(Missile.BulletData, "viewcone") or this.ViewCone
	self.ViewConeCos = math.cos(math.rad(self.ViewCone))
	self.SeekCone = ACF_GetGunValue(Missile.BulletData, "seekcone") or this.SeekCone
end

-- Use this to make sure you don't alter the shared default filter unintentionally
function this:GetSeekFilter()
	if self.Filter == self.DefaultFilter then
		self.Filter = table.Copy(self.DefaultFilter)
	end

	return self.Filter
end

function this:GetNamedWireInputs(Missile)
	local Launcher = Missile.Launcher
	local Outputs = Launcher.Outputs
	local Names = {}

	if Outputs.Target and Outputs.Target.Type == "ENTITY" then
		Names[#Names + 1] = "Target"
	end

	return Names
end

function this:GetFallbackWireInputs()
	-- Can't scan for entity outputs: a lot of ents have self-outputs.
	return {}
end

--TODO: still a bit messy, refactor this so we can check if a flare exits the viewcone too.
function this:GetGuidance(Missile)
	self:PreGuidance(Missile)

	local Override = self:ApplyOverride(Missile)

	if Override then
		return Override
	end

	self:CheckTarget(Missile)

	if not IsValid(self.Target) then
		return {}
	end

	local Position  = self.Target:GetPos()
	local Forward   = Missile:GetForward()
	local Direction = (Missile:GetPos() - Position):GetNormalized()

	if Forward:Dot(Direction) < self.ViewConeCos then
		self.Target = nil

		return {}
	else
		self.TargetPos = Position

		return { TargetPos = Position, ViewCone = self.ViewCone }
	end
end

function this:ApplyOverride(Missile)
	if self.Override then

		local Override = self.Override:GetGuidanceOverride(Missile, self)

		if Override then
			Override.ViewCone = self.ViewCone
			Override.ViewConeRad = math.rad(self.ViewCone)

			return Override
		end
	end
end

function this:CheckTarget(Missile)
	if not (self.Target or self.Override) then
		local Target = self:AcquireLock(Missile)

		if IsValid(Target) then
			self.Target = Target
		end
	end
end

function this:GetWireTarget()
	if not IsValid(self.InputSource) then
		return nil
	end

	local Outputs = self.InputSource.Outputs

	if not Outputs then
		return nil
	end

	for _, Input in pairs(self.InputNames) do
		local Output = Outputs[Input]

		if not (Output and Output.Value) then continue end

		local Value = Output.Value

		if IsValid(Value) and IsEntity(Value) then
			return Value
		end
	end
end

--ents.findincone not working? weird.
--TODO: add a check on the allents table to ignore if parent is valid
function JankCone(Position, Forward, Radius, ConeAng)
	local Entities = ents.GetAll()
	local Result = {}

	for _, Ent in pairs(Entities) do
		if IsValid(Ent) then
			local PosDelta = Ent:GetPos() - Position
			local Distance = PosDelta:Length()
			local Angle = math.deg(math.acos(math.Clamp((PosDelta:GetNormalized()):Dot(Forward), -1, 1)))

			if Distance <= Radius and Angle <= ConeAng then
				Result[#Result + 1] = Ent
			end
		end
	end

	return Result
end

function this:GetWhitelistedEntsInCone(Missile)
	local missilePos = Missile:GetPos()
	local missileForward = Missile:GetForward()
	local minDot = math.cos(math.rad(self.SeekCone))

	local found = JankCone(missilePos, missileForward, 50000, self.SeekCone)
	local foundAnim = {}
	local minDistSqr = self.MinimumDistance * self.MinimumDistance

	for _, foundEnt in pairs(found) do
		if (not IsValid(foundEnt)) or (not self.Filter[foundEnt:GetClass()]) then	continue end
		local foundLocalPos = foundEnt:GetPos() - missilePos

		local foundDistSqr = foundLocalPos:LengthSqr()
		if foundDistSqr < minDistSqr then continue end

		local foundDot = foundLocalPos:GetNormalized():Dot(missileForward)
		if foundDot < minDot then continue end

		table.insert(foundAnim, foundEnt)
	end

	return foundAnim
end

function this:HasLOSVisibility(ent, Missile)
	local traceArgs = {
		start = Missile:GetPos(),
		endpos = ent:GetPos(),
		mask = MASK_SOLID_BRUSHONLY,
		filter = {Missile, ent}
	}

	local res = util.TraceLine(traceArgs)

	return not res.Hit
end

-- Return the first entity found within the seek-tolerance, or the entity within the seek-ConeAng closest to the seek-tolerance.
function this:AcquireLock(Missile)
	local curTime = CurTime()

	if self.LastSeek + self.WireSeekDelay <= curTime then

		local wireEnt = self:GetWireTarget(Missile)

		if wireEnt then
			return wireEnt
		end

	end

	if self.LastSeek + self.SeekDelay > curTime then
		return nil
	end
	self.LastSeek = curTime

	-- Part 1: get all whitelisted entities in seek-ConeAng.
	local found = self:GetWhitelistedEntsInCone(Missile)

	-- Part 2: get a good seek target
	local foundCt = table.Count(found)
	if foundCt < 2 then
		return found[1]
	end

	local missilePos = Missile:GetPos()
	local missileForward = Missile:GetForward()

	local mostCentralEnt
	local lastKey

	while not mostCentralEnt do
		local ent
		lastKey, ent = next(found, lastKey)

		if not ent then break end

		if self:HasLOSVisibility(ent, Missile) then
			mostCentralEnt = ent
		end

	end

	if not mostCentralEnt then return nil end

	local highestDot = (mostCentralEnt:GetPos() - missilePos):GetNormalized():Dot(missileForward)
	local currentEnt
	local currentDot

	for _, ent in next, found, lastKey do
		currentEnt = ent
		currentDot = (currentEnt:GetPos() - missilePos):GetNormalized():Dot(missileForward)

		if currentDot > highestDot and self:HasLOSVisibility(currentEnt, Missile) then
			mostCentralEnt = currentEnt
			highestDot = currentDot

			if currentDot >= self.SeekTolerance then
				return currentEnt
			end
		end
	end

	return mostCentralEnt
end

function this:GetDisplayConfig()
	return
	{
		Seeking = math.Round(self.SeekCone * 2, 1) .. " deg",
		Tracking = math.Round(self.ViewCone * 2, 1) .. " deg"
	}
end
