
ACF.RegisterMissileClass("SAM", {
	Name		= "Surface-To-Air Missiles",
	Description	= "Missiles specialized for surface-to-air operation, and well suited to lower altitude operation against ground attack aircraft.",
	Sound		= "acf_missiles/missiles/missile_rocket.mp3",
	Effect		= "Rocket Motor",
	Spread		= 1,
	Blacklist	= { "AP", "APHE", "HEAT", "HP", "FL", "SM" }
})

ACF.RegisterMissile("FIM-92 SAM", "SAM", {
	Name		= "FIM-92 Stinger",
	Description	= "The FIM-92 Stinger is a lightweight and versatile close-range air defense missile.",
	Model		= "models/missiles/fim_92.mdl",
	Length		= 152,
	Caliber		= 70,
	Mass		= 10,
	Year		= 1978,
	ReloadTime	= 10,
	Racks		= { ["1x FIM-92"] = true, ["2x FIM-92"] = true, ["4x FIM-92"] = true },
	Guidance	= { Dumb = true, Infrared = true, ["Anti-missile"] = true },
	Fuzes		= { Contact = true, Radio = true },
	SeekCone	= 7.5,
	ViewCone	= 30,
	Agility		= 3,
	ArmDelay	= 0.2,
	Round = {
		Model			= "models/missiles/fim_92.mdl",
		RackModel		= "models/missiles/fim_92_folded.mdl",
		MaxLength		= 152,
		Armor			= 5,
		PropMass		= 4,
		Thrust			= 100000,	-- in kg*in/s^2
		FuelConsumption = 0.03,		-- in g/s/f
		StarterPercent	= 0.1,
		MinSpeed		= 3000,
		DragCoef		= 0.003,
		FinMul			= 0.03,
		ControlSurfMul  = 1e-9,
		TailFinMul		= 0.001,
		ActualLength 	= 152,
		ActualWidth		= 7
	},
})

ACF.RegisterMissile("Strela-1 SAM", "SAM", {
	Name		= "9M31 Strela-1",
	Description	= "The 9M31 Strela-1 (SA-9 Gaskin) is a medium-range homing SAM, best suited to ground vehicles or stationary units.",
	Model		= "models/missiles/9m31.mdl",
	Length		= 180,
	Caliber		= 120,
	Mass		= 30,
	Year		= 1960,
	ReloadTime	= 25,
	Racks		= { ["1x Strela-1"] = true, ["2x Strela-1"] = true, ["4x Strela-1"] = true },
	Guidance	= { Dumb = true, Infrared = true, ["Anti-missile"] = true },
	Fuzes		= { Contact = true, Radio = true },
	SeekCone	= 20,
	ViewCone	= 40,
	Agility		= 2,
	ArmDelay	= 0.2,
	Round = {
		Model			= "models/missiles/9m31.mdl",
		RackModel		= "models/missiles/9m31f.mdl",
		MaxLength		= 180,
		Armor			= 5,
		PropMass		= 13,
		Thrust			= 500000,	-- in kg*in/s^2
		FuelConsumption = 0.033,	-- in g/s/f
		StarterPercent	= 0.1,
		MinSpeed		= 3000,
		DragCoef		= 0.003,
		FinMul			= 0.04,
		ControlSurfMul  = 1e-9,
		TailFinMul		= 0.001,
		ActualLength 	= 180,
		ActualWidth		= 12
	},
})
