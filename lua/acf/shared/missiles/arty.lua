
ACF.RegisterMissileClass("ARTY", {
	Name		= "Artillery Rockets",
	Description	= "Artillery rockets provide massive HE delivery over a broad area, with arcing ballistic trajectories and limited guidance.",
	Sound		= "acf_missiles/missiles/missile_rocket.mp3",
	Effect		= "Rocket Motor",
	Spread		= 1,
	Blacklist	= { "AP", "APHE", "HP", "FL", "SM" }
})

ACF.RegisterMissile("Type 63 RA", "ARTY", {
	Name		= "Type 63 Rocket",
	Description	= "A common artillery rocket in the third world, able to be launched from a variety of platforms with a painful whallop and a very arced trajectory.",
	Model		= "models/missiles/glatgm/mgm51.mdl",
	Caliber		= 107,
	Mass		= 19,
	Length		= 80,
	Diameter	= 6.5 * 25.4, -- in mm
	Year		= 1960,
	ReloadTime	= 10,
	Racks		= { ["1xRK_small"] = true, ["1xRK"] = true, ["2xRK"] = true, ["4xRK"] = true, ["6xUARRK"] = true },
	Guidance	= { Dumb = true, Laser = true, ["GPS Guided"] = true },
	Fuzes		= { Contact = true, Timed = true, Optical = true, Cluster = true },
	ViewCone	= 180,
	Agility		= 0.08,
	ArmDelay	= 0.2,
	Round = {
		Model			= "models/missiles/glatgm/mgm51.mdl",
		MaxLength		= 80,
		Armor			= 5,
		PropLength		= 45,
		Thrust			= 240000,	-- in kg*in/s^2
		FuelConsumption = 0.06, 	-- in g/s/f
		StarterPercent	= 0.05,
		MinSpeed		= 200,
		DragCoef		= 0.005,
		FinMul			= 0,
		TailFinMul		= 2,
		PenMul			= math.sqrt(2),
		ActualLength 	= 80,
		ActualWidth		= 10.7
	},
	Preview = {
		Height = 100,
		FOV    = 60,
	},
})

ACF.RegisterMissile("SAKR-10 RA", "ARTY", {
	Name		= "SAKR-10 Rocket",
	Description	= "A short-range but formidable artillery rocket, based upon the Grad. Well suited to the backs of trucks.",
	Model		= "models/missiles/9m31.mdl",
	Caliber		= 122,
	Mass		= 56,
	Length		= 287,
	Diameter	= 4.6 * 25.4, -- in mm
	Year		= 1980,
	ReloadTime	= 20,
	Racks		= { ["1xRK"] = true, ["2xRK"] = true, ["4xRK"] = true, ["6xUARRK"] = true },
	Guidance	= { Dumb = true, Laser = true, ["GPS Guided"] = true },
	Fuzes		= { Contact = true, Timed = true, Optical = true, Cluster = true },
	Agility		= 0.07,
	ViewCone	= 180,
	ArmDelay	= 0.4,
	Round = {
		Model		= "models/missiles/9m31.mdl",
		MaxLength		= 287,
		Armor			= 5,
		PropLength		= 160,
		Thrust			= 800000, -- in kg*in/s^2
		FuelConsumption = 0.012,	-- in g/s/f
		StarterPercent	= 0.05,
		MinSpeed		= 300,
		DragCoef		= 0.02,
		FinMul			= 0.06,
		TailFinMul		= 2,
		PenMul			= math.sqrt(0.5),
		ActualLength 	= 287,
		ActualWidth		= 12.2
	},
	Preview = {
		Height = 60,
		FOV    = 60,
	},
})

ACF.RegisterMissile("SS-40 RA", "ARTY", {
	Name		= "SS-40 Rocket",
	Description	= "A large, heavy, guided artillery rocket for taking out stationary or dug-in targets. Slow to load, slow to fire, slow to guide, and slow to arrive.",
	Model		= "models/missiles/aim120.mdl",
	Caliber		= 180,
	Mass		= 152,
	Length		= 370,
	Diameter	= 6.75 * 25.4, -- in mm
	Year		= 1983,
	ReloadTime	= 30,
	Racks		= { ["1xRK"] = true, ["2xRK"] = true, ["4xRK"] = true, ["6xUARRK"] = true },
	Guidance	= { Dumb = true, Laser = true, ["GPS Guided"] = true },
	Fuzes		= { Contact = true, Timed = true, Optical = true, Cluster = true },
	Agility		= 0.04,
	ViewCone	= 180,
	ArmDelay	= 0.6,
	Round = {
		Model		= "models/missiles/aim120.mdl",
		MaxLength		= 370,
		Armor			= 5,
		PropLength		= 200,
		Thrust			= 2400000, -- in kg*in/s^2
		FuelConsumption = 0.022,	-- in g/s/f
		StarterPercent	= 0.05,
		MinSpeed		= 300,
		DragCoef		= 0.02,
		FinMul			= 0.12,
		TailFinMul		= 10,
		PenMul			= math.sqrt(0.5),
		ActualLength 	= 370,
		ActualWidth		= 18
	},
	Preview = {
		Height = 80,
		FOV    = 60,
	},
})
