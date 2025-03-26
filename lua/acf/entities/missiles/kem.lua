local Missiles = ACF.Classes.Missiles

Missiles.Register("KEM", {
	Name		= "Kinetic Energy Missiles",
	Description	= "Missiles specialized on utilizing their kinetic energy to penerate armor.",
	Sound		= "acf_missiles/missiles/missile_rocket.mp3",
	Effect		= "Rocket Motor ATGM",
	Spread		= 1,
	Blacklist	= {"AP", "APHE", "FL", "HE", "HEAT", "SM"}
})

Missiles.RegisterItem("MGM-166 KEM", "KEM", {
	Name		= "MGM-166 LOSAT",
	Description	= "The MGM-166 was designed to be mounted on to light vehicles allowing them to defeat enemy tanks and other targets.",
	Model		= "models/novoscar/losat.mdl",
	Length		= 2.85,
	Caliber		= 162,
	Mass		= 80,
	Diameter	= 16.2 * ACF.InchToMm,
	Year		= 1990,
	ReloadTime	= 1,
	ExhaustPos  = Vector(-20),
	Racks		= {["1x LOSAT"] = true},
	Navigation  = "APN",
	Guidance	= { Dumb = true, ["Radio (SACLOS)"] = true},
	Fuzes		= { Contact = true },
	Agility		= 0.0005,
	ArmDelay	= 0,
	Round = {
		Model           = "models/novoscar/losat.mdl",
		MaxLength       = 285,
		Armor           = 2,
		ProjLength      = 35,
		PropLength      = 200,
		Thrust          = 99000, -- in kg*in/s^2
		FuelConsumption = 0.097, -- in g/s/f
		StarterPercent  = 0.15,
		MaxAgilitySpeed = 30, -- in m/s
		DragCoef        = 0.0025,
		FinMul          = 0.01,
		GLimit          = 12,
		TailFinMul      = 0.5,
		CanDelayLaunch  = true,
		ActualLength    = 280,
		ActualWidth     = 15
	},
	Preview = {
		FOV = 50,
	},
})
