local Guidance = ACF.RegisterGuidance("Infrared", "Anti-radiation")

Guidance.desc = "This guidance package will detect a contraption in front of itself and guide the munition towards it."

function Guidance:FindNewTarget(Missile)
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

	return Target
end

function Guidance:GetGuidance(Missile)
	self:PreGuidance(Missile)

	local Override = self:ApplyOverride(Missile)

	if Override then return Override end

	if IsValid(self.Target) then
		local TargetPos = self.Target:GetPos()

		if self:CheckConeLOS(Missile, Missile:GetPos(), TargetPos, self.ViewConeCos) then
			return { TargetPos = TargetPos, ViewCone = self.ViewCone }
		end
	end

	self.Target = self:FindNewTarget(Missile)

	if not self.Target then return {} end

	return { TargetPos = self.Target:GetPos(), ViewCone = self.ViewCone }
end
