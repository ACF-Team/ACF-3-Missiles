
ACF.RegisterMissileClass("BOMB", {
	Name		= "Free Falling Bombs",
	Description	= "Despite their lack of guidance and sophistication, they are exceptionally destructive on impact relative to their weight.",
	Sound		= "acf_missiles/fx/clunk.mp3",
	NoThrust	= true,
	Spread		= 1,
	Blacklist	= { "AP", "APHE", "HP", "FL" }
})

ACF.RegisterMissile("50kgBOMB", "BOMB", {
	Name		= "50kg Free Falling Bomb",
	Description	= "Old WW2 100lb bomb, most effective vs exposed infantry and light trucks.",
	Model		= "models/bombs/fab50.mdl",
	Length		= 5,
	Caliber		= 50,
	Mass		= 50,
	Year		= 1936,
	Diameter	= 8.35 * 25.4, -- in mm
	Offset		= Vector(-6, 0, 0),
	Racks		= { ["1xRK_small"] = true, ["1xRK"] = true, ["2xRK"] = true, ["4xRK"] = true },
	Guidance	= { Dumb = true },
	Fuzes		= { Contact = true, Optical = true, Cluster = true },
	Agility		= 1,
	ArmDelay	= 0.5,
	Round = {
		Model			= "models/bombs/fab50.mdl",
		MaxLength		= 50,
		Armor			= 25,
		PropMass		= 0,
		Thrust			= 1, -- in kg*in/s^2
		BurnRate		= 1, -- in cm^3/s
		StarterPercent	= 0.01,
		MinSpeed		= 1,
		DragCoef		= 0.002,
		FinMul			= 0.008,
		PenMul			= math.sqrt(0.6)
	},
})

ACF.RegisterMissile("100kgBOMB", "BOMB", {
	Name		= "100kg Free Falling Bomb",
	Description	= "An old 250lb WW2 bomb, as used by Soviet bombers to destroy enemies of the Motherland.",
	Model		= "models/bombs/fab100.mdl",
	Length		= 50,
	Caliber		= 100,
	Mass		= 100,
	Year		= 1939,
	Diameter	= 10.5 * 25.4, -- in mm
	Offset		= Vector(-6, 0, 0),
	Racks		= { ["1xRK_small"] = true, ["1xRK"] = true, ["2xRK"] = true, ["4xRK"] = true },
	Guidance	= { Dumb = true },
	Fuzes		= { Contact = true, Optical = true, Cluster = true },
	Agility		= 1,
	ArmDelay	= 1,
	Round = {
		Model			= "models/bombs/fab100.mdl",
		MaxLength		= 100,
		Armor			= 25,
		PropMass		= 0,
		Thrust			= 1, -- in kg*in/s^2
		BurnRate		= 1, -- in cm^3/s
		StarterPercent	= 0.005,
		MinSpeed		= 1,
		DragCoef		= 0.002,
		FinMul			= 0.007,
		PenMul			= math.sqrt(0.6)
	},
})

ACF.RegisterMissile("250kgBOMB", "BOMB", {
	Name		= "250kg Free Falling Bomb",
	Description	= "A heavy 500lb bomb, widely used as a tank buster on various WW2 aircraft.",
	Model		= "models/bombs/fab250.mdl",
	Length		= 5000,
	Caliber		= 125,
	Mass		= 250,
	Year		= 1941,
	Diameter	= 12.7 * 25.4, -- in mm
	Offset		= Vector(-14, 0, 0),
	Racks		= { ["1xRK"] = true, ["2xRK"] = true, ["3xRK"] = true, ["4xRK"] = true },
	Guidance	= { Dumb = true },
	Fuzes		= { Contact = true, Optical = true, Cluster = true },
	Agility		= 1,
	ArmDelay	= 1,
	Round = {
		Model			= "models/bombs/fab250.mdl",
		MaxLength		= 250,
		Armor			= 25,
		PropMass		= 0,
		Thrust			= 1, -- in kg*in/s^2
		BurnRate		= 1, -- in cm^3/s
		StarterPercent	= 0.005,
		MinSpeed		= 1,
		DragCoef		= 0.002,
		FinMul			= 0.005,
		PenMul			= math.sqrt(0.6)
	},
})

ACF.RegisterMissile("500kgBOMB", "BOMB", {
	Name		= "500kg Free Falling Bomb",
	Description	= "A 1000lb bomb, as found in the heavy bombers of late WW2. Best used against fortifications or immobile targets.",
	Model		= "models/bombs/fab500.mdl",
	Length		= 15000,
	Caliber		= 300,
	Mass		= 500,
	Year		= 1943,
	Diameter	= 15.25 * 25.4, -- in mm
	Offset		= Vector(-14, 0, 0),
	Racks		= { ["1xRK"] = true, ["2xRK"] = true, ["4xRK"] = true },
	Guidance	= { Dumb = true },
	Fuzes		= { Contact = true, Optical = true, Cluster = true },
	Agility		= 1,
	ArmDelay	= 2,
	Round = {
		Model			= "models/bombs/fab500.mdl",
		MaxLength		= 200,
		Armor			= 25,
		PropMass		= 0,
		Thrust			= 1, -- in kg*in/s^2
		BurnRate		= 1, -- in cm^3/s
		StarterPercent	= 0.005,
		MinSpeed		= 1,
		DragCoef		= 0.002,
		FinMul			= 0.004,
		PenMul			= math.sqrt(0.6)
	},
})

ACF.RegisterMissile("1000kgBOMB", "BOMB", {
	Name		= "1000kg Free Falling Bomb",
	Description	= "A 2000lb bomb. As close to a nuke as you can get in ACF, this munition will turn everything it touches to ashes. Handle with care.",
	Model		= "models/bombs/an_m66.mdl",
	Length		= 30000,
	Caliber		= 300,
	Mass		= 1000,
	Year		= 1945,
	Diameter	= 22 * 25.4, -- in mm
	Offset		= Vector(-10, 0, 0),
	Racks		= { ["1xRK"] = true, ["2xRK"] = true },
	Guidance	= { Dumb = true },
	Fuzes		= { Contact = true, Optical = true, Cluster = true },
	Agility		= 1,
	ArmDelay	= 3,
	Round = {
		Model			= "models/bombs/an_m66.mdl",
		MaxLength		= 375,
		Armor			= 25,
		PropMass		= 0,
		Thrust			= 1, -- in kg*in/s^2
		BurnRate		= 1, -- in cm^3/s
		StarterPercent	= 0.005,
		MinSpeed		= 1,
		DragCoef		= 0.002,
		FinMul			= 0.004,
		PenMul			= math.sqrt(0.6)
	},
})
