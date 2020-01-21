
ACF_DefineRadarClass("OMNI-AM", {
	name = "Spherical Anti-missile Radar",
	desc = "A missile radar with full 360-degree detection but a limited range. Only detects launched missiles.",
	type = "AM",
	detect = function(Radar)
		return ACFM_GetMissilesInSphere(Radar:LocalToWorld(Radar.Origin), Radar.Range)
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

ACF_DefineRadarClass("OMNI-TGT", {
	name = "Spherical Targeting Radar",
	desc = "A missile radar with full 360-degree detection but a limited range. Will detect enemy vehicles.",
	type = "TGT",
	detect = function(Radar)
		return ACF.GetEntitiesInSphere(Radar:LocalToWorld(Radar.Origin), Radar.Range)
	end,
} )

ACF_DefineRadar("SmallOMNI-TGT", {
	name 	= "Small Spherical Radar",
	desc 	= "A lightweight omni-directional radar with a smaller range.",
	model	= "models/radar/radar_sp_sml.mdl",
	class 	= "OMNI-TGT",
	weight 	= 300,
	range 	= 7874, -- range in inches.
	origin	= "missile1",
} )

ACF_DefineRadar("MediumOMNI-TGT", {
	name 	= "Medium Spherical Radar",
	desc 	= "A omni-directional radar with a regular range.",
	model	= "models/radar/radar_sp_mid.mdl", -- medium one is for now scalled big one - will be changed
	class 	= "OMNI-TGT",
	weight 	= 600,
	range 	= 15748, -- range in inches.
	origin	= "missile1",
} )

ACF_DefineRadar("LargeOMNI-TGT", {
	name 	= "Large Spherical Radar",
	desc 	= "A heavy omni-directional radar with a large range.",
	model	= "models/radar/radar_sp_big.mdl",
	class 	= "OMNI-TGT",
	weight 	= 1200,
	range 	= 31496, -- range in inches.
	origin	= "missile1",
} )
