local Guidance = ACF.RegisterGuidance("Semi-Active Radar", "Anti-missile")

Guidance.desc = "This guidance package uses a radar to detect contraptions and guides the munition towards the most centered one it can find."

function Guidance:FindNewTarget(Missile, Radar)
	if not Radar then return end
	if Radar.TargetCount == 0 then return end

	local Targets = Radar.Targets
	local Position = Missile:GetPos()
	local HighestDot = 0
	local CurrentDot, Target

	for Entity, Info in pairs(Targets) do
		local TargetPos = Info.Position
		local Distance = Position:DistToSqr(TargetPos)

		if Distance >= self.MinDistance and self:CheckConeLOS(Missile, Position, TargetPos, self.ViewConeCos) then
			CurrentDot = self.GetDirectionDot(Missile, TargetPos)

			if CurrentDot > HighestDot then
				HighestDot = CurrentDot
				Target = Entity
			end
		end
	end

	return Target
end

function Guidance:OnLaunched(Missile)
	self.Target = self:FindNewTarget(Missile, self:GetRadar("TGT"))
end

function Guidance:GetGuidance(Missile)
	local Radar = self:GetRadar("TGT")

	if not Radar then return {} end

	self:PreGuidance(Missile)

	local Override = self:ApplyOverride(Missile)

	if Override then return Override end

	local Targets = Radar.Targets
	local TargetInfo = IsValid(self.Target) and Targets[self.Target]

	if TargetInfo then
		local TargetPos = TargetInfo.Position

		if self:CheckConeLOS(Missile, Missile:GetPos(), TargetPos, self.ViewConeCos) then
			return { TargetPos = TargetPos, ViewCone = self.ViewCone }
		end
	end

	self.Target = self:FindNewTarget(Missile, Radar)

	if not self.Target then return {} end

	TargetInfo = Targets[self.Target]

	return { TargetPos = TargetInfo.Position, ViewCone = self.ViewCone }
end
