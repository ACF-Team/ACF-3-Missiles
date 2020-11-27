ACF.RegisterMissileClass("ARM", {
	Name		= "Anti-Radiation Missiles",
	Description	= "Missiles specialized for Suppression of Enemy Air Defenses.",
	Sound		= "acf_missiles/missiles/missile_rocket.mp3",
	Effect		= "Rocket Motor ATGM",
	Spread		= 1,
	Blacklist	= { "AP", "APHE", "HEAT", "HP", "FL", "SM" }
})

ACF.RegisterMissile("AGM-122 ASM", "ARM", {
	Name		= "AGM-122 Sidearm",
	Description	= "A refurbished early-model AIM-9, for attacking ground targets.",
	Model		= "models/missiles/aim9.mdl",
	Length		= 205,
	Caliber		= 127,
	Mass		= 89,
	Diameter	= 3.5 * 25.4, -- in mm
	Offset		= Vector(-6, 0, 0),
	Year		= 1986,
	ReloadTime	= 10,
	Racks		= { ["1xRK_small"] = true, ["1xRK"] = true, ["2xRK"] = true, ["4xRK"] = true },
	Guidance	= { Dumb = true, ["Anti-radiation"] = true },
	Fuzes		= { Contact = true, Optical = true },
	SeekCone	= 10,
	ViewCone	= 20,
	Agility		= 0.3,
	ArmDelay	= 0.2,
	Round = {
		Model			= "models/missiles/aim9.mdl",
		MaxLength		= 70,
		Armor			= 8,
		PropMass		= 4,
		Thrust			= 4500, -- in kg*in/s^2
		BurnRate		= 1400, -- in cm^3/s
		StarterPercent	= 0.4,
		MinSpeed		= 5000,
		DragCoef		= 0.001,
		DragCoefFlight	= 0.001,
		FinMul			= 0.03,
		CanDelayLaunch	= true,
	},
})

ACF.RegisterMissile("AGM-45 ASM", "ARM", {
	Name		= "AGM-45 Shrike",
	Description	= "Long range anti-SAM missile, built on the body of an AIM-7 Sparrow.",
	Model		= "models/missiles/aim120.mdl",
	Length		= 1000,
	Caliber		= 203,
	Mass		= 177,
	Diameter	= 6.75 * 25.4, -- in mm
	Year		= 1969,
	ReloadTime	= 25,
	Racks		= { ["1xRK"] = true, ["2xRK"] = true, ["4xRK"] = true },
	Guidance	= { Dumb = true, ["Anti-radiation"] = true },
	Fuzes		= { Contact = true, Timed = true },
	SeekCone	= 5,
	ViewCone	= 10,
	Agility		= 0.08,
	ArmDelay	= 0.3,
	Round = {
		Model			= "models/missiles/aim120.mdl",
		MaxLength		= 120,
		Armor			= 10,
		PropMass		= 3,
		Thrust			= 800, -- in kg*in/s^2
		BurnRate		= 300, -- in cm^3/s
		StarterPercent	= 0.05,
		MinSpeed		= 4000,
		DragCoef		= 0.001,
		DragCoefFlight	= 0,
		FinMul			= 0.2,
		CanDelayLaunch	= true,
	},
})
