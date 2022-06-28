local Classes = ACF.Classes
local Racks   = Classes.Racks
local Entries = {}


function Racks.Register(ID, Data)
	local Class = Classes.AddSimple(ID, Entries, Data)

	if not Class.EntType then -- TODO: Replace with flag CanDelayMotor
		Class.EntType = "Rack"
	end

	if not Class.LimitConVar then
		Class.LimitConVar = {
			Name   = "_acf_rack",
			Amount = 12,
			Text   = "Maximum amount of ACF Racks a player can create."
		}
	end

	Classes.AddSboxLimit(Class.LimitConVar)

	return Class
end

Classes.AddSimpleFunctions(Racks, Entries)

do -- Discontinued functions
	function ACF_DefineRackClass(ID)
		print("Attempted to register rack class " .. ID .. " with a discontinued function. Racks are no longer separated in classes.")
	end

	function ACF_DefineRack(ID)
		print("Attempted to register rack " .. ID .. " with a discontinued function. Use ACF.RegisterRack instead.")
	end
end
