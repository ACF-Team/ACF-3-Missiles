local Missiles = ACF.Classes.Missiles

Missiles.Register("BOMB", {
	Name		= "Free Falling Bombs",
	Description	= "Despite their lack of guidance and sophistication, they are exceptionally destructive on impact relative to their weight.",
	Sound		= "acf_missiles/fx/clunk.mp3",
	NoThrust	= true,
	Spread		= 1,
	Blacklist	= { "AP", "APHE", "HP", "FL" }
})

Missiles.RegisterItem("50kgBOMB", "BOMB", {
	Name		= "50kg Free Falling Bomb",
	Description	= "Old WW2 100lb bomb, most effective vs exposed infantry and light trucks.",
	Model		= "models/bombs/fab50.mdl",
	Length		= 109,
	Caliber		= 200,
	Mass		= 50,
	Year		= 1936,
	Diameter	= 8.35 * 25.4, -- in mm
	ReloadTime	= 10,
	Offset		= Vector(-6, 0, 0),
	Racks		= { ["1xRK_small"] = true, ["1xRK"] = true, ["2xRK"] = true, ["4xRK"] = true },
	Guidance	= { Dumb = true },
	Navigation  = "Chase",
	Fuzes		= { Contact = true, Optical = true},
	Agility		= 1,
	ArmDelay	= 0.5,
	Round = {
		Model           = "models/bombs/fab50.mdl",
		MaxLength       = 109,
		Armor           = 10,
		ProjLength      = 50,
		PropLength      = 0,
		Thrust          = 1,    -- in kg*in/s^2
		FuelConsumption = 0.1,  -- in g/s/f
		StarterPercent  = 0.01,
		MaxAgilitySpeed = 1,    -- in m/s
		DragCoef        = 0.01,
		FinMul          = 0.001,
		GLimit          = 1,
		TailFinMul      = 10,
		PenMul          = 1,
		FillerRatio     = 0.78,
		ActualLength    = 109,
		ActualWidth     = 20
	},
	Preview = {
		FOV = 75,
	},
})

Missiles.RegisterItem("100kgBOMB", "BOMB", {
	Name		= "100kg Free Falling Bomb",
	Description	= "An old 250lb WW2 bomb, as used by Soviet bombers to destroy enemies of the Motherland.",
	Model		= "models/bombs/fab100.mdl",
	Length		= 106,
	Caliber		= 273,
	Mass		= 100,
	Year		= 1939,
	Diameter	= 10.5 * 25.4, -- in mm
	ReloadTime	= 15,
	Offset		= Vector(-6, 0, 0),
	Racks		= { ["1xRK_small"] = true, ["1xRK"] = true, ["2xRK"] = true, ["4xRK"] = true },
	Guidance	= { Dumb = true },
	Navigation  = "Chase",
	Fuzes		= { Contact = true, Optical = true},
	Agility		= 1,
	ArmDelay	= 1,
	Round = {
		Model           = "models/bombs/fab100.mdl",
		MaxLength       = 106,
		Armor           = 10,
		ProjLength      = 55,
		PropLength      = 0,
		Thrust          = 1,    -- in kg*in/s^2
		FuelConsumption = 0.1,  -- in g/s/f
		StarterPercent  = 0.005,
		MaxAgilitySpeed = 1,    -- in m/s
		DragCoef        = 0.02,
		FinMul          = 0.002,
		GLimit          = 1,
		TailFinMul      = 30,
		PenMul          = 1,
		FillerRatio     = 0.78,
		ActualLength    = 106,
		ActualWidth     = 27.3
	},
	Preview = {
		FOV = 80,
	},
})

Missiles.RegisterItem("250kgBOMB", "BOMB", {
	Name		= "250kg Free Falling Bomb",
	Description	= "A heavy 500lb bomb, widely used as a tank buster on various WW2 aircraft.",
	Model		= "models/bombs/fab250.mdl",
	Length		= 145,
	Caliber		= 325,
	Mass		= 250,
	Year		= 1941,
	Diameter	= 12.7 * 25.4, -- in mm
	ReloadTime	= 25,
	Offset		= Vector(-14, 0, 0),
	Racks		= { ["1xRK"] = true, ["2xRK"] = true, ["3xRK"] = true, ["4xRK"] = true },
	Guidance	= { Dumb = true },
	Navigation  = "Chase",
	Fuzes		= { Contact = true, Optical = true},
	Agility		= 1,
	ArmDelay	= 1,
	Round = {
		Model           = "models/bombs/fab250.mdl",
		MaxLength       = 145,
		Armor           = 10,
		ProjLength      = 100,
		PropLength      = 0,
		Thrust          = 1,    -- in kg*in/s^2
		FuelConsumption = 0.1,  -- in g/s/f
		StarterPercent  = 0.005,
		MaxAgilitySpeed = 1,    -- in m/s
		DragCoef        = 0.03,
		FinMul          = 0.003,
		GLimit          = 1,
		TailFinMul      = 50,
		PenMul          = 1,
		FillerRatio     = 0.8,
		ActualLength    = 145,
		ActualWidth     = 32.5
	},
	Preview = {
		FOV = 70,
	},
})

Missiles.RegisterItem("500kgBOMB", "BOMB", {
	Name		= "500kg Free Falling Bomb",
	Description	= "A 1000lb bomb, as found in the heavy bombers of late WW2. Best used against fortifications or immobile targets.",
	Model		= "models/bombs/fab500.mdl",
	Length		= 240,
	Caliber		= 400,
	Mass		= 500,
	Year		= 1943,
	Diameter	= 15.25 * 25.4, -- in mm
	ReloadTime	= 40,
	Offset		= Vector(-14, 0, 0),
	Racks		= { ["1xRK"] = true, ["2xRK"] = true, ["4xRK"] = true },
	Guidance	= { Dumb = true },
	Navigation  = "Chase",
	Fuzes		= { Contact = true, Optical = true},
	Agility		= 1,
	ArmDelay	= 2,
	Round = {
		Model           = "models/bombs/fab500.mdl",
		MaxLength       = 240,
		Armor           = 10,
		ProjLength      = 130,
		PropLength      = 0,
		Thrust          = 1,    -- in kg*in/s^2
		FuelConsumption = 0.1,  -- in g/s/f
		StarterPercent  = 0.005,
		MaxAgilitySpeed = 1,    -- in m/s
		DragCoef        = 0.05,
		FinMul          = 0.005,
		GLimit          = 1,
		TailFinMul      = 70,
		PenMul          = 1,
		FillerRatio     = 0.79,
		ActualLength    = 240,
		ActualWidth     = 40
	},
	Preview = {
		FOV = 70,
	},
})

Missiles.RegisterItem("1000kgBOMB", "BOMB", {
	Name		= "1000kg Free Falling Bomb",
	Description	= "A 2000lb bomb. As close to a nuke as you can get in ACF, this munition will turn everything it touches to ashes. Handle with care.",
	Model		= "models/bombs/an_m66.mdl",
	Length		= 270,
	Caliber		= 500,
	Mass		= 1000,
	Year		= 1945,
	Diameter	= 22 * 25.4, -- in mm
	ReloadTime	= 60,
	Offset		= Vector(-10, 0, 0),
	Racks		= { ["1xRK"] = true, ["2xRK"] = true },
	Guidance	= { Dumb = true },
	Navigation  = "Chase",
	Fuzes		= { Contact = true, Optical = true},
	Agility		= 1,
	ArmDelay	= 3,
	Round = {
		Model           = "models/bombs/an_m66.mdl",
		MaxLength       = 270,
		Armor           = 10,
		ProjLength      = 190,
		PropLength      = 0,
		Thrust          = 1,    -- in kg*in/s^2
		FuelConsumption = 0.1,  -- in g/s/f
		StarterPercent  = 0.005,
		MaxAgilitySpeed = 1,    -- in m/s
		DragCoef        = 0.1,
		FinMul          = 0.01,
		GLimit          = 1,
		TailFinMul      = 200,
		PenMul          = 1,
		FillerRatio     = 0.85,
		ActualLength    = 270,
		ActualWidth     = 50
	},
	Preview = {
		FOV = 80,
	},
})
