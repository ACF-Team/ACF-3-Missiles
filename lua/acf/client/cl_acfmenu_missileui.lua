AddCSLuaFile()

function ACFMissiles_SetCommand(Combo, ControlGroup, Concmd)
	local Argument

	if not ControlGroup then
		Argument = tostring(Combo:GetValue())
	else
		local CGString = ""

		for _, Control in ipairs(ControlGroup) do
			CGString = CGString .. ":" .. Control.Configurable.CommandName .. "=" .. tostring(Control:GetConfigValue())
		end

		Argument = tostring(Combo:GetValue()) .. tostring(CGString)
	end

	RunConsoleCommand(Concmd, Argument)
end

function ACFMissiles_MenuSlider(Config, ControlGroup, Combo, Concmd, Min, Max)
	local MenuSlider = vgui.Create("DNumSlider")
	MenuSlider.Label:SetText(Config.DisplayName or "")
	MenuSlider.Label:SetDark(true)
	MenuSlider:SetMinMax(Min, Max)
	MenuSlider:SetValue(Config.Min)
	MenuSlider:SetDecimals( 2 )
	MenuSlider.Configurable = Config

	MenuSlider.GetConfigValue = function(This)
		local SliderConfig = MenuSlider.Configurable

		return math.Round(math.Clamp(This:GetValue(), SliderConfig.Min, SliderConfig.Max), 3)
	end

	MenuSlider.OnValueChanged = function()
		ACFMissiles_SetCommand(Combo, ControlGroup, Concmd)
	end

	ControlGroup[#ControlGroup + 1] = MenuSlider

	return MenuSlider
end

ACFMissiles_ConfigurationFactory = {
	number = function(Config, ControlGroup, Combo, Concmd, GunData)
		local Min = Config.MinConfig and GunData.armdelay or Config.Min

		return ACFMissiles_MenuSlider(Config, ControlGroup, Combo, Concmd, Min, Config.Max)
	end
}

function ACFMissiles_CreateMenuConfiguration(Data, Combo, Concmd, Panel, GunData)

	Panel = Panel or vgui.Create("DScrollPanel")
	Panel:Clear()

	if not Data.Configurable or not next(Data.Configurable) then
		Panel:SetTall(0)

		return Panel
	end

	local ControlGroup = {}
	local Height = 0

	for _, Config in pairs(Data.Configurable) do
		local Control = ACFMissiles_ConfigurationFactory[Config.Type](Config, ControlGroup, Combo, Concmd, GunData)
		Control:SetPos(6, Height)

		Panel:Add(Control)

		Control:StretchToParent(0, nil, 0, nil)

		Height = Height + Control:GetTall()
	end

	Panel:SetTall(Height + 2)

	Combo.ControlGroup = ControlGroup

	return Panel
end
