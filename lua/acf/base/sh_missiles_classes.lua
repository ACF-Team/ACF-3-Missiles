local RegisterClass   = ACF.RegisterClass
local AddSimpleClass  = ACF.AddSimpleClass
local AddClassGroup   = ACF.AddClassGroup
local AddGroupedClass = ACF.AddGroupedClass

do -- Fuze registration function
	ACF.Classes.Fuzes = ACF.Classes.Fuzes or {}

	local Fuzes = ACF.Classes.Fuzes

	function ACF.RegisterFuze(Name, Base)
		return RegisterClass(Name, Base, Fuzes)
	end
end

do -- Guidance registration function
	ACF.Classes.Guidances = ACF.Classes.Guidances or {}

	local Guidances = ACF.Classes.Guidances

	function ACF.RegisterGuidance(Name, Base)
		return RegisterClass(Name, Base, Guidances)
	end
end

do -- Countermeasure registration function
	ACF.Classes.Countermeasures = ACF.Classes.Countermeasures or {}

	local Countermeasures = ACF.Classes.Countermeasures

	function ACF.RegisterCountermeasure(Name, Base)
		return RegisterClass(Name, Base, Countermeasures)
	end
end

do -- Rack registration function
	ACF.Classes.Racks = ACF.Classes.Racks or {}

	local Racks = ACF.Classes.Racks

	local function AddSboxLimit(Data)
		if CLIENT then return end
		if ConVarExists("sbox_max" .. Data.Name) then return end

		CreateConVar("sbox_max" .. Data.Name,
					Data.Amount,
					FCVAR_ARCHIVE + FCVAR_NOTIFY,
					Data.Text or "")
	end

	function ACF.RegisterRack(ID, Data)
		local Class = AddSimpleClass(ID, Racks, Data)

		if not Class.EntClass then
			Class.EntClass = "Rack"
		end

		if not Class.LimitConVar then
			Class.LimitConVar = {
				Name = "_acf_rack",
				Amount = 12,
				Text = "Maximum amount of ACF Racks a player can create."
			}
		end

		AddSboxLimit(Class.LimitConVar)

		return Class
	end
end

do -- Missile registration functions
	ACF.Classes.Missiles = ACF.Classes.Missiles or {}

	local Missiles = ACF.Classes.Missiles
	local Blacklist = {}

	local function SaveBlacklist(Group)
		if not Group.Blacklist then return end

		for _, V in pairs(Group.Blacklist) do
			local Current = Blacklist[V]

			if not Current then
				Blacklist[V] = {
					[Group.ID] = true
				}
			else
				Current[Group.ID] = true
			end
		end
	end

	function ACF.RegisterMissileClass(ID, Data)
		local Group = AddClassGroup(ID, Missiles, Data)

		if not Group.Entity then
			Group.Entity = "acf_rack"
		end

		SaveBlacklist(Group)

		return Group
	end

	function ACF.RegisterMissile(ID, ClassID, Data)
		local Class = AddGroupedClass(ID, ClassID, Missiles, Data)

		Class.Destiny = "Missiles"

		return Class
	end

	hook.Add("OnClassLoaded", "ACF Missiles Ammo Blacklist", function(ID, Class)
		if not Blacklist[ID] then return end
		if not Class.Blacklist then return end

		local ClassList = Class.Blacklist
		local List = Blacklist[ID]

		for K in pairs(List) do
			ClassList[K] = true
		end
	end)
end
