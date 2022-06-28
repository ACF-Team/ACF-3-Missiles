local Classes = ACF.Classes
local Fuzes   = Classes.Fuzes
local Entries = {}


function Fuzes.Register(ID, Base)
	return Classes.AddObjectClass(ID, Base, Entries)
end

Classes.AddSimpleFunctions(Fuzes, Entries)
