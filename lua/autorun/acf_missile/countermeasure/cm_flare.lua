
local ClassName = "Flare"


ACF = ACF or {}
ACF.Countermeasure = ACF.Countermeasure or {}

local this = ACF.Countermeasure[ClassName] or inherit.NewBaseClass()
ACF.Countermeasure[ClassName] = this

---

this.AppliesTo = {
	Radar = true,
	Infrared = true,
	Laser = true
}

-- bulletdata bound to this object
this.Flare = nil

-- chance as a fraction, 0 - 1
this.SuccessChance = 1

-- Can deactivate after time has passed
this.Active = false

-- indicate to ACFM that this should only be applied when guidance is activated or Flare is spawned - not per-frame.
this.ApplyContinuous = false

function this:Init() end

function this:Configure(Flare)
	self.Flare = Flare
	self.SuccessChance = Flare.DistractChance
	self:UpdateActive()
end

function this:UpdateActive()
	local Flare = self.Flare

	if not Flare then
		self.Active = false
		return
	end

	self.Active = (Flare.CreateTime + Flare.BurnTime) > SysTime()
end

function this:GetGuidanceOverride()
	if not self.Flare then return end

	self:UpdateActive()

	if not self.Active then return end

	local activeFlare = ACF.Bullet[self.Flare.Index]
	if not (activeFlare and activeFlare.FlareUID == self.Flare.FlareUID) then return end

	return {TargetPos = self.Flare.Pos, TargetVel = self.Flare.Vel}
end

-- TODO: refine formula.
function this:ApplyChance()
	self:UpdateActive()

	if not self.Active then return false end

	local success = math.random() < self.SuccessChance

	return success
end

-- roll the dice against a missile.  returns true if the Flare succeeds in distracting the missile.
-- does not actually apply the effect, just tests the chance of it happening.
-- 'Flare' is bulletdata.
function this:TryAgainst(Missile, Guidance)
	if not self.Flare then return end

	self:UpdateActive()

	if not self.Active then return end

	local ViewCone = Guidance.ViewCone

	if not ViewCone or ViewCone <= 0 then return end

	local Position = Missile:GetPos()
	local Forward = Missile:GetForward()

	return ACFM_ConeContainsPos(Position, Forward, ViewCone, self.Flare.Pos) and self:ApplyChance(Missile, Guidance, self.Flare)
end

-- counterpart to ApplyAll.  this takes one Flare and applies it to all missiles.
-- returns all missiles which should be affected by this Flare.
function this:ApplyToAll()
	if not self.Flare then return {} end

	self:UpdateActive()

	if not self.Active then return {} end

	local Result = {}
	local Targets = ACFM_GetAllMissilesWhichCanSee(self.Flare.Pos)

	for _, Missile in pairs(Targets) do
		local Guidance = Missile.Guidance

		if self:ApplyChance(Missile, Guidance) then
			Result[#Result + 1] = Missile
		end
	end

	return Result
end

-- 'static' function to iterate over all flares in flight and return one which affects the guidance.
-- TODO: apply sub-1 chance to distract guidance in ACFM_GetAnyFlareInCone.
function this.ApplyAll(Missile, Guidance)
	local ViewCone = Guidance.ViewCone

	if not ViewCone or ViewCone <= 0 then return end

	local Position = Missile:GetPos()
	local Forward = Missile:GetForward()
	local Flares = ACFM_GetFlaresInCone(Position, Forward, ViewCone)

	for _, Flare in pairs(Flares) do
		local Result = Flare.FlareObj

		if Result:ApplyChance(Missile, Guidance, Flare) then
			return Result
		end
	end

	return nil
end
