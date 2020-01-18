
local Fuse = ACF.RegisterFuse("Timed", "Contact")

Fuse.Name = "Timed"
Fuse.desc = "This fuse triggers upon direct contact, or when the timer ends.\nDelay in seconds."
Fuse.Timer = 10 -- Time to explode, begins ticking after configuration.

function Fuse:OnLoaded()
	Fuse.BaseClass.OnLoaded(self)

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

function Fuse:GetDetonate()
	return self:IsArmed() and self.TimeStarted + self.Timer <= CurTime()
end

function Fuse:GetDisplayConfig()
	return
	{
		Primer = math.Round(self.Primer, 1) .. " s",
		Timer = math.Round(self.Timer, 1) .. " s"
	}
end
