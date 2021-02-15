
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
		MaxLength		= 50,
		Armor			= 5,
		PropMass		= 0.7,
		Thrust			= 2400, -- in kg*in/s^2
		FuelConsumption = 0.16, -- in g/s/f
		StarterPercent	= 0.05,
		MinSpeed		= 200,
		DragCoef		= 0.002,
		DragCoefFlight	= 0.001,
		FinMul			= 0,
		TailFinMul		= 2,
		PenMul			= math.sqrt(2),
		ActualLength 	= 50,
		ActualWidth		= 7.2
	},
})

ACF.RegisterMissile("SAKR-10 RA", "ARTY", {
	Name		= "SAKR-10 Rocket",
	Description	= "A short-range but formidable artillery rocket, based upon the Grad. Well suited to the backs of trucks.",
	Model		= "models/missiles/9m31.mdl",
	Caliber		= 122,
	Mass		= 56,
	Length		= 320,
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
		MaxLength		= 140,
		Armor			= 5,
		PropMass		= 1.2,
		Thrust			= 1300, -- in kg*in/s^2
		FuelConsumption = 0.1,	-- in g/s/f
		StarterPercent	= 0.05,
		MinSpeed		= 300,
		DragCoef		= 0.002,
		DragCoefFlight	= 0.010,
		FinMul			= 1,
		TailFinMul		= 3,
		PenMul			= math.sqrt(1.1),
		ActualLength 	= 86.5,
		ActualWidth		= 5.5
	},
})

ACF.RegisterMissile("SS-40 RA", "ARTY", {
	Name		= "SS-40 Rocket",
	Description	= "A large, heavy, guided artillery rocket for taking out stationary or dug-in targets. Slow to load, slow to fire, slow to guide, and slow to arrive.",
	Model		= "models/missiles/aim120.mdl",
	Caliber		= 180,
	Mass		= 152,
	Length		= 420,
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
		MaxLength		= 115,
		Armor			= 5,
		PropMass		= 4.0,
		Thrust			= 1850,	-- in kg*in/s^2
		FuelConsumption = 0.4,	-- in g/s/f
		StarterPercent	= 0.05,
		MinSpeed		= 300,
		DragCoef		= 0.002,
		DragCoefFlight	= 0.009,
		FinMul			= 1.2,
		TailFinMul		= 5,
		PenMul			= math.sqrt(2),
		ActualLength 	= 151.5,
		ActualWidth		= 7.1
	},
})
