
local ACF = ACF
local Fuze = ACF.RegisterFuze("Contact")

--[[
-- Configuration information for things like acfmenu.

Name = "Primer",            -- name of the variable to change
DisplayName = "Arming Delay (in seconds)",   -- name displayed to the user
CommandName = "AD",         -- shorthand name used in console commands
Type = "number",            -- lua type of the configurable variable
Min = 0,                    -- number specific: minimum value
MinConfig = "ArmDelay",     -- round specific override for minimum value
Max = 10                    -- number specific: maximum value
]]--

function Fuze:OnLoaded()
	self.Name = self.ID -- Workaround
end

function Fuze:Configure()
	self.TimeStarted = ACF.CurTime
end

function Fuze:GetDisplayConfig()
	return { Primer = math.Round(self.Primer, 2) .. " s" }
end

if CLIENT then
	Fuze.desc = "This fuze triggers upon direct contact against solid surfaces."
else
	ACF.AddEntityArguments("acf_ammo", "ArmingDelay") -- Adding extra info to ammo crates

	function Fuze:VerifyData(_, Data)
		local Delay = Data.ArmingDelay
		local Args = Data.FuzeArgs

		if not ACF.CheckNumber(Delay) and Args then
			Delay = ACF.CheckNumber(Args.AD) or 0

			Args.AD = nil
		end

		local Min = ACF_GetGunValue(Data.Weapon, "ArmDelay") or 0

		Data.ArmingDelay = math.Clamp(Delay or 0, Min, 10)
	end

	function Fuze:OnFirst(_, Data)
		self.Primer = Data.ArmingDelay -- TODO: This needs to be done in the clientside aswell
	end

	function Fuze:IsArmed()
		return ACF.CurTime - self.TimeStarted >= self.Primer
	end

	-- Do nothing, projectiles auto-detonate on contact anyway.
	function Fuze:GetDetonate()
		return false
	end

	function Fuze:OnLast(Entity)
		Entity.ArmingDelay = nil
	end
end
