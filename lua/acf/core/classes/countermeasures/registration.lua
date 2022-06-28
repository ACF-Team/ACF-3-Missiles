local Classes  = ACF.Classes
local Measures = Classes.Countermeasures
local Entries  = {}


function Measures.Register(ID, Base)
	return Classes.AddObjectClass(ID, Base, Entries)
end

Classes.AddSimpleFunctions(Measures, Entries)
