local Guidance = ACF.RegisterGuidance("Wire (SACLOS)", "Wire (MCLOS)")

Guidance.desc = "This guidance package allows you to control the direction of the missile using a computer's aiming position."

function Guidance:GetGuidance(Missile)
	local Computer = self:GetComputer()

	if not IsValid(Computer) then return {} end
	if self.WireSnapped then return {} end

	if not self:OnRange(Missile) then
		self:SnapRope(Missile)

		return {}
	end

	if not Computer.Active then return {} end

	return { TargetPos = Computer.HitPos }
end