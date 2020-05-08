do -- Fuze registration function
	ACF.Classes.Fuzes = ACF.Classes.Fuzes or {}

	local Fuzes = ACF.Classes.Fuzes

	function ACF.RegisterFuze(Name, Base)
		return ACF.RegisterClass(Name, Base, Fuzes)
	end
end

do -- Guidance registration function
	ACF.Classes.Guidances = ACF.Classes.Guidances or {}

	local Guidances = ACF.Classes.Guidances

	function ACF.RegisterGuidance(Name, Base)
		return ACF.RegisterClass(Name, Base, Guidances)
	end
end

do -- Countermeasure registration function
	ACF.Classes.Countermeasures = ACF.Classes.Countermeasures or {}

	local Countermeasures = ACF.Classes.Countermeasures

	function ACF.RegisterCountermeasure(Name, Base)
		return ACF.RegisterClass(Name, Base, Countermeasures)
	end
end
