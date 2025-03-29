local Missiles = ACF.Classes.Missiles

Missiles.Register("KEM", {
	Name		= "Kinetic Energy Missiles",
	Description	= "Missiles specialized in utilizing their kinetic energy to penetrate armor.",
	Sound		= "acf_missiles/missiles/missile_rocket.mp3",
	Effect		= "Rocket Motor ATGM",
	Spread		= 1,
	Blacklist	= {"AP", "APHE", "FL", "HE", "HEAT", "SM"}
})

Missiles.RegisterItem("MGM-166 KEM", "KEM", {
	Name		= "MGM-166 LOSAT",
	Description	= "The MGM-166 was designed to be mounted on to light vehicles allowing them to defeat enemy tanks and other targets.",
	Model		= "models/acf/missiles/losat.mdl",
	Length		= 2.85,
	Caliber		= 162,
	Mass		= 80,
	Diameter	= 16.2 * ACF.InchToMm,
	Year		= 1990,
	ReloadTime	= 30,
	ExhaustPos  = Vector(-20),
	Racks		= {["1x LOSAT"] = true, ["2x LOSAT"] = true, ["6x LOSAT"] = true},
	Navigation  = "APN",
	Guidance	= { Dumb = true, ["Radio (SACLOS)"] = true},
	Fuzes		= { Contact = true },
	Agility		= 0.25,
	ArmDelay	= 0,
	Round = {
		Model           = "models/acf/missiles/losat.mdl",
		MaxLength       = 285,
		Armor           = 2,
		ProjLength      = 45,
		PropLength      = 80,
		Thrust          = 1500000, -- in kg*in/s^2
		FuelConsumption = 0.0175, -- in g/s/f
		StarterPercent  = 0.295,
		MaxAgilitySpeed = 400, -- in m/s
		DragCoef        = 0.0025,
		FinMul          = 0.04,
		GLimit          = 25,
		TailFinMul      = 0.4,
		CanDelayLaunch  = true,
		ActualLength    = 280,
		ActualWidth     = 15
	},
	Preview = {
		FOV = 50,
	},
})
