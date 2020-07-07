ACF.RegisterRack("40mm7xPOD", {
	Name		= "7x 40mm FFAR Pod",
	Description	= "A lightweight pod for small rockets which is vulnerable to shots and explosions.",
	Model		= "models/missiles/launcher7_40mm.mdl",
	Caliber		= 40,
	Mass		= 20,
	Year		= 1940,
	MagSize		= 7,
	Armor		= 15,

	ProtectMissile = true,
	WhitelistOnly = true,

	MountPoints = {
		missile1 = { Offset = Vector(), ScaleDir = Vector() },
		missile2 = { Offset = Vector(), ScaleDir = Vector() },
		missile3 = { Offset = Vector(), ScaleDir = Vector() },
		missile4 = { Offset = Vector(), ScaleDir = Vector() },
		missile5 = { Offset = Vector(), ScaleDir = Vector() },
		missile6 = { Offset = Vector(), ScaleDir = Vector() },
		missile7 = { Offset = Vector(), ScaleDir = Vector() }
	}
})

ACF.RegisterRack("70mm7xPOD", {
	Name		= "7x 70mm FFAR Pod",
	Description	= "A lightweight pod for rockets which is vulnerable to shots and explosions.",
	Model		= "models/missiles/launcher7_70mm.mdl",
	Caliber		= 70,
	Mass		= 40,
	Year		= 1940,
	MagSize		= 7,
	Armor		= 24,

	ProtectMissile = true,
	WhitelistOnly = true,

	MountPoints = {
		missile1 = { Offset = Vector(), ScaleDir = Vector() },
		missile2 = { Offset = Vector(), ScaleDir = Vector() },
		missile3 = { Offset = Vector(), ScaleDir = Vector() },
		missile4 = { Offset = Vector(), ScaleDir = Vector() },
		missile5 = { Offset = Vector(), ScaleDir = Vector() },
		missile6 = { Offset = Vector(), ScaleDir = Vector() },
		missile7 = { Offset = Vector(), ScaleDir = Vector() }
	}
})

ACF.RegisterRack("1x BGM-71E", {
	Name		= "TOW Launch Tube",
	Description	= "A single BGM-71E round.",
	Model		= "models/missiles/bgm_71e_round.mdl",
	Caliber		= 152,
	Mass		= 10,
	Year		= 1970,
	MagSize		= 1,
	Armor		= 18,

	WhitelistOnly = true,
	ProtectMissile = true,
	HideMissile = true,

	MountPoints = {
		missile1 = { Offset = Vector(), ScaleDir = Vector() }
	}
})

ACF.RegisterRack("2x BGM-71E", {
	Name		= "Dual TOW Launch Tube",
	Description	= "A BGM-71E rack designed to carry 2 rounds.",
	Model		= "models/missiles/bgm_71e_2xrk.mdl",
	Caliber		= 152,
	Mass		= 60,
	Year		= 1970,
	MagSize		= 2,
	Armor		= 18,

	WhitelistOnly = true,
	ProtectMissile = true,
	HideMissile = true,

	MountPoints = {
		missile1 = { Offset = Vector(), ScaleDir = Vector() },
		missile2 = { Offset = Vector(), ScaleDir = Vector() }
	}
})

ACF.RegisterRack("4x BGM-71E", {
	Name		= "Quad TOW Launch Tube",
	Description	= "A BGM-71E rack designed to carry 4 rounds.",
	Model		= "models/missiles/bgm_71e_4xrk.mdl",
	Caliber		= 152,
	Mass		= 100,
	Year		= 1970,
	MagSize		= 4,
	Armor		= 24,

	WhitelistOnly = true,
	ProtectMissile = true,
	HideMissile = true,

	MountPoints = {
		missile1 = { Offset = Vector(), ScaleDir = Vector() },
		missile2 = { Offset = Vector(), ScaleDir = Vector() },
		missile3 = { Offset = Vector(), ScaleDir = Vector() },
		missile4 = { Offset = Vector(), ScaleDir = Vector() }
	}
})

ACF.RegisterRack("380mmRW61", {
	Name		= "380mm Rocket Mortar",
	Description	= "A lightweight pod for rocket-asisted mortars which is vulnerable to shots and explosions.",
	Model		= "models/launcher/rw61.mdl",
	Caliber		= 380,
	Mass		= 600,
	Year		= 1945,
	MagSize		= 1,
	Armor		= 24,

	WhitelistOnly = true,
	ProtectMissile = true,

	MountPoints = {
		missile1 = { Offset = Vector(), ScaleDir = Vector() },
	}
})

ACF.RegisterRack("3xUARRK", {
	Name		= "Triple Launch Tube",
	Description	= "A lightweight rack for bombs which is vulnerable to shots and explosions.\nNice generic description bro.",
	Model		= "models/missiles/rk3uar.mdl",
	Mass		= 150,
	Year		= 1941,
	Armor		= 30,
	MagSize		= 3,

	ProtectMissile = true,
	WhitelistOnly = true,

	MountPoints = {
		missile1 = { Offset = Vector(), ScaleDir = Vector() },
		missile2 = { Offset = Vector(), ScaleDir = Vector() },
		missile3 = { Offset = Vector(), ScaleDir = Vector() },
	}
})

ACF.RegisterRack("6xUARRK", {
	Name		= "6x Launch Tube",
	Description	= "6-pack of death, used to efficiently carry artillery rockets",
	Model		= "models/missiles/6pod_rk.mdl",
	RackModel	= "models/missiles/6pod_cover.mdl",
	Mass		= 600,
	Year		= 1980,
	Armor		= 45,
	MagSize		= 6,

	ProtectMissile = true,
	WhitelistOnly = true,

	MountPoints = {
		missile1 = { Offset = Vector(3.075, -0.1, 0), ScaleDir = Vector() },
		missile2 = { Offset = Vector(3.075, -0.1, 0), ScaleDir = Vector() },
		missile3 = { Offset = Vector(3.075, -0.1, 0), ScaleDir = Vector() },
		missile4 = { Offset = Vector(3.075, -0.1, 0), ScaleDir = Vector() },
		missile5 = { Offset = Vector(3.075, -0.1, 0), ScaleDir = Vector() },
		missile6 = { Offset = Vector(3.075, -0.1, 0), ScaleDir = Vector() },
	}
})

ACF.RegisterRack("1x FIM-92", {
	Name		= "Stinger Launch Tube",
	Description	= "An FIM-92 rack designed to carry 1 missile.",
	Model		= "models/missiles/fim_92_1xrk.mdl",
	Caliber		= 70,
	Mass		= 10,
	Year		= 1984,
	MagSize		= 1,
	Armor		= 12,

	ProtectMissile = true,
	WhitelistOnly = true,

	MountPoints = {
		missile1 = { Offset = Vector(), ScaleDir = Vector() }
	}
})

ACF.RegisterRack("2x FIM-92", {
	Name		= "Double Stinger Launch Tube",
	Description	= "An FIM-92 rack designed to carry 2 missiles.",
	Model		= "models/missiles/fim_92_2xrk.mdl",
	Caliber		= 70,
	Mass		= 30,
	Year		= 1984,
	MagSize		= 2,
	Armor		= 16,
	RoFMod		= 3,

	ProtectMissile = true,
	WhitelistOnly = true,

	MountPoints = {
		missile1 = { Offset = Vector(), ScaleDir = Vector() },
		missile2 = { Offset = Vector(), ScaleDir = Vector() }
	}
})

ACF.RegisterRack("4x FIM-92", {
	Name		= "Quad Stinger Launch Tube",
	Description	= "An FIM-92 rack designed to carry 4 missile.",
	Model		= "models/missiles/fim_92_4xrk.mdl",
	Caliber		= 70,
	Mass		= 30,
	Year		= 1984,
	MagSize		= 4,
	Armor		= 20,

	ProtectMissile = true,
	WhitelistOnly = true,

	MountPoints = {
		missile1 = { Offset = Vector(), ScaleDir = Vector() },
		missile2 = { Offset = Vector(), ScaleDir = Vector() },
		missile3 = { Offset = Vector(), ScaleDir = Vector(0, 0, -1) },
		missile4 = { Offset = Vector(), ScaleDir = Vector(0, 0, -1) }
	}
})

ACF.RegisterRack("1x Strela-1", {
	Name		= "Strela Launch Tube",
	Description	= "An 9M31 rack designed to carry 1 missile.",
	Model		= "models/missiles/9m31_rk1.mdl",
	Caliber		= 120,
	Mass		= 10,
	Year		= 1968,
	MagSize		= 1,
	Armor		= 50,

	ProtectMissile = true,
	WhitelistOnly = true,

	MountPoints = {
		missile1 = { Offset = Vector(), ScaleDir = Vector() }
	}
})

ACF.RegisterRack("2x Strela-1", {
	Name		= "Double Strela Launch Tube",
	Description	= "An 9M31 rack designed to carry 1 missile.",
	Model		= "models/missiles/9m31_rk2.mdl",
	Caliber		= 120,
	Mass		= 30,
	Year		= 1968,
	MagSize		= 2,
	Armor		= 80,

	ProtectMissile = true,
	WhitelistOnly = true,

	MountPoints = {
		missile1 = { Offset = Vector(), ScaleDir = Vector() },
		missile2 = { Offset = Vector(), ScaleDir = Vector() }
	}
})

ACF.RegisterRack("4x Strela-1", {
	Name		= "Quad Strela Launch Tube",
	Description	= "An 9m31 rack designed to carry 4 missile.",
	Model		= "models/missiles/9m31_rk4.mdl",
	Caliber		= 120,
	Mass		= 50,
	Year		= 1968,
	MagSize		= 4,
	Armor		= 100,

	ProtectMissile = true,
	WhitelistOnly = true,

	MountPoints = {
		missile1 = { Offset = Vector(0.5, 0, 0), ScaleDir = Vector() },
		missile2 = { Offset = Vector(0.5, 0, 0), ScaleDir = Vector() },
		missile3 = { Offset = Vector(0.5, 0, 0), ScaleDir = Vector() },
		missile4 = { Offset = Vector(0.5, 0, 0), ScaleDir = Vector() }
	}
})

ACF.RegisterRack("1x Ataka", {
	Name		= "Ataka Launch Tube",
	Description	= "An 9M120 rack designed to carry 1 missile.",
	Model		= "models/missiles/9m120_rk1.mdl",
	Caliber		= 130,
	Mass		= 10,
	Year		= 1968,
	MagSize		= 1,
	Armor		= 50,

	ProtectMissile = true,
	HideMissile = true,
	WhitelistOnly = true,

	MountPoints = {
		missile1 = { Offset = Vector(), ScaleDir = Vector() }
	}
})

ACF.RegisterRack("1x SPG9", {
	Name		= "SPG-9 Launch Tube",
	Description	= "Launch tube for SPG-9 recoilless rocket.",
	Model		= "models/spg9/spg9.mdl",
	Caliber		= 73,
	Mass		= 90,
	Year		= 1968,
	MagSize		= 1,
	Armor		= 30,

	ProtectMissile = true,
	HideMissile = true,
	WhitelistOnly = true,

	MountPoints = {
		missile1 = { Offset = Vector(), ScaleDir = Vector() }
	}
})

ACF.RegisterRack("1x Kornet", {
	Name		= "Kornet Launch Tube",
	Description	= "Launch tube for Kornet antitank missile.",
	Model		= "models/kali/weapons/kornet/parts/9m133 kornet tube.mdl",
	Caliber		= 152,
	Mass		= 30,
	Year		= 1994,
	MagSize		= 1,
	Armor		= 20,

	ProtectMissile = true,
	WhitelistOnly = true,

	MountPoints = {
		missile1 = { Offset = Vector(), ScaleDir = Vector() }
	}
})

ACF.RegisterRack("127mm4xPOD", {
	Name		= "Quad Zuni Rocket Pod",
	Description	= "LAU-10/A Pod for the Zuni rocket.",
	Model		= "models/ghosteh/lau10.mdl",
	Caliber		= 127,
	Mass		= 100,
	Year		= 1957,
	MagSize		= 4,
	Armor		= 40,

	ProtectMissile = true,
	WhitelistOnly = true,

	MountPoints = {
		missile1 = { Offset = Vector(5.2, 2.75, 2.65), ScaleDir = Vector() },
		missile2 = { Offset = Vector(5.2, -2.75, 2.65), ScaleDir = Vector() },
		missile3 = { Offset = Vector(5.2, 2.75, -2.83), ScaleDir = Vector() },
		missile4 = { Offset = Vector(5.2, -2.75, -2.83), ScaleDir = Vector() }
	}
})
