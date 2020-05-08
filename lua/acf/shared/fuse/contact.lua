
local Fuze = ACF.RegisterFuze("Contact")

Fuze.desc = "This fuze triggers upon direct contact against solid surfaces."
Fuze.Primer = 0

function Fuze:OnLoaded()
	self.Name = self.ID -- Workaround

	-- Configuration information for things like acfmenu.
	self.Configurable = {
		{
			Name = "Primer",            -- name of the variable to change
			DisplayName = "Arming Delay (in seconds)",   -- name displayed to the user
			CommandName = "AD",         -- shorthand name used in console commands

			Type = "number",            -- lua type of the configurable variable
			Min = 0,                    -- number specific: minimum value
			MinConfig = "armdelay",     -- round specific override for minimum value
			Max = 10                    -- number specific: maximum value
		}
	}
end

function Fuze:IsArmed()
	return self.TimeStarted + self.Primer <= CurTime()
end

function Fuze:Configure()
	self.TimeStarted = CurTime()
end

-- Do nothing, projectiles auto-detonate on contact anyway.
function Fuze:GetDetonate()
	return false
end

function Fuze:GetDisplayConfig()
	return { Primer = math.Round(self.Primer, 1) .. " s" }
end
