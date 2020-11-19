
local ACF = ACF
local Fuze = ACF.RegisterFuze("Optical", "Contact")

Fuze.MinDistance = 40
Fuze.MaxDistance = 2500

function Fuze:GetDisplayConfig()
	local Config = Fuze.BaseClass.GetDisplayConfig(self)

	Config.Distance = math.Round(self.Distance * 0.0254, 2) .. " m"

	return Config
end

if CLIENT then
	Fuze.Description = "This fuze fires a beam directly ahead and detonates when the beam hits something close-by. Distance in inches."

	function Fuze:AddMenuControls(Base, ToolData, ...)
		Fuze.BaseClass.AddMenuControls(self, Base, ToolData, ...)

		local Distance = Base:AddSlider("Fuze Distance", self.MinDistance, self.MaxDistance, 2)
		Distance:SetDataVar("FuzeDistance", "OnValueChanged")
		Distance:SetValueFunction(function(Panel)
			local Value = ACF.ReadNumber("FuzeDistance")

			Panel:SetValue(Value)

			return Value
		end)
	end
else
	ACF.AddEntityArguments("acf_ammo", "FuzeDistance") -- Adding extra info to ammo crates

	local TraceData = { start = true, endpos = true, filter = true }

	function Fuze:VerifyData(EntClass, Data, ...)
		Fuze.BaseClass.VerifyData(self, EntClass, Data, ...)

		local Distance = Data.FuzeDistance
		local Args = Data.FuzeArgs

		if not ACF.CheckNumber(Distance) and Args then
			Distance = ACF.CheckNumber(Args.DS) or 0

			Args.DS = nil
		end

		Data.FuzeDistance = math.Clamp(Distance or 0, self.MinDistance, self.MaxDistance)
	end

	function Fuze:OnFirst(Entity, Data)
		Fuze.BaseClass.OnFirst(self, Entity, Data)

		self.Distance = Data.FuzeDistance
	end

	function Fuze:GetDetonate(Missile)
		if not self:IsArmed() then return false end

		local Position = Missile:GetPos()

		TraceData.start = Position
		TraceData.endpos = Position + Missile:GetForward() * self.Distance
		TraceData.filter = Missile.Filter or { Missile }

		return util.TraceLine(TraceData).Hit
	end

	function Fuze:OnLast(Entity)
		Fuze.BaseClass.OnLast(self, Entity)

		Entity.FuzeDistance = nil
	end
end
