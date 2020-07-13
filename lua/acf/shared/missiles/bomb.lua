--define the class
ACF_defineGunClass("BOMB", {
	type            = "missile",  -- i know i know
	spread          = 1,
	name            = "General Purpose Bomb",
	desc            = "Free-falling bombs.  Despite their lack of guidance and sophistication, they are exceptionally destructive on impact relative to their weight.",
	muzzleflash     = "gl_muzzleflash_noscale",
	rofmod          = 0.1,
	sound           = "acf_missiles/fx/clunk.mp3",
	soundDistance   = " ",
	soundNormal     = " ",
	nothrust		= true,

	reloadmul       = 8,

	ammoBlacklist   = {"AP", "APHE", "FL"} -- Including FL would mean changing the way round classes work.
} )

--[[ we don't use barrels!
ACF_defineGun("BarrelBOMB", { --id
	name = "Barrel Bomb",
	desc = "Dissidents annoying you?  Can't afford a real bomb?  Just feel like screwing around?  Lob one of these out of a plane!  (working description --Red",
	model = "models/props_c17/oildrum001_explosive.mdl",
	gunclass = "BOMB",
	rack = "1xRK",
	length = 50,
	caliber = 10.0,
	weight = 50,
	year = 2015,
	modeldiameter = 30,
	round = {
			model = "models/props_c17/oildrum001_explosive.mdl",
			rackmdl = "models/props_c17/oildrum001_explosive.mdl",
			maxlength = 50,
			casing = 20,
			armor = 3,
			propweight = 1,
			thrust = 1,
			burnrate = 1,
			starterpct = 1,
			minspeed = 1,
			dragcoef = 0.01, -- as aerodynamic as a brick
			finmul = 0,
			penmul = math.sqrt(0.01),
	},

	ent         = "acf_rack", -- A workaround ent which spawns an appropriate rack for the missile.
	guidance    = {"Dumb"}, --no shit.
	fuzes       = {"Contact"},

	racks       = {["1xRK_small"] = true,  ["1xRK"] = true, ["2xRK"] = true,  ["3xRK"] = true, ["4xRK"] = true},   -- a whitelist for racks that this missile can load into.  can also be a 'function(bulletData, rackEntity) return boolean end'

	seekcone = 1,
	viewcone = 1,

	agility = 0.01,
	armdelay = 0.1,
} )
]]--

-- Balance the round in line with the 40mm pod rocket.
ACF_defineGun("50kgBOMB", { --id
	name = "50kg Free Falling Bomb",
	desc = "Old WW2 100lb bomb, most effective vs exposed infantry and light trucks.",
	model = "models/bombs/fab50.mdl",
	gunclass = "BOMB",
	rack = "3xRK",  -- Which rack to spawn this missile on?
	length = 5,
	caliber = 5.0,
	weight = 50,    -- Don't scale down the weight though!
	year = 1936,
	modeldiameter = 2.4 * 2.7, -- in cm
	round = {
		model		= "models/bombs/fab50.mdl",
		maxlength	= 50,
		casing		= 0.5,	        -- thickness of missile casing, cm
		armour		= 25,			-- effective armour thickness of casing, in mm
		propweight	= 0,	        -- motor mass - motor casing
		thrust		= 1,	    	-- average thrust - kg*in/s^2
		burnrate	= 1,	        -- cm^3/s at average chamber pressure
		starterpct	= 0.01,         -- percentage of the propellant consumed in the starter motor.
		minspeed	= 1,			-- minimum speed beyond which the fins work at 100% efficiency
		dragcoef	= 0.002,		-- drag coefficient of the missile
		finmul		= 0.008,		-- fin multiplier (mostly used for unpropelled guidance)
		penmul      = math.sqrt(0.6)  	-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

	ent         = "acf_rack", -- A workaround ent which spawns an appropriate rack for the missile.
	guidance    = {"Dumb"},
	fuzes       = {"Contact", "Optical", "Cluster"},

	racks       = {["1xRK_small"] = true,  ["1xRK"] = true, ["2xRK"] = true,  ["3xRK"] = true, ["4xRK"] = true},   -- a whitelist for racks that this missile can load into.  can also be a 'function(bulletData, rackEntity) return boolean end'


	seekcone    = 40,   -- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)
	viewcone    = 60,   -- getting outside this cone will break the lock.  Divided by 2. 

	agility     = 1,     -- multiplier for missile turn-rate.
	armdelay    = 0.5     -- minimum fuze arming delay
} )

ACF_defineGun("100kgBOMB", { --id
	name = "100kg Free Falling Bomb",
	desc = "An old 250lb WW2 bomb, as used by Soviet bombers to destroy enemies of the Motherland.",
	model = "models/bombs/fab100.mdl",
	gunclass = "BOMB",
	rack = "1xRK",  -- Which rack to spawn this missile on?
	length = 50,
	caliber = 10.0,
	weight = 100,    -- Don't scale down the weight though!
	year = 1939,
	modeldiameter = 21.2 * 1.4, -- in cm
	round = {
		model		= "models/bombs/fab100.mdl",
		maxlength	= 100,
		casing		= 0.7,	        -- thickness of missile casing, cm
		armour		= 25,			-- effective armour thickness of casing, in mm
		propweight	= 0,	        -- motor mass - motor casing
		thrust		= 1,	    	-- average thrust - kg*in/s^2
		burnrate	= 1,	        -- cm^3/s at average chamber pressure
		starterpct	= 0.005,        -- percentage of the propellant consumed in the starter motor.
		minspeed	= 1,			-- minimum speed beyond which the fins work at 100% efficiency
		dragcoef	= 0.002,		-- drag coefficient of the missile
		finmul		= 0.007,			-- fin multiplier (mostly used for unpropelled guidance)
		penmul      = math.sqrt(0.6)  	-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

	ent         = "acf_rack", -- A workaround ent which spawns an appropriate rack for the missile.
	guidance    = {"Dumb"},
	fuzes       = {"Contact", "Optical", "Cluster"},

	racks       = {["1xRK_small"] = true, ["1xRK"] = true, ["2xRK"] = true,  ["3xRK"] = true, ["4xRK"] = true},   -- a whitelist for racks that this missile can load into.  can also be a 'function(bulletData, rackEntity) return boolean end'

	seekcone    = 40,   -- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)
	viewcone    = 60,   -- getting outside this cone will break the lock.  Divided by 2. 

	agility     = 1,     -- multiplier for missile turn-rate.
	armdelay    = 1     -- minimum fuze arming delay
} )

ACF_defineGun("250kgBOMB", { --id
	name = "250kg Free Falling Bomb",
	desc = "A heavy 500lb bomb, widely used as a tank buster on various WW2 aircraft.",
	model = "models/bombs/fab250.mdl",
	gunclass = "BOMB",
	rack = "1xRK",  -- Which rack to spawn this missile on?
	length = 5000,
	caliber = 12.5,
	weight = 250,    -- Don't scale down the weight though!
	year = 1941,
	modeldiameter = 16.3 * 1.9, -- in cm
	round = {
		model		= "models/bombs/fab250.mdl",
		maxlength	= 250, --was 115, wtf!
		casing		= 1.5,	        -- thickness of missile casing, cm
		armour		= 25,			-- effective armour thickness of casing, in mm
		propweight	= 0,	        -- motor mass - motor casing
		thrust		= 1,	    	-- average thrust - kg*in/s^2
		burnrate	= 1,	        -- cm^3/s at average chamber pressure
		starterpct	= 0.005,        -- percentage of the propellant consumed in the starter motor.
		minspeed	= 1,			-- minimum speed beyond which the fins work at 100% efficiency
		dragcoef	= 0.002,		-- drag coefficient of the missile
		finmul		= 0.005,			-- fin multiplier (mostly used for unpropelled guidance)
		penmul      = math.sqrt(0.6)  	-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

	ent         = "acf_rack", -- A workaround ent which spawns an appropriate rack for the missile.
	guidance    = {"Dumb"},
	fuzes       = {"Contact", "Optical", "Cluster"},

	racks       = {["1xRK"] = true,  ["2xRK"] = true},   -- a whitelist for racks that this missile can load into.  can also be a 'function(bulletData, rackEntity) return boolean end'


	seekcone    = 40,   -- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)
	viewcone    = 60,   -- getting outside this cone will break the lock.  Divided by 2. 

	agility     = 1,     -- multiplier for missile turn-rate.
	armdelay    = 1     -- minimum fuze arming delay
} )

ACF_defineGun("500kgBOMB", { --id
	name = "500kg Free Falling Bomb",
	desc = "A 1000lb bomb, as found in the heavy bombers of late WW2. Best used against fortifications or immobile targets.",
	model = "models/bombs/fab500.mdl",
	gunclass = "BOMB",
	rack = "1xRK",  -- Which rack to spawn this missile on?
	length = 15000,
	caliber = 30.0,
	weight = 500,    -- Don't scale down the weight though!
	year = 1943,
	modeldiameter = 16.3 * 1.9, -- in cm
	round = {
		model		= "models/bombs/fab500.mdl",
		maxlength	= 200,
		casing		= 1.5,	        -- thickness of missile casing, cm
		armour		= 25,			-- effective armour thickness of casing, in mm
		propweight	= 0,	        -- motor mass - motor casing
		thrust		= 1,	    	-- average thrust - kg*in/s^2
		burnrate	= 1,	        -- cm^3/s at average chamber pressure
		starterpct	= 0.005,        -- percentage of the propellant consumed in the starter motor.
		minspeed	= 1,			-- minimum speed beyond which the fins work at 100% efficiency
		dragcoef	= 0.002,		-- drag coefficient of the missile
		finmul		= 0.004,			-- fin multiplier (mostly used for unpropelled guidance)
		penmul      = math.sqrt(0.6)  	-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

	ent         = "acf_rack", -- A workaround ent which spawns an appropriate rack for the missile.
	guidance    = {"Dumb"},
	fuzes       = {"Contact", "Optical", "Cluster"},

	racks       = {["1xRK"] = true,  ["2xRK"] = true},   -- a whitelist for racks that this missile can load into.  can also be a 'function(bulletData, rackEntity) return boolean end'

	seekcone    = 40,   -- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)
	viewcone    = 60,   -- getting outside this cone will break the lock.  Divided by 2. 

	agility     = 1,     -- multiplier for missile turn-rate.
	armdelay    = 2     -- minimum fuze arming delay
} )

ACF_defineGun("1000kgBOMB", { --id
	name = "1000kg Free Falling Bomb",
	desc = "A 2000lb bomb. As close to a nuke as you can get in ACF, this munition will turn everything it touches to ashes. Handle with care.",
	model = "models/bombs/an_m66.mdl",
	gunclass = "BOMB",
	rack = "1xRK",  -- Which rack to spawn this missile on?
	length = 30000,
	caliber = 30.0,
	weight = 1000,    -- Don't scale down the weight though! 
	year = 1945,
	modeldiameter = 16.3 * 4.5, -- in cm
	round = {
		model		= "models/bombs/an_m66.mdl",
		maxlength	= 375,
		casing		= 2.0,	        -- thickness of missile casing, cm
		armour		= 25,			-- effective armour thickness of casing, in mm
		propweight	= 0,	        -- motor mass - motor casing
		thrust		= 1,	    	-- average thrust - kg*in/s^2
		burnrate	= 1,	        -- cm^3/s at average chamber pressure
		starterpct	= 0.005,        -- percentage of the propellant consumed in the starter motor.
		minspeed	= 1,			-- minimum speed beyond which the fins work at 100% efficiency
		dragcoef	= 0.002,		-- drag coefficient of the missile
		finmul		= 0.004,			-- fin multiplier (mostly used for unpropelled guidance)
		penmul      = math.sqrt(0.6)  	-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

	ent         = "acf_rack", -- A workaround ent which spawns an appropriate rack for the missile.
	guidance    = {"Dumb"},
	fuzes       = {"Contact", "Optical", "Cluster"},

	racks       = {["1xRK"] = true},   -- a whitelist for racks that this missile can load into.  can also be a 'function(bulletData, rackEntity) return boolean end'

	seekcone    = 40,   -- getting inside this cone will get you locked.  Divided by 2 ('seekcone = 40' means 80 degrees total.)
	viewcone    = 60,   -- getting outside this cone will break the lock.  Divided by 2. 

	agility     = 1,     -- multiplier for missile turn-rate.
	armdelay    = 3     -- minimum fuze arming delay
} )

ACF_defineGun("100kgGBOMB", { --id
	name = "100kg Glide Bomb",
	desc = "A 250-pound bomb, fitted with fins for a longer reach.  Well suited to dive bombing, but bulkier and heavier from its fins.",
	model = "models/missiles/micro.mdl",
	gunclass = "BOMB",
	rack = "1xRK",  -- Which rack to spawn this missile on?
	length = 75,
	caliber = 10.0,
	weight = 150,    -- Don't scale down the weight though!
	year = 1939,
	modeldiameter = 21.2 * 1.4, -- in cm
	round = {
		model		= "models/missiles/micro.mdl",
		maxlength	= 100,
		casing		= 0.7,	        -- thickness of missile casing, cm
		armour		= 25,			-- effective armour thickness of casing, in mm
		propweight	= 0,	        -- motor mass - motor casing
		thrust		= 1,	    	-- average thrust - kg*in/s^2
		burnrate	= 1,	        -- cm^3/s at average chamber pressure
		starterpct	= 0.005,        -- percentage of the propellant consumed in the starter motor.
		minspeed	= 500,			-- minimum speed beyond which the fins work at 100% efficiency
		dragcoef	= 0.0001,		-- drag coefficient of the missile
		finmul		= 0.05,			-- fin multiplier (mostly used for unpropelled guidance)
		penmul      = math.sqrt(0.6)  	-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

	ent         = "acf_rack", -- A workaround ent which spawns an appropriate rack for the missile.
	guidance    = {"Dumb"},
	fuzes       = {"Contact", "Optical", "Cluster"},
	racks       = {["1xRK_small"] = true, ["1xRK"] = true, ["2xRK"] = true,  ["3xRK"] = true, ["4xRK"] = true},   -- a whitelist for racks that this missile can load into.  can also be a 'function(bulletData, rackEntity) return boolean end'

	armdelay    = 1     -- minimum fuze arming delay
})

ACF_defineGun("250kgGBOMB", { --id
	name = "250kg Glide Bomb",
	desc = "A heavy 500lb bomb, fitted with fins for a gliding trajectory better suited to striking point targets.",
	model = "models/missiles/fab250.mdl",
	gunclass = "BOMB",
	rack = "1xRK",  -- Which rack to spawn this missile on?
	length = 150,
	caliber = 12.5,
	weight = 375,    -- Don't scale down the weight though!
	year = 1941,
	modeldiameter = 16.3 * 1.9, -- in cm
	round = {
		model		= "models/missiles/fab250.mdl",
		maxlength	= 250,
		casing		= 1.5,	        -- thickness of missile casing, cm
		armour		= 25,			-- effective armour thickness of casing, in mm
		propweight	= 0,	        -- motor mass - motor casing
		thrust		= 1,	    	-- average thrust - kg*in/s^2
		burnrate	= 1,	        -- cm^3/s at average chamber pressure
		starterpct	= 0.005,        -- percentage of the propellant consumed in the starter motor.
		minspeed	= 500,			-- minimum speed beyond which the fins work at 100% efficiency
		dragcoef	= 0.001,		-- drag coefficient of the missile
		finmul		= 0.05,			-- fin multiplier (mostly used for unpropelled guidance)
		penmul      = math.sqrt(0.6)  	-- HEAT velocity multiplier. Squared relation to penetration (math.sqrt(2) means 2x pen)
	},

	ent         = "acf_rack", -- A workaround ent which spawns an appropriate rack for the missile.
	guidance    = {"Dumb"},
	fuzes       = {"Contact", "Optical", "Cluster"},

	racks       = {["1xRK"] = true,  ["2xRK"] = true, ["3xRK"] = true, ["4xRK"] = true},   -- a whitelist for racks that this missile can load into.  can also be a 'function(bulletData, rackEntity) return boolean end'
	armdelay    = 1     -- minimum fuze arming delay
} )

ACF.RegisterMissileClass("BOMB", {
	Name		= "General Purpose Bomb",
	Description	= "Despite their lack of guidance and sophistication, they are exceptionally destructive on impact relative to their weight.",
	Sound		= "acf_missiles/fx/clunk.mp3",
	NoThrust	= true,
	ReloadMul	= 8,
	RoFMod		= 0.1,
	Spread		= 1,
	Blacklist	= { "AP", "APHE", "HP", "FL" }
})

ACF.RegisterMissile("50kgBOMB", "BOMB", {
	Name		= "50kg Free Falling Bomb",
	Description	= "Old WW2 100lb bomb, most effective vs exposed infantry and light trucks.",
	Model		= "models/bombs/fab50.mdl",
	Rack		= "3xRK",
	Length		= 5,
	Caliber		= 50,
	Mass		= 50,
	Year		= 1936,
	Diameter	= 2.4 * 2.7, -- in cm
	Guidance	= { "Dumb" },
	Fuzes		= { "Contact", "Optical", "Cluster" },
	Racks		= { ["1xRK_small"] = true, ["1xRK"] = true, ["2xRK"] = true, ["3xRK"] = true, ["4xRK"] = true },
	SeekCone	= 40,
	ViewCone	= 60,
	Agility		= 1,
	ArmDelay	= 0.5,
	Round = {
		Model			= "models/bombs/fab50.mdl",
		MaxLength		= 50,
		Armor			= 25,
		PropMass		= 0,
		Thrust			= 1, -- in kg*in/s^2
		BurnRate		= 1, -- in cm^3/s
		StarterPercent	= 0.01,
		MinSpeed		= 1,
		DragCoef		= 0.002,
		FinMul			= 0.008,
		PenMul			= math.sqrt(0.6)
	},
})

ACF.RegisterMissile("100kgBOMB", "BOMB", {
	Name		= "100kg Free Falling Bomb",
	Description	= "An old 250lb WW2 bomb, as used by Soviet bombers to destroy enemies of the Motherland.",
	Model		= "models/bombs/fab100.mdl",
	Rack		= "1xRK",
	Length		= 50,
	Caliber		= 100,
	Mass		= 100,
	Year		= 1939,
	Diameter	= 21.2 * 1.4, -- in cm
	Guidance	= {"Dumb"},
	Fuzes		= {"Contact", "Optical", "Cluster"},
	Racks		= {["1xRK_small"] = true, ["1xRK"] = true, ["2xRK"] = true, ["3xRK"] = true, ["4xRK"] = true},
	SeekCone	= 40,
	ViewCone	= 60,
	Agility		= 1,
	ArmDelay	= 1,
	Round = {
		Model			= "models/bombs/fab100.mdl",
		MaxLength		= 100,
		Armor			= 25,
		PropMass		= 0,
		Thrust			= 1, -- in kg*in/s^2
		BurnRate		= 1, -- in cm^3/s
		StarterPercent	= 0.005,
		MinSpeed		= 1,
		DragCoef		= 0.002,
		FinMul			= 0.007,
		PenMul			= math.sqrt(0.6)
	},
})

ACF.RegisterMissile("250kgBOMB", "BOMB", {
	Name		= "250kg Free Falling Bomb",
	Description	= "A heavy 500lb bomb, widely used as a tank buster on various WW2 aircraft.",
	Model		= "models/bombs/fab250.mdl",
	Rack		= "1xRK",
	Length		= 5000,
	Caliber		= 125,
	Mass		= 250,
	Year		= 1941,
	Diameter	= 16.3 * 1.9, -- in cm
	Guidance	= { "Dumb" },
	Fuzes		= { "Contact", "Optical", "Cluster" },
	Racks		= { ["1xRK"] = true, ["2xRK"] = true },
	SeekCone	= 40,
	ViewCone	= 60,
	Agility		= 1,
	ArmDelay	= 1,
	Round = {
		Model			= "models/bombs/fab250.mdl",
		MaxLength		= 250,
		Armor			= 25,
		PropMass		= 0,
		Thrust			= 1, -- in kg*in/s^2
		BurnRate		= 1, -- in cm^3/s
		StarterPercent	= 0.005,
		MinSpeed		= 1,
		DragCoef		= 0.002,
		FinMul			= 0.005,
		PenMul			= math.sqrt(0.6)
	},
})

ACF.RegisterMissile("500kgBOMB", "BOMB", {
	Name		= "500kg Free Falling Bomb",
	Description	= "A 1000lb bomb, as found in the heavy bombers of late WW2. Best used against fortifications or immobile targets.",
	Model		= "models/bombs/fab500.mdl",
	Rack		= "1xRK",
	Length		= 15000,
	Caliber		= 300,
	Mass		= 500,
	Year		= 1943,
	Diameter	= 16.3 * 1.9, -- in cm
	Guidance	= { "Dumb" },
	Fuzes		= { "Contact", "Optical", "Cluster" },
	Racks		= { ["1xRK"] = true, ["2xRK"] = true },
	SeekCone	= 40,
	ViewCone	= 60,
	Agility		= 1,
	ArmDelay	= 2,
	Round = {
		Model			= "models/bombs/fab500.mdl",
		MaxLength		= 200,
		Armor			= 25,
		PropMass		= 0,
		Thrust			= 1, -- in kg*in/s^2
		BurnRate		= 1, -- in cm^3/s
		StarterPercent	= 0.005,
		MinSpeed		= 1,
		DragCoef		= 0.002,
		FinMul			= 0.004,
		PenMul			= math.sqrt(0.6)
	},
})

ACF.RegisterMissile("1000kgBOMB", "BOMB", {
	Name		= "1000kg Free Falling Bomb",
	Description	= "A 2000lb bomb. As close to a nuke as you can get in ACF, this munition will turn everything it touches to ashes. Handle with care.",
	Model		= "models/bombs/an_m66.mdl",
	Rack		= "1xRK",
	Length		= 30000,
	Caliber		= 300,
	Mass		= 1000,
	Year		= 1945,
	Diameter	= 16.3 * 4.5, -- in cm
	Guidance	= { "Dumb" },
	Fuzes		= { "Contact", "Optical", "Cluster" },
	Racks		= { ["1xRK"] = true },
	SeekCone	= 40,
	ViewCone	= 60,
	Agility		= 1,
	ArmDelay	= 3,
	Round = {
		Model			= "models/bombs/an_m66.mdl",
		MaxLength		= 375,
		Armor			= 25,
		PropMass		= 0,
		Thrust			= 1, -- in kg*in/s^2
		BurnRate		= 1, -- in cm^3/s
		StarterPercent	= 0.005,
		MinSpeed		= 1,
		DragCoef		= 0.002,
		FinMul			= 0.004,
		PenMul			= math.sqrt(0.6)
	},
})
