local Guidance = ACF.RegisterGuidance("Radio (SACLOS)", "Radio (MCLOS)")

Guidance.desc = "This guidance package allows you to control the direction of the missile using a computer's aiming position."

function Guidance:CheckComputer()
	local Computer = self:GetComputer()

	if not Computer then return end
	if not Computer.IsComputer then return end
	if Computer.HitPos == Vector() then return end

	return Computer.HitPos
end

function Guidance:GetGuidance(Missile)
	if not self:CheckLOS(Missile) then return {} end

	local HitPos = self:CheckComputer()

	return { TargetPos = HitPos }
end