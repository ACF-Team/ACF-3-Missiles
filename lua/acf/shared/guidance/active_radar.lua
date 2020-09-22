local Guidance = ACF.RegisterGuidance("Active Radar", "Semi-Active Radar")

Guidance.desc = "This guidance package uses a radar to detect contraptions and guides the munition towards the most centered one it can find."
Guidance.Spread = 100 -- Max spread when not using a radar

function Guidance:SeekNewTarget(Missile)
	local Position = Missile:GetPos()
	local Entities = ACF.GetEntitiesInCone(Position, Missile:GetForward(), self.SeekCone)
	local HighestDot = 0
	local CurrentDot, TargetPos, Distance, Target

	for Entity in pairs(Entities) do
		TargetPos = Entity:GetPos()
		Distance = Position:DistToSqr(TargetPos)

		if Distance >= self.MinDistance and self:CheckConeLOS(Missile, Position, TargetPos, self.SeekConeCos) then
			CurrentDot = self.GetDirectionDot(Missile, TargetPos)

			if CurrentDot > HighestDot then
				HighestDot = CurrentDot
				Target = Entity
			end
		end
	end

	self.TargetMode = "Active"

	return Target
end

function Guidance:FindNewTarget(Missile, Radar)
	if not Radar or Radar.TargetCount == 0 then
		return self:SeekNewTarget(Missile)
	end

	local Position = Missile:GetPos()
	local HighestDot = 0
	local CurrentDot, Target

	for Entity, Info in pairs(Radar.Targets) do
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

	self.TargetMode = "Radar"

	return Target or self:SeekNewTarget(Missile)
end

function Guidance:GetGuidance(Missile)
	self:PreGuidance(Missile)

	local Override = self:ApplyOverride(Missile)

	if Override then return Override end

	local Radar = self:GetRadar("TGT")
	local TargetPos

	if IsValid(self.Target) then
		if self.TargetMode == "Active" then
			TargetPos = self.Target:GetPos() + VectorRand(-self.Spread, self.Spread)
		else
			local TargetInfo = Radar.Targets[self.Target]

			TargetPos = TargetInfo.Position
		end

		if self:CheckConeLOS(Missile, Missile:GetPos(), TargetPos, self.ViewConeCos) then
			return { TargetPos = TargetPos, ViewCone = self.ViewCone }
		end
	end

	self.Target = self:FindNewTarget(Missile, Radar)

	if not self.Target then return {} end

	if self.TargetMode == "Active" then
		TargetPos = self.Target:GetPos() + VectorRand(-self.Spread, self.Spread)
	else
		local TargetInfo = Radar.Targets[self.Target]

		TargetPos = TargetInfo.Position
	end

	return { TargetPos = TargetPos, ViewCone = self.ViewCone }
end
