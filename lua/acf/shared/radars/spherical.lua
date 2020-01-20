
ACF_DefineRadarClass("OMNI-AM", {
	name = "Spherical Anti-missile Radar",
	desc = "A missile radar with full 360-degree detection but a limited range. Only detects launched missiles.",
	type = "AM",
	detect = function(Radar)
		return ACFM_GetMissilesInSphere(Radar:GetPos(), Radar.Range)
	end,
} )

ACF_DefineRadar("SmallOMNI-AM", {
	name 	= "Small Spherical Missile Radar",
	desc 	= "A lightweight omni-directional radar with a smaller range.",
	model	= "models/radar/radar_sp_sml.mdl",
	class 	= "OMNI-AM",
	weight 	= 300,
	range 	= 7874, -- range in inches.
	origin	= "missile1",
} )

ACF_DefineRadar("MediumOMNI-AM", {
	name 	= "Medium Spherical Missile Radar",
	desc 	= "A omni-directional radar with a regular range.",
	model	= "models/radar/radar_sp_mid.mdl", -- medium one is for now scalled big one - will be changed
	class 	= "OMNI-AM",
	weight 	= 600,
	range 	= 15748, -- range in inches.
	origin	= "missile1",
} )

ACF_DefineRadar("LargeOMNI-AM", {
	name 	= "Large Spherical Missile Radar",
	desc 	= "A heavy omni-directional radar with a large range.",
	model	= "models/radar/radar_sp_big.mdl",
	class 	= "OMNI-AM",
	weight 	= 1200,
	range 	= 31496, -- range in inches.
	origin	= "missile1",
} )

ACF_DefineRadarClass("OMNI-A2A", {
	name = "Spherical Air-To-Air Radar",
	desc = "A missile radar with full 360-degree detection but a limited range. Will detect enemy vehicles.",
	type = "A2A",
	detect = function(Radar)
		return ACF.GetEntitiesInSphere(Radar:GetPos(), Radar.Range)
	end,
} )

ACF_DefineRadar("SmallOMNI-A2A", {
	name 	= "Small Spherical Radar",
	desc 	= "A lightweight omni-directional radar with a smaller range.",
	model	= "models/radar/radar_sp_sml.mdl",
	class 	= "OMNI-A2A",
	weight 	= 300,
	range 	= 7874, -- range in inches.
	origin	= "missile1",
} )

ACF_DefineRadar("MediumOMNI-A2A", {
	name 	= "Medium Spherical Radar",
	desc 	= "A omni-directional radar with a regular range.",
	model	= "models/radar/radar_sp_mid.mdl", -- medium one is for now scalled big one - will be changed
	class 	= "OMNI-A2A",
	weight 	= 600,
	range 	= 15748, -- range in inches.
	origin	= "missile1",
} )

ACF_DefineRadar("LargeOMNI-A2A", {
	name 	= "Large Spherical Radar",
	desc 	= "A heavy omni-directional radar with a large range.",
	model	= "models/radar/radar_sp_big.mdl",
	class 	= "OMNI-A2A",
	weight 	= 1200,
	range 	= 31496, -- range in inches.
	origin	= "missile1",
} )
