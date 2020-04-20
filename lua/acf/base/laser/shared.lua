local Lasers = ACF.ActiveLasers
local Sources = ACF.LaserSources
local TraceLine = util.TraceLine
local TraceData = { start = true, endpos = true, filter = true }

local function GetSpread(Entity, Data)
	local Name = Data.Spread

	if not Name then return Vector() end
	if Name == "" then return Vector() end

	return Entity[Name] or Vector()
end

local function GetHitPos(Entity, Data)
	TraceData.start = Entity:LocalToWorld(Data.Offset)
	TraceData.endpos = Entity:LocalToWorld(Data.Direction * 50000)
	TraceData.filter = Data.Filter

	return TraceLine(TraceData).HitPos + GetSpread(Entity, Data)
end

local function LaserTick()
	for Entity in pairs(Lasers) do
		Lasers[Entity] = GetHitPos(Entity, Sources[Entity])
	end
end

function ACF.AddLaserSource(Entity, NetVar, Offset, Direction, Spread, Filter)
	if not IsValid(Entity) then return end

	if not next(Sources) then
		hook.Add("Tick", "ACF Active Lasers", LaserTick)
	end

	Sources[Entity] = {
		NetVar = NetVar,
		Offset = Offset,
		Direction = Direction,
		Spread = Spread,
		Filter = Filter or { Entity },
	}

	if Entity:GetNW2Bool(NetVar) then
		Lasers[Entity] = GetHitPos(Entity, Sources[Entity])
	end

	Entity:CallOnRemove("ACF Active Laser", function()
		Sources[Entity] = nil
		Lasers[Entity] = nil

		if not next(Sources) then
			hook.Remove("Tick", "ACF Active Lasers")
		end
	end)
end

hook.Add("EntityNetworkedVarChanged", "ACF Laser Toggle", function(Entity, Name, Old, New)
	local Data = Sources[Entity]

	if Data and Data.NetVar == Name and Old ~= New then
		Lasers[Entity] = New and GetHitPos(Entity, Data) or nil
	end
end)
