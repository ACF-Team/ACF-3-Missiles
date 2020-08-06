
local Fuze = ACF.RegisterFuze("Optical", "Contact")
local TraceData = { start = true, endpos = true, filter = true }

Fuze.desc = "This fuze fires a beam directly ahead and detonates when the beam hits something close-by.\nDistance in inches."
Fuze.Distance = 1000

function Fuze:OnLoaded()
	Fuze.BaseClass.OnLoaded(self)

	local Config = self.Configurable

	Config[#Config + 1] = {
		Name = "Distance",			-- name of the variable to change
		DisplayName = "Distance",	-- name displayed to the user
		CommandName = "Ds",			-- shorthand name used in console commands
		Type = "number",			-- lua type of the configurable variable
		Min = 0,					-- number specific: minimum value
		Max = 2500					-- number specific: maximum value
	}
end

-- Do nothing, projectiles auto-detonate on contact anyway.
function Fuze:GetDetonate(Missile)
	if not self:IsArmed() then return false end

	local Position = Missile:GetPos()

	TraceData.start = Position
	TraceData.endpos = Position + Missile:GetForward() * self.Distance
	TraceData.filter = Missile.Filter or Missile

	return util.TraceLine(TraceData).Hit
end

function Fuze:GetDisplayConfig()
	local Config = Fuze.BaseClass.GetDisplayConfig(self)

	Config.Distance = math.Round(self.Distance * 0.0254, 2) .. " meter(s)"

	return Config
end
