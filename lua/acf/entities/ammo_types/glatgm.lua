local ACF       = ACF
local AmmoTypes = ACF.Classes.AmmoTypes
local Ammo      = AmmoTypes.Register("GLATGM", "HEATFS")

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

function Ammo:BaseConvert(ToolData)
	local Data, GUIData = ACF.RoundBaseGunpowder(ToolData, {})

	GUIData.MinConeAng	 = 0
	GUIData.MinFillerVol = 0

	Data.ShovePower		= 0.1
	Data.LimitVel		= 100 -- Most efficient penetration speed in m/s
	Data.Ricochet		= 91 -- Base ricochet angle
	Data.DetonatorAngle	= 91

	self:UpdateRoundData(ToolData, Data, GUIData)

	return Data, GUIData
end

if SERVER then
	local CrateText  = "Peak Velocity: %s m/s\nLaunch Velocity: %s m/s\nAcceleration: %s s\nMax Penetration: %s mm\nBlast Radius: %s m\nBlast Energy: %s KJ"
	local Ballistics = ACF.Ballistics

	function Ammo:Create(Gun, BulletData)
		if Gun:GetClass() == "acf_ammo" then
			Ballistics.CreateBullet(BulletData)
		else
			MakeACF_GLATGM(Gun, BulletData)
		end
	end

	function Ammo:Network(Entity, BulletData)
		Ammo.BaseClass.Network(self, Entity, BulletData)

		Entity:SetNW2String("AmmoType", "GLATGM")
	end

	function Ammo:GetCrateText(BulletData)
		local Data      = self:GetDisplayData(BulletData)
		local Velocity  = math.Clamp(BulletData.MuzzleVel / ACF.Scale, 200, 1600) -- Minimum initial launch velocity of 40m/s and lowest peak at 100m/s while top speed is 800m/s
		local PeakVel   = math.Round(Velocity * 0.5, 2)
		local LaunchVel = math.Round(Velocity * 0.2, 2)
		local Accel     = math.Round(math.Clamp(BulletData.ProjMass / BulletData.PropMass + BulletData.Caliber / 7, 0.2, 10), 2)

		return CrateText:format(PeakVel, LaunchVel, Accel,  math.floor(Data.MaxPen), math.Round(Data.BlastRadius, 2), math.floor(BulletData.BoomFillerMass * ACF.HEPower))
	end

	function Ammo:HEATExplosionEffect(Bullet, Pos)
		local Data = EffectData()
		Data:SetOrigin(Pos)
		Data:SetNormal(Bullet.Flight:GetNormalized())
		Data:SetRadius(math.max(Bullet.FillerMass ^ 0.33 * 8 * 39.37, 1))

		util.Effect("ACF_GLATGMExplosion", Data)
	end
else
	ACF.RegisterAmmoDecal("GLATGM", "damage/heat_pen", "damage/heat_rico", function(Caliber) return Caliber * 0.1667 end)

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
			local BoomFillerMass = Bullet.FillerMass * ACF.HEATBoomConvert

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

	function Ammo:AddAmmoPreview(Preview, Setup, ToolData, BulletData)
		Ammo.BaseClass.AddAmmoPreview(self, Preview, Setup, ToolData, BulletData)

		local Caliber = BulletData.Caliber
		local Model, FOV, Height

		if Caliber < 12 then
			Model = "models/missiles/glatgm/9m117.mdl"
			FOV   = 65
		elseif Caliber >= 14 then
			Model  = "models/missiles/glatgm/mgm51.mdl"
			Height = 100
			FOV    = 60
		else
			Model = "models/missiles/glatgm/9m112.mdl"
			FOV   = 80
		end

		Setup.Model  = Model
		Setup.FOV    = FOV
		Setup.Height = Height or Setup.Height
	end

	function Ammo:AddAmmoControls(Base, ToolData, BulletData)
		local LinerAngle = Base:AddSlider("Liner Angle", BulletData.MinConeAng, 90, 1)
		LinerAngle:SetClientData("LinerAngle", "OnValueChanged")
		LinerAngle:TrackClientData("Projectile")
		LinerAngle:DefineSetter(function(Panel, _, Key, Value)
			if Key == "LinerAngle" then
				ToolData.LinerAngle = math.Round(Value, 2)
			end

			self:UpdateRoundData(ToolData, BulletData)

			Panel:SetMin(BulletData.MinConeAng)
			Panel:SetValue(BulletData.ConeAng)

			return BulletData.ConeAng
		end)

		local StandoffRatio = Base:AddSlider("Extra Standoff Ratio", 0, 0.4, 2)
		StandoffRatio:SetClientData("StandoffRatio", "OnValueChanged")
		StandoffRatio:DefineSetter(function(_, _, _, Value)
			ToolData.StandoffRatio = math.Round(Value, 2)

			self:UpdateRoundData(ToolData, BulletData)

			return ToolData.StandoffRatio
		end)
	end

	function Ammo:AddAmmoInformation(Base, ToolData, BulletData)
		local RoundStats = Base:AddLabel()
		RoundStats:TrackClientData("Projectile", "SetText")
		RoundStats:TrackClientData("Propellant")
		RoundStats:TrackClientData("LinerAngle")
		RoundStats:TrackClientData("StandoffRatio")
		RoundStats:DefineSetter(function()
			self:UpdateRoundData(ToolData, BulletData)

			local Text		= "Peak Velocity: %s m/s\nLaunch Velocity: %s m/s\nAcceleration: %s s\nProjectile Mass : %s\nPropellant Mass : %s\nExplosive Mass : %s"
			local Velocity  = math.Clamp(BulletData.MuzzleVel / ACF.Scale, 200, 1600) -- Minimum initial launch velocity of 40m/s and lowest peak at 100m/s while top speed is 800m/s
			local PeakVel	= math.Round(Velocity * 0.5, 2)
			local LaunchVel = math.Round(Velocity * 0.2, 2)
			local Accel     = math.Round(math.Clamp(BulletData.ProjMass / BulletData.PropMass + BulletData.Caliber / 7, 0.2, 10), 2)
			local ProjMass	= ACF.GetProperMass(BulletData.ProjMass)
			local PropMass	= ACF.GetProperMass(BulletData.PropMass)
			local Filler	= ACF.GetProperMass(BulletData.FillerMass)

			return Text:format(PeakVel, LaunchVel, Accel, ProjMass, PropMass, Filler)
		end)

		local FillerStats = Base:AddLabel()
		FillerStats:TrackClientData("FillerRatio", "SetText")
		FillerStats:TrackClientData("LinerAngle")
		FillerStats:TrackClientData("StandoffRatio")
		FillerStats:DefineSetter(function()
			self:UpdateRoundData(ToolData, BulletData)

			local Text	   = "Blast Radius : %s m\nFragments : %s\nFragment Mass : %s\nFragment Velocity : %s m/s"
			local Blast	   = math.Round(BulletData.BlastRadius, 2)
			local FragMass = ACF.GetProperMass(BulletData.FragMass)
			local FragVel  = math.Round(BulletData.FragVel, 2)

			return Text:format(Blast, BulletData.Fragments, FragMass, FragVel)
		end)

		local Penetrator = Base:AddLabel()
		Penetrator:TrackClientData("Projectile", "SetText")
		Penetrator:TrackClientData("Propellant")
		Penetrator:TrackClientData("LinerAngle")
		Penetrator:TrackClientData("StandoffRatio")
		Penetrator:DefineSetter(function()
			self:UpdateRoundData(ToolData, BulletData)

			local Text     = "Copper mass : %s g\nJet mass : %s g\nJet velocity : %s m/s - %s m/s"
			local CuMass   = math.Round(BulletData.LinerMass * 1e3, 0)
			local JetMass  = math.Round(BulletData.JetMass * 1e3, 0)
			local MinVel   = math.Round(BulletData.JetMinVel, 0)
			local MaxVel   = math.Round(BulletData.JetMaxVel, 0)

			return Text:format(CuMass, JetMass, MinVel, MaxVel)
		end)

		local PenStats = Base:AddLabel()
		PenStats:TrackClientData("Projectile", "SetText")
		PenStats:TrackClientData("Propellant")
		PenStats:TrackClientData("LinerAngle")
		PenStats:TrackClientData("StandoffRatio")
		PenStats:DefineSetter(function()
			self:UpdateRoundData(ToolData, BulletData)

			local Text   = "Penetration at passive standoff :\nAt %s mm : %s mm RHA\nMaximum penetration :\nAt %s mm : %s mm RHA"
			local Standoff1 = math.Round(BulletData.Standoff * 1e3, 0)
			local Pen1 = math.Round(self:GetPenetration(BulletData, BulletData.Standoff), 1)
			local Standoff2 = math.Round(BulletData.BreakupDist * 1e3, 0)
			local Pen2 = math.Round(self:GetPenetration(BulletData, BulletData.BreakupDist), 1)

			return Text:format(Standoff1, Pen1, Standoff2, Pen2)
		end)
	end
end
