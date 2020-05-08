
local Fuze = ACF.RegisterFuze("Timed", "Contact")

Fuze.desc = "This fuze triggers upon direct contact, or when the timer ends.\nDelay in seconds."
Fuze.Timer = 10 -- Time to explode, begins ticking after configuration.

function Fuze:OnLoaded()
	Fuze.BaseClass.OnLoaded(self)

	local Config = self.Configurable

	Config[#Config + 1] = {
		Name = "Timer",					-- name of the variable to change
		DisplayName = "Trigger Delay",	-- name displayed to the user
		CommandName = "Tm",				-- shorthand name used in console commands
		Type = "number",				-- lua type of the configurable variable
		Min = 0,						-- number specific: minimum value
		Max = 30						-- number specific: maximum value
	}
end

function Fuze:GetDetonate()
	return self:IsArmed() and self.TimeStarted + self.Timer <= CurTime()
end

function Fuze:GetDisplayConfig()
	return
	{
		Primer = math.Round(self.Primer, 1) .. " s",
		Timer = math.Round(self.Timer, 1) .. " s"
	}
end
