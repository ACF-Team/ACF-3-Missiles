local Missiles = ACF.Classes.Missiles

Missiles.Register("FFAR", {
	Name		= "Folding-Fin Aerial Rockets",
	Description	= "Small rockets which fit in tubes or pods. Rapid-firing and versatile.",
	Sound		= "acf_missiles/missiles/missile_rocket.mp3",
	Effect		= "Rocket Motor",
	Spread		= 1,
	Blacklist	= { "AP", "APHE", "HP", "FL" }
})

Missiles.RegisterItem("40mmFFAR", "FFAR", {
	Name		= "40mm Pod Rocket",
	Description	= "A tiny, unguided rocket. Useful for anti-infantry, smoke and suppression. Folding fins allow the rocket to be stored in pods, which defend them from damage.",
	Model		= "models/missiles/ffar_40mm.mdl",
	Caliber		= 40,
	Mass		= 4,
	Length		= 60,
	Year		= 1960,
	ReloadTime	= 2,
	ExhaustPos  = Vector(-12),
	Racks		= { ["40mm7xPOD"] = true },
	Guidance	= { Dumb = true },
	Navigation  = "Chase",
	Fuzes		= { Contact = true, Timed = true },
	Agility     = 1,
	ArmDelay	= 0.1,
	Round = {
		Model			= "models/missiles/ffar_40mm.mdl",
		RackModel		= "models/missiles/ffar_40mm_closed.mdl",
		MaxLength		= 60,
		Armor			= 5,
		ProjLength		= 25,
		PropLength		= 35,
		Thrust			= 150000,   -- in kg*in/s^2
		FuelConsumption = 0.015,    -- in g/s/f
		StarterPercent	= 0.1,
		MaxAgilitySpeed = 1,        -- in m/s
		DragCoef		= 0.0005,
		FinMul			= 0.01,
		GLimit          = 1,
		TailFinMul		= 0.004,
		PenMul			= 0.91,
		ActualLength 	= 60,
		ActualWidth		= 4
	},
	Preview = {
		Height = 100,
		FOV    = 60,
	},
})

Missiles.RegisterItem("57mmFFAR", "FFAR", {
	Name		= "57mm Pod Rocket",
	Description	= "A small, spammy rocket with light anti-armor capabilities. Works well on technicals.",
	Model		= "models/missiles/ffar_40mm.mdl",
	Caliber		= 57,
	Mass		= 4,
	Length		= 85,
	Year		= 1956,
	ReloadTime	= 2,
	ExhaustPos  = Vector(-12),
	Racks		= { ["57mm32xPOD"] = true , ["57mm16xPOD"] = true},
	Navigation	= "Chase",
	Guidance	= { Dumb = true },
	Fuzes		= { Contact = true, Timed = true },
	Agility		= 1,
	ArmDelay	= 0.1,
	Round = {
		Model			= "models/missiles/ffar_70mm.mdl",
		RackModel		= "models/missiles/ffar_70mm_closed.mdl",
		MaxLength		= 85,
		Armor			= 5,
		ProjLength		= 35,
		PropLength		= 50,
		Thrust			= 210000, -- in kg*in/s^2
		FuelConsumption	= 0.015,
		StarterPercent 	= 0.2,
		MaxAgilitySpeed	= 1,
		DragCoef		= 0.0007,
		FinMul			= 0.01,
		GLimit			= 1,
		TailFinMul		= 0.003,
		PenMul			= 1.3,
		ActualLength	= 85,
		ActualWidth		= 5.7,
	},
	Preview = {
		Height = 100,
		FOV    = 60,
	},
})

Missiles.RegisterItem("70mmFFAR", "FFAR", {
	Name		= "70mm Pod Rocket",
	Description	= "A small, unguided rocket. Useful against light vehicles and infantry. Folding fins allow the rocket to be stored in pods, which defend them from damage.",
	Model		= "models/missiles/ffar_70mm.mdl",
	Caliber		= 70,
	Mass		= 6,
	Length		= 106,
	Year		= 1960,
	ReloadTime	= 5,
	ExhaustPos  = Vector(-21),
	Racks		= { ["70mm7xPOD"] = true, ["70mm19xPOD"] = true },
	Guidance	= { Dumb = true },
	Navigation  = "Chase",
	Fuzes		= { Contact = true, Timed = true },
	Agility		= 0.05,
	ArmDelay	= 0.1,
	Round = {
		Model			= "models/missiles/ffar_70mm.mdl",
		RackModel		= "models/missiles/ffar_70mm_closed.mdl",
		MaxLength		= 106,
		Armor			= 5,
		ProjLength		= 66,
		PropLength		= 40,
		Thrust			= 850000,	-- in kg*in/s^2
		FuelConsumption = 0.005,	-- in g/s/f
		StarterPercent	= 0.1,
		MaxAgilitySpeed = 1,        -- in m/s
		DragCoef		= 0.002,
		FinMul			= 0.01,
		GLimit          = 1,
		TailFinMul		= 0.005,
		PenMul			= 0.85,
		ActualLength 	= 106,
		ActualWidth		= 7
	},
	Preview = {
		Height = 100,
		FOV    = 60,
	},
})

Missiles.RegisterItem("80mmFFAR", "FFAR", {
	Name		= "80mm Rocket Pod",
	Description	= "A large aerial rocket designed for use against ground targets. Good HEAT performance.",
	Model		= "models/missiles/ffar_70mm.mdl",
	Caliber		= 80,
	Mass		= 6,
	Length		= 127,
	Year		= 1960,
	ReloadTime	= 5,
	ExhaustPos  = Vector(-21),
	Racks		= { ["80mm20xPOD"] = true },
	Navigation	= "Chase",
	Guidance	= { Dumb = true },
	Fuzes		= { Contact = true, Timed = true },
	Agility		= 0.05,
	ArmDelay	= 0.1,
	Round = {
		Model			= "models/missiles/ffar_70mm.mdl",
		RackModel		= "models/missiles/ffar_70mm_closed.mdl",
		MaxLength		= 127,
		Armor			= 5,
		ProjLength		= 76,
		PropLength		= 51,
		Thrust			= 700000,	-- in kg*in/s^2
		FuelConsumption = 0.006,	-- in g/s/f
		StarterPercent	= 0.1,
		MaxAgilitySpeed = 1,        -- in m/s
		DragCoef		= 0.0023,
		FinMul			= 0.01,
		GLimit          = 1,
		TailFinMul		= 0.005,
		PenMul			= 0.85,
		ActualLength 	= 127,
		ActualWidth		= 8
	},
	Preview = {
		Height = 100,
		FOV    = 60,
	},
})

Missiles.RegisterItem("Zuni ASR", "FFAR", {
	Name		= "127mm Pod Rocket",
	Description	= "A heavy 5in air to surface unguided rocket, able to provide heavy suppressive fire in a single pass.",
	Model		= "models/ghosteh/zuni.mdl",
	Caliber		= 127,
	Mass		= 45,
	Length		= 200,
	Year		= 1957,
	ReloadTime	= 10,
	ExhaustPos  = Vector(-45),
	Racks		= { ["127mm4xPOD"] = true },
	Guidance	= { Dumb = true },
	Navigation  = "Chase",
	Fuzes		= { Contact = true, Timed = true, Optical = true, Radio = true },
	Agility		= 0.05,
	ArmDelay	= 0.1,
	Round = {
		Model			= "models/ghosteh/zuni.mdl",
		RackModel		= "models/ghosteh/zuni_folded.mdl",
		MaxLength		= 200,
		Armor			= 5,
		ProjLength		= 90,
		PropLength		= 110,
		Thrust			= 1900000,   -- in kg*in/s^2
		FuelConsumption = 0.010,    -- in g/s/f
		StarterPercent	= 0.1,
		MaxAgilitySpeed = 1,        -- in m/s
		DragCoef		= 0.004,
		FinMul			= 0.005,
		GLimit          = 1,
		TailFinMul		= 0.004,
		PenMul			= 1,
		ActualLength 	= 200,
		ActualWidth		= 12.7
	},
	Preview = {
		Height = 100,
		FOV    = 60,
	},
})
