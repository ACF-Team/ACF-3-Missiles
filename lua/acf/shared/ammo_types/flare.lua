local Ammo = ACF.RegisterAmmoType("FLR", "AP")
local IgniteConVar = GetConVar("ACFM_FlaresIgnite")

function Ammo:OnLoaded()
	Ammo.BaseClass.OnLoaded(self)

	self.Name = "Flare"
	self.Description = "A flare designed to confuse guided munitions."
	self.Blacklist = ACF.GetWeaponBlacklist({
		FLR = true,
		GL = true,
		SL = true,
	})
end

function Ammo.Create(_, BulletData)
	local Bullet = ACF_CreateBullet(BulletData)

	Bullet.CreateTime = ACF.CurTime

	ACFM_RegisterFlare(Bullet)
end

function Ammo.Convert(_, PlayerData)
	local Data = {}
	local ServerData = {}
	local GUIData = {}

	if not PlayerData.PropLength then PlayerData.PropLength = 0 end
	if not PlayerData.ProjLength then PlayerData.ProjLength = 0 end
	if not PlayerData.Data5 then PlayerData.Data5 = 0 end
	if not PlayerData.Data10 then PlayerData.Data10 = 0 end

	PlayerData, Data, ServerData, GUIData = ACF_RoundBaseGunpowder(PlayerData, Data, ServerData, GUIData)

	Data.ProjMass = math.max(GUIData.ProjVolume - PlayerData.Data5, 0) * 7.9 / 1000 + math.min(PlayerData.Data5, GUIData.ProjVolume) * ACF.HEDensity / 1000 --Volume of the projectile as a cylinder - Volume of the filler * density of steel + Volume of the filler * density of TNT
	Data.MuzzleVel = ACF_MuzzleVelocity(Data.PropMass, Data.ProjMass, Data.Caliber)

	local Energy = ACF_Kinetic(Data.MuzzleVel * 39.37, Data.ProjMass, Data.LimitVel)
	local MaxVol = ACF_RoundShellCapacity(Energy.Momentum, Data.FrArea, Data.Caliber, Data.ProjLength)

	GUIData.MinFillerVol = 0
	GUIData.MaxFillerVol = math.min(GUIData.ProjVolume, MaxVol * 0.9)
	GUIData.FillerVol = math.min(PlayerData.Data5, GUIData.MaxFillerVol)

	Data.FillerMass = GUIData.FillerVol * ACF.HEDensity / 200
	Data.ProjMass = math.max(GUIData.ProjVolume-GUIData.FillerVol,0) * 7.9 / 1000 + Data.FillerMass
	Data.MuzzleVel = ACF_MuzzleVelocity(Data.PropMass, Data.ProjMass, Data.Caliber)
	Data.ShovePower = 0.1
	Data.PenArea = Data.FrArea^ACF.PenAreaMod
	Data.DragCoef = (Data.FrArea / 375) / Data.ProjMass
	Data.LimitVel = 700										--Most efficient penetration speed in m/s
	Data.KETransfert = 0.1									--Kinetic energy transfert to the target for movement purposes
	Data.Ricochet = 75										--Base ricochet angle
	Data.BurnRate = Data.FrArea * ACFM.FlareBurnMultiplier
	Data.DistractChance = (2 / math.pi) * math.atan(Data.FrArea * ACFM.FlareDistractMultiplier)	* 0.5	--reduced effectiveness 50%--red
	Data.BurnTime = Data.FillerMass / Data.BurnRate
	Data.BoomPower = Data.PropMass + Data.FillerMass

	if SERVER then --Only the crates need this part
		ServerData.Id = PlayerData.Id
		ServerData.Type = PlayerData.Type

		return table.Merge(Data, ServerData)
	end

	if CLIENT then --Only tthe GUI needs this part
		GUIData = table.Merge(GUIData, Ammo.GetDisplayData(Data))

		return table.Merge(Data, GUIData)
	end
end

function Ammo.Network(Crate, BulletData)
	Crate:SetNWString("AmmoType", "FLR")
	Crate:SetNWString("AmmoID", BulletData.Id)
	Crate:SetNWFloat("Caliber", BulletData.Caliber)
	Crate:SetNWFloat("ProjMass", BulletData.ProjMass)
	Crate:SetNWFloat("FillerMass", BulletData.FillerMass)
	Crate:SetNWFloat("PropMass", BulletData.PropMass)
	Crate:SetNWFloat("DragCoef", BulletData.DragCoef)
	Crate:SetNWFloat("MuzzleVel", BulletData.MuzzleVel)
	Crate:SetNWFloat("Tracer", BulletData.Tracer)
end

function Ammo.GetDisplayData(Data)
	return {
		MaxPen = 0,
		BurnRate = Data.BurnRate,
		DistractChance = Data.DistractChance,
		BurnTime = Data.BurnTime,
	}
end

function Ammo.GetCrateText(BulletData)
	local Text = "Muzzle Velocity: %s m/s\nBurn Rate: %s kg/s\nBurn Duration: %s s\nDistract Chance: %s %"
	local Data = Ammo.GetDisplayData(BulletData)

	return Text:format(math.Round(BulletData.MuzzleVel, 2), math.Round(Data.BurnRate, 2), math.Round(Data.BurnTime, 2), math.floor(Data.DistractChance * 100))
end

function Ammo.PropImpact(_, _, Target)
	if IgniteConVar:GetBool() then
		local Type = ACF_Check(Target)

		if Type == "Squishy" and ((Target:IsPlayer() and not Target:HasGodMode()) or Target:IsNPC()) then
			Target:Ignite(30)
		end
	end

	return false
end

function Ammo.WorldImpact()
	return false
end

function Ammo.ImpactEffect()
end

function Ammo.CreateMenu(Panel, Table)
	acfmenupanel:AmmoSelect(Ammo.Blacklist)

	acfmenupanel:CPanelText("BonusDisplay", "")
	acfmenupanel:CPanelText("Desc", "")	--Description (Name, Desc)
	acfmenupanel:CPanelText("LengthDisplay", "")	--Total round length (Name, Desc)
	acfmenupanel:AmmoSlider("PropLength", 0, 0, 1000, 3, "Propellant Length", "")	--Propellant Length Slider (Name, Value, Min, Max, Decimals, Title, Desc)
	acfmenupanel:AmmoSlider("ProjLength", 0, 0, 1000, 3, "Projectile Length", "")	--Projectile Length Slider (Name, Value, Min, Max, Decimals, Title, Desc)
	acfmenupanel:AmmoSlider("FillerVol", 0, 0, 1000, 3, "Dual Spectrum Filler", "") --Hollow Point Cavity Slider (Name, Value, Min, Max, Decimals, Title, Desc)
	acfmenupanel:CPanelText("VelocityDisplay", "")	--Proj muzzle velocity (Name, Desc)
	acfmenupanel:CPanelText("BurnRateDisplay", "")	--Proj muzzle penetration (Name, Desc)
	acfmenupanel:CPanelText("BurnDurationDisplay", "")	--HE Blast data (Name, Desc)
	acfmenupanel:CPanelText("DistractChanceDisplay", "")	--HE Fragmentation data (Name, Desc)

	Ammo.UpdateMenu(Panel, Table)
end

function Ammo.UpdateMenu(Panel)
	local PlayerData = {
		Id = acfmenupanel.AmmoData.Data.id,					--AmmoSelect GUI
		Type = "FLR",										--Hardcoded, match ACFRoundTypes table index
		PropLength = acfmenupanel.AmmoData.PropLength,		--PropLength slider
		ProjLength = acfmenupanel.AmmoData.ProjLength,		--ProjLength slider
		Data5 = acfmenupanel.AmmoData.FillerVol,
		Data10 = acfmenupanel.AmmoData.Tracer and 1 or 0,	--Tracer
	}

	local Data = Ammo.Convert(Panel, PlayerData)

	RunConsoleCommand("acfmenu_data1", acfmenupanel.AmmoData.Data.id)
	RunConsoleCommand("acfmenu_data2", PlayerData.Type)
	RunConsoleCommand("acfmenu_data3", Data.PropLength)		--For Gun ammo, Data3 should always be Propellant
	RunConsoleCommand("acfmenu_data4", Data.ProjLength)		--And Data4 total round mass
	RunConsoleCommand("acfmenu_data5", Data.FillerVol)
	RunConsoleCommand("acfmenu_data10", Data.Tracer)

	acfmenupanel:AmmoSlider("PropLength", Data.PropLength, Data.MinPropLength, Data.MaxTotalLength, 3, "Propellant Length", "Propellant Mass : " .. math.floor(Data.PropMass * 1000) .. " g")	--Propellant Length Slider (Name, Min, Max, Decimals, Title, Desc)
	acfmenupanel:AmmoSlider("ProjLength", Data.ProjLength, Data.MinProjLength, Data.MaxTotalLength, 3, "Projectile Length", "Projectile Mass : " .. math.floor(Data.ProjMass * 1000) .. " g")	--Projectile Length Slider (Name, Min, Max, Decimals, Title, Desc)
	acfmenupanel:AmmoSlider("FillerVol", Data.FillerVol, Data.MinFillerVol, Data.MaxFillerVol, 3, "Dual Spectrum Filler", "Filler Mass : " .. math.floor(Data.FillerMass * 1000) .. " g")	--HE Filler Slider (Name, Min, Max, Decimals, Title, Desc)
	acfmenupanel:CPanelText("Desc", Ammo.Description)	--Description (Name, Desc)
	acfmenupanel:CPanelText("LengthDisplay", "Round Length : " .. math.floor((Data.PropLength + Data.ProjLength + Data.Tracer) * 100) / 100 .. "/" .. Data.MaxTotalLength .. " cm")	--Total round length (Name, Desc)
	acfmenupanel:CPanelText("VelocityDisplay", "Muzzle Velocity : " .. math.floor(Data.MuzzleVel * ACF.Scale) .. " m/s")	--Proj muzzle velocity (Name, Desc)
	acfmenupanel:CPanelText("BurnRateDisplay", "Burn Rate : " .. math.Round(Data.BurnRate, 1) .. " kg/s")
	acfmenupanel:CPanelText("BurnDurationDisplay", "Burn Duration : " .. math.Round(Data.BurnTime, 1) .. " s")
	acfmenupanel:CPanelText("DistractChanceDisplay", "Distraction Chance : " .. math.floor(Data.DistractChance * 100) .. " %")
end

function Ammo.MenuAction(Menu)
	Menu:AddParagraph("Testing FLR menu.")
end

ACF.RegisterAmmoDecal("FLR", "damage/ap_pen", "damage/ap_rico")
