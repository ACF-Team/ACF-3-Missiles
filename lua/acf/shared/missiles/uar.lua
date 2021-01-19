
ACF.RegisterMissileClass("UAR", {
	Name		= "Unguided Aerial Rockets",
	Description	= "Rockets which fit in racks, useful for rocket artillery.",
	Sound		= "acf_missiles/missiles/missile_rocket.mp3",
	Effect		= "Rocket Motor",
	Spread		= 0.2,
	Blacklist	= { "AP", "APHE", "HP", "FL", "SM" }
})

ACF.RegisterMissile("RS82 ASR", "UAR", {
	Name		= "RS-82 Rocket",
	Description	= "A small, unguided rocket, often used in multiple-launch artillery as well as for attacking pinpoint ground targets.",
	Model		= "models/missiles/rs82.mdl",
	Caliber		= 82,
	Mass		= 7,
	Length		= 40,
	Diameter	= 2.2 * 25.4, -- in mm
	ReloadTime	= 5,
	Offset		= Vector(1, 0, 0),
	Year		= 1933,
	Racks		= { ["1xRK_small"] = true, ["1xRK"] = true, ["2xRK"] = true, ["4xRK"] = true },
	Guidance	= { Dumb = true },
	Fuzes		= { Contact = true, Timed = true },
	ArmDelay	= 0.3,
	Bodygroups = {
		warhead = {
			DataSource = function(Entity)
				return Entity.BulletData and Entity.BulletData.Type
			end,
			HE = {
				OnRack = "HE.smd",
			},
			HEAT = {
				OnRack = "HEAT.smd",
			}
		}
	},
	Round = {
		Model			= "models/missiles/rs82.mdl",
		MaxLength		= 25,
		Armor			= 5,
		PropMass		= 0.7,
		Thrust			= 15000, -- in kg*in/s^2
		BurnRate		= 800, -- in cm^3/s
		StarterPercent	= 0.15,
		MinSpeed		= 6000,
		DragCoef		= 0.002,
		DragCoefFlight	= 0.025,
		FinMul			= 0.008,
		PenMul			= math.sqrt(6.63)
	},
})

ACF.RegisterMissile("HVAR ASR", "UAR", {
	Name		= "HVAR Rocket",
	Description	= "A medium, unguided rocket. More bang than the RS82, at the cost of size and weight.",
	Model		= "models/missiles/hvar.mdl",
	Caliber		= 127,
	Mass		= 64,
	Length		= 44,
	Diameter	= 4 * 25.4, -- in mm
	ReloadTime	= 10,
	Offset		= Vector(2, 0, 0),
	Year		= 1933,
	Racks		= { ["1xRK_small"] = true, ["1xRK"] = true, ["2xRK"] = true, ["3xUARRK"] = true, ["4xRK"] = true },
	Guidance	= { Dumb = true },
	Fuzes		= { Contact = true, Timed = true },
	ArmDelay	= 0.3,
	Round = {
		Model			= "models/missiles/hvar.mdl",
		RackModel		= "models/missiles/hvar_folded.mdl",
		MaxLength		= 25,
		Armor			= 5,
		PropMass		= 0.7,
		Thrust			= 25000, -- in kg*in/s^2
		BurnRate		= 600, -- in cm^3/s
		StarterPercent	= 0.15,
		MinSpeed		= 5000,
		DragCoef		= 0.002,
		DragCoefFlight	= 0.02,
		FinMul			= 0.01,
		PenMul			= math.sqrt(6.25)
	},
})

ACF.RegisterMissile("SPG-9 ASR", "UAR", {
	Name		= "SPG-9 Rocket",
	Description	= "A recoilless rocket launcher similar to an RPG or Grom.",
	Model		= "models/munitions/round_100mm_mortar_shot.mdl",
	Caliber		= 73,
	Mass		= 5,
	Length		= 20,
	Year		= 1962,
	ReloadTime	= 10,
	Racks		= { ["1x SPG9"] = true },
	Guidance	= { Dumb = true },
	Fuzes		= { Contact = true, Optical = true },
	ArmDelay	= 0.05,
	Round = {
		Model			= "models/missiles/glatgm/9m112f.mdl",
		RackModel		= "models/munitions/round_100mm_mortar_shot.mdl",
		MaxLength		= 50,
		Armor			= 5,
		PropMass		= 0.5,
		Thrust			= 120000, -- in kg*in/s^2 very high but only burns a brief moment, most of which is in the tube
		BurnRate		= 1200, -- in cm^3/s
		StarterPercent	= 0.72,
		MinSpeed		= 900,
		DragCoefFlight	= 0.05,
		DragCoef		= 0.001,
		FinMul			= 0.02,
		PenMul			= math.sqrt(4.5)
	},
})

ACF.RegisterMissile("S-24 ASR", "UAR", {
	Name		= "S-24 Rocket",
	Description	= "A big, unguided rocket. Mostly used by late cold war era attack planes and helicopters.",
	Model		= "models/missiles/s24.mdl",
	Caliber		= 240,
	Mass		= 235,
	Length		= 25,
	Diameter	= 8.3 * 25.4, -- in mm
	ReloadTime	= 20,
	Year		= 1960,
	Racks		= { ["1xRK"] = true, ["2xRK"] = true, ["4xRK"] = true },
	Guidance	= { Dumb = true },
	Fuzes		= { Contact = true, Timed = true },
	SkinIndex	= { HEAT = 0, HE = 1 },
	ArmDelay	= 0.3,
	Round = {
		Model			= "models/missiles/s24.mdl",
		MaxLength		= 40,
		Armor			= 5,
		PropMass		= 15,
		Thrust			= 9000, -- in kg*in/s^2
		BurnRate		= 1000, -- in cm^3/s
		StarterPercent	= 0.15,
		MinSpeed		= 10000,
		DragCoef		= 0.001,
		DragCoefFlight	= 0.01,
		FinMul			= 0.02,
		PenMul			= math.sqrt(5)
	},
})

ACF.RegisterMissile("RW61 ASR", "UAR", {
	Name		= "Raketenwerfer 61",
	Description	= "A heavy, demolition-oriented rocket-assisted mortar, devastating against field works but takes a very long time to load.",
	Model		= "models/missiles/RW61M.mdl",
	Caliber		= 380,
	Mass		= 476,
	Length		= 38,
	Year		= 1960,
	ReloadTime	= 40,
	Racks		= { ["380mmRW61"] = true },
	Guidance	= { Dumb = true },
	Fuzes		= { Contact = true, Optical = true },
	SeekCone	= 35,
	ViewCone	= 55,
	Agility		= 1,
	ArmDelay	= 0.5,
	Round = {
		Model			= "models/missiles/RW61M.mdl",
		RackModel		= "models/missiles/RW61M.mdl",
		MaxLength		= 60,
		Armor			= 5,
		PropMass		= 5,
		Thrust			= 5000, -- in kg*in/s^2
		BurnRate		= 5000, -- in cm^3/s
		StarterPercent	= 0.01,
		MinSpeed		= 1,
		DragCoef		= 0,
		FinMul			= 0.001,
		PenMul			= math.sqrt(2)
	},
})
