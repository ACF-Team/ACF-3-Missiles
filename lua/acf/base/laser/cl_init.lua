net.Receive("ACF_SetupLaserSource", function()
	local Entity = net.ReadEntity()
	local NetVar = net.ReadString()
	local Offset = net.ReadVector()
	local Direction = net.ReadVector()
	local Filter = net.WriteType()

	ACF.AddLaserSource(Entity, NetVar, Offset, Direction, nil, Filter)
end)

net.Receive("ACF_SyncLaserSources", function()
	local Sources = net.ReadTable()

	for Entity, Data in pairs(Sources) do
		ACF.AddLaserSource(Entity, Data.NetVar, Data.Offset, Data.Direction, nil, Data.Filter)
	end
end)

hook.Add("Initialize", "ACF Wire FLIR Compatibility", function()
	if FLIR then
		local LaserMat = Material("cable/redlaser")
		local Sources = ACF.LaserSources
		local Lasers = ACF.ActiveLasers

		local function DrawBeam(Entity, HitPos)
			local Data = Sources[Entity]

			render.SetMaterial(LaserMat)
			render.DrawBeam(Entity:LocalToWorld(Data.Offset), HitPos, 15, 0, 12.5)
		end

		hook.Add("PostDrawOpaqueRenderables", "ACF Active Lasers", function()
			if FLIR.enabled and next(Lasers) then
				for Entity, HitPos in pairs(Lasers) do
					DrawBeam(Entity, HitPos)
				end
			end
		end)
	end

	hook.Remove("Initialize", "ACF Wire FLIR Compatibility")
end)
