local Ammo = ACF.RegisterAmmoType("FLR", "AP")
local IgniteConVar = GetConVar("ACFM_FlaresIgnite")

function Ammo:OnLoaded()
	Ammo.BaseClass.OnLoaded(self)

	self.Name		 = "Flare"
	self.Description = "A countermeasure for infrared guided munitions."
	self.Blacklist = ACF.GetWeaponBlacklist({
		GL = true,
		SL = true,
		FLR = true,
	})
end

function Ammo:Create(_, BulletData)
	local Bullet = ACF_CreateBullet(BulletData)

	Bullet.CreateTime = ACF.CurTime

	ACFM_RegisterFlare(Bullet)
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

	Data.FillerMass	= GUIData.FillerVol * ACF.HEDensity * 0.005
	Data.ProjMass	= math.max(GUIData.ProjVolume - GUIData.FillerVol, 0) * 0.0079 + Data.FillerMass
	Data.MuzzleVel	= ACF_MuzzleVelocity(Data.PropMass, Data.ProjMass)
	Data.DragCoef	= Data.FrArea * 0.0027 / Data.ProjMass
	Data.BurnTime	= Data.FillerMass / Data.BurnRate

	for K, V in pairs(self:GetDisplayData(Data)) do
		GUIData[K] = V
	end
end

function Ammo:BaseConvert(_, ToolData)
	if not ToolData.Projectile then ToolData.Projectile = 0 end
	if not ToolData.Propellant then ToolData.Propellant = 0 end
	if not ToolData.FillerMass then ToolData.FillerMass = 0 end

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

function Ammo:Network(Crate, BulletData)
	Crate:SetNW2String("AmmoType", "FLR")
	Crate:SetNW2String("AmmoID", BulletData.Id)
	Crate:SetNW2Float("Caliber", BulletData.Caliber)
	Crate:SetNW2Float("ProjMass", BulletData.ProjMass)
	Crate:SetNW2Float("FillerMass", BulletData.FillerMass)
	Crate:SetNW2Float("PropMass", BulletData.PropMass)
	Crate:SetNW2Float("DragCoef", BulletData.DragCoef)
	Crate:SetNW2Float("MuzzleVel", BulletData.MuzzleVel)
	Crate:SetNW2Float("Tracer", BulletData.Tracer)
end

function Ammo:GetDisplayData(Data)
	return {
		MaxPen		   = 0,
		BurnRate	   = Data.BurnRate,
		DistractChance = Data.DistractChance,
		BurnTime	   = Data.BurnTime,
	}
end

function Ammo:GetCrateText(BulletData)
	local Text = "Muzzle Velocity: %s m/s\nBurn Rate: %s kg/s\nBurn Duration: %s s\nDistract Chance: %s %"
	local Data = self:GetDisplayData(BulletData)

	return Text:format(math.Round(BulletData.MuzzleVel, 2), math.Round(Data.BurnRate, 2), math.Round(Data.BurnTime, 2), math.floor(Data.DistractChance * 100))
end

function Ammo:PropImpact(_, _, Target)
	if IgniteConVar:GetBool() then
		local Type = ACF_Check(Target)

		if Type == "Squishy" and ((Target:IsPlayer() and not Target:HasGodMode()) or Target:IsNPC()) then
			Target:Ignite(30)
		end
	end

	return false
end

function Ammo:WorldImpact()
	return false
end

function Ammo:ImpactEffect()
end

function Ammo:MenuAction(Menu, ToolData, Data)
	local FillerMass = Menu:AddSlider("Flare Filler", 0, Data.MaxFillerVol, 2)
	FillerMass:SetDataVar("FillerMass", "OnValueChanged")
	FillerMass:TrackDataVar("Projectile")
	FillerMass:SetValueFunction(function(Panel)
		ToolData.FillerMass = math.Round(ACF.ReadNumber("FillerMass"), 2)

		self:UpdateRoundData(ToolData, Data)

		Panel:SetMax(Data.MaxFillerVol)
		Panel:SetValue(Data.FillerVol)

		return Data.FillerVol
	end)

	local Tracer = Menu:AddCheckBox("Tracer")
	Tracer:SetDataVar("Tracer", "OnChange")
	Tracer:SetValueFunction(function(Panel)
		ToolData.Tracer = ACF.ReadBool("Tracer")

		self:UpdateRoundData(ToolData, Data)

		ACF.WriteValue("Projectile", Data.ProjLength)
		ACF.WriteValue("Propellant", Data.PropLength)

		Panel:SetText("Tracer : " .. Data.Tracer .. " cm")
		Panel:SetValue(ToolData.Tracer)

		return ToolData.Tracer
	end)

	local RoundStats = Menu:AddLabel()
	RoundStats:TrackDataVar("Projectile", "SetText")
	RoundStats:TrackDataVar("Propellant")
	RoundStats:TrackDataVar("FillerMass")
	RoundStats:SetValueFunction(function()
		self:UpdateRoundData(ToolData, Data)

		local Text		= "Muzzle Velocity : %s m/s\nProjectile Mass : %s\nPropellant Mass : %s\nFlare Filler Mass : %s"
		local MuzzleVel	= math.Round(Data.MuzzleVel * ACF.Scale, 2)
		local ProjMass	= ACF.GetProperMass(Data.ProjMass)
		local PropMass	= ACF.GetProperMass(Data.PropMass)
		local Filler	= ACF.GetProperMass(Data.FillerMass)

		return Text:format(MuzzleVel, ProjMass, PropMass, Filler)
	end)

	local FillerStats = Menu:AddLabel()
	FillerStats:TrackDataVar("FillerMass", "SetText")
	FillerStats:SetValueFunction(function()
		self:UpdateRoundData(ToolData, Data)

		local Text		= "Burn Rate : %s/s\nBurn Duration : %s s\nDistraction Chance : %s"
		local Rate		= ACF.GetProperMass(Data.BurnRate)
		local Duration	= math.Round(Data.BurnTime, 2)
		local Chance	= math.Round(Data.DistractChance * 100, 2) .. "%"

		return Text:format(Rate, Duration, Chance)
	end)
end

ACF.RegisterAmmoDecal("FLR", "damage/ap_pen", "damage/ap_rico")
