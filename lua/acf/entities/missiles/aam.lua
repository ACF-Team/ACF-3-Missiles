local Missiles = ACF.Classes.Missiles

Missiles.Register("AAM", {
	Name		= "Air-To-Air Missiles",
	Description	= "Missiles specialized for air-to-air flight. They have varying range, but are agile, can be radar-guided, and withstand difficult launch angles well.",
	Sound		= "acf_missiles/missiles/missile_rocket.mp3",
	Effect		= "Rocket Motor",
	Spread		= 1,
	Blacklist	= { "AP", "APHE", "HEAT", "HP", "FL", "SM" }
})

Missiles.RegisterItem("AIM-9 AAM", "AAM", {
	Name		= "AIM-9 Sidewinder",
	Description	= "Agile and reliable with a rather underwhelming effective range, this homing missile is the weapon of choice for dogfights.",
	Model		= "models/missiles/aim9m.mdl",
	Length		= 289,
	Caliber		= 127,
	Mass		= 85,
	Year		= 1953,
	Diameter	= 101.6, -- in mm
	ReloadTime	= 10,
	ExhaustPos  = Vector(-42),
	Racks		= { ["1xRK_small"] = true, ["1xRK"] = true, ["2xRK"] = true, ["4xRK"] = true },
	Guidance	= { Dumb = true, Infrared = true, ["Semi-Active Radar"] = true },
	Navigation  = "APN",
	Fuzes		= { Contact = true, Radio = true },
	SeekCone	= 10,
	ViewCone	= 30,
	Agility		= 0.0017,
	ArmDelay	= 0.2,
	Round = {
		Model			= "models/missiles/aim9m.mdl",
		MaxLength		= 289,
		ProjLength		= 68,
		Armor			= 5,
		PropLength		= 160,
		Thrust			= 800000,	-- in kg*in/s^2
		FuelConsumption = 0.02,		-- in g/s/f
		StarterPercent	= 0.05,
		MaxAgilitySpeed = 300,      -- in m/s
		DragCoef		= 0.005,
		FinMul			= 0.1,
		GLimit          = 20,
		TailFinMul		= 0.001,
		CanDelayLaunch	= true,
		ActualLength 	= 289,
		ActualWidth		= 12.7
	},
	Preview = {
		Height = 100,
		FOV    = 60,
	},
})

Missiles.RegisterItem("AIM-120 AAM", "AAM", {
	Name		= "AIM-120 AMRAAM",
	Description	= "Burns hot and fast, with a good reach, but harder to lock with. This long-range missile is sure to deliver one heck of a blast upon impact.",
	Model		= "models/missiles/aim120c.mdl",
	Length		= 370,
	Caliber		= 180,
	Mass		= 152,
	Year		= 1991,
	Diameter	= 154.5, -- in mm
	ReloadTime	= 25,
	ExhaustPos  = Vector(-66),
	Racks		= { ["1xRK"] = true, ["2xRK"] = true, ["4xRK"] = true },
	Guidance	= { Dumb = true, ["Semi-Active Radar"] = true, ["Active Radar"] = true },
	Navigation  = "APN",
	Fuzes		= { Contact = true, Radio = true },
	SeekCone	= 10,
	ViewCone	= 30,
	Agility		= 0.006,
	ArmDelay	= 0.2,
	Round = {
		Model			= "models/missiles/aim120c.mdl",
		MaxLength		= 370,
		Armor			= 5,
		ProjLength		= 70,
		PropLength		= 140,
		Thrust			= 1500000, 	-- in kg*in/s^2
		FuelConsumption = 0.02,		-- in g/s/f
		StarterPercent	= 0.05,
		MaxAgilitySpeed = 350,      -- in m/s
		DragCoef		= 0.01,
		FinMul			= 0.2,
		GLimit          = 20,
		TailFinMul		= 0.001,
		CanDelayLaunch	= true,
		ActualLength 	= 370,
		ActualWidth		= 18
	},
	Preview = {
		Height = 60,
		FOV    = 60,
	},
})

Missiles.RegisterItem("AIM-54 AAM", "AAM", {
	Name		= "AIM-54 Phoenix",
	Description	= "A BEEFY god-tier anti-bomber weapon, made with Jimmy Carter's repressed rage. Getting hit with one of these is a significant emotional event that is hard to avoid if you're flying high.",
	Model		= "models/missiles/aim54.mdl",
	Length		= 400,
	Caliber		= 380,
	Mass		= 453,
	Year		= 1974,
	Diameter	= 327.5, -- in mm
	ReloadTime	= 40,
	ExhaustPos  = Vector(-60),
	Racks		= { ["1xRK"] = true, ["2xRK"] = true },
	Guidance	= { Dumb = true, ["Semi-Active Radar"] = true, ["Active Radar"] = true },
	Navigation  = "APN",
	Fuzes		= { Contact = true, Radio = true },
	SeekCone	= 10,
	ViewCone	= 20,
	Agility		= 0.02,
	ArmDelay	= 0.4,
	Round = {
		Model			= "models/missiles/aim54.mdl",
		MaxLength		= 400,
		Armor			= 5,
		ProjLength		= 60,
		PropLength		= 220,
		Thrust			= 4000000,	-- in kg*in/s^2
		FuelConsumption = 0.04,		-- in g/s/f
		StarterPercent	= 0.05,
		MaxAgilitySpeed = 300,      -- in m/s
		DragCoef		= 0.03,
		FinMul			= 0.3,
		GLimit          = 12,
		TailFinMul		= 0.001,
		CanDelayLaunch	= true,
		ActualLength 	= 400,
		ActualWidth		= 38
	},
	Preview = {
		Height = 100,
		FOV    = 60,
	},
})
