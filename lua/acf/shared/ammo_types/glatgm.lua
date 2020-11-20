local Ammo = ACF.RegisterAmmoType("GLATGM", "HEAT")

function Ammo:OnLoaded()
	Ammo.BaseClass.OnLoaded(self)

	self.Name		 = "Gun-Launched Anti-Tank Missile"
	self.Description = "A missile fired from a gun. While slower than a traditional shell, it makes up for that with guidance."
	self.Blacklist = ACF.GetWeaponBlacklist({
		C = true,
		AL = true,
		HW = true,
		SB = true,
		SC = true,
	})
end

function Ammo:GetDisplayData(Data)
	local Energy    = ACF_Kinetic(Data.MuzzleVel * 39.37 + Data.SlugMV * 39.37 , Data.SlugMass, 999999)
	local Fragments = math.max(math.floor(Data.BoomFillerMass / Data.CasingMass * ACF.HEFrag), 2)
	local Display   = {
		MaxPen		= Energy.Penetration / Data.SlugPenArea * ACF.KEtoRHA,
		BlastRadius	= Data.BoomFillerMass ^ 0.33 * 8,
		Fragments	= Fragments,
		FragMass	= Data.CasingMass / Fragments,
		FragVel		= (Data.BoomFillerMass * ACF.HEPower * 1000 / Data.CasingMass / Fragments) ^ 0.5,
	}

	hook.Run("ACF_GetDisplayData", self, Data, Display)

	return Display
end

function Ammo:BaseConvert(ToolData)
	local Data, GUIData = ACF.RoundBaseGunpowder(ToolData, {})

	GUIData.MinConeAng	 = 0
	GUIData.MinFillerVol = 0

	Data.SlugRicochet	= 500 -- Base ricochet angle (The HEAT slug shouldn't ricochet at all)
	Data.ShovePower		= 0.1
	Data.PenArea		= Data.FrArea ^ ACF.PenAreaMod
	Data.LimitVel		= 100 -- Most efficient penetration speed in m/s
	Data.KETransfert	= 0.1 -- Kinetic energy transfert to the target for movement purposes
	Data.Ricochet		= 60 -- Base ricochet angle
	Data.DetonatorAngle	= 75
	Data.Detonated		= false
	Data.NotFirstPen	= false

	self:UpdateRoundData(ToolData, Data, GUIData)

	return Data, GUIData
end

if SERVER then
	function Ammo:Create(Gun, BulletData)
		if Gun:GetClass() == "acf_ammo" then
			ACF.CreateBullet(BulletData)
		else
			MakeACF_GLATGM(Gun, BulletData)
		end
	end

	function Ammo:Network(Entity, BulletData)
		Ammo.BaseClass.Network(self, Entity, BulletData)

		Entity:SetNW2String("AmmoType", "GLATGM")
	end

	function Ammo:GetCrateText(BulletData)
		local Text = "Command Link: %s m\nMax Penetration: %s mm\nBlast Radius: %s m\nBlast Energy: %s KJ"
		local Data = self:GetDisplayData(BulletData)

		return Text:format(math.Round(BulletData.MuzzleVel * 2 / ACF.Scale, 2), math.floor(Data.MaxPen), math.Round(Data.BlastRadius, 2), math.floor(BulletData.BoomFillerMass * ACF.HEPower))
	end
else
	ACF.RegisterAmmoDecal("GLATGM", "damage/heat_pen", "damage/heat_rico", function(Caliber) return Caliber * 0.1667 end)

	local DecalIndex = ACF.GetAmmoDecalIndex

	function Ammo:PenetrationEffect(Effect, Bullet)
		local Data = EffectData()

		if Bullet.Detonated then
			Data:SetOrigin(Bullet.SimPos)
			Data:SetNormal(Bullet.SimFlight:GetNormalized())
			Data:SetScale(Bullet.SimFlight:Length())
			Data:SetMagnitude(Bullet.RoundMass)
			Data:SetRadius(Bullet.Caliber)
			Data:SetDamageType(DecalIndex(Bullet.AmmoType))

			util.Effect("ACF_Penetration", Data)
		else
			local _, _, BoomFillerMass = self:CrushCalc(Bullet.SimFlight:Length() * 0.0254, Bullet.FillerMass)

			Data:SetOrigin(Bullet.SimPos)
			Data:SetNormal(Bullet.SimFlight:GetNormalized())
			Data:SetScale(math.max(BoomFillerMass ^ 0.33 * 3 * 39.37, 1))
			Data:SetRadius(Bullet.Caliber)

			util.Effect("ACF_GLATGMExplosion", Data)

			Bullet.Detonated = true

			Effect:SetModel("models/Gibs/wood_gib01e.mdl")
		end
	end

	function Ammo:SetupAmmoMenuSettings(Settings)
		Settings.SuppressTracer = true
	end

	function Ammo:AddAmmoPreview(Preview, _, BulletData)
		local Model = "models/missiles/glatgm/9m117.mdl"

		if BulletData.Caliber == 12 then
			Model = "models/missiles/glatgm/9m112.mdl"
		elseif BulletData.Caliber > 12 then
			Model = "models/missiles/glatgm/mgm51.mdl"
		end

		Preview:SetModel(Model)
	end

	function Ammo:AddAmmoInformation(Base, ToolData, BulletData)
		local RoundStats = Base:AddLabel()
		RoundStats:TrackDataVar("Projectile", "SetText")
		RoundStats:TrackDataVar("Propellant")
		RoundStats:TrackDataVar("FillerMass")
		RoundStats:TrackDataVar("LinerAngle")
		RoundStats:SetValueFunction(function()
			self:UpdateRoundData(ToolData, BulletData)

			local Text		= "Command Distance : %s m\nProjectile Mass : %s\nPropellant Mass : %s\nExplosive Mass : %s"
			local MuzzleVel	= math.Round(BulletData.MuzzleVel * 2 / ACF.Scale, 2)
			local ProjMass	= ACF.GetProperMass(BulletData.ProjMass)
			local PropMass	= ACF.GetProperMass(BulletData.PropMass)
			local Filler	= ACF.GetProperMass(BulletData.FillerMass)

			return Text:format(MuzzleVel, ProjMass, PropMass, Filler)
		end)

		local FillerStats = Base:AddLabel()
		FillerStats:TrackDataVar("FillerMass", "SetText")
		FillerStats:TrackDataVar("LinerAngle")
		FillerStats:SetValueFunction(function()
			self:UpdateRoundData(ToolData, BulletData)

			local Text	   = "Blast Radius : %s m\nFragments : %s\nFragment Mass : %s\nFragment Velocity : %s m/s"
			local Blast	   = math.Round(BulletData.BlastRadius, 2)
			local FragMass = ACF.GetProperMass(BulletData.FragMass)
			local FragVel  = math.Round(BulletData.FragVel, 2)

			return Text:format(Blast, BulletData.Fragments, FragMass, FragVel)
		end)

		local Penetrator = Base:AddLabel()
		Penetrator:TrackDataVar("Projectile", "SetText")
		Penetrator:TrackDataVar("Propellant")
		Penetrator:TrackDataVar("FillerMass")
		Penetrator:TrackDataVar("LinerAngle")
		Penetrator:SetValueFunction(function()
			self:UpdateRoundData(ToolData, BulletData)

			local Text	   = "Penetrator Caliber : %s mm\nPenetrator Mass : %s\nPenetrator Velocity : %s m/s"
			local Caliber  = math.Round(BulletData.SlugCaliber * 10, 2)
			local Mass	   = ACF.GetProperMass(BulletData.SlugMass)
			local Velocity = math.Round(BulletData.MuzzleVel + BulletData.SlugMV, 2)

			return Text:format(Caliber, Mass, Velocity)
		end)

		local PenStats = Base:AddLabel()
		PenStats:TrackDataVar("Projectile", "SetText")
		PenStats:TrackDataVar("Propellant")
		PenStats:TrackDataVar("FillerMass")
		PenStats:TrackDataVar("LinerAngle")
		PenStats:SetValueFunction(function()
			self:UpdateRoundData(ToolData, BulletData)

			local Text	   = "Penetration : %s mm RHA\nAt 300m : %s mm RHA @ %s m/s\nAt 800m : %s mm RHA @ %s m/s"
			local MaxPen   = math.Round(BulletData.MaxPen, 2)
			local R1V, R1P = ACF.PenRanging(BulletData.MuzzleVel, BulletData.DragCoef, BulletData.ProjMass, BulletData.PenArea, BulletData.LimitVel, 300)
			local R2V, R2P = ACF.PenRanging(BulletData.MuzzleVel, BulletData.DragCoef, BulletData.ProjMass, BulletData.PenArea, BulletData.LimitVel, 800)

			R1P = math.Round((ACF_Kinetic((R1V + BulletData.SlugMV) * 39.37, BulletData.SlugMass, 999999).Penetration / BulletData.SlugPenArea) * ACF.KEtoRHA, 2)
			R2P = math.Round((ACF_Kinetic((R2V + BulletData.SlugMV) * 39.37, BulletData.SlugMass, 999999).Penetration / BulletData.SlugPenArea) * ACF.KEtoRHA, 2)

			return Text:format(MaxPen, R1P, R1V, R2P, R2V)
		end)

		Base:AddLabel("Note: The penetration range data is an approximation and may not be entirely accurate.")
	end
end
