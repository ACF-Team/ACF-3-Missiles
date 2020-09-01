--define the class
ACF_defineGunClass("ASM", {
	type            = "missile",
	spread          = 1,
	name            = "Air-To-Surface Missile",
	desc            = "Missiles specialized for air-to-surface operation or antitank. These missiles are heavier than air-to-air missiles and may only be wire or laser guided.",
	muzzleflash     = "gl_muzzleflash_noscale",
	rofmod          = 1,
	sound           = "acf_missiles/missiles/missile_rocket.mp3",
	soundDistance   = " ",
	soundNormal     = " ",
	effect          = "Rocket Motor ATGM",

	reloadmul       = 8,

	ammoBlacklist   = {"AP", "APHE", "FL", "SM"} -- Including FL would mean changing the way round classes work.
} )

-------------------------------------------------------------------------------
--Lighter ATGMs are suitable for closer range
-------------------------------------------------------------------------------

-- The AT-3, a short-range wire-guided missile with better agility than the BGM-71E but much slower.
ACF_defineGun("AT-3 ASM", {
	name = "AT-3 Missile",
	desc = "The AT-3 missile (9M14P) is a short-range wire-guided anti-tank missile. It can be mounted on both helicopters and ground vehicles conveniently due to its light weight and high maneuverability.",
	model = "models/missiles/at3.mdl",
	gunclass = "ASM",
	rack = "1xAT3RK",
	length = 43,
	caliber = 12.5,
	weight = 11.4,
	year = 1969,
	rofmod = 0.6,
	round = {
		model		= "models/missiles/at3.mdl",
		maxlength	= 35,
		casing		= 0.1,
		armour		= 5,
		propweight	= 0.2,
		thrust		= 8000,
		burnrate	= 20,
		starterpct	= 0.2,
		minspeed	= 1500,
		dragcoef	= 0.005,
		dragcoefflight  = 0.1,
		finmul		= 0.1,
		penmul      = math.sqrt(5.39)
	},

	ent         = "acf_rack",
	guidance    = { "Dumb", "Wire (MCLOS)", "Wire (SACLOS)" },
	fuzes       = { "Contact", "Optical" },

	racks       = {["1xAT3RKS"] = true, ["1xAT3RK"] = true, ["1xRK_small"] = true, ["3xRK"] = true},

	skinindex   = {HEAT = 0, HE = 1},

	agility     = 0.2,
	armdelay    = 0.1
} )

-- The BGM-71E, a wire guided missile with high anti-tank effectiveness.
ACF_defineGun("BGM-71E ASM", {
	name = "BGM-71E Missile",
	desc = "The BGM-71E missile is a medium-range wire guided anti-tank missile. It is faster and more powerful than the AT-3 but has less maneuverability.",
	model = "models/missiles/bgm_71e.mdl",
	gunclass = "ASM",
	rack = "1x BGM-71E",
	length = 46,
	caliber = 15.2,
	weight = 22.6,
	year = 1970,
	rofmod = 0.6,
	round = {
		model		= "models/missiles/bgm_71e.mdl",
		maxlength	= 64,
		casing		= 0.1,
		armour		= 6,
		propweight	= 0.2,
		thrust		= 13000,
		burnrate	= 31,
		starterpct	= 0.2,
		minspeed	= 2000,
		dragcoef	= 0.005,
		dragcoefflight  = 0.05,
		finmul		= 0.05,
		penmul      = math.sqrt(3.97)
	},

	ent         = "acf_rack",
	guidance    = { "Dumb", "Wire (SACLOS)" },
	fuzes       = { "Contact", "Optical" },

	racks       = {["1x BGM-71E"] = true, ["2x BGM-71E"] = true, ["4x BGM-71E"] = true},

	agility     = 0.13,
	armdelay    = 0.1
} )

-------------------------------------------------------------------------------
--Heavy ATGMs are suitable for all range and aircraft/dedicated tank killer use
-------------------------------------------------------------------------------

-- The AGM-114, a laser guided missile with high anti-tank effectiveness.
ACF_defineGun("AGM-114 ASM", {
	name = "AGM-114 Missile",
	desc = "The AGM-114 Hellfire is a heavy air-to-surface missile, used often by American aircraft, which is well-suited to both antitank and antimateriel precision strikes.",
	model = "models/missiles/agm_114.mdl",
	gunclass = "ASM",
	rack = "2x AGM-114",
	length = 66,
	caliber = 18,
	weight = 49,
	modeldiameter = 17.2 * 1.27,
	year = 1984,
	rofmod = 1,
	round = {
		model		= "models/missiles/agm_114.mdl",
		maxlength	= 67,
		casing		= 0.2,
		armour		= 5,
		propweight	= 0.25,
		thrust		= 18000,
		burnrate	= 80,
		starterpct	= 0.1,
		minspeed	= 4000,
		dragcoef	= 0.001,
		dragcoefflight  = 0.05,
		finmul		= 0.05,
		penmul      = math.sqrt(4.175)
	},

	ent         = "acf_rack",
	guidance    = { "Dumb", "Laser", "Active Radar" },
	fuzes       = { "Contact", "Optical" },

	racks       = {["2x AGM-114"] = true, ["4x AGM-114"] = true, ["1xRK"] = true},

	viewcone    = 40,
	seekcone	= 10,

	bodygroups	= {
		guidance = {
			DataSource = function(Entity)
				return Entity.Guidance and Entity.Guidance.Name
			end,
			Laser = {
				OnRack = "laser.smd",
			},
			["Active Radar"] = {
				OnRack = "radar.smd",
			}
		}
	},

	agility     = 0.09,		-- multiplier for missile turn-rate.
	armdelay    = 0.5     -- minimum fuze arming delay
} )

-- The 9M120 Ataka, a radio guided equivalent to the AGM-114.
ACF_defineGun("Ataka ASM", {
	name = "9M120 Ataka Missile",
	desc = "The 9M120 Ataka is a heavy air-to-surface missile, used often by soviet helicopters and ground vehicles, which is well suited to antitank use at range. It is lighter and faster than the hellfire, but less maneuverable and with a slightly lighter warhead.",
	model = "models/missiles/9m120.mdl",
	gunclass = "ASM",
	rack = "1x Ataka",
	length = 85,
	caliber = 13,
	weight = 49.5,
	modeldiameter = 17.2 * 1.27,
	year = 1984,
	rofmod = 0.8,
	round = {
		model		= "models/missiles/9m120.mdl",
		maxlength	= 120,
		casing		= 0.12,
		armour		= 5,
		propweight	= 0.11,
		thrust		= 20000,
		burnrate	= 300,
		starterpct	= 0.2,
		minspeed	= 800,
		dragcoef	= 0.001,
		dragcoefflight  = 0.04,
		finmul		= 0.05,
		penmul      = math.sqrt(1.454)
	},

	ent         = "acf_rack",
	guidance    = { "Dumb", "Radio (SACLOS)" },
	fuzes       = { "Contact", "Optical" },

	racks       = {["1x Ataka"] = true, ["1xRK"] = true, ["2xRK"] = true, ["3xRK"] = true, ["4xRK"] = true},    -- a whitelist for racks that this missile can load into.  can also be a 'function(bulletData, rackEntity) return boolean end'

	viewcone    = 45,

	agility     = 0.092,
	armdelay    = 0.1
} )

-------------------------------------------------------------
--Special ATGMs are harder to use, more high risk/high reward
-------------------------------------------------------------

--The 9M113, a very long range, very powerful, but with a long boost phase antitank missile
ACF_defineGun("9M113 ASM", {
	name = "9M133 Missile",
	desc = "The Kornet is an extremely powerful antitank missile, with excellent range and a very powerful warhead, but limited maneuverability.  Best used at long range or in an ambush role.",
	model = "models/kali/weapons/kornet/parts/9m133 kornet missile.mdl",
	gunclass = "ASM",
	rack = "1x Kornet",
	length = 80,
	caliber = 15.2,
	weight = 27,
	modeldiameter = 15.2,
	year = 1994,
	rofmod = 0.75,
	ExhaustOffset = Vector(-29.1, 0, 0),
	round = {
		model		= "models/kali/weapons/kornet/parts/9m133 kornet missile.mdl",
		maxlength	= 70,
		casing		= 0.2,
		armour		= 5,
		propweight	= 0.1,
		thrust		= 15000,
		burnrate	= 10,
		starterpct	= 0.2,
		minspeed	= 8000,
		dragcoef	= 0.005,
		dragcoefflight  = 0.05,
		finmul		= 0.05,
		penmul      = math.sqrt(4.2)
	},

	ent         = "acf_rack",
	guidance    = { "Dumb", "Laser" },
	fuzes       = { "Contact", "Optical" },

	racks       = {["1x Kornet"] = true},

	viewcone    = 20,

	bodygroups	= {
		fins = {
			DataSource = function()
				return "Fins"
			end,
			Fins = {
				OnRack = "Fins_Stowed",
				OnLaunch = "Fins_Deployed",
			},
		}
	},

	agility     = 0.2,		-- multiplier for missile turn-rate.
	armdelay    = 0.1     -- minimum fuse arming delay
} )

-- The 9M17P, a medium range, very powerful but slow antitank missile
ACF_defineGun("AT-2 ASM", {
	name = "AT-2 Missile",
	desc = "The 9M17P is a powerful radio command medium-range antitank missile, intended for use on helicopters and anti tank vehicles. It has a more powerful warhead and longer range than the AT-3 at the cost of weight and agility.",
	model = "models/missiles/at2.mdl",
	gunclass = "ASM",
	rack = "1xRK",
	length = 55,
	caliber = 14.8,
	weight = 27,
	year = 1969,
	rofmod = 0.9,
	round = {
		model		= "models/missiles/at2.mdl",
		maxlength	= 60,
		casing		= 0.1,
		armour		= 5,
		propweight	= 0.07,
		thrust		= 6000,
		burnrate	= 9,
		starterpct	= 0.2,
		minspeed	= 500,
		dragcoef	= 0.01,
		dragcoefflight  = 0.04,
		finmul		= 0.1,
		penmul      = math.sqrt(3.025)
	},

	ent         = "acf_rack",
	guidance    = { "Dumb", "Radio (MCLOS)", "Radio (SACLOS)" },
	fuses       = { "Contact", "Optical" },
	viewcone    = 90,
	racks       = {["1xRK"] = true, ["2xRK"] = true, ["3xRK"] = true, ["4xRK"] = true, ["2x AGM-114"] = true, ["4x AGM-114"] = true, ["1xRK_small"] = true},    -- a whitelist for racks that this missile can load into.  can also be a 'function(bulletData, rackEntity) return boolean end'
	agility     = 0.08,
	armdelay    = 0.1
} )
-----------------------------
-- Anti-radiation Missiles --
-----------------------------

-- The AGM-45 shrike, a vietnam war-era antiradiation missile built off the AIM-7 airframe.
ACF_defineGun("AGM-45 ASM", { --id
	name = "AGM-45 Shrike Missile",
	desc = "The body of an AIM-7 sparrow, an air-to-ground seeker kit, and a far larger warhead than its ancestor.\nWith its homing radar seeker option, thicker skin, and long range, it is a great weapon for long-range, precision standoff attack versus squishy things, like those pesky sam sites.",
	model = "models/missiles/aim120.mdl",
	gunclass = "ASM",
	rack = "1xRK",  -- Which rack to spawn this missile on?
	length = 1000,
	caliber = 20.3,
	weight = 150,    -- Don't scale down the weight though!
	modeldiameter = 7.1 * 2.54, -- in cm
	year = 1969,
	rofmod = 0.6,
	round = {
		model		= "models/missiles/aim120.mdl",
		maxlength	= 120,
		casing		= 0.15,			-- thickness of missile casing, cm
		armour		= 10,			-- effective armour thickness of casing, in mm
		propweight	= 3,			-- motor mass - motor casing
		thrust		= 800,		-- average thrust - kg*in/s^2
		burnrate	= 300,			-- cm^3/s at average chamber pressure
		starterpct	= 0.05,			-- percentage of the propellant consumed in the starter motor.
		minspeed	= 4000,			-- minimum speed beyond which the fins work at 100% efficiency
		dragcoef	= 0.001,		-- drag coefficient while falling
				dragcoefflight  = 0,                 -- drag coefficient during flight
		finmul		= 0.2,			-- fin multiplier (mostly used for unpropelled guidance)
		penmul      = math.sqrt(0.5)  	-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

	ent         = "acf_rack", -- A workaround ent which spawns an appropriate rack for the missile.
	guidance    = { "Dumb", "Anti-radiation" },
	fuzes       = { "Contact", "Timed" },

	racks       = {["1xRK"] = true, ["2xRK"] = true, ["3xRK"] = true, ["4xRK"] = true, ["6xUARRK"] = true},    -- a whitelist for racks that this missile can load into.  can also be a 'function(bulletData, rackEntity) return boolean end'

	seekcone = 5,		--why do you need a big seeker cone if yuo're firing vs a SAM site?
	viewcone = 10,		--I don't think a fucking SAM site should have to dodge much >_>

	agility     = 0.08,		-- multiplier for missile turn-rate.
	armdelay    = 0.3     -- minimum fuze arming delay
} )

--Sidearm, a lightweight anti-radar missile used by helicopters in the 80s
ACF_defineGun("AGM-122 ASM", { --id
	name = "AGM-122 Sidearm Missile",
		desc = "A refurbished early-model AIM-9, for attacking ground targets.  Less well-known than the bigger Shrike, it provides easy-to-use blind-fire anti-SAM performance for helicopters and light aircraft, with far heavier a punch than its ancestor.",
	model = "models/missiles/aim9.mdl",
	gunclass = "ASM",
	rack = "1xRK",  -- Which rack to spawn this missile on?
	length = 205,
	caliber = 12.7, -- Aim-9 is listed as 9 as of 6/30/2017, why?  Wiki lists it as a 5" rocket!
	weight = 88.5,    -- Don't scale down the weight though!
	rofmod = 0.3,
	year = 1986,
	round = {
		model		= "models/missiles/aim9.mdl",
		maxlength	= 70,
		casing		= 0.1,	        -- thickness of missile casing, cm
		armour		= 8,			-- effective armour thickness of casing, in mm
		propweight	= 4,	        -- motor mass - motor casing
		thrust		= 4500,	    -- average thrust - kg*in/s^2		--was 100000
		burnrate	= 1400,	        -- cm^3/s at average chamber pressure	--was 350
		starterpct	= 0.4,          -- percentage of the propellant consumed in the starter motor.	--was 0.2
		minspeed	= 5000,		-- minimum speed beyond which the fins work at 100% efficiency
		dragcoef	= 0.001,		-- drag coefficient while falling
				dragcoefflight  = 0.001,                 -- drag coefficient during flight
		finmul		= 0.03			-- fin multiplier (mostly used for unpropelled guidance)
	},

	ent         = "acf_rack", -- A workaround ent which spawns an appropriate rack for the missile.
	guidance    = { "Dumb", "Anti-radiation" },
	fuzes       = { "Contact", "Optical" },

	racks       = {["1xRK"] = true,  ["2xRK"] = true, ["3xRK"] = true, ["4xRK"] = true, ["1xRK_small"] = true},   -- a whitelist for racks that this missile can load into.  can also be a 'function(bulletData, rackEntity) return boolean end'

	seekcone    = 10,   -- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)	--was 25
	viewcone    = 20,   -- getting outside this cone will break the lock.  Divided by 2.

	agility     = 0.3,  -- multiplier for missile turn-rate.
	armdelay    = 0.2     -- minimum fuze arming delay		--was 0.4
} )

-- The AGM-119, a heavy antiship missile
--[[
ACF_defineGun("AGM-119 ASM", { --id
	name = "AGM-119 Penguin Missile",
	desc = "An antiship missile, capable of delivering a massive punch versus ships or fixed targets.\nAlthough maneuverable and dangerous, it is very heavy and large, with only its laser-guided variant being able to engage moving targets.",
	model = "models/props/missiles/agm119_s.mdl",
	gunclass = "ASM",
	rack = "1xRK",  -- Which rack to spawn this missile on?
	length = 1000,
	caliber = 30,
	weight = 380,    -- Don't scale down the weight though!
	modeldiameter = 28, -- in cm
	year = 1972,
	round = {
		model		= "models/props/missiles/agm119_s.mdl",
		maxlength	= 50,
		casing		= 0.3,			-- thickness of missile casing, cm
		armour		= 25,			-- effective armour thickness of casing, in mm
		propweight	= 3,			-- motor mass - motor casing
		thrust		= 725,		-- average thrust - kg*in/s^2
		burnrate	= 50,			-- cm^3/s at average chamber pressure
		starterpct	= 0.2,			-- percentage of the propellant consumed in the starter motor.
		minspeed	= 250,			-- minimum speed beyond which the fins work at 100% efficiency
		dragcoef	= 0,		-- drag coefficient while falling
				dragcoefflight  = 0.005,                 -- drag coefficient during flight
		finmul		= 0.2,			-- fin multiplier (mostly used for unpropelled guidance)
		penmul      = math.sqrt(0.25)  	-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

	ent         = "acf_rack", -- A workaround ent which spawns an appropriate rack for the missile.
	guidance    = {"Dumb", "Laser", "Radar"},
	fuzes       = ACF_GetAllFuzeNamesExcept( {"Radio"} ),

	racks       = {["1xRK"] = true, ["2xRK"] = true},    -- a whitelist for racks that this missile can load into.  can also be a 'function(bulletData, rackEntity) return boolean end'
	seekcone = 1,
	viewcone = 1,		--I don't think a fucking SAM site should have to dodge much >_>

	agility     = 0.1,		-- multiplier for missile turn-rate.
	armdelay    = 0.3     -- minimum fuze arming delay
} )
]]--

ACF.RegisterMissileClass("ATGM", {
	Name		= "Anti-Tank Guided Missiles",
	Description	= "Missiles specialized on destroying heavily armored vehicles.",
	Sound		= "acf_missiles/missiles/missile_rocket.mp3",
	Effect		= "Rocket Motor ATGM",
	ReloadMul	= 8,
	RoFMod		= 1,
	Spread		= 1,
	Blacklist	= { "AP", "APHE", "HP", "FL", "SM" }
})

ACF.RegisterMissile("AT-3 ASM", "ATGM", {
	Name		= "9M14 Malyutka",
	Description	= "The 9M14 Malyutka (AT-3 Sagger) is a short-range wire-guided anti-tank missile.",
	Model		= "models/missiles/at3.mdl",
	Length		= 43,
	Caliber		= 125,
	Mass		= 11,
	Diameter	= 4.2 * 25.4,
	Year		= 1969,
	RoFMod		= 0.6,
	Guidance	= { "Dumb", "Wire (MCLOS)", "Wire (SACLOS)" },
	Fuzes		= { "Contact", "Optical" },
	Racks		= { ["1xAT3RKS"] = true, ["1xAT3RK"] = true, ["1xRK_small"] = true, ["4xRK"] = true },
	SkinIndex	= { HEAT = 0, HE = 1 },
	Agility		= 0.3,
	ArmDelay	= 0.3,
	Round = {
		Model			= "models/missiles/at3.mdl",
		MaxLength		= 35,
		Armor			= 5,
		PropMass		= 1.2,
		Thrust			= 7000, -- in kg*in/s^2
		BurnRate		= 150, -- in cm^3/s
		StarterPercent	= 0.2,
		MinSpeed		= 1500,
		DragCoef		= 0.005,
		DragCoefFlight	= 0.1,
		FinMul			= 0.1,
		PenMul			= math.sqrt(5.5)
	},
})

ACF.RegisterMissile("BGM-71E ASM", "ATGM", {
	Name		= "BGM-71E TOW",
	Description	= "The BGM-71E TOW is a short-range wire guided anti-tank missile.",
	Model		= "models/missiles/bgm_71e.mdl",
	Length		= 46,
	Caliber		= 152,
	Mass		= 23,
	Year		= 1970,
	RoFMod		= 0.8,
	Guidance	= { "Dumb", "Wire (SACLOS)" },
	Fuzes		= { "Contact", "Optical" },
	Racks		= { ["1x BGM-71E"] = true, ["2x BGM-71E"] = true, ["4x BGM-71E"] = true },
	Agility		= 0.25,
	ArmDelay	= 0.3,
	Round = {
		Model			= "models/missiles/bgm_71e.mdl",
		MaxLength		= 35,
		Armor			= 6,
		PropMass		= 1.2,
		Thrust			= 13000, -- in kg*in/s^2
		BurnRate		= 200, -- in cm^3/s
		StarterPercent	= 0.2,
		MinSpeed		= 2000,
		DragCoef		= 0.005,
		DragCoefFlight	= 0.05,
		FinMul			= 0.05,
		PenMul			= math.sqrt(6)
	},
})

ACF.RegisterMissile("AGM-114 ASM", "ATGM", {
	Name		= "AGM-114 Hellfire",
	Description	= "The AGM-114 Hellfire is a heavy air-to-surface missile, used often by American aircraft.",
	Model		= "models/missiles/agm_114.mdl",
	Length		= 66,
	Caliber		= 180,
	Mass		= 45,
	Diameter	= 6.5 * 25.4, -- in mm
	Year		= 1984,
	RoFMod		= 1,
	Guidance	= { "Dumb", "Laser", "Active Radar" },
	Fuzes		= { "Contact", "Optical" },
	Racks		= { ["1xRK"] = true, ["2x AGM-114"] = true, ["4x AGM-114"] = true },
	ViewCone	= 40,
	SeekCone	= 10,
	Agility		= 0.09,
	ArmDelay	= 0.5,
	Bodygroups = {
		guidance = {
			DataSource = function(Entity)
				return Entity.Guidance and Entity.Guidance.Name
			end,
			Laser = {
				OnRack = "laser.smd",
			},
			["Active Radar"] = {
				OnRack = "radar.smd",
			}
		}
	},
	Round = {
		Model			= "models/missiles/agm_114.mdl",
		MaxLength		= 46,
		Armor			= 5,
		PropMass		= 1,
		Thrust			= 12000, -- in kg*in/s^2
		BurnRate		= 150, -- in cm^3/s
		StarterPercent	= 0.1,
		MinSpeed		= 4000,
		DragCoef		= 0.001,
		DragCoefFlight	= 0.05,
		FinMul			= 0.1,
		PenMul			= math.sqrt(5)
	},
})

ACF.RegisterMissile("Ataka ASM", "ATGM", {
	Name		= "9M120 Ataka",
	Description	= "The 9M120 Ataka (AT-9 Spiral-2) is a heavy air-to-surface missile, used often by soviet helicopters and ground vehicles.",
	Model		= "models/missiles/9m120.mdl",
	Length		= 85,
	Caliber		= 130,
	Mass		= 50,
	Year		= 1984,
	RoFMod		= 0.8,
	Guidance	= { "Dumb", "Radio (SACLOS)" },
	Fuzes		= { "Contact", "Optical" },
	Racks		= { ["1x Ataka"] = true },
	ViewCone	= 40,
	Agility		= 0.06,
	ArmDelay	= 0.4,
	Round = {
		Model			= "models/missiles/9m120.mdl",
		MaxLength		= 60,
		Armor			= 5,
		PropMass		= 2.4,
		Thrust			= 14000, -- in kg*in/s^2
		BurnRate		= 400, -- in cm^3/s
		StarterPercent	= 0.2,
		MinSpeed		= 5000,
		DragCoef		= 0.001,
		DragCoefFlight	= 0.04,
		FinMul			= 0.05,
		PenMul			= math.sqrt(4.5)
	},
})

ACF.RegisterMissile("9M113 ASM", "ATGM", {
	Name		= "9M133 Kornet",
	Description	= "The 9M133 Kornet (AT-14 Spriggan) is an extremely powerful antitank missile.",
	Model		= "models/kali/weapons/kornet/parts/9m133 kornet missile.mdl",
	Length		= 80,
	Caliber		= 152,
	Mass		= 27,
	Year		= 1994,
	RoFMod		= 0.75,
	ExhaustOffset = Vector(-29.1, 0, 0),
	Guidance	= { "Dumb", "Laser" },
	Fuzes		= { "Contact", "Optical" },
	Racks		= { ["1x Kornet"] = true },
	ViewCone	= 20,
	Agility		= 0.06,
	ArmDelay	= 0.1,
	Bodygroups = {
		fins = {
			DataSource = function()
				return "Fins"
			end,
			Fins = {
				OnRack = "Fins_Stowed",
				OnLaunch = "Fins_Deployed",
			},
		}
	},
	Round = {
		Model			= "models/kali/weapons/kornet/parts/9m133 kornet missile.mdl",
		MaxLength		= 70,
		Armor			= 5,
		PropMass		= 3,
		Thrust			= 16000, -- in kg*in/s^2
		BurnRate		= 300, -- in cm^3/s
		StarterPercent	= 0.2,
		MinSpeed		= 6000,
		DragCoef		= 0.005,
		DragCoefFlight	= 0.05,
		FinMul			= 0.05,
		PenMul			= math.sqrt(3.9)
	},
})

ACF.RegisterMissile("AT-2 ASM", "ATGM", {
	Name		= "9M17 Fleyta",
	Description	= "The 9M17 Fleyta (AT-2 Sagger) is a VERY powerful long-range antitank missile.",
	Model		= "models/missiles/at2.mdl",
	Length		= 55,
	Caliber		= 148,
	Mass		= 27,
	Year		= 1969,
	RoFMod		= 0.9,
	Guidance	= { "Dumb", "Radio (MCLOS)", "Radio (SACLOS)" },
	Fuzes		= { "Contact", "Optical" },
	ViewCone	= 90,
	Racks		= { ["1xRK"] = true, ["2xRK"] = true, ["3xRK"] = true },
	Agility		= 0.2,
	ArmDelay	= 1,
	Round = {
		Model			= "models/missiles/at2.mdl",
		MaxLength		= 55,
		Armor			= 5,
		PropMass		= 1,
		Thrust			= 1500, -- in kg*in/s^2
		BurnRate		= 50, -- in cm^3/s
		StarterPercent	= 0.2,
		MinSpeed		= 500,
		DragCoef		= 0.001,
		DragCoefFlight	= 0.01,
		FinMul			= 0.1,
		PenMul			= math.sqrt(5.4)
	},
})
