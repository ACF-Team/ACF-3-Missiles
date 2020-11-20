
ACF.RegisterMissileClass("GBU", {
	Name		= "Guided Bomb Units",
	Description	= "Similar to a regular bomb, but able to be guided in flight to a vector coordinate. Most useful versus hard, unmoving targets.",
	Sound		= "acf_missiles/fx/clunk.mp3",
	NoThrust	= true,
	Spread		= 1,
	Blacklist	= {"AP", "APHE", "HP", "FL"}
})

ACF.RegisterMissile("WalleyeGBU", "GBU", {
	Name		= "AGM-62 Walleye",
	Description	= "An early guided bomb of yield roughly between the 454kg and 227kg, used over Vietnam by American strike aircraft.",
	Model		= "models/bombs/gbu/agm62.mdl",
	Length		= 3450,
	Caliber		= 318,
	Mass		= 510,
	Year		= 1967,
	Diameter	= 16.4 * 25.4, -- in mm
	Racks		= { ["1xRK"] = true, ["2xRK"] = true },
	Guidance	= { Dumb = true, ["Radio (MCLOS)"] = true },
	Fuzes		= { Contact = true, Timed = true, Optical = true },
	SeekCone	= 90,
	ViewCone	= 120,
	Agility		= 2,
	ArmDelay	= 1,
	Round = {
		Model			= "models/bombs/gbu/agm62.mdl",
		MaxLength		= 80,
		Armor			= 25,
		PropMass		= 1,
		Thrust			= 1,
		BurnRate		= 1, -- in cm^3/s
		StarterPercent	= 0.005,
		MinSpeed		= 500,
		DragCoef		= 0.00001,
		FinMul			= 0.02,
		PenMul			= math.sqrt(0.5)
	},
})

ACF.RegisterMissile("227kgGBU", "GBU", {
	Name		= "227kg GBU-12 Paveway II",
	Description	= "Based on the Mk 82 500-pound general-purpose bomb, but with the addition of a nose-mounted laser seeker and fins for guidance.",
	Model		= "models/bombs/gbu/gbu12.mdl",
	Length		= 5000,
	Caliber		= 105,
	Mass		= 227,
	Year		= 1976,
	Diameter	= 10 * 25.4, -- in mm
	Offset		= Vector(12, 0, 0),
	Racks		= { ["1xRK"] = true, ["2xRK"] = true, ["3xRK"] = true, ["4xRK"] = true },
	Guidance	= { Dumb = true, Laser = true, ["GPS Guided"] = true },
	Fuzes		= { Contact = true, Timed = true, Optical = true, Cluster = true },
	SeekCone	= 60,
	ViewCone	= 80,
	Agility		= 1,
	ArmDelay	= 1,
	Bodygroups = {
		guidance = {
			DataSource = function(Entity)
				return Entity.GuidanceData and Entity.GuidanceData.Name
			end,
			Laser = {
				OnRack = "laser.smd",
				OnLaunch = "laser_f.smd",
			},
			["GPS Guided"] = {
				OnRack = "laser.smd",
				OnLaunch = "laser_f.smd",
			}
		}
	},
	Round = {
		Model			= "models/bombs/gbu/gbu12_fold.mdl",
		RackModel		= "models/bombs/gbu/gbu12.mdl",
		MaxLength		= 250,
		Armor			= 20,
		PropMass		= 0,
		Thrust			= 1, -- in kg*in/s^2
		BurnRate		= 1, -- in cm^3/s
		StarterPercent	= 0.005,
		MinSpeed		= 1,
		DragCoef		= 0.002,
		FinMul			= 0.02,
		PenMul			= math.sqrt(0.4)
	},
})

ACF.RegisterMissile("454kgGBU", "GBU", {
	Name		= "454kg GBU-16 Paveway II",
	Description	= "Based on the Mk 83 general-purpose bomb, but with laser seeker and wings for guidance.",
	Model		= "models/bombs/gbu/gbu16.mdl",
	Length		= 15000,
	Caliber		= 170,
	Mass		= 454,
	Year		= 1976,
	Diameter	= 11.5 * 25.4, -- in mm
	Racks		= { ["1xRK"] = true, ["2xRK"] = true, ["3xRK"] = true, ["4xRK"] = true },
	Guidance	= { Dumb = true, Laser = true, ["GPS Guided"] = true },
	Fuzes		= { Contact = true, Timed = true, Optical = true, Cluster = true },
	SeekCone	= 60,
	ViewCone	= 80,
	Agility		= 1,
	ArmDelay	= 1,
	Bodygroups = {
		guidance = {
			DataSource = function(Entity)
				return Entity.GuidanceData and Entity.GuidanceData.Name
			end,
			Laser = {
				OnRack = "laser.smd",
				OnLaunch = "laser_f.smd",
			},
			["GPS Guided"] = {
				OnRack = "laser.smd",
				OnLaunch = "laser_f.smd",
			}
		}
	},
	Round = {
		Model			= "models/bombs/gbu/gbu16_fold.mdl",
		RackModel		= "models/bombs/gbu/gbu16.mdl",
		MaxLength		= 500,
		Armor			= 25,
		PropMass		= 0,
		Thrust			= 1, -- in kg*in/s^2
		BurnRate		= 1, -- in cm^3/s
		StarterPercent	= 0.005,
		MinSpeed		= 1,
		DragCoef		= 0.002,
		FinMul			= 0.02,
		PenMul			= math.sqrt(0.3)
	},
})

ACF.RegisterMissile("909kgGBU", "GBU", {
	Name		= "909kg GBU-10 Paveway II",
	Description	= "Based on the Mk 84 general-purpose bomb, but with laser seeker and wings for guidance.",
	Model		= "models/bombs/gbu/gbu10.mdl",
	Length		= 30000,
	Caliber		= 200,
	Mass		= 909,
	Year		= 1976,
	Diameter	= 17 * 25.4, -- in mm
	Offset		= Vector(15, 0, 0),
	Racks		= { ["1xRK"] = true, ["2xRK"] = true, ["4xRK"] = true },
	Guidance	= { Dumb = true, Laser = true, ["GPS Guided"] = true },
	Fuzes		= { Contact = true, Timed = true, Optical = true, Cluster = true },
	SeekCone	= 60,
	ViewCone	= 80,
	Agility		= 1,
	ArmDelay	= 3,
	Bodygroups = {
		guidance = {
			DataSource = function(Entity)
				return Entity.GuidanceData and Entity.GuidanceData.Name
			end,
			Laser = {
				OnRack = "laser.smd",
				OnLaunch = "laser_f.smd",
			},
			["GPS Guided"] = {
				OnRack = "laser.smd",
				OnLaunch = "laser_f.smd",
			}
		}
	},
	Round = {
		Model			= "models/bombs/gbu/gbu10_fold.mdl",
		RackModel		= "models/bombs/gbu/gbu10.mdl",
		MaxLength		= 510,
		Armor			= 20,
		PropMass		= 0,
		Thrust			= 1, -- in kg*in/s^2
		BurnRate		= 1, -- in cm^3/s
		StarterPercent	= 0.005,
		MinSpeed		= 1,
		DragCoef		= 0.002,
		FinMul			= 0.01,
		PenMul			= math.sqrt(0.2)
	},
})
