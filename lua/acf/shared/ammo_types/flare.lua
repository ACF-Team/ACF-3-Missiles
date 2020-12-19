local Ammo = ACF.RegisterAmmoType("FLR", "AP")

function Ammo:OnLoaded()
	Ammo.BaseClass.OnLoaded(self)

	self.Name		 = "Flare"
	self.Description = "A countermeasure for infrared guided munitions."
	self.Blacklist = ACF.GetWeaponBlacklist({
		SL = true,
		FGL = true,
	})
end

function Ammo:GetDisplayData(Data)
	local Display = {
		MaxPen         = 0,
		BurnRate       = Data.BurnRate,
		DistractChance = Data.DistractChance,
		BurnTime       = Data.BurnTime,
	}

	hook.Run("ACF_GetDisplayData", self, Data, Display)

	return Display
end

function Ammo:UpdateRoundData(ToolData, Data, GUIData)
	GUIData = GUIData or Data

	ACF.UpdateRoundSpecs(ToolData, Data, GUIData)

	local ProjMass	= math.max(GUIData.ProjVolume - ToolData.FillerMass, 0) * 0.0079 + math.min(ToolData.FillerMass, GUIData.ProjVolume) * ACF.HEDensity / 1000 --Volume of the projectile as a cylinder - Volume of the filler * density of steel + Volume of the filler * density of TNT
	local MuzzleVel	= ACF_MuzzleVelocity(Data.PropMass, ProjMass)
	local Energy	= ACF_Kinetic(MuzzleVel * 39.37, ProjMass, Data.LimitVel)
	local MaxVolume	= ACF.RoundShellCapacity(Energy.Momentum, Data.FrArea, Data.Caliber, Data.ProjLength)

	GUIData.MaxFillerVol = math.Round(math.min(GUIData.ProjVolume, MaxVolume * 0.9), 2)
	GUIData.FillerVol	 = math.Round(math.Clamp(ToolData.FillerMass, GUIData.MinFillerVol, GUIData.MaxFillerVol), 2)

	Data.FillerMass	= GUIData.FillerVol * ACF.HEDensity * 0.001
	Data.ProjMass	= math.max(GUIData.ProjVolume - GUIData.FillerVol, 0) * 0.0079 + Data.FillerMass
	Data.MuzzleVel	= ACF_MuzzleVelocity(Data.PropMass, Data.ProjMass)
	Data.DragCoef	= Data.FrArea * 0.0027 / Data.ProjMass
	Data.BurnTime	= Data.FillerMass / Data.BurnRate
	Data.CartMass	= Data.PropMass + Data.ProjMass

	hook.Run("ACF_UpdateRoundData", self, ToolData, Data, GUIData)

	for K, V in pairs(self:GetDisplayData(Data)) do
		GUIData[K] = V
	end
end

function Ammo:BaseConvert(ToolData)
	local Data, GUIData = ACF.RoundBaseGunpowder(ToolData, {})

	GUIData.MinFillerVol = 0

	Data.ShovePower		= 0.1
	Data.PenArea		= Data.FrArea ^ ACF.PenAreaMod
	Data.LimitVel		= 700 -- Most efficient penetration speed in m/s
	Data.KETransfert	= 0.1 -- Kinetic energy transfert to the target for movement purposes
	Data.Ricochet		= 75 -- Base ricochet angle
	Data.BurnRate		= Data.FrArea * ACFM.FlareBurnMultiplier
	Data.DistractChance	= (2 / math.pi) * math.atan(Data.FrArea * ACFM.FlareDistractMultiplier)	* 0.5 -- Reduced effectiveness 50% -red

	self:UpdateRoundData(ToolData, Data, GUIData)

	return Data, GUIData
end

function Ammo:VerifyData(ToolData)
	Ammo.BaseClass.VerifyData(self, ToolData)

	if not ToolData.FillerMass then
		local Data5 = ToolData.RoundData5

		ToolData.FillerMass = Data5 and tonumber(Data5) or 0
	end
end

if SERVER then
	local IgniteConVar = GetConVar("ACFM_FlaresIgnite")

	function Ammo:Create(_, BulletData)
		local Bullet = ACF.CreateBullet(BulletData)

		Bullet.CreateTime = ACF.CurTime

		ACFM_RegisterFlare(Bullet)
	end

	function Ammo:Network(Entity, BulletData)
		Ammo.BaseClass.Network(self, Entity, BulletData)

		Entity:SetNW2String("AmmoType", "FLR")
		Entity:SetNW2Float("FillerMass", BulletData.FillerMass)
	end

	function Ammo:GetCrateText(BulletData)
		local Text = "Muzzle Velocity: %s m/s\nBurn Rate: %s kg/s\nBurn Duration: %s s\nDistract Chance: %s%%"
		local Data = self:GetDisplayData(BulletData)

		return Text:format(math.Round(BulletData.MuzzleVel, 2), math.Round(Data.BurnRate, 2), math.Round(Data.BurnTime, 2), math.floor(Data.DistractChance * 100))
	end

	function Ammo:PropImpact(_, Trace)
		if IgniteConVar:GetBool() then
			local Target = Trace.Entity
			local Type = ACF.Check(Target)

			if Type == "Squishy" and ((Target:IsPlayer() and not Target:HasGodMode()) or Target:IsNPC()) then
				Target:Ignite(30)
			end
		end

		return false
	end

	function Ammo:WorldImpact()
		return false
	end
else
	ACF.RegisterAmmoDecal("FLR", "damage/ap_pen", "damage/ap_rico")

	function Ammo:ImpactEffect()
	end

	function Ammo:SetupAmmoMenuSettings(Settings)
		Settings.SuppressTracer = true
	end

	function Ammo:AddAmmoControls(Base, ToolData, BulletData)
		local FillerMass = Base:AddSlider("Flare Filler", 0, BulletData.MaxFillerVol, 2)
		FillerMass:SetClientData("FillerMass", "OnValueChanged")
		FillerMass:TrackClientData("Projectile")
		FillerMass:DefineSetter(function(Panel, _, Key, Value)
			if Key == "FillerMass" then
				ToolData.FillerMass = math.Round(Value, 2)
			end

			self:UpdateRoundData(ToolData, BulletData)

			Panel:SetMax(BulletData.MaxFillerVol)
			Panel:SetValue(BulletData.FillerVol)

			return BulletData.FillerVol
		end)
	end

	function Ammo:AddAmmoInformation(Base, ToolData, BulletData)
		local RoundStats = Base:AddLabel()
		RoundStats:TrackClientData("Projectile", "SetText")
		RoundStats:TrackClientData("Propellant")
		RoundStats:TrackClientData("FillerMass")
		RoundStats:DefineSetter(function()
			self:UpdateRoundData(ToolData, BulletData)

			local Text		= "Muzzle Velocity : %s m/s\nProjectile Mass : %s\nPropellant Mass : %s\nFlare Filler Mass : %s"
			local MuzzleVel	= math.Round(BulletData.MuzzleVel * ACF.Scale, 2)
			local ProjMass	= ACF.GetProperMass(BulletData.ProjMass)
			local PropMass	= ACF.GetProperMass(BulletData.PropMass)
			local Filler	= ACF.GetProperMass(BulletData.FillerMass)

			return Text:format(MuzzleVel, ProjMass, PropMass, Filler)
		end)

		local FillerStats = Base:AddLabel()
		FillerStats:TrackClientData("FillerMass", "SetText")
		FillerStats:DefineSetter(function()
			self:UpdateRoundData(ToolData, BulletData)

			local Text		= "Burn Rate : %s/s\nBurn Duration : %s s\nDistraction Chance : %s"
			local Rate		= ACF.GetProperMass(BulletData.BurnRate)
			local Duration	= math.Round(BulletData.BurnTime, 2)
			local Chance	= math.Round(BulletData.DistractChance * 100, 2) .. "%"

			return Text:format(Rate, Duration, Chance)
		end)
	end
end
