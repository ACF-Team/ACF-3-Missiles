function ACF.RegisterFuse(Name, Base)
	return ACF.RegisterClass(Name, Base, ACF.Fuse)
end

function ACF.RegisterGuidance(Name, Base)
	return ACF.RegisterClass(Name, Base, ACF.Guidance)
end

function ACF.RegisterCountermeasure(Name, Base)
	return ACF.RegisterClass(Name, Base, ACF.Countermeasure)
end
