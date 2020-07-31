ACF.RegisterMissileClass("ARM", {
	Name		= "Anti-Radiation Missiles",
	Description	= "Missiles specialized for Suppression of Enemy Air Defenses.",
	Sound		= "acf_missiles/missiles/missile_rocket.mp3",
	Effect		= "Rocket Motor ATGM",
	ReloadMul	= 8,
	RoFMod		= 1,
	Spread		= 1,
	Blacklist	= { "AP", "APHE", "HEAT", "HP", "FL", "SM" }
})

ACF.RegisterMissile("AGM-122 ARM", "ARM", {
	Name		= "AGM-122 Sidearm",
	Description	= "A refurbished early-model AIM-9, for attacking ground targets.",
	Model		= "models/missiles/aim9.mdl",
	Length		= 205,
	Caliber		= 127,
	Mass		= 89,
	RoFMod		= 0.3,
	Year		= 1986,
	Guidance	= { "Dumb", "Anti-radiation" },
	Fuzes		= { "Contact", "Optical" },
	Racks		= { ["1xRK"] = true, ["2xRK"] = true, ["3xRK"] = true, ["4xRK"] = true, ["1xRK_small"] = true },
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
		FinMul			= 0.03
	},
})

ACF.RegisterMissile("AGM-45 ASM", "ARM", {
	Name		= "AGM-45 Shrike",
	Description	= "Long range anti-SAM missile, built on the body of an AIM-7 Sparrow.",
	Model		= "models/missiles/aim120.mdl",
	Length		= 1000,
	Caliber		= 203,
	Mass		= 177,
	Diameter	= 7.1 * 25.4, -- in mm
	Year		= 1969,
	RoFMod		= 0.6,
	Guidance	= { "Dumb", "Anti-radiation" },
	Fuzes		= { "Contact", "Timed" },
	Racks		= { ["1xRK"] = true, ["2xRK"] = true, ["3xRK"] = true },
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
		PenMul			= math.sqrt(0.5)
	},
})
