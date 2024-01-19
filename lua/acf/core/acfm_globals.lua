local ACF = ACF

ACF.LaserSources   = ACF.LaserSources or {}
ACF.ActiveLasers   = ACF.ActiveLasers or {}
ACF.ActiveMissiles = ACF.ActiveMissiles or {}
ACF.ActiveRadars   = ACF.ActiveRadars or {}

ACF.FlareBurnMultiplier     = 0.025
ACF.FlareDistractMultiplier = 1 / 35
ACF.MaxDamageInaccuracy     = 1000
ACF.DefaultRadarSound       = "buttons/button16.wav"

game.AddParticles("particles/flares_fx.pcf")

PrecacheParticleSystem("ACFM_Flare")

do -- Update checker
	hook.Add("ACF_OnLoadAddon", "ACF Missiles Checker", function()
		ACF.AddRepository("ACF-Team", "ACF-3-Missiles", "lua/acf/core/acfm_globals.lua")

		hook.Remove("ACF_OnLoadAddon", "ACF Missiles Checker")
	end)
end