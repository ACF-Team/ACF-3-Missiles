
local Fuse = ACF.RegisterFuse("Radio", "Contact")

Fuse.desc = "This fuse tracks the Guidance module's target and detonates when the distance becomes low enough.\nDistance in inches."
Fuse.Distance = 2000

function Fuse:OnLoaded()
	Fuse.BaseClass.OnLoaded(self)

	local Config = self.Configurable

	Config[#Config + 1] = {
		Name = "Distance",			-- name of the variable to change
		DisplayName = "Distance",	-- name displayed to the user
		CommandName = "Ds",			-- shorthand name used in console commands
		Type = "number",			-- lua type of the configurable variable
		Min = 0,					-- number specific: minimum value
		Max = 10000					-- number specific: maximum value
	}
end

function Fuse:GetDetonate(Missile, Guidance)
	if not self:IsArmed() then return false end

	local Target = Guidance.TargetPos or Guidance:GetGuidance(Missile).TargetPos

	if not Target then return false end

	return (Missile.CurPos + Missile.LastVel):Distance(Target) <= self.Distance
end

function Fuse:GetDisplayConfig()
	return
	{
		Primer = math.Round(self.Primer, 1) .. " s",
		Distance = math.Round(self.Distance / 39.37, 1) .. " m"
	}
end
