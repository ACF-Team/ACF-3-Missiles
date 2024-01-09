local Hooks = ACF.Utilities.Hooks


Hooks.Add("ACF_Missiles_Server", function(Gamemode)
	--- Called after a missile is fired.
	-- @param Entity The missile entity that was launched.
	function Gamemode:ACF_OnMissileLaunched()
	end

	--- Called when a missile attempts to create an explosion.
	-- @param Entity The affected missile.
	-- @param Data The bullet data of the affected missile.
	-- @return True if the missile can explode, false otherwise.
	function Gamemode:ACF_MissileCanExplode()
		return true
	end

	--- Called when a missile plays its sound if the ACF Sound Extension Project by looterz is installed.
	-- This is a legacy hook from ACF-2 and may be removed at any time.
	-- @param Entity The missile entity to play sound on.
	-- @param Sound The sound to play.
	function Gamemode:ACF_SOUND_MISSILE()
	end
end)
