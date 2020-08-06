
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

function Fuze:IsOnTime()
	return ACF.CurTime - self.TimeStarted >= self.Timer
end

function Fuze:GetDetonate()
	return self:IsArmed() and self:IsOnTime()
end

function Fuze:GetDisplayConfig()
	local Config = Fuze.BaseClass.GetDisplayConfig(self)

	Config.Timer = math.Round(self.Timer, 2) .. " second(s)"

	return Config
end
