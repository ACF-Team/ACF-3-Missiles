
ACF.RegisterWeaponClass("FGL", {
	Name		  = "Flare Launcher",
	Description	  = "Flare Launchers can fire flares much more rapidly than other launchers, but can't load any other ammo types.",
	MuzzleFlash	  = "gl_muzzleflash_noscale",
	ROFMod		  = 0.6,
	Spread		  = 1.5,
	Sound		  = "acf_missiles/missiles/flare_launch.mp3",
	LimitConVar = {
		Name = "_acf_flarelauncher",
		Amount = 4,
		Text = "Maximum amount of ACF Flare Launchers a player can create."
	},
	Caliber	= {
		Min = 25,
		Max = 40,
	},
})

ACF.RegisterWeapon("40mmFGL", "FGL", {
	Name		= "40mm Flare Launcher",
	Description	= "Put on an all-American fireworks show with this flare launcher: high fire rate, low distraction rate. Fill the air with flare. Careful of your reload time.",
	Model		= "models/missiles/blackjellypod.mdl",
	Caliber		= 40,
	Mass		= 75,
	Year		= 1970,
	MagSize		= 30,
	MagReload	= 20,
	Cyclic		= 300,
	Round = {
		MaxLength = 9,
		PropMass  = 0.007,
	}
})