
local ACF = ACF
local Fuze = ACF.RegisterFuze("Timed", "Contact")

Fuze.MinTime = 1
Fuze.MaxTime = 30

function Fuze:OnFirst(Entity, Data)
	Fuze.BaseClass.OnFirst(self, Entity, Data)

	self.Timer = Data.FuzeTimer
end

function Fuze:GetDisplayConfig()
	local Config = Fuze.BaseClass.GetDisplayConfig(self)

	Config.Timer = math.Round(self.Timer, 2) .. " s"

	return Config
end

if CLIENT then
	Fuze.Description = "This fuze triggers upon direct contact, or when the timer ends. Delay in seconds."

	function Fuze:AddMenuControls(Base, ToolData, ...)
		Fuze.BaseClass.AddMenuControls(self, Base, ToolData, ...)

		local Timer = Base:AddSlider("Fuze Timer", self.MinTime, self.MaxTime, 2)
		Timer:SetDataVar("FuzeTimer", "OnValueChanged")
		Timer:SetValueFunction(function(Panel)
			local Value = ACF.ReadNumber("FuzeTimer")

			Panel:SetValue(Value)

			return Value
		end)
	end
else
	ACF.AddEntityArguments("acf_ammo", "FuzeTimer") -- Adding extra info to ammo crates

	function Fuze:VerifyData(EntClass, Data, ...)
		Fuze.BaseClass.VerifyData(self, EntClass, Data, ...)

		local Timer = Data.FuzeTimer
		local Args = Data.FuzeArgs

		if not ACF.CheckNumber(Timer) and Args then
			Timer = ACF.CheckNumber(Args.TM) or 0

			Args.TM = nil
		end

		Data.FuzeTimer = math.Clamp(Timer or 0, self.MinTime, self.MaxTime)
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
