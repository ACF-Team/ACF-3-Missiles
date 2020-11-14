
local Fuze = ACF.RegisterFuze("Radio", "Optical")

if CLIENT then
	Fuze.desc = "This fuze tracks the Guidance module's target and detonates when the distance becomes low enough.\nDistance in inches."
else
	function Fuze:GetDetonate(Missile, Guidance)
		if not self:IsArmed() then return false end

		local Target = Guidance.TargetPos or Guidance:GetGuidance(Missile).TargetPos

		if not Target then return false end

		return (Missile.Position + Missile.LastVel):Distance(Target) <= self.Distance
	end
end
