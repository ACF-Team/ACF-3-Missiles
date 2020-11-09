
local ACF = ACF
local Fuze = ACF.RegisterFuze("Timed", "Contact")

--[[
-- Configuration information for things like acfmenu.

Name = "Timer",					-- name of the variable to change
DisplayName = "Trigger Delay",	-- name displayed to the user
CommandName = "Tm",				-- shorthand name used in console commands
Type = "number",				-- lua type of the configurable variable
Min = 0,						-- number specific: minimum value
Max = 30						-- number specific: maximum value
]]--

function Fuze:GetDisplayConfig()
	local Config = Fuze.BaseClass.GetDisplayConfig(self)

	Config.Timer = math.Round(self.Timer, 2) .. " s"

	return Config
end

if CLIENT then
	Fuze.desc = "This fuze triggers upon direct contact, or when the timer ends.\nDelay in seconds."
else
	ACF.AddEntityArguments("acf_ammo", "FuzeTimer") -- Adding extra info to ammo crates

	function Fuze:VerifyData(EntClass, Data, ...)
		Fuze.BaseClass.VerifyData(self, EntClass, Data, ...)

		local Timer = Data.FuzeTimer
		local Args = Data.FuzeArgs

		if not ACF.CheckNumber(Timer) and Args then
			Timer = ACF.CheckNumber(Args.TM) or 1

			Args.TM = nil
		end

		Data.FuzeTimer = math.Clamp(Timer or 1, 1, 30)
	end

	function Fuze:OnFirst(Entity, Data)
		Fuze.BaseClass.OnFirst(self, Entity, Data)

		self.Timer = Data.FuzeTimer -- TODO: This needs to be done in the clientside aswell
	end

	function Fuze:IsOnTime()
		return ACF.CurTime - self.TimeStarted >= self.Timer
	end

	function Fuze:GetDetonate()
		return self:IsArmed() and self:IsOnTime()
	end

	function Fuze:OnLast(Entity)
		Fuze.BaseClass.OnLast(self, Entity)

		Entity.FuzeTimer = nil
	end
end
