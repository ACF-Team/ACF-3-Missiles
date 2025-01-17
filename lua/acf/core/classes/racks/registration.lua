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