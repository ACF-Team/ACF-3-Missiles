ACF.RegisterRack("1xRK", {
	Name		= "Single Munition Rack",
	Description	= "A rather long but light rack that can hold a single missile or bomb.",
	Model		= "models/missiles/rkx1.mdl",
	Mass		= 79,
	RoFMod		= 2,
	Year		= 1915,
	MagSize		= 1,
	Armor		= 10,

	MountPoints = {
		{ Name = "missile1", Offset = Vector(0, 0, 2), ScaleDir = Vector(0, 0, -1) }
	}
})

ACF.RegisterRack("1xRK_small", {
	Name		= "Small Single Munition Rack",
	Description	= "A shorter version of the regular single munition rack, tends to be limited to smaller munitions.",
	Model		= "models/missiles/rkx1_sml.mdl",
	Mass		= 31,
	RoFMod		= 2,
	Year		= 1915,
	MagSize		= 1,
	Armor		= 10,

	MountPoints = {
		{ Name = "missile1", Offset = Vector(0, 0, 2), ScaleDir = Vector(0, 0, -1) }
	}
})

ACF.RegisterRack("2xRK", {
	Name		= "Dual Munitions Rack",
	Description	= "A rather lightweight rack with two mounting points separated horizontally.",
	Model		= "models/missiles/rack_double.mdl",
	Mass		= 160,
	Year		= 1915,
	MagSize		= 2,
	Armor		= 20,

	MountPoints = {
		{ Name = "missile1", Offset = Vector(4, -16.5, -1.7), ScaleDir = Vector(0, -1, 0) },
		{ Name = "missile2", Offset = Vector(4, 16.5, -1.7),	ScaleDir = Vector(0, 1, 0) }
	}
})

ACF.RegisterRack("3xRK", {
	Name		= "Triple Munitions Rack",
	Description	= "Based on the BRU-42 Triple Ejector Rack, it can hold up to three missiles or bombs.",
	Model		= "models/missiles/bomb_3xrk.mdl",
	Mass		= 61,
	Year		= 1936,
	Armor		= 10,
	MagSize		= 3,

	MountPoints = {
		{ Name = "missile1", Offset = Vector(1.9, 0, -12.6), ScaleDir = Vector(-0.2, 0, -0.3) },
		{ Name = "missile2", Offset = Vector(2.26, 6.42, -3.6), ScaleDir = Vector(-0.2, 0.3, -0.1) },
		{ Name = "missile3", Offset = Vector(2.26, -6.42, -3.6), ScaleDir = Vector(-0.2, -0.3, -0.1) },
	}
})

ACF.RegisterRack("4xRK", {
	Name		= "Quad Munitions Rack",
	Description	= "Despite its rather small size, it can hold up to 4 different munitions.",
	Model		= "models/missiles/rack_quad.mdl",
	Mass		= 92,
	Year		= 1936,
	Armor		= 10,
	MagSize		= 4,

	MountPoints = {
		{ Name = "missile1", Offset = Vector(0, 12.5, 9), ScaleDir = Vector(0, 1, 0) },
		{ Name = "missile2", Offset = Vector(0, -12.5, 9), ScaleDir = Vector(0, -1, 0) },
		{ Name = "missile3", Offset = Vector(0, -12.5, -5), ScaleDir = Vector(0, 0, -1) },
		{ Name = "missile4", Offset = Vector(0, 12.5, -5), ScaleDir = Vector(0, 0, -1) }
	}
})

ACF.RegisterRack("2x AGM-114", {
	Name		= "Dual Hellfire Rack",
	Description	= "Based on the upper section of the M299 Launcher, can load up to two missiles.",
	Model		= "models/missiles/agm_114_2xrk.mdl",
	Mass		= 60,
	Year		= 1984,
	MagSize		= 2,
	Armor		= 5,

	MountPoints = {
		{ Name = "missile1", Offset = Vector(0, -8.1, 5.4), ScaleDir = Vector(0, 0, -1) },
		{ Name = "missile2", Offset = Vector(0, 8.1, 5.4), ScaleDir = Vector(0, 0, -1) },
	}
})

ACF.RegisterRack("4x AGM-114", {
	Name		= "Quad Hellfire Rack",
	Description	= "Based on the M299 Launcher, it's capable of loading up to four missiles.",
	Model		= "models/missiles/agm_114_4xrk.mdl",
	Mass		= 162,
	Year		= 1984,
	MagSize		= 4,
	Armor		= 5,

	MountPoints = {
		{ Name = "missile1", Offset = Vector(0, -8.1, 5.4), ScaleDir = Vector(0, 0, -1) },
		{ Name = "missile2", Offset = Vector(0, 8.1, 5.4), ScaleDir = Vector(0, 0, -1) },
		{ Name = "missile3", Offset = Vector(0, -8.1, -12.6), ScaleDir = Vector(0, 0, -1) },
		{ Name = "missile4", Offset = Vector(0, 8.1, -12.6), ScaleDir = Vector(0, 0, -1) }
	}
})

ACF.RegisterRack("1xAT3RK", {
	Name		= "Single 9M14 Rack",
	Description	= "Based on the 9P111 Portable Launcher, it can load a single AT-3 missile.",
	Model		= "models/missiles/at3rk.mdl",
	Mass		= 17,
	RoFMod		= 1.4,
	Year		= 1969,
	MagSize		= 1,
	Armor		= 2.5,

	MountPoints = {
		{ Name = "missile1", Offset = Vector(3.2, 0, 3.4), ScaleDir = Vector(0, 0, -1) }
	}
})

ACF.RegisterRack("1xAT3RKS", {
	Name		= "Single 9M14 Rail",
	Description	= "Consisting of only the launch rail, it can be used to carry a single AT-3 missile on any kind of vehicle.",
	Model		= "models/missiles/at3rs.mdl",
	Mass		= 8,
	RoFMod		= 1,
	Year		= 1972,
	MagSize		= 1,
	Armor		= 2.5,

	MountPoints = {
		{ Name = "missile1", Offset = Vector(21, 0, 8.6), ScaleDir = Vector(0, 0, -1) }
	}
})
