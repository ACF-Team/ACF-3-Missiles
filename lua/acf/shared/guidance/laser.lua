
local Guidance = ACF.RegisterGuidance("Laser", "Radio (MCLOS)")
local TraceData = { start = true, endpos = true, mask = MASK_SOLID_BRUSHONLY }
local TraceLine = util.TraceLine
local Lasers = ACF.ActiveLasers

Guidance.desc = "This guidance package reads a target-position from the launcher and guides the munition towards it."

function Guidance:Configure(Missile)
	Guidance.BaseClass.Configure(self, Missile)

	self.ViewCone = ACF_GetGunValue(Missile.BulletData, "viewcone") or 20
	self.ViewConeCos = math.cos(math.rad(self.ViewCone))
end

function Guidance.GetDirectionDot(Missile, TargetPos)
	local Position = Missile:GetPos()
	local Forward = Missile:GetForward()
	local Direction = (TargetPos - Position):GetNormalized()

	return Direction:Dot(Forward)
end

function Guidance:CheckConeLOS(Missile, Position, TargetPos, ConeCos)
	if self.GetDirectionDot(Missile, TargetPos) < ConeCos then return end

	TraceData.start = Position
	TraceData.endpos = TargetPos

	return not TraceLine(TraceData).Hit
end

function Guidance:CheckComputer(Missile)
	local Computer = self:GetComputer()

	if not IsValid(Computer) then return end
	if not Computer.Lasing then return end

	local Position = Missile:GetPos()
	local HitPos = Computer.HitPos

	if not self:CheckConeLOS(Missile, Position, HitPos, self.ViewConeCos) then return end

	return HitPos
end

function Guidance:GetGuidance(Missile)
	if not next(Lasers) then return {} end

	local HitPos = self:CheckComputer(Missile)

	if HitPos then return { TargetPos = HitPos } end

	local Position = Missile:GetPos()
	local HighestDot = 0
	local CurrentDot

	for _, Laser in pairs(Lasers) do
		if self:CheckConeLOS(Missile, Position, Laser, self.ViewConeCos) then
			CurrentDot = self.GetDirectionDot(Missile, Laser)

			if CurrentDot > HighestDot then
				HighestDot = CurrentDot
				HitPos = Laser
			end
		end
	end

	return { TargetPos = HitPos }
end

function Guidance:GetDisplayConfig()
	return { Tracking = math.Round(self.ViewCone * 2, 2) .. " deg" }
end