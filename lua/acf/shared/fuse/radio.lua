
local ClassName = "Radio"

ACF = ACF or {}
ACF.Fuse = ACF.Fuse or {}

local this = ACF.Fuse[ClassName] or inherit.NewSubOf(ACF.Fuse.Contact)
ACF.Fuse[ClassName] = this

---

this.Name = ClassName

-- The entity to measure distance to.
this.Target = nil

-- the fuse may trigger at some point under this range - unless it's travelling so fast that it steps right on through.
this.Distance = 2000

this.desc = "This fuse tracks the Guidance module's target and detonates when the distance becomes low enough.\nDistance in inches."

-- Configuration information for things like acfmenu.
this.Configurable = table.Copy(this:super().Configurable)

local configs = this.Configurable

configs[#configs + 1] = {
	Name = "Distance",          -- name of the variable to change
	DisplayName = "Distance",   -- name displayed to the user
	CommandName = "Ds",         -- shorthand name used in console commands

	Type = "number",            -- lua type of the configurable variable
	Min = 0,                    -- number specific: minimum value
	Max = 10000                 -- number specific: maximum value

	-- in future if needed: min/max getter function based on munition type.  useful for modifying radar cones?
}

function this:GetDetonate(Missile, Guidance)
	if not self:IsArmed() then return false end

	local Target = Guidance.TargetPos or Guidance:GetGuidance(Missile).TargetPos

	if not Target then return false end

	if (Missile.CurPos + Missile.LastVel):DistToSqr(Target) > (self.Distance ^ 2) then
		return false
	end

	return true
end

function this:GetDisplayConfig()
	return
	{
		Primer = math.Round(self.Primer, 1) .. " s",
		Distance = math.Round(self.Distance / 39.37, 1) .. " m"
	}
end
