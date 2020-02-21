
local Guidance = ACF.RegisterGuidance("Dumb")

Guidance.desc = "This guidance package is empty and provides no control."

function Guidance:OnLoaded()
	self.Name = self.ID -- Workaround
end

function Guidance:Configure() end

function Guidance:OnLaunched() end

function Guidance:PreGuidance(Missile)
	if not self.AppliedSpawnCountermeasures then
		ACFM_ApplySpawnCountermeasures(Missile, self)

		self.AppliedSpawnCountermeasures = true
	end

	ACFM_ApplyCountermeasures(Missile, self)
end

function Guidance:ApplyOverride(Missile)
	if not self.Override then return end

	local Override = self.Override:GetGuidanceOverride(Missile, self)

	if Override then
		Override.ViewCone = self.ViewCone or 0
		Override.ViewConeRad = math.rad(self.ViewCone)

		return Override
	end
end

function Guidance:GetGuidance() return {} end

function Guidance:OnRemoved() end

function Guidance:GetDisplayConfig()
	return {}
end
