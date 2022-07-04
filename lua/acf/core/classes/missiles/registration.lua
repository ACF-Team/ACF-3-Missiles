local Classes  = ACF.Classes
local Missiles = Classes.Missiles
local Entries  = {}


function Missiles.RegisterGroup(ID, Data)
	local Group = Classes.AddGroup(ID, Entries, Data)

	if not Group.Entity then
		Group.Entity = "acf_rack"
	end

	return Group
end

function Missiles.Register(ID, ClassID, Data)
	local Class = Classes.AddGroupItem(ID, ClassID, Entries, Data)

	Class.Destiny = "Missiles"

	return Class
end

Classes.AddGroupedFunctions(Missiles, Entries)
