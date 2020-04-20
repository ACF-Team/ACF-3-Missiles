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

function ACF.FilterLaserEntity(Source, Entity)
	if not IsValid(Source) then return end
	if not IsValid(Entity) then return end
	if not Sources[Source] then return end

	local Data = Sources[Source]
	local Filter = Data.Filter

	Filter[#Filter + 1] = Entity

	Data.Filter = Filter

	net.Start("ACF_UpdateLaserFilter")
		net.WriteEntity(Source)
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
	local Source = IsValid(Missile.Launcher) and Missile.Launcher.Computer

	if not IsValid(Source) then return end

	ACF.FilterLaserEntity(Source, Missile)
end)
