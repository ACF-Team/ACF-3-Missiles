local Guidance = ACF.RegisterGuidance("Radio (MCLOS)", "Dumb")
local TraceData = { start = true, endpos = true, mask = MASK_SOLID_BRUSHONLY }
local TraceLine = util.TraceLine

Guidance.desc = "This guidance package allows you to manually control the direction of the missile."

function Guidance:Configure(Missile)
	self.Source = Missile.Launcher
end

function Guidance:OnLaunched(Missile)
	self.InPos = Missile.AttachPos
	self.OutPos = Missile.ExhaustPos
end

function Guidance:GetComputer()
	local Source = self.Source

	if not IsValid(Source) then return end
	if not IsValid(Source.Computer) then return end

	return Source.Computer
end

function Guidance:CheckLOS(Missile)
	TraceData.start = self.Source:LocalToWorld(self.InPos)
	TraceData.endpos = Missile:LocalToWorld(self.OutPos)

	return not TraceLine(TraceData).Hit
end

function Guidance:GetGuidance(Missile)
	local Computer = self:GetComputer()

	if not IsValid(Computer) then return {} end
	if not Computer.Active then return {} end
	if not self:CheckLOS(Missile) then return {} end

	local Source = self.Source
	local Elevation = Source.Elevation
	local Azimuth = Source.Azimuth

	if Elevation == 0 and Azimuth == 0 then return {} end

	local Direction = Angle(Elevation, Azimuth):Forward() * 12000

	return { TargetPos = Missile:LocalToWorld(Direction) }
end