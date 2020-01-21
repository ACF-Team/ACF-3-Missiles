local Guidance = ACF.RegisterGuidance("GPS Guided", "Radio (MCLOS)")

Guidance.desc = "This guidance package allows you to guide the munition to a desired point in the map."

function Guidance:GetGuidance(Missile)
	local Computer = self:GetComputer()

	if not IsValid(Computer) then return {} end
	if not Computer.Active then return {} end
	if not self:CheckLOS(Missile) then return {} end

	return { TargetPos = self.Source.TargetPos }
end