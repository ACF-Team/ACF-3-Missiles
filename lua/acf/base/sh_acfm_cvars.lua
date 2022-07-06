
if CLIENT then

	-- Should missiles emit light while their motors are burning?  Looks nice but hits framerate.
	-- Set to 1 to enable, set to 0 to disable, set to another number to set minimum light-size.
	CreateClientConVar("ACFM_MissileLights", 0)

	CreateClientConVar("ACF_GunInfoWhileSeated", 0)

elseif SERVER then

	-- Should flares light players and NPCs on fire?  Does not affect godded players.
	-- Set to 1 to enable, set to 0 to disable.
	CreateConVar("ACFM_FlaresIgnite", 1, FCVAR_ARCHIVE + FCVAR_NOTIFY)

	-- Should missiles ignore impacts for a duration after they're launched?
	-- Set to 0 to disable, or set to a number of seconds that missiles should "ghost" through entities.
	CreateConVar("ACFM_GhostPeriod", 0.05, FCVAR_ARCHIVE + FCVAR_NOTIFY)

	CreateConVar("sbox_max_acf_explosive", 20, FCVAR_ARCHIVE + FCVAR_NOTIFY)
end
