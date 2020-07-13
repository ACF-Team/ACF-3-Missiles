local AmmoTypes = ACF.Classes.AmmoTypes
local Missiles = ACF.Classes.Missiles
local Crates = ACF.Classes.Crates
local Racks = ACF.Classes.Racks
local AmmoLists = {}
local RackLists = {}
local Selected = {}
local Sorted = {}

local function GetAmmoList(Class)
	if not Class then return {} end
	if AmmoLists[Class] then return AmmoLists[Class] end

	local Result = {}

	for K, V in pairs(AmmoTypes) do
		if V.Unlistable then continue end
		if V.Blacklist[Class] then continue end

		Result[K] = V
	end

	AmmoLists[Class] = Result

	return Result
end

local function GetRackList(Data)
	if not Data then return {} end
	if RackLists[Data] then return RackLists[Data] end

	local Result = {}

	for Rack in pairs(Data.Racks) do
		local Info = Racks[Rack]

		if Racks[Rack] then
			Result[Rack] = Info
		end
	end

	RackLists[Data] = Result

	return Result
end

local function LoadSortedList(Panel, List, Member)
	local Choices = Sorted[List]

	if not Choices then
		Choices = {}

		local Count = 0
		for _, V in pairs(List) do
			Count = Count + 1
			Choices[Count] = V
		end

		table.SortByMember(Choices, Member, true)

		Sorted[List] = Choices
		Selected[Choices] = 1
	end

	Panel:Clear()

	for _, V in pairs(Choices) do
		Panel:AddChoice(V.Name, V)
	end

	Panel:ChooseOptionID(Selected[Choices])
end

local BaseText = "Caliber : %s\nMass : %s kg"
local RackText = BaseText .. "\nMunitions : %s%s\n\nThis entity can be fully parented."
local MissileText = BaseText .. "\nArming Delay : %ss%s%s"

local function GetMissileText(Data)
	local Caliber = Data.Caliber .. "mm"
	local Seek = ""
	local View = ""

	if Data.SeekCone then
		Seek = "\nSeek Cone : " .. Data.SeekCone * 2 .. " degrees"
	end

	if Data.ViewCone then
		View = "\nView Cone : " .. Data.ViewCone * 2 .. " degrees"
	end

	return MissileText:format(Caliber, Data.Mass, Data.ArmDelay, Seek, View)
end

local function GetRackText(Data)
	local Caliber = "Any caliber"
	local Protect = ""

	if Data.Caliber then
		Caliber = Data.Caliber .. "mm"
	end

	if Data.ProtectMissile then
		Protect = "\n\nThis rack will protect its payload from getting destroyed."
	end

	return RackText:format(Caliber, Data.Mass, Data.MagSize, Protect)
end

local function CreateMenu(Menu)
	Menu:AddTitle("Missile Settings")

	local MissileTypes = Menu:AddComboBox()
	local MissileList = Menu:AddComboBox()

	local MissileBase = Menu:AddCollapsible("Missile Information")
	local MissileClass = MissileBase:AddLabel()
	local MissileDesc = MissileBase:AddLabel()
	local MissilePreview = MissileBase:AddModelPreview()
	local MissileInfo = MissileBase:AddLabel()

	Menu:AddTitle("Rack Settings")

	local RackList = Menu:AddComboBox()

	local RackBase = Menu:AddCollapsible("Rack Information")
	local RackDesc = RackBase:AddLabel()
	local RackPreview = RackBase:AddModelPreview()
	local RackInfo = RackBase:AddLabel()

	Menu:AddTitle("Ammo Settings")

	local CrateList = Menu:AddComboBox()
	local AmmoList = Menu:AddComboBox()

	local AmmoBase = Menu:AddCollapsible("Ammo Information")
	local AmmoDesc = AmmoBase:AddLabel()
	local AmmoPreview = AmmoBase:AddModelPreview()

	ACF.WriteValue("PrimaryClass", "acf_rack")
	ACF.WriteValue("SecondaryClass", "acf_ammo")

	ACF.SetToolMode("acf_menu2", "Main", "Spawner")

	function MissileTypes:OnSelect(Index, _, Data)
		if self.Selected == Data then return end

		self.Selected = Data

		local Choices = Sorted[Missiles]
		Selected[Choices] = Index

		ACF.WriteValue("WeaponClass", Data.ID)

		MissileClass:SetText(Data.Description)

		LoadSortedList(MissileList, Data.Items, "Caliber")
		LoadSortedList(AmmoList, GetAmmoList(Data.ID), "Name")
	end

	function MissileList:OnSelect(Index, _, Data)
		if self.Selected == Data then return end

		self.Selected = Data

		local Preview = Data.Preview
		local ClassData = MissileTypes.Selected
		local Choices = Sorted[ClassData.Items]
		Selected[Choices] = Index

		ACF.WriteValue("Weapon", Data.ID)
		ACF.WriteValue("Destiny", Data.Destiny)

		LoadSortedList(RackList, GetRackList(Data), "Mass")

		MissileDesc:SetText(Data.Description)

		MissilePreview:SetModel(Data.Model)
		MissilePreview:SetCamPos(Preview and Preview.Offset or Vector(45, 60, 45))
		MissilePreview:SetLookAt(Preview and Preview.Position or Vector())
		MissilePreview:SetHeight(Preview and Preview.Height or 80)
		MissilePreview:SetFOV(Preview and Preview.FOV or 75)

		MissileInfo:SetText(GetMissileText(Data))

		AmmoList:UpdateMenu()
	end

	function RackList:OnSelect(Index, _, Data)
		if self.Selected == Data then return end

		self.Selected = Data

		local Preview = Data.Preview
		local Choices = Sorted[GetRackList(MissileList.Selected)]
		Selected[Choices] = Index

		ACF.WriteValue("Rack", Data.ID)

		RackDesc:SetText(Data.Description)
		RackInfo:SetText(GetRackText(Data))

		RackPreview:SetModel(Data.Model)
		RackPreview:SetCamPos(Preview and Preview.Offset or Vector(45, 60, 45))
		RackPreview:SetLookAt(Preview and Preview.Position or Vector())
		RackPreview:SetHeight(Preview and Preview.Height or 80)
		RackPreview:SetFOV(Preview and Preview.FOV or 75)
	end

	function CrateList:OnSelect(Index, _, Data)
		if self.Selected == Data then return end

		self.Selected = Data

		local Preview = Data.Preview
		local Choices = Sorted[Crates]
		Selected[Choices] = Index

		ACF.WriteValue("Crate", Data.ID)

		AmmoPreview:SetModel(Data.Model)
		AmmoPreview:SetCamPos(Preview and Preview.Offset or Vector(45, 60, 45))
		AmmoPreview:SetLookAt(Preview and Preview.Position or Vector())
		AmmoPreview:SetHeight(Preview and Preview.Height or 80)
		AmmoPreview:SetFOV(Preview and Preview.FOV or 75)
	end

	function AmmoList:OnSelect(Index, _, Data)
		if self.Selected == Data then return end

		self.Selected = Data

		local Choices = Sorted[GetAmmoList(MissileTypes.Selected.ID)]
		Selected[Choices] = Index

		ACF.WriteValue("Ammo", Data.ID)

		AmmoDesc:SetText(Data.Description .. "\n\nThis entity can be fully parented.")

		self:UpdateMenu()
	end

	function AmmoList:UpdateMenu()
		if not self.Selected then return end

		local Ammo = self.Selected
		local ToolData = ACF.GetToolData()

		AmmoData = Ammo:ClientConvert(Menu, ToolData)

		Menu:ClearTemporal(AmmoBase)
		Menu:StartTemporal(AmmoBase)

		if not Ammo.SupressDefaultMenu then
			local RoundLength = AmmoBase:AddLabel()
			RoundLength:TrackDataVar("Projectile", "SetText")
			RoundLength:TrackDataVar("Propellant")
			RoundLength:TrackDataVar("Tracer")
			RoundLength:SetValueFunction(function()
				local Text = "Round Length: %s / %s cm"
				local CurLength = AmmoData.ProjLength + AmmoData.PropLength + AmmoData.Tracer
				local MaxLength = AmmoData.MaxRoundLength

				return Text:format(CurLength, MaxLength)
			end)

			local Projectile = AmmoBase:AddSlider("Projectile Length", 0, AmmoData.MaxRoundLength, 2)
			Projectile:SetDataVar("Projectile", "OnValueChanged")
			Projectile:SetValueFunction(function(Panel, IsTracked)
				ToolData.Projectile = ACF.ReadNumber("Projectile")

				if not IsTracked then
					AmmoData.Priority = "Projectile"
				end

				Ammo:UpdateRoundData(ToolData, AmmoData)

				ACF.WriteValue("Propellant", AmmoData.PropLength)

				Panel:SetValue(AmmoData.ProjLength)

				return AmmoData.ProjLength
			end)

			local Propellant = AmmoBase:AddSlider("Propellant Length", 0, AmmoData.MaxRoundLength, 2)
			Propellant:SetDataVar("Propellant", "OnValueChanged")
			Propellant:SetValueFunction(function(Panel, IsTracked)
				ToolData.Propellant = ACF.ReadNumber("Propellant")

				if not IsTracked then
					AmmoData.Priority = "Propellant"
				end

				Ammo:UpdateRoundData(ToolData, AmmoData)

				ACF.WriteValue("Projectile", AmmoData.ProjLength)

				Panel:SetValue(AmmoData.PropLength)

				return AmmoData.PropLength
			end)
		end

		if Ammo.MenuAction then
			Ammo:MenuAction(AmmoBase, ToolData, AmmoData)
		end

		Menu:EndTemporal(AmmoBase)
	end

	LoadSortedList(MissileTypes, Missiles, "ID")
	LoadSortedList(CrateList, Crates, "ID")
end

ACF.AddOptionItem("Entities", "Missiles", "wand", CreateMenu)
