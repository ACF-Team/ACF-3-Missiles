util.AddNetworkString("ACF_SetupLaserSource")
util.AddNetworkString("ACF_SyncLaserSources")

function ACF.SetupLaserSource(Entity, NetVar, Offset, Direction, Spread, Filter)
	if not IsValid(Entity) then return end

	Offset = Offset or Vector()
	Direction = Direction or Vector(1)
	Spread = Spread or ""

	ACF.AddLaserSource(Entity, NetVar, Offset, Direction, Spread, Filter)

	-- We have to wait for the entity to be created on the clientside
	timer.Simple(0.05, function()
		net.Start("ACF_SetupLaserSource")
			net.WriteEntity(Entity)
			net.WriteString(NetVar)
			net.WriteVector(Offset)
			net.WriteVector(Direction)
			net.WriteType(Filter)
		net.Broadcast()
	end)
end

hook.Add("PlayerInitialSpawn", "ACF Laser Setup", function(Player)
	timer.Simple(10, function()
		if not IsValid(Player) then return end

		net.Start("ACF_SyncLaserSources")
			net.WriteTable(ACF.LaserSources)
		net.Send(Player)
	end)
end)
