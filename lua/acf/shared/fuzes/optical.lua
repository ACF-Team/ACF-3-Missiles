
local ACF = ACF
local Fuze = ACF.RegisterFuze("Optical", "Contact")

--[[
-- Configuration information for things like acfmenu.

Name = "Distance",			-- name of the variable to change
DisplayName = "Distance",	-- name displayed to the user
CommandName = "Ds",			-- shorthand name used in console commands
Type = "number",			-- lua type of the configurable variable
Min = 0,					-- number specific: minimum value
Max = 2500					-- number specific: maximum value
]]--

function Fuze:GetDisplayConfig()
	local Config = Fuze.BaseClass.GetDisplayConfig(self)

	Config.Distance = math.Round(self.Distance * 0.0254, 2) .. " m"

	return Config
end

if CLIENT then
	Fuze.desc = "This fuze fires a beam directly ahead and detonates when the beam hits something close-by.\nDistance in inches."
else
	ACF.AddEntityArguments("acf_ammo", "FuzeDistance") -- Adding extra info to ammo crates

	local TraceData = { start = true, endpos = true, filter = true }

	function Fuze:VerifyData(EntClass, Data, ...)
		Fuze.BaseClass.VerifyData(self, EntClass, Data, ...)

		local Distance = Data.FuzeDistance
		local Args = Data.FuzeArgs

		if not ACF.CheckNumber(Distance) and Args then
			Distance = ACF.CheckNumber(Args.DS) or 0

			Args.DS = nil
		end

		Data.FuzeDistance = math.Clamp(Distance or 0, 0, 2500)
	end

	function Fuze:OnFirst(Entity, Data)
		Fuze.BaseClass.OnFirst(self, Entity, Data)

		self.Distance = Data.FuzeDistance -- TODO: This needs to be done in the clientside aswell
	end

	function Fuze:GetDetonate(Missile)
		if not self:IsArmed() then return false end

		local Position = Missile:GetPos()

		TraceData.start = Position
		TraceData.endpos = Position + Missile:GetForward() * self.Distance
		TraceData.filter = Missile.Filter or { Missile }

		return util.TraceLine(TraceData).Hit
	end

	function Fuze:OnLast(Entity)
		Fuze.BaseClass.OnLast(self, Entity)

		Entity.FuzeDistance = nil
	end
end
