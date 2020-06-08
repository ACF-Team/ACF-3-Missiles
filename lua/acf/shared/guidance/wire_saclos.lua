local Guidance = ACF.RegisterGuidance("Wire (SACLOS)", "Wire (MCLOS)")

Guidance.desc = "This guidance package allows you to control the direction of the missile using a computer's aiming position."

function Guidance:CheckComputer()
	local Computer = self:GetComputer()

	if not Computer then return end
	if not Computer.IsComputer then return end
	if Computer.HitPos == Vector() then return end

	return Computer.HitPos
end

function Guidance:GetGuidance(Missile)
	if self.WireSnapped then return {} end
	if not self:OnRange(Missile) then
		self:SnapRope(Missile)

		return {}
	end

	local HitPos = self:CheckComputer()

	return { TargetPos = HitPos }
end