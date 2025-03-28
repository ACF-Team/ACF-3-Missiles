local ACF   = ACF
local Types = ACF.Classes.AmmoTypes
local Ammo  = Types.Register("LRP", "AP")


function Ammo:OnLoaded()
	Ammo.BaseClass.OnLoaded(self)

	self.Name		 = "Long Rod Penetrator"
	self.Model		 = "models/munitions/dart_100mm.mdl"
	self.Description = "Ammo used for the MGM-166 LOSAT. The missile penetrates ~720mm @ 1000m and ~165mm @ 100m"
	self.Blacklist = ACF.GetWeaponBlacklist({
		KEM = true,
	})
end

function Ammo:GetPenetration(Bullet, Speed)
	if not isnumber(Speed) then
		Speed = Bullet.Flight and Bullet.Flight:Length() / ACF.Scale * ACF.InchToMeter or Bullet.MuzzleVel
	end

	return ACF.Penetration(Speed, Bullet.ProjMass, Bullet.Diameter * 1.5)
end

function Ammo:UpdateRoundData(ToolData, Data, GUIData)
	GUIData = GUIData or Data

	ACF.UpdateRoundSpecs(ToolData, Data, GUIData)

	Data.ProjMass  = Data.ProjArea * Data.ProjLength * ACF.SteelDensity -- Volume of the projectile as a cylinder * density of steel
	Data.MuzzleVel = ACF.MuzzleVelocity(Data.PropMass, Data.ProjMass, Data.Efficiency)*0.28
	Data.DragCoef  = Data.ProjArea * 0.0001 / Data.ProjMass
	Data.CartMass  = Data.PropMass + Data.ProjMass

	hook.Run("ACF_OnUpdateRound", self, ToolData, Data, GUIData)

	for K, V in pairs(self:GetDisplayData(Data)) do
		GUIData[K] = V
	end
end

function Ammo:BaseConvert(ToolData)
	local Data, GUIData = ACF.RoundBaseGunpowder(ToolData, { ProjScale = 0.35 })

	Data.ShovePower = 0.3
	Data.LimitVel   = 1200 --Most efficient penetration speed in m/s
	Data.Ricochet   = 80 --Base ricochet angle

	self:UpdateRoundData(ToolData, Data, GUIData)

	return Data, GUIData
end

if SERVER then
	function Ammo:Network(Entity, BulletData)
		Ammo.BaseClass.Network(self, Entity, BulletData)

		Entity:SetNW2String("AmmoType", "LRP")
	end
else
	ACF.RegisterAmmoDecal("LRP", "damage/apcr_pen", "damage/apcr_rico")
end
