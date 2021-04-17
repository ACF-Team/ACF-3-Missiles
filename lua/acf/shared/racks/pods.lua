ACF.RegisterRack("40mm7xPOD", {
	Name		= "7x 40mm FFAR Pod",
	Description	= "A lightweight pod for small rockets which is vulnerable to shots and explosions.",
	Model		= "models/missiles/launcher7_40mm.mdl",
	EntType		= "Pod",
	Caliber		= 40,
	Mass		= 10,
	Year		= 1940,
	MagSize		= 7,
	Armor		= 5,

	ProtectMissile = true,

	MountPoints = {
		{ Name = "missile1", Position = Vector() },
		{ Name = "missile2", Position = Vector(0, -2, 0) },
		{ Name = "missile3", Position = Vector(0, -1, -1.73) },
		{ Name = "missile4", Position = Vector(0, 1, -1.73) },
		{ Name = "missile5", Position = Vector(0, 2, 0) },
		{ Name = "missile6", Position = Vector(0, 1, 1.74) },
		{ Name = "missile7", Position = Vector(0, -1, 1.74) }
	}
})

ACF.RegisterRack("57mm16xPOD", {
	Name		= "16x 57mm FFAR Pod",
	Description	= "A lightweight pod for small rockets which is vulnerable to shots and explosions.",
	Model		= "models/failz/ub_16.mdl",
	EntType		= "Pod",
	Caliber		= 57,
	Mass		= 30,
	Year		= 1956,
	MagSize		= 16,
	Armor		= 5,

	ProtectMissile = true,

	MountPoints = {
	
		{ Name = "missile1", Position = Vector(3.5,3.1179842073128,0.71984337390037) },
		{ Name = "missile2", Position = Vector(3.5,1.6481218397122,-2.7429353622468) },
		{ Name = "missile3", Position = Vector(3.5,-2.0993888927696,-2.4150706567129) },
		{ Name = "missile4", Position = Vector(3.5,-2.9456155310478,1.2503396111657) },
		{ Name = "missile5", Position = Vector(3.5,0.27889837679251,3.1878230338936) },
		{ Name = "missile6", Position = Vector(3.5,-2.8625729438519,-4.6963471061163) },
		{ Name = "missile7", Position = Vector(3.5,-4.9471865405083,-2.4031948180315) },
		{ Name = "missile8", Position = Vector(3.5,-5.4611033657031,0.65295484461518) },
		{ Name = "missile9", Position = Vector(3.5,-4.2411584585996,3.501795957655) },
		{ Name = "missile10", Position = Vector(3.5,-1.6746757074845,5.2388415966472) },
		{ Name = "missile11", Position = Vector(3.5,1.4235047480639,5.3125920445899) },
		{ Name = "missile12", Position = Vector(3.5,4.0697325041059,3.6996320553569) },
		{ Name = "missile13", Position = Vector(3.5,5.42384894545,0.91206502889906) },
		{ Name = "missile14", Position = Vector(3.5,5.0559316696992,-2.1650761998907) },
		{ Name = "missile15", Position = Vector(3.5,3.0827918123249,-4.5548210329125) },
		{ Name = "missile16", Position = Vector(3.5,0.13088733650359,-5.4984423708122) },

	}
})

ACF.RegisterRack("57mm32xPOD", {
	Name		= "32x 57mm FFAR Pod",
	Description	= "A lightweight pod for small rockets which is vulnerable to shots and explosions.",
	Model		= "models/failz/ub_32.mdl",
	EntType		= "Pod",
	Caliber		= 57,
	Mass		= 130,
	Year		= 1956,
	MagSize		= 32,
	Armor		= 5,

	ProtectMissile = true,

	MountPoints = {

		{ Name = "missile1", Position = Vector(-8,0,3.5) },
		{ Name = "missile2", Position = Vector(-8,3.3286979198456,1.0815595388412) },
		{ Name = "missile3", Position = Vector(-8,2.0572483539581,-2.831559419632) },
		{ Name = "missile4", Position = Vector(-8,-2.0572483539581,-2.831559419632) },
		{ Name = "missile5", Position = Vector(-8,-3.3286979198456,1.0815595388412) },
		{ Name = "missile6", Position = Vector(-8,3.5,6.0621776580811) },
		{ Name = "missile7", Position = Vector(-8,6.0621776580811,3.5) },
		{ Name = "missile8", Position = Vector(-8,7,4.2862638516992e-16) },
		{ Name = "missile9", Position = Vector(-8,6.0621776580811,-3.5) },
		{ Name = "missile10", Position = Vector(-8,3.5,-6.0621776580811) },
		{ Name = "missile11", Position = Vector(-8,8.5725277033984e-16,-7) },
		{ Name = "missile12", Position = Vector(-8,-3.5,-6.0621776580811) },
		{ Name = "missile13", Position = Vector(-8,-6.0621776580811,-3.5) },
		{ Name = "missile14", Position = Vector(-8,-7,-1.28587912904e-15) },
		{ Name = "missile15", Position = Vector(-8,-6.0621776580811,3.5) },
		{ Name = "missile16", Position = Vector(-8,-3.5,6.0621776580811) },
		{ Name = "missile17", Position = Vector(-8,5.5,9.5262794494629) },
		{ Name = "missile18", Position = Vector(-8,8.4264888763428,7.0706639289856) },
		{ Name = "missile19", Position = Vector(-8,10.336618423462,3.7622215747833) },
		{ Name = "missile20", Position = Vector(-8,11,3.3677786460859e-15) },
		{ Name = "missile21", Position = Vector(-8,10.336618423462,-3.7622215747833) },
		{ Name = "missile22", Position = Vector(-8,8.4264888763428,-7.0706639289856) },
		{ Name = "missile23", Position = Vector(-8,5.5,-9.5262794494629) },
		{ Name = "missile24", Position = Vector(-8,1.910129904747,-10.832885742188) },
		{ Name = "missile25", Position = Vector(-8,-1.910129904747,-10.832885742188) },
		{ Name = "missile26", Position = Vector(-8,-5.5,-9.5262794494629) },
		{ Name = "missile27", Position = Vector(-8,-8.4264888763428,-7.0706639289856) },
		{ Name = "missile28", Position = Vector(-8,-10.336618423462,-3.7622215747833) },
		{ Name = "missile29", Position = Vector(-8,-11,-4.7148903162784e-15) },
		{ Name = "missile30", Position = Vector(-8,-10.336618423462,3.7622215747833) },
		{ Name = "missile31", Position = Vector(-8,-8.4264888763428,7.0706639289856) },
		{ Name = "missile32", Position = Vector(-8,-5.5,9.5262794494629) },

	}
})

ACF.RegisterRack("70mm7xPOD", {
	Name		= "7x 70mm FFAR Pod",
	Description	= "A lightweight pod for rockets which is vulnerable to shots and explosions.",
	Model		= "models/missiles/launcher7_70mm.mdl",
	EntType		= "Pod",
	Caliber		= 70,
	Mass		= 30,
	Year		= 1940,
	MagSize		= 7,
	Armor		= 5,

	ProtectMissile = true,

	MountPoints = {
		{ Name = "missile1", Position = Vector() },
		{ Name = "missile2", Position = Vector(0, -3.5, 0) },
		{ Name = "missile3", Position = Vector(0, -1.75, -3.03) },
		{ Name = "missile4", Position = Vector(0, 1.75, -3.03) },
		{ Name = "missile5", Position = Vector(0, 3.5, 0) },
		{ Name = "missile6", Position = Vector(0, 1.75, 3.04) },
		{ Name = "missile7", Position = Vector(0, -1.75, 3.04) }
	}
})

ACF.RegisterRack("70mm19xPOD", {
	Name		= "19x 70mm FFAR Pod",
	Description	= "A lightweight pod for rockets which is vulnerable to shots and explosions.",
	Model		= "models/failz/lau_61.mdl",
	EntType		= "Pod",
	Caliber		= 70,
	Mass		= 90,
	Year		= 1960,
	MagSize		= 19,
	Armor		= 5,

	ProtectMissile = true,

	MountPoints = {
		{ Name = "missile1", Position = Vector(5,-4.2,7.2) },
		{ Name = "missile2", Position = Vector(5,0,7.2) },
		{ Name = "missile3", Position = Vector(5,4.2,7.2) },
		{ Name = "missile4", Position = Vector(5,-6.3,3.6) },
		{ Name = "missile5", Position = Vector(5,-1.9,3.6) },
		{ Name = "missile6", Position = Vector(5,1.9,3.6) },
		{ Name = "missile7", Position = Vector(5,6.3,3.6) },
		{ Name = "missile8", Position = Vector(5,-8.4,0) },
		{ Name = "missile9", Position = Vector(5,-4.2,0) },
		{ Name = "missile10", Position = Vector(5,0,0) },
		{ Name = "missile11", Position = Vector(5,4.2,0) },
		{ Name = "missile12", Position = Vector(5,8.4,0) },
		{ Name = "missile13", Position = Vector(5,-6.3,-3.6) }, 
		{ Name = "missile14", Position = Vector(5,-1.9,-3.6) },
		{ Name = "missile15", Position = Vector(5,1.9,-3.6) },
		{ Name = "missile16", Position = Vector(5,6.3,-3.6) },
		{ Name = "missile17", Position = Vector(5,-4.2,-7.2) },
		{ Name = "missile18", Position = Vector(5,0,-7.2) },
		{ Name = "missile19", Position = Vector(5,4.2,-7.2) },
	}
})

ACF.RegisterRack("80mm20xPOD", {
	Name		= "20x 80mm FFAR Pod",
	Description	= "A lightweight pod for rockets which is vulnerable to shots and explosions.",
	Model		= "models/failz/b8.mdl",
	EntType		= "Pod",
	Caliber		= 80,
	Mass		= 120,
	Year		= 1970,
	MagSize		= 20,
	Armor		= 5,

	ProtectMissile = true,

	MountPoints = {
		{ Name = "missile1", Position = Vector(4,2.5386675750302,5.0463922137019) },
		{ Name = "missile2", Position = Vector(4,5.2927365341992,1.2773805680876) },
		{ Name = "missile3", Position = Vector(4,3.5463922137019,-3.9386675750302) },
		{ Name = "missile4", Position = Vector(4,-0.2773805680876,-5.2927365341992) },
		{ Name = "missile5", Position = Vector(4,-3.9386675750302,-3.5463922137019) },
		{ Name = "missile6", Position = Vector(4,-5.2927365341992,1.2773805680876) },
		{ Name = "missile7", Position = Vector(4,-2.5463922137019,5.0486675750302) },
		{ Name = "missile8", Position = Vector(4,4.5557792607344,9.4601731129754) },
		{ Name = "missile9", Position = Vector(4,8.2092305659143,6.5466429195167) },
		{ Name = "missile10", Position = Vector(4,10.236743077909,2.3364698065413) },
		{ Name = "missile11", Position = Vector(4,10.236743077909,-2.3364698065413) },
		{ Name = "missile12", Position = Vector(4,8.2092305659143,-6.5466429195167) },
		{ Name = "missile13", Position = Vector(4,4.5557792607344,-9.4601731129754) },
		{ Name = "missile14", Position = Vector(4,3.8576374173142e-15,-10.5) },
		{ Name = "missile15", Position = Vector(4,-4.5557792607344,-9.4601731129754) },
		{ Name = "missile16", Position = Vector(4,-8.2092305659143,-6.5466429195167) },
		{ Name = "missile17", Position = Vector(4,-10.236743077909,-2.3364698065413) },
		{ Name = "missile18", Position = Vector(4,-10.236743077909,2.3364698065413) },
		{ Name = "missile19", Position = Vector(4,-8.2092305659143,6.5466429195167) },
		{ Name = "missile20", Position = Vector(4,-4.5557792607344,9.4601731129754) },

	}
})

ACF.RegisterRack("1x BGM-71E", {
	Name		= "TOW Launch Tube",
	Description	= "A single BGM-71E round.",
	Model		= "models/missiles/bgm_71e_round.mdl",
	EntType		= "Pod",
	Caliber		= 152,
	Mass		= 11,
	Year		= 1970,
	MagSize		= 1,
	Armor		= 2.5,

	ProtectMissile = true,
	HideMissile = true,

	MountPoints = {
		{ Name = "missile1", Position = Vector(15.76, 0, 0) }
	}
})

ACF.RegisterRack("2x BGM-71E", {
	Name		= "Dual TOW Launch Tube",
	Description	= "A BGM-71E rack designed to carry 2 rounds.",
	Model		= "models/missiles/bgm_71e_2xrk.mdl",
	EntType		= "Pod",
	Caliber		= 152,
	Mass		= 32,
	Year		= 1970,
	MagSize		= 2,
	Armor		= 2.5,

	ProtectMissile = true,
	HideMissile = true,

	MountPoints = {
		{ Name = "missile1", Position = Vector(23.64, 4.73, 0) },
		{ Name = "missile2", Position = Vector(23.64, -4.73, 0) }
	}
})

ACF.RegisterRack("4x BGM-71E", {
	Name		= "Quad TOW Launch Tube",
	Description	= "A BGM-71E rack designed to carry 4 rounds.",
	Model		= "models/missiles/bgm_71e_4xrk.mdl",
	EntType		= "Pod",
	Caliber		= 152,
	Mass		= 65,
	Year		= 1970,
	MagSize		= 4,
	Armor		= 2.5,

	ProtectMissile = true,
	HideMissile = true,

	MountPoints = {
		{ Name = "missile1", Position = Vector(23.64, 4.73, 0) },
		{ Name = "missile2", Position = Vector(23.64, -4.73, 0) },
		{ Name = "missile3", Position = Vector(23.64, 4.73, -11.43) },
		{ Name = "missile4", Position = Vector(23.64, -4.73, -11.43) }
	}
})

ACF.RegisterRack("380mmRW61", {
	Name		= "380mm Rocket Mortar",
	Description	= "A lightweight pod for rocket-asisted mortars which is vulnerable to shots and explosions.",
	Model		= "models/launcher/rw61.mdl",
	EntType		= "Pod",
	Caliber		= 380,
	Mass		= 429,
	Year		= 1945,
	MagSize		= 1,
	Armor		= 25,

	ProtectMissile = true,

	MountPoints = {
		{ Name = "missile1", Position = Vector(8.39, -0.01, 0) },
	}
})

ACF.RegisterRack("3xUARRK", {
	Name		= "Triple Launch Tube",
	Description	= "A lightweight rack for bombs which is vulnerable to shots and explosions.\nNice generic description bro.",
	Model		= "models/missiles/rk3uar.mdl",
	EntType		= "Pod",
	Mass		= 61,
	Year		= 1941,
	Armor		= 5,
	MagSize		= 3,

	ProtectMissile = true,

	MountPoints = {
		{ Name = "missile1", Position = Vector(-4.5, 0, 9.09) },
		{ Name = "missile2", Position = Vector(-4.5, 3.19, 3.48) },
		{ Name = "missile3", Position = Vector(-4.5, -3.21, 3.48) },
	}
})

ACF.RegisterRack("6xUARRK", {
	Name		= "6x Launch Tube",
	Description	= "6-pack of death, used to efficiently carry artillery rockets",
	Model		= "models/missiles/6pod_rk.mdl",
	RackModel	= "models/missiles/6pod_cover.mdl",
	EntType		= "Pod",
	Mass		= 213,
	Year		= 1980,
	Armor		= 5,
	MagSize		= 6,

	ProtectMissile = true,

	MountPoints = {
		{ Name = "missile1", Position = Vector(0.035, -11.26, 5.58) },
		{ Name = "missile2", Position = Vector(0.025, 0.03, 5.58) },
		{ Name = "missile3", Position = Vector(0.025, 11.18, 5.58) },
		{ Name = "missile4", Position = Vector(0.025, -11.26, -5.51) },
		{ Name = "missile5", Position = Vector(0.025, 0.03, -5.51) },
		{ Name = "missile6", Position = Vector(0.025, 11.18, -5.51) },
	}
})

ACF.RegisterRack("1x FIM-92", {
	Name		= "Stinger Launch Tube",
	Description	= "An FIM-92 rack designed to carry 1 missile.",
	Model		= "models/missiles/fim_92_1xrk.mdl",
	EntType		= "Pod",
	Caliber		= 70,
	Mass		= 11,
	Year		= 1984,
	MagSize		= 1,
	Armor		= 2.5,

	ProtectMissile = true,

	MountPoints = {
		{ Name = "missile1", Position = Vector() }
	}
})

ACF.RegisterRack("2x FIM-92", {
	Name		= "Dual Stinger Launch Tube",
	Description	= "An FIM-92 rack designed to carry 2 missiles.",
	Model		= "models/missiles/fim_92_2xrk.mdl",
	EntType		= "Pod",
	Caliber		= 70,
	Mass		= 16,
	Year		= 1984,
	MagSize		= 2,
	Armor		= 16,

	ProtectMissile = true,

	MountPoints = {
		{ Name = "missile1", Position = Vector(0, 3.35, 0.45) },
		{ Name = "missile2", Position = Vector(0, -3.35, 0.45) }
	}
})

ACF.RegisterRack("4x FIM-92", {
	Name		= "Quad Stinger Launch Tube",
	Description	= "An FIM-92 rack designed to carry 4 missiles.",
	Model		= "models/missiles/fim_92_4xrk.mdl",
	EntType		= "Pod",
	Caliber		= 70,
	Mass		= 42,
	Year		= 1984,
	MagSize		= 4,
	Armor		= 5,

	ProtectMissile = true,

	MountPoints = {
		{ Name = "missile1", Position = Vector(0, 2.6, 2.65) },
		{ Name = "missile2", Position = Vector(0, -2.6, 2.65) },
		{ Name = "missile3", Position = Vector(0, 2.6, -3.6) },
		{ Name = "missile4", Position = Vector(0, -2.6, -3.6) }
	}
})

ACF.RegisterRack("1x Strela-1", {
	Name		= "Strela Launch Tube",
	Description	= "An 9M31 rack designed to carry 1 missile.",
	Model		= "models/missiles/9m31_rk1.mdl",
	EntType		= "Pod",
	Caliber		= 120,
	Mass		= 75,
	Year		= 1968,
	MagSize		= 1,
	Armor		= 5,

	ProtectMissile = true,

	MountPoints = {
		{ Name = "missile1", Position = Vector(44.12, 2.65, 0.13) }
	}
})

ACF.RegisterRack("2x Strela-1", {
	Name		= "Dual Strela Launch Tube",
	Description	= "An 9M31 rack designed to carry 2 missiles.",
	Model		= "models/missiles/9m31_rk2.mdl",
	EntType		= "Pod",
	Caliber		= 120,
	Mass		= 177,
	Year		= 1968,
	MagSize		= 2,
	Armor		= 5,

	ProtectMissile = true,

	MountPoints = {
		{ Name = "missile1", Position = Vector(44.12, -5.59, 0.13) },
		{ Name = "missile2", Position = Vector(44.12, 10.97, 0.13) }
	}
})

ACF.RegisterRack("4x Strela-1", {
	Name		= "Quad Strela Launch Tube",
	Description	= "An 9m31 rack designed to carry 4 missiles.",
	Model		= "models/missiles/9m31_rk4.mdl",
	EntType		= "Pod",
	Caliber		= 120,
	Mass		= 482,
	Year		= 1968,
	MagSize		= 4,
	Armor		= 5,

	ProtectMissile = true,

	MountPoints = {
		{ Name = "missile1", Position = Vector(44.17, -42.66, 3.74) },
		{ Name = "missile2", Position = Vector(44.17, -26.1, 3.74) },
		{ Name = "missile3", Position = Vector(44.17, 25.98, 3.74) },
		{ Name = "missile4", Position = Vector(44.17, 42.54, 3.74) }
	}
})

ACF.RegisterRack("1x Ataka", {
	Name		= "Ataka Launch Tube",
	Description	= "An 9M120 rack designed to carry 1 missile.",
	Model		= "models/missiles/9m120_rk1.mdl",
	RackModel	= "models/missiles/9m120.mdl",
	EntType		= "Pod",
	Caliber		= 130,
	Mass		= 13,
	Year		= 1968,
	MagSize		= 1,
	Armor		= 2.5,

	ProtectMissile = true,
	HideMissile = true,

	MountPoints = {
		{ Name = "missile1", Position = Vector(0, 0, 3) }
	}
})

ACF.RegisterRack("1x SPG9", {
	Name		= "SPG-9 Launch Tube",
	Description	= "Launch tube for SPG-9 recoilless rocket.",
	Model		= "models/spg9/spg9.mdl",
	EntType		= "Pod",
	Caliber		= 73,
	Mass		= 26,
	Year		= 1968,
	MagSize		= 1,
	Armor		= 5,

	ProtectMissile = true,
	HideMissile = true,

	MountPoints = {
		{ Name = "missile1", Position = Vector() }
	}
})

ACF.RegisterRack("1x Kornet", {
	Name		= "Kornet Launch Tube",
	Description	= "Launch tube for Kornet antitank missile.",
	Model		= "models/kali/weapons/kornet/parts/9m133 kornet tube.mdl",
	EntType		= "Pod",
	Caliber		= 152,
	Mass		= 16,
	Year		= 1994,
	MagSize		= 1,
	Armor		= 2.5,

	ProtectMissile = true,
	HideMissile = true,

	MountPoints = {
		{ Name = "missile1", Position = Vector() }
	}
})

ACF.RegisterRack("127mm4xPOD", {
	Name		= "Quad Zuni Rocket Pod",
	Description	= "LAU-10/A Pod for the Zuni rocket.",
	Model		= "models/ghosteh/lau10.mdl",
	EntType		= "Pod",
	Caliber		= 127,
	Mass		= 68,
	Year		= 1957,
	MagSize		= 4,
	Armor		= 5,

	ProtectMissile = true,

	MountPoints = {
		{ Name = "missile1", Position = Vector(5.2, 2.75, 2.65) },
		{ Name = "missile2", Position = Vector(5.2, -2.75, 2.65) },
		{ Name = "missile3", Position = Vector(5.2, 2.75, -2.83) },
		{ Name = "missile4", Position = Vector(5.2, -2.75, -2.83) }
	}
})
