
local Fuze = ACF.RegisterFuze("Cluster", "Optical")

Fuze.MinDistance = 500
Fuze.MaxDistance = 5000

if CLIENT then
	Fuze.Description = "This fuze fires a beam directly ahead and releases bomblets when the beam hits something close-by. Distance in inches."
else
	Fuze.Spread = 15

	function Fuze:HandleDetonation(Entity, BulletData)
		local FillerMass = BulletData.FillerMass
		local Bomblets   = math.Clamp(math.Round(FillerMass * 0.5), 10, 100)
		local MuzzleVec  = BulletData.Flight:GetNormalized()
		local RoundData  = Entity.RoundData
		local Velocity   = BulletData.Flight

		BulletData.Caliber    = BulletData.Caliber / Bomblets
		BulletData.Diameter   = BulletData.Diameter
		BulletData.DragCoef   = BulletData.DragCoef / Bomblets
		BulletData.FillerMass = FillerMass / Bomblets
		BulletData.ProjLength = BulletData.ProjLength / Bomblets
		BulletData.ProjMass   = BulletData.ProjMass / Bomblets
		BulletData.Tracer     = 0

		if BulletData.Type == "HEAT" then
			BulletData.SlugMass       = BulletData.SlugMass / Bomblets
			BulletData.SlugCaliber    = BulletData.SlugCaliber / Bomblets
			BulletData.SlugDragCoef   = BulletData.SlugDragCoef / Bomblets
			BulletData.SlugMV         = BulletData.SlugMV / Bomblets
			BulletData.CasingMass     = BulletData.CasingMass / Bomblets
			BulletData.BoomFillerMass = BulletData.BoomFillerMass / Bomblets
		end

		RoundData:Network(Entity, BulletData)

		local Effect = EffectData()
		Effect:SetOrigin(Entity.Position)
		Effect:SetNormal(Entity.CurDir)
		Effect:SetScale(math.max(FillerMass ^ 0.33 * 8 * 39.37, 1))
		Effect:SetRadius(BulletData.Caliber)

		util.Effect("ACF_Explosion", Effect)

		for _ = 1, Bomblets do
			local Cone = math.tan(math.rad(self.Spread * ACF.GunInaccuracyScale))
			local Spread = (Entity:GetUp() * math.Rand(-1, 1) + Entity:GetRight() * math.Rand(-1, 1)):GetNormalized()
			local ShootDir = (MuzzleVec + Cone * Spread * (math.random() ^ (1 / ACF.GunInaccuracyBias))):GetNormalized()

			BulletData.Flight = ShootDir * Velocity:Length()

			RoundData:Create(Entity, BulletData)
		end
	end
end
