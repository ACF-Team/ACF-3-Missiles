local ACF      = ACF
local Classes  = ACF.Classes
local Missiles = Classes.Missiles
local Racks    = Classes.Racks
local Settings = { SuppressTracer = true }

local function GetRackList(Data)
	local Result = {}

	if Data then
		for Rack in pairs(Data.Racks) do
			local Info = Racks.Get(Rack)

			if Info then
				Result[Rack] = Info
			end
		end
	end

	return Result
end

local BaseText = "Caliber : %s\nMass : %s kg"
local RackText = BaseText .. "\nMunitions : %s%s\n"
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
	local Entries = Missiles.GetEntries()

	Menu:AddTitle("Missile Settings")

	local MissileTypes = Menu:AddComboBox()
	local MissileList = Menu:AddComboBox()

	local MissileBase = Menu:AddCollapsible("Missile Information")
	local MissileClass = MissileBase:AddLabel()
	local MissileDesc = MissileBase:AddLabel()
	local MissilePreview = MissileBase:AddModelPreview(nil, true)
	local MissileInfo = MissileBase:AddLabel()

	Menu:AddTitle("Rack Settings")

	local RackList = Menu:AddComboBox()

	local RackBase = Menu:AddCollapsible("Rack Information")
	local RackDesc = RackBase:AddLabel()
	local RackPreview = RackBase:AddModelPreview(nil, true)
	local RackInfo = RackBase:AddLabel()

	local AmmoList = ACF.CreateAmmoMenu(Menu, Settings)

	ACF.SetClientData("PrimaryClass", "acf_rack")
	ACF.SetClientData("SecondaryClass", "acf_ammo")

	ACF.SetToolMode("acf_menu", "Spawner", "Missile")

	function MissileTypes:OnSelect(Index, _, Data)
		if self.Selected == Data then return end

		self.ListData.Index = Index
		self.Selected = Data

		ACF.SetClientData("WeaponClass", Data.ID)

		MissileClass:SetText(Data.Description)

		ACF.LoadSortedList(MissileList, Data.Items, "Caliber")

		AmmoList:LoadEntries(Data.ID)
	end

	function MissileList:OnSelect(Index, _, Data)
		if self.Selected == Data then return end

		self.ListData.Index = Index
		self.Selected = Data

		ACF.SetClientData("Weapon", Data.ID)
		ACF.SetClientData("Destiny", Data.Destiny or "Missiles")

		ACF.LoadSortedList(RackList, GetRackList(Data), "MagSize")

		MissileDesc:SetText(Data.Description)

		MissilePreview:UpdateModel(Data.Model)
		MissilePreview:UpdateSettings(Data.Preview)

		MissileInfo:SetText(GetMissileText(Data))

		Menu.AmmoBase.MissileData = Data

		ACF.UpdateAmmoMenu(Menu, Settings)
	end

	function RackList:OnSelect(Index, _, Data)
		if self.Selected == Data then return end

		self.ListData.Index = Index
		self.Selected = Data

		ACF.SetClientData("Rack", Data.ID)

		RackDesc:SetText(Data.Description)
		RackInfo:SetText(GetRackText(Data))

		RackPreview:UpdateModel(Data.Model)
		RackPreview:UpdateSettings(Data.Preview)
	end

	ACF.LoadSortedList(MissileTypes, Entries, "ID")
end

ACF.AddMenuItem(101, "Entities", "Missiles", "wand", CreateMenu)
