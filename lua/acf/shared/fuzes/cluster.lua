
local Fuze = ACF.RegisterFuze("Cluster", "Optical")

Fuze.MinDistance = 500
Fuze.MaxDistance = 5000

if CLIENT then
	Fuze.Description = "This fuze fires a beam directly ahead and releases bomblets when the beam hits something close-by. Distance in inches."
else
	Fuze.Spread = 30

	local AmmoTypes = ACF.Classes.AmmoTypes

	local function PrepareBullet(ToolData)
		local Caliber = ToolData.Caliber / 6.42 -- Circle packing 30 circles within a circle
		local Rows    = math.max(1, math.floor(ToolData.Projectile / Caliber))

		ToolData.Weapon     = "C"
		ToolData.Caliber    = Caliber
		ToolData.Projectile = ToolData.Projectile / Rows
		ToolData.Propellant = 0
		ToolData.Destiny    = "Weapons"
		ToolData.Bomblets   = Rows * 30

		return AmmoTypes[ToolData.AmmoType]()
	end

	function Fuze:HandleDetonation(Entity, BulletData)
		local ToolData  = Entity.ToolData
		local AmmoType  = PrepareBullet(ToolData)
		local Bomblets  = ToolData.Bomblets
		local Bullet    = AmmoType:ServerConvert(ToolData)
		local Velocity  = BulletData.Flight

		Bullet.Crate  = BulletData.Crate
		Bullet.Owner  = BulletData.Owner
		Bullet.Gun    = BulletData.Gun
		Bullet.Pos    = BulletData.Pos
		Bullet.Flight = Velocity
		Bullet.Filter = BulletData.Filter

		AmmoType:Network(Entity, Bullet)

		local Effect = EffectData()
		Effect:SetOrigin(Entity.Position)
		Effect:SetNormal(Entity.CurDir)
		Effect:SetScale(math.max(Bomblets ^ 0.33 * 39.37, 1))
		Effect:SetRadius(BulletData.Caliber)

		util.Effect("ACF_Explosion", Effect)

		for _ = 1, Bomblets do
			local Cone = math.tan(math.rad(self.Spread * ACF.GunInaccuracyScale))
			local Spread = (Entity:GetUp() * math.Rand(-1, 1) + Entity:GetRight() * math.Rand(-1, 1)):GetNormalized()
			local ShootDir = (Velocity:GetNormalized() + Cone * Spread * (math.random() ^ (1 / ACF.GunInaccuracyBias))):GetNormalized()

			Bullet.Flight = ShootDir * Velocity:Length()

			AmmoType:Create(Entity, Bullet)
		end
	end
end
