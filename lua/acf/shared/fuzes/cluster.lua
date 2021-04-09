
local Fuze = ACF.RegisterFuze("Cluster", "Optical")

Fuze.MinDistance = 500
Fuze.MaxDistance = 5000

if CLIENT then
	Fuze.Description = "This fuze fires a beam directly ahead and releases bomblets when the beam hits something close-by. Distance in inches."
else
	Fuze.Spread = 500

	function Fuze:HandleDetonation(Entity, BulletData)
		local FillerMass = BulletData.FillerMass
		-- Seven circles packed in a circle: https://en.wikipedia.org/wiki/Circle_packing_in_a_circle
		local Layers     = math.Clamp(math.Round(FillerMass * 0.5 / 7), 1, 4)
		local Bomblets   = Layers * 7
		local Density    = 0.77778  -- Volume density of the circle packing
		local RoundData  = Entity.RoundData

		BulletData.Caliber    = BulletData.Caliber / 3
		BulletData.Diameter   = BulletData.Diameter / 3
		BulletData.ProjArea   = math.pi * (BulletData.Diameter * 0.5) ^ 2
		BulletData.ProjLength = BulletData.ProjLength / Layers
		BulletData.ProjMass   = BulletData.ProjMass * Density / Bomblets
		BulletData.DragCoef   = BulletData.ProjArea * 0.0001 / BulletData.ProjMass
		BulletData.FillerMass = FillerMass * Density / Bomblets
		BulletData.Tracer     = 0

		if BulletData.Type == "HEAT" then
			BulletData.SlugMass       = BulletData.SlugMass * Density / Bomblets
			BulletData.SlugCaliber    = BulletData.SlugCaliber * Density / Bomblets
			BulletData.SlugDragCoef   = BulletData.SlugDragCoef * Density / Bomblets
			BulletData.SlugMV         = BulletData.SlugMV * Density / Bomblets
			BulletData.CasingMass     = BulletData.CasingMass * Density / Bomblets
			BulletData.BoomFillerMass = BulletData.BoomFillerMass * Density / Bomblets
		end

		RoundData:Network(Entity, BulletData)

		local Effect = EffectData()
		Effect:SetOrigin(Entity.Position)
		Effect:SetNormal(Entity.CurDir)
		Effect:SetScale(math.max(BulletData.Caliber * 20, 1))
		Effect:SetRadius(BulletData.Caliber)

		util.Effect("ACF_Explosion", Effect)

		local Angle     = 0
		local Increment = 2 * math.pi * (Layers + 1) / Layers / 7 -- Equally spaces the bomblets angle-wise
		local Velocity  = BulletData.Flight

		for _ = 1, Bomblets do
			local SpreadVec = Entity:GetUp() * math.sin(Angle) + Entity:GetRight() * math.cos(Angle)
			local SpreadVel = SpreadVec * self.Spread * math.random() ^ 0.5
			BulletData.Flight = Velocity + SpreadVel

			Angle = Angle + Increment

			RoundData:Create(Entity, BulletData)
		end
	end
end
