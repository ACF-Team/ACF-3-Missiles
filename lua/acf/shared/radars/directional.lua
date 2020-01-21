
ACF_DefineRadarClass("DIR-AM", {
	name = "Directional Anti-missile Radar",
	desc = "A radar with unlimited range but a limited view cone. Only detects launched missiles.",
	type = "AM",
	detect = function(Radar)
		return ACFM_GetMissilesInCone(Radar:LocalToWorld(Radar.Origin), Radar:GetForward(), Radar.ConeDegs)
	end,
} )

ACF_DefineRadar("SmallDIR-AM", {
	name 		= "Small Directional Missile Radar",
	desc 		= "A lightweight directional radar with a smaller view cone.",
	model		= "models/radar/radar_sml.mdl",
	class 		= "DIR-AM",
	weight 		= 200,
	viewcone 	= 15, -- half of the total cone.  'viewcone = 30' means 60 degs total viewcone.
	origin		= "missile1",
	delay		= 2,
} )

ACF_DefineRadar("MediumDIR-AM", {
	name 		= "Medium Directional Missile Radar",
	desc 		= "A directional radar with a regular view cone.",
	model		= "models/radar/radar_mid.mdl", -- medium one is for now scalled big one - will be changed
	class 		= "DIR-AM",
	weight 		= 400,
	viewcone 	= 35, -- half of the total cone.  'viewcone = 30' means 60 degs total viewcone.
	origin		= "missile1",
	delay		= 4,
} )

ACF_DefineRadar("LargeDIR-AM", {
	name 		= "Large Directional Missile Radar",
	desc 		= "A heavy directional radar with a large view cone.",
	model		= "models/radar/radar_big.mdl",
	class 		= "DIR-AM",
	weight 		= 800,
	viewcone 	= 80, -- half of the total cone.  'viewcone = 30' means 60 degs total viewcone.
	origin		= "missile1",
	delay		= 8,
} )

ACF_DefineRadarClass("DIR-TGT", {
	name = "Directional Targeting Radar",
	desc = "A radar with unlimited range but a limited view cone. Will detect enemy vehicles.",
	type = "TGT",
	detect = function(Radar)
		return ACF.GetEntitiesInCone(Radar:LocalToWorld(Radar.Origin), Radar:GetForward(), Radar.ConeDegs)
	end,
})

ACF_DefineRadar("SmallDIR-TGT", {
	name 		= "Small Directional Radar",
	desc 		= "A lightweight directional radar with a smaller view cone.",
	model		= "models/radar/radar_sml.mdl",
	class 		= "DIR-TGT",
	weight 		= 200,
	viewcone 	= 15, -- half of the total cone.  'viewcone = 30' means 60 degs total viewcone.
	origin		= "missile1",
	delay		= 2,
} )

ACF_DefineRadar("MediumDIR-TGT", {
	name 		= "Medium Directional Radar",
	desc 		= "A directional radar with a regular view cone.",
	model		= "models/radar/radar_mid.mdl", -- medium one is for now scalled big one - will be changed
	class 		= "DIR-TGT",
	weight 		= 400,
	viewcone 	= 35, -- half of the total cone.  'viewcone = 30' means 60 degs total viewcone.
	origin		= "missile1",
	delay		= 4,
} )

ACF_DefineRadar("LargeDIR-TGT", {
	name 		= "Large Directional Radar",
	desc 		= "A heavy directional radar with a large view cone.",
	model		= "models/radar/radar_big.mdl",
	class 		= "DIR-TGT",
	weight 		= 800,
	viewcone 	= 80, -- half of the total cone.  'viewcone = 30' means 60 degs total viewcone.
	origin		= "missile1",
	delay		= 8,
} )