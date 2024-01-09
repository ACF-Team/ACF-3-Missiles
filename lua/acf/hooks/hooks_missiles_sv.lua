local Hooks = ACF.Utilities.Hooks


Hooks.Add("ACF_Missiles_Server", function(Gamemode)
	--- Called after a missile is fired.
	-- @param Missile The missile entity that was launched.
	function Gamemode:ACF_OnMissileLaunched()
	end
end)
