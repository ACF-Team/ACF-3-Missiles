local Sources = ACF.LaserSources

net.Receive("ACF_SetupLaserSource", function()
	local Entity = net.ReadEntity()
	local NetVar = net.ReadString()
	local Offset = net.ReadVector()
	local Direction = net.ReadVector()
	local Filter = net.WriteType()

	ACF.AddLaserSource(Entity, NetVar, Offset, Direction, nil, Filter)
end)

net.Receive("ACF_SyncLaserSources", function()
	local Message = net.ReadTable()

	for Entity, Data in pairs(Message) do
		ACF.AddLaserSource(Entity, Data.NetVar, Data.Offset, Data.Direction, nil, Data.Filter)
	end
end)

net.Receive("ACF_UpdateLaserFilter", function()
	local Entity = net.ReadEntity()

	timer.Simple(0.05, function()
		if not IsValid(Entity) then return end

		for Source, Data in pairs(Sources) do
			local Filter = Data.Filter

			Filter[#Filter + 1] = Entity

			Data.Filter = Filter

			if Source.UpdateFilter then
				Source:UpdateFilter(Filter)
			end
		end
	end)
end)

hook.Add("Initialize", "ACF Wire FLIR Compatibility", function()
	if FLIR then
		local LaserMat = Material("cable/redlaser")
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
