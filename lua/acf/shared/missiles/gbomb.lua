ACF.RegisterMissileClass("GBOMB", {
	Name		= "Gliding Bombs",
	Description	= "Similar to regular free falling bombs, gliding bombs are capable of travelling longer distances.",
	Sound		= "acf_missiles/fx/clunk.mp3",
	NoThrust	= true,
	ReloadMul	= 8,
	RoFMod		= 0.1,
	Spread		= 1,
	Blacklist	= { "AP", "APHE", "HP", "FL" }
})

ACF.RegisterMissile("100kgGBOMB", "GBOMB", {
	Name		= "100kg Glide Bomb",
	Description	= "A 250-pound bomb, fitted with fins for a longer reach. Well suited to dive bombing, but bulkier and heavier from its fins.",
	Model		= "models/missiles/micro.mdl",
	Length		= 75,
	Caliber		= 100,
	Mass		= 100,
	Year		= 1939,
	Diameter	= 10.8 * 25.4, -- in mm
	Guidance	= { "Dumb" },
	Fuzes		= { "Contact", "Optical", "Cluster" },
	Racks		= { ["1xRK_small"] = true, ["1xRK"] = true, ["2xRK"] = true, ["3xRK"] = true, ["4xRK"] = true },
	ArmDelay	= 1,
	Round = {
		Model			= "models/missiles/micro.mdl",
		MaxLength		= 100,
		Armor			= 25,
		PropMass		= 0,
		Thrust			= 1, -- in kg*in/s^2
		BurnRate		= 1, -- in cm^3/s
		StarterPercent	= 0.005,
		MinSpeed		= 500,
		DragCoef		= 0.0001,
		FinMul			= 0.05,
		PenMul			= math.sqrt(0.6)
	},
})

ACF.RegisterMissile("250kgGBOMB", "GBOMB", {
	Name		= "250kg Glide Bomb",
	Description	= "A heavy 500lb bomb, fitted with fins for a gliding trajectory better suited to striking point targets.",
	Model		= "models/missiles/fab250.mdl",
	Length		= 150,
	Caliber		= 125,
	Mass		= 250,
	Year		= 1941,
	Diameter	= 14.5 * 25.4, -- in mm
	Guidance	= { "Dumb" },
	Fuzes		= { "Contact", "Optical", "Cluster" },
	Racks		= { ["1xRK"] = true, ["2xRK"] = true, ["3xRK"] = true, ["4xRK"] = true },
	ArmDelay	= 1,
	Round = {
		Model			= "models/missiles/fab250.mdl",
		MaxLength		= 250,
		Armor			= 25,
		PropMass		= 0,
		Thrust			= 1, -- in kg*in/s^2
		BurnRate		= 1, -- in cm^3/s
		StarterPercent	= 0.005,
		MinSpeed		= 500,
		DragCoef		= 0.001,
		FinMul			= 0.05,
		PenMul			= math.sqrt(0.6)
	},
})
