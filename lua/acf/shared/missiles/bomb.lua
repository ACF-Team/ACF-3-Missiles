
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
	ReloadTime	= 10,
	Offset		= Vector(-6, 0, 0),
	Racks		= { ["1xRK_small"] = true, ["1xRK"] = true, ["2xRK"] = true, ["4xRK"] = true },
	Guidance	= { Dumb = true },
	Fuzes		= { Contact = true, Optical = true, Cluster = true },
	Agility		= 1,
	ArmDelay	= 0.5,
	Round = {
		Model			= "models/bombs/fab50.mdl",
		MaxLength		= 50,
		Armor			= 10,
		PropMass		= 0,
		Thrust			= 1, 	-- in kg*in/s^2
		FuelConsumption = 0.1,	-- in g/s/f
		StarterPercent	= 0.01,
		MinSpeed		= 1,
		DragCoef		= 0.002,
		FinMul			= 0.48,
		TailFinMul		= 10,
		PenMul			= math.sqrt(0.6),
		ActualLength 	= 37,
		ActualWidth		= 9.2
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
	ReloadTime	= 15,
	Offset		= Vector(-6, 0, 0),
	Racks		= { ["1xRK_small"] = true, ["1xRK"] = true, ["2xRK"] = true, ["4xRK"] = true },
	Guidance	= { Dumb = true },
	Fuzes		= { Contact = true, Optical = true, Cluster = true },
	Agility		= 1,
	ArmDelay	= 1,
	Round = {
		Model			= "models/bombs/fab100.mdl",
		MaxLength		= 100,
		Armor			= 10,
		PropMass		= 0,
		Thrust			= 1, 	-- in kg*in/s^2
		FuelConsumption = 0.1,	-- in g/s/f
		StarterPercent	= 0.005,
		MinSpeed		= 1,
		DragCoef		= 0.002,
		FinMul			= 0.42,
		TailFinMul		= 20,
		PenMul			= math.sqrt(0.6),
		ActualLength 	= 44,
		ActualWidth		= 12
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
	ReloadTime	= 25,
	Offset		= Vector(-14, 0, 0),
	Racks		= { ["1xRK"] = true, ["2xRK"] = true, ["3xRK"] = true, ["4xRK"] = true },
	Guidance	= { Dumb = true },
	Fuzes		= { Contact = true, Optical = true, Cluster = true },
	Agility		= 1,
	ArmDelay	= 1,
	Round = {
		Model			= "models/bombs/fab250.mdl",
		MaxLength		= 250,
		Armor			= 10,
		PropMass		= 0,
		Thrust			= 1, 	-- in kg*in/s^2
		FuelConsumption = 0.1,	-- in g/s/f
		StarterPercent	= 0.005,
		MinSpeed		= 1,
		DragCoef		= 0.002,
		FinMul			= 0.3,
		TailFinMul		= 20,
		PenMul			= math.sqrt(0.6),
		ActualLength 	= 83,
		ActualWidth		= 14.5
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
	ReloadTime	= 40,
	Offset		= Vector(-14, 0, 0),
	Racks		= { ["1xRK"] = true, ["2xRK"] = true, ["4xRK"] = true },
	Guidance	= { Dumb = true },
	Fuzes		= { Contact = true, Optical = true, Cluster = true },
	Agility		= 1,
	ArmDelay	= 2,
	Round = {
		Model			= "models/bombs/fab500.mdl",
		MaxLength		= 200,
		Armor			= 10,
		PropMass		= 0,
		Thrust			= 1, 	-- in kg*in/s^2
		FuelConsumption = 0.1,	-- in g/s/f
		StarterPercent	= 0.005,
		MinSpeed		= 1,
		DragCoef		= 0.002,
		FinMul			= 0.24,
		TailFinMul		= 30,
		PenMul			= math.sqrt(0.6),
		ActualLength 	= 85,
		ActualWidth		= 17.5
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
	ReloadTime	= 60,
	Offset		= Vector(-10, 0, 0),
	Racks		= { ["1xRK"] = true, ["2xRK"] = true },
	Guidance	= { Dumb = true },
	Fuzes		= { Contact = true, Optical = true, Cluster = true },
	Agility		= 1,
	ArmDelay	= 3,
	Round = {
		Model			= "models/bombs/an_m66.mdl",
		MaxLength		= 375,
		Armor			= 10,
		PropMass		= 0,
		Thrust			= 1, 	-- in kg*in/s^2
		FuelConsumption = 0.1,	-- in g/s/f
		StarterPercent	= 0.005,
		MinSpeed		= 1,
		DragCoef		= 0.002,
		FinMul			= 0.24,
		TailFinMul		= 40,
		PenMul			= math.sqrt(0.6),
		ActualLength 	= 90.5,
		ActualWidth		= 22.7
	},
})
