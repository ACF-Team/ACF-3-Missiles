
ACF.RegisterMissileClass("AAM", {
	Name		= "Air-To-Air Missiles",
	Description	= "Missiles specialized for air-to-air flight. They have varying range, but are agile, can be radar-guided, and withstand difficult launch angles well.",
	Sound		= "acf_missiles/missiles/missile_rocket.mp3",
	Effect		= "Rocket Motor",
	Spread		= 1,
	Blacklist	= { "AP", "APHE", "HEAT", "HP", "FL", "SM" }
})

ACF.RegisterMissile("AIM-9 AAM", "AAM", {
	Name		= "AIM-9 Sidewinder",
	Description	= "Agile and reliable with a rather underwhelming effective range, this homing missile is the weapon of choice for dogfights.",
	Model		= "models/missiles/aim9m.mdl",
	Length		= 200,
	Caliber		= 127,
	Mass		= 85,
	Year		= 1953,
	Diameter	= 101.6, -- in mm
	ReloadTime	= 10,
	Racks		= { ["1xRK_small"] = true, ["1xRK"] = true, ["2xRK"] = true, ["4xRK"] = true },
	Guidance	= { Dumb = true, Infrared = true, ["Semi-Active Radar"] = true },
	Fuzes		= { Contact = true, Radio = true },
	SeekCone	= 10,
	ViewCone	= 30,
	Agility		= 5,
	ArmDelay	= 0.2,
	Round = {
		Model			= "models/missiles/aim9m.mdl",
		MaxLength		= 35,
		Armor			= 5,
		PropMass		= 1,
		Thrust			= 20000,	-- in kg*in/s^2
		FuelConsumption = 0.025,	-- in g/s/f
		StarterPercent	= 0.1,
		MinSpeed		= 3000,
		DragCoef		= 0.002,
		DragCoefFlight	= 0.03,
		FinMul			= 1.25,
		CanDelayLaunch	= true,
		ActualLength 	= 85,
		ActualWidth		= 4.3
	},
})

ACF.RegisterMissile("AIM-120 AAM", "AAM", {
	Name		= "AIM-120 AMRAAM",
	Description	= "Burns hot and fast, with a good reach, but harder to lock with. This long-range missile is sure to deliver one heck of a blast upon impact.",
	Model		= "models/missiles/aim120c.mdl",
	Length		= 1000,
	Caliber		= 180,
	Mass		= 152,
	Year		= 1991,
	Diameter	= 154.5, -- in mm
	ReloadTime	= 25,
	Racks		= { ["1xRK"] = true, ["2xRK"] = true, ["4xRK"] = true },
	Guidance	= { Dumb = true, ["Semi-Active Radar"] = true, ["Active Radar"] = true },
	Fuzes		= { Contact = true, Radio = true },
	SeekCone	= 5,
	ViewCone	= 20,
	Agility		= 0.173,
	ArmDelay	= 0.2,
	Round = {
		Model			= "models/missiles/aim120c.mdl",
		MaxLength		= 50,
		Armor			= 5,
		PropMass		= 2,
		Thrust			= 24000, 	-- in kg*in/s^2
		FuelConsumption = 0.1,		-- in g/s/f
		StarterPercent	= 0.3,
		MinSpeed		= 2000,
		DragCoef		= 0.002,
		DragCoefFlight	= 0.0013,
		FinMul			= 1.62,
		CanDelayLaunch	= true,
		ActualLength 	= 129.5,
		ActualWidth		= 6.8
	},
})

ACF.RegisterMissile("AIM-54 AAM", "AAM", {
	Name		= "AIM-54 Phoenix",
	Description	= "A BEEFY god-tier anti-bomber weapon, made with Jimmy Carter's repressed rage. Getting hit with one of these is a significant emotional event that is hard to avoid if you're flying high.",
	Model		= "models/missiles/aim54.mdl",
	Length		= 1000,
	Caliber		= 380,
	Mass		= 453,
	Year		= 1974,
	Diameter	= 327.5, -- in mm
	ReloadTime	= 40,
	Racks		= { ["1xRK"] = true, ["2xRK"] = true },
	Guidance	= { Dumb = true, ["Semi-Active Radar"] = true, ["Active Radar"] = true },
	Fuzes		= { Contact = true, Radio = true },
	SeekCone	= 5,
	ViewCone	= 20,
	Agility		= 0.05,
	ArmDelay	= 0.4,
	Round = {
		Model			= "models/missiles/aim54.mdl",
		MaxLength		= 60,
		Armor			= 5,
		PropMass		= 5,
		Thrust			= 45000, 	-- in kg*in/s^2
		FuelConsumption = 0.03,		-- in g/s/f
		StarterPercent	= 0.1,
		MinSpeed		= 4000,
		DragCoef		= 0.005,
		DragCoefFlight	= 0.05,
		FinMul			= 1.2,
		CanDelayLaunch	= true,
		ActualLength 	= 139.5,
		ActualWidth		= 13.5
	},
})
