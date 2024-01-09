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
end)
