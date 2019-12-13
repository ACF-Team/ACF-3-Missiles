
function ACF_GetGunValue(BulletData, Value)
	BulletData = istable(BulletData) and BulletData.Id or BulletData

	local Class = list.Get("ACFEnts").Guns[BulletData]

	if Class then
		local Result = Class.RoundData and Class.RoundData[Value] or Class[Value]

		if Result then
			return Result
		end

		local GunClasses = list.Get("ACFClasses").GunClass

		Class = GunClasses[Class.gunclass]

		if Class then
			return Class[Value]
		end
	end
end

function ACF_GetRackValue(RackData, Value)
	RackData = istable(RackData) and RackData.Id or RackData

	local Class = ACF.Weapons.Rack[RackData]

	if Class then
		if Class[Value] then
			return Class[Value]
		end

		Class = ACF.Classes.Rack[Class.gunclass]

		if Class then
			return Class[Value]
		end
	end
end

function ACF_RackCanLoadCaliber(RackID, Caliber)
	local RackData = ACF.Weapons.Rack[RackID]

	if not RackData then
		return false, "Rack '" .. tostring(RackID) .. "' does not exist."
	end

	if RackData.caliber then
		if RackData.caliber == Caliber then return true end

		return false, "Only " .. math.Round(RackData.caliber * 10, 2) .. "mm rounds can fit in this GunData."
	end

	if RackData.mincaliber and Caliber < RackData.mincaliber then
		return false, "Rounds must be at least " .. math.Round(RackData.mincaliber * 10, 2) .. "mm to fit in this GunData."
	end

	if RackData.maxcaliber and Caliber > RackData.maxcaliber then
		return false, "Rounds cannot be more than " .. math.Round(RackData.maxcaliber * 10, 2) .. "mm to fit in this GunData."
	end

	return true
end

function ACF_CanLinkRack(RackID, AmmoID, BulletData)
	local RackData = ACF.Weapons.Rack[RackID]

	if not RackData then
		return false, "Rack '" .. tostring(RackID) .. "' does not exist."
	end

	local GunData = list.Get("ACFEnts").Guns[AmmoID]

	if not GunData then
		return false, "Ammo '" .. tostring(AmmoID) .. "' does not exist."
	end

	local AllowedRacks = ACF_GetGunValue(AmmoID, "racks")
	local AllowedType = type(AllowedRacks)
	local IsAllowed

	if AllowedRacks == nil and RackData.whitelistonly then
		IsAllowed = false
	elseif AllowedType == "table" then
		IsAllowed = AllowedRacks[RackID]
	elseif AllowedType == "function" then
		IsAllowed = AllowedRacks(BulletData or AmmoID, RackData or RackID)
	end

	if not IsAllowed then
		return false, AmmoID .. " rounds are not compatible with a " .. tostring(RackID) .. "!"
	end

	local Bool, Message = ACF_RackCanLoadCaliber(RackID, GunData.caliber)

	if not Bool then
		return false, Message
	end

	local Classes = list.Get("ACFClasses").GunClass

	if Classes[GunData.gunclass].type ~= "missile" then
		return false, "Racks cannot be linked to ammo crates of type '" .. tostring(AmmoID) .. "'!"
	end

	return true
end

function ACF_GetCompatibleRacks(AmmoID)
	local Result = {}

	for RackID in pairs(ACF.Weapons.Rack) do
		if ACF_CanLinkRack(RackID, AmmoID) then
			Result[#Result + 1] = RackID
		end
	end

	return Result
end

local ConVarData1 = GetConVar("acfmenu_data1")
local ConVarData2 = GetConVar("acfmenu_data2")
local ConVarData3 = GetConVar("acfmenu_data3")
local ConVarData4 = GetConVar("acfmenu_data4")
local ConVarData5 = GetConVar("acfmenu_data5")
local ConVarData6 = GetConVar("acfmenu_data6")
local ConVarData7 = GetConVar("acfmenu_data7")
local ConVarData8 = GetConVar("acfmenu_data8")
local ConVarData9 = GetConVar("acfmenu_data9")
local ConVarData10 = GetConVar("acfmenu_data10")

function ACF_GetRoundFromCVars()
	local RoundData = {
		Id            = ConVarData1:GetString(),
		Type          = ConVarData2:GetString(),
		PropLength    = ConVarData3:GetFloat(),
		ProjLength    = ConVarData4:GetFloat(),
		Data5         = ConVarData5:GetFloat(),
		Data6         = ConVarData6:GetFloat(),
		Data7         = ConVarData7:GetString(),
		Data8         = ConVarData8:GetString(),
		Data9         = ConVarData9:GetString(),
		Data10        = ConVarData10:GetFloat(),
	}

	return RoundData
end
