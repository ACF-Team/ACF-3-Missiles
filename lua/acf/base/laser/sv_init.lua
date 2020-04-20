util.AddNetworkString("ACF_SetupLaserSource")
util.AddNetworkString("ACF_SyncLaserSources")
util.AddNetworkString("ACF_UpdateLaserFilter")

local Sources = ACF.LaserSources

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

function ACF.FilterLaserEntity(Entity)
	if not IsValid(Entity) then return end

	for Source, Data in pairs(Sources) do
		local Filter = Data.Filter

		Filter[#Filter + 1] = Entity

		Data.Filter = Filter

		if Source.UpdateFilter then
			Source:UpdateFilter(Filter)
		end
	end

	net.Start("ACF_UpdateLaserFilter")
		net.WriteEntity(Entity)
	net.Broadcast()
end

hook.Add("PlayerInitialSpawn", "ACF Laser Setup", function(Player)
	timer.Simple(5, function()
		if not IsValid(Player) then return end

		net.Start("ACF_SyncLaserSources")
			net.WriteTable(ACF.LaserSources)
		net.Send(Player)
	end)
end)

hook.Add("OnMissileLaunched", "ACF Laser Filter Update", function(Missile)
	ACF.FilterLaserEntity(Missile)
end)
