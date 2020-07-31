
--define the class
ACF_defineGunClass("FFAR", {
	type            = "missile",
	spread          = 1,
	name            = "Folding-Fin Aerial Rockets",
	desc            = "Small rockets which fit in tubes or pods.  Rapid-firing and versatile.",
	muzzleflash     = "gl_muzzleflash_noscale",
	rofmod          = 0.5,
	sound           = "acf_missiles/missiles/missile_rocket.mp3",
	soundDistance   = " ",
	soundNormal     = " ",
	effect          = "Rocket Motor",

	ammoBlacklist   = {"AP", "APHE", "FL"} -- Including FL would mean changing the way round classes work.
} )

ACF_defineGun("40mmFFAR", { --id

	name		= "40mm Pod Rocket",
	desc		= "A tiny, unguided rocket.  Useful for anti-infantry, smoke and suppression.  Folding fins allow the rocket to be stored in pods, which defend them from damage.",
	model		= "models/missiles/launcher7_40mm.mdl",
	caliber		= 4,
	gunclass	= "FFAR",
	rack        = "40mm7xPOD",  -- Which rack to spawn this missile on?
	weight		= 6,
	length	    = 2, -- Length affects inertia calculations
	rofmod		= 0.8,
	year		= 1960,
	round		=
	{
		model		= "models/missiles/ffar_40mm.mdl",
		rackmdl		= "models/missiles/ffar_40mm_closed.mdl",
		maxlength	= 25,
		casing		= 0.2,			-- thickness of missile casing, cm
		armour		= 4,			-- effective armour thickness of casing, in mm
		propweight	= 0.2,			-- motor mass - motor casing
		thrust		= 10000,		-- average thrust - kg*in/s^2
		burnrate	= 120,			-- cm^3/s at average chamber pressure
		starterpct	= 0.15,         -- percentage of the propellant consumed in the starter motor.
		minspeed	= 5000,			-- minimum speed beyond which the fins work at 100% efficiency
		dragcoef	= 0.001,		-- drag coefficient while falling
		dragcoefflight  = 0.02,                 -- drag coefficient during flight
		finmul		= 0.003,		-- fin multiplier (mostly used for unpropelled guidance)
		penmul		= math.sqrt(4)
	},

	ent         = "acf_rack", -- A workaround ent which spawns an appropriate rack for the missile.
	guidance    = {"Dumb"},
	fuzes       = {"Contact", "Timed"},

	racks       = {["40mm7xPOD"] = true},    -- a whitelist for racks that this missile can load into.  can also be a 'function(bulletData, rackEntity) return boolean end'

	armdelay    = 0.3     -- minimum fuze arming delay
} )

ACF_defineGun("70mmFFAR", { --id

	name		= "70mm Pod Rocket",
	desc		= "A small, unguided rocket.  Useful against light vehicles and infantry.  Folding fins allow the rocket to be stored in pods, which defend them from damage.",
	model		= "models/missiles/launcher7_70mm.mdl",
	caliber		= 7,
	gunclass	= "FFAR",
	rack        = "70mm7xPOD",  -- Which rack to spawn this missile on?
	weight		= 12,
	length	    = 15,
	year		= 1960,
	rofmod		= 0.6,
	roundclass	= "Rocket",
	round		=
	{
		model		= "models/missiles/ffar_70mm.mdl",
		rackmdl		= "models/missiles/ffar_70mm_closed.mdl",
		maxlength	= 25,
		casing		= 0.2,			-- thickness of missile casing, cm
		armour		= 6,			-- effective armour thickness of casing, in mm
		propweight	= 0.7,			-- motor mass - motor casing
		thrust		= 15000,		-- average thrust - kg*in/s^2
		burnrate	= 300,			-- cm^3/s at average chamber pressure
		starterpct	= 0.15,
		minspeed	= 4000,			-- minimum speed beyond which the fins work at 100% efficiency
		dragcoef	= 0.001,		-- drag coefficient while falling
		dragcoefflight  = 0.02,                 -- drag coefficient during flight
		finmul		= 0.015,			-- fin multiplier (mostly used for unpropelled guidance)
		penmul      = math.sqrt(6)  	-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

	ent         = "acf_rack", -- A workaround ent which spawns an appropriate rack for the missile.
	guidance    = { "Dumb", "Laser" },
	fuzes       = { "Contact", "Timed" },

	racks       = {["70mm7xPOD"] = true},    -- a whitelist for racks that this missile can load into.  can also be a 'function(bulletData, rackEntity) return boolean end'

	viewcone	= 20,

	agility		= 0.05,
	armdelay    = 0.3     -- minimum fuze arming delay
} )

ACF.RegisterMissileClass("FFAR", {
	Name		= "Folding-Fin Aerial Rockets",
	Description	= "Small rockets which fit in tubes or pods. Rapid-firing and versatile.",
	Sound		= "acf_missiles/missiles/missile_rocket.mp3",
	Effect		= "Rocket Motor",
	RoFMod		= 0.5,
	Spread		= 1,
	Blacklist	= { "AP", "APHE", "HP", "FL" }
})

ACF.RegisterMissile("40mmFFAR", "FFAR", {
	Name		= "40mm Pod Rocket",
	Description	= "A tiny, unguided rocket. Useful for anti-infantry, smoke and suppression. Folding fins allow the rocket to be stored in pods, which defend them from damage.",
	Model		= "models/missiles/ffar_40mm.mdl",
	Caliber		= 40,
	Mass		= 4,
	Length		= 2,
	RoFMod		= 0.8,
	Year		= 1960,
	Guidance	= { "Dumb" },
	Fuzes		= { "Contact", "Timed" },
	Racks		= { ["40mm7xPOD"] = true },
	ArmDelay	= 0.3,
	Round = {
		Model			= "models/missiles/ffar_40mm.mdl",
		RackModel		= "models/missiles/ffar_40mm_closed.mdl",
		MaxLength		= 25,
		Armor			= 4,
		PropMass		= 0.2,
		Thrust			= 10000, -- in kg*in/s^2
		BurnRate		= 120, -- in cm^3/s
		StarterPercent	= 0.15,
		MinSpeed		= 5000,
		DragCoef		= 0.001,
		DragCoefFlight	= 0.02,
		FinMul			= 0.003,
		PenMul			= math.sqrt(4)
	},
})

ACF.RegisterMissile("70mmFFAR", "FFAR", {
	Name		= "70mm Pod Rocket",
	Description	= "A small, unguided rocket. Useful against light vehicles and infantry. Folding fins allow the rocket to be stored in pods, which defend them from damage.",
	Model		= "models/missiles/ffar_70mm.mdl",
	Caliber		= 70,
	Mass		= 6,
	Length		= 15,
	Year		= 1960,
	RoFMod		= 0.6,
	Guidance	= { "Dumb", "Laser" },
	Fuzes		= { "Contact", "Timed" },
	Racks		= { ["70mm7xPOD"] = true },
	ViewCone	= 20,
	Agility		= 0.05,
	ArmDelay	= 0.3,
	Round = {
		Model			= "models/missiles/ffar_70mm.mdl",
		RackModel		= "models/missiles/ffar_70mm_closed.mdl",
		MaxLength		= 25,
		Armor			= 6,
		PropMass		= 0.7,
		Thrust			= 15000, -- in kg*in/s^2
		BurnRate		= 300, -- in cm^3/s
		StarterPercent	= 0.15,
		MinSpeed		= 4000,
		DragCoef		= 0.001,
		DragCoefFlight	= 0.02,
		FinMul			= 0.015,
		PenMul			= math.sqrt(6)
	},
})

ACF.RegisterMissile("Zuni ASR", "FFAR", {
	Name		= "127mm Pod Rocket",
	Description	= "A heavy 5in air to surface unguided rocket, able to provide heavy suppressive fire in a single pass.",
	Model		= "models/ghosteh/zuni.mdl",
	Caliber		= 127,
	Mass		= 45,
	Length		= 80,
	Year		= 1957,
	RoFMod		= 0.5,
	Guidance	= { "Dumb", "Laser" },
	Fuzes		= { "Contact", "Timed", "Optical", "Radio" },
	Racks		= { ["127mm4xPOD"] = true },
	ViewCone	= 50,
	Agility		= 0.05,
	ArmDelay	= 0.1,
	Round = {
		Model			= "models/ghosteh/zuni.mdl",
		RackModel		= "models/ghosteh/zuni_folded.mdl",
		MaxLength		= 60,
		Armor			= 12,
		PropMass		= 0.7,
		Thrust			= 18000, -- in kg*in/s^2
		BurnRate		= 600, -- in cm^3/s
		StarterPercent	= 0.15,
		MinSpeed		= 6000,
		DragCoef		= 0.001,
		DragCoefFlight	= 0.02,
		FinMul			= 0.015,
		PenMul			= math.sqrt(2)
	},
})
