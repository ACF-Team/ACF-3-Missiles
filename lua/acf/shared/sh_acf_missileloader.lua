
function ACF_DefineRack(ID)
	print("Attempted to register rack " .. ID .. " with a discontinued function. Use ACF.RegisterRack instead.")
end

function ACF_DefineRackClass(ID)
	print("Attempted to register rack class " .. ID .. " with a discontinued function. Racks are no longer separated in classes.")
end

function ACF_DefineRadar(ID)
	print("Attempted to register radar " .. ID .. " with a discontinued function. Use ACF.RegisterSensor instead.")
end

function ACF_DefineRadarClass(ID)
	print("Attempted to register radar class " .. ID .. " with a discontinued function. Use ACF.RegisterSensorClass instead.")
end

game.AddParticles("particles/flares_fx.pcf")
PrecacheParticleSystem("ACFM_Flare")

-- Adding the ACF Missiles repository to the update checker
ACF.AddRepository("TwistedTail", "ACF-3-Missiles", "lua/acf/server/sv_acf_missiles.lua")
