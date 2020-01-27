local Guidance = ACF.RegisterGuidance("Radio (SACLOS)", "Radio (MCLOS)")

Guidance.desc = "This guidance package allows you to control the direction of the missile using a computer's aiming position."

function Guidance:GetGuidance(Missile)
	local Computer = self:GetComputer()

	if not IsValid(Computer) then return {} end
	if not Computer.Active then return {} end
	if not self:CheckLOS(Missile) then return {} end

	return { TargetPos = Computer.HitPos }
end