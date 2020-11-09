
local Guidance = ACF.RegisterGuidance("Active Radar", "Semi-Active Radar")

if CLIENT then
	Guidance.desc = "This guidance package uses a radar to detect contraptions and guides the munition towards the most centered one it can find."
else
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
		local CurrentDot, TargetPos, Distance, Target

		for Entity, Spread in pairs(Radar.Targets) do
			TargetPos = Entity:GetPos() + Spread
			Distance = Position:DistToSqr(TargetPos)

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
		local TargetPos, Spread

		if IsValid(self.Target) then
			if self.TargetMode == "Active" then
				Spread = Vector()
			else
				Spread = Radar and Radar.Targets[self.Target]
			end

			TargetPos = self.Target:GetPos()

			if Spread and self:CheckConeLOS(Missile, Missile:GetPos(), TargetPos + Spread, self.ViewConeCos) then
				return { TargetPos = TargetPos + Spread, ViewCone = self.ViewCone }
			end
		end

		self.Target = self:FindNewTarget(Missile, Radar)

		if not self.Target then return {} end

		TargetPos = self.Target:GetPos()
		Spread = Radar and Radar.Targets[self.Target] or Vector()

		return { TargetPos = TargetPos + Spread, ViewCone = self.ViewCone }
	end
end
