local ACF     = ACF
local Classes = ACF.Classes
local Fuzes   = Classes.Fuzes
local Fuze    = Fuzes.Register("Altitude", "Contact")

if CLIENT then
	Fuze.Description = "This fuze tracks the guidance module's target and detonates once it crosses the altitude of the target position."
else
	function Fuze:GetDetonate(Missile, Guidance)
		if not self:IsArmed() then return false end

		local Target = Guidance.TargetPos or Guidance:GetGuidance(Missile).TargetPos
		if not Target then return false end

		local TargetElevation = Target.z
		local MissileElevation = Missile:GetPos().z

		return MissileElevation >= TargetElevation
	end
end