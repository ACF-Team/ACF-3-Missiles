
local Guidance = ACF.RegisterGuidance("Active Radar", "Semi-Active Radar")

if CLIENT then
	Guidance.Description = "This guidance package uses a radar to detect contraptions and guides the munition towards the most centered one it can find."
else
	function Guidance:SeekNewTarget(Missile)
		local Position = Missile:GetPos()
		local Entities = ACF.GetEntitiesInCone(Position, Missile:GetForward(), self.SeekCone)
		local HighestDot = 0
		local CurrentDot, Target, TargetOffset

		for Entity in pairs(Entities) do
			local Offset    = VectorRand() * 50
			local TargetPos = Entity.Position + Offset
			local Distance  = Position:DistToSqr(TargetPos)

			if Distance >= self.MinDistance and self:CheckConeLOS(Missile, Position, TargetPos, self.SeekConeCos) then
				CurrentDot = self.GetDirectionDot(Missile, TargetPos)

				if CurrentDot > HighestDot then
					HighestDot = CurrentDot
					TargetOffset = Offset
					Target = Entity
				end
			end
		end

		self.ForcedPos = Target and Target.Position + TargetOffset

		return Target
	end

	function Guidance:FindNewTarget(Missile, Radar)
		if not Radar or Radar.TargetCount == 0 then
			return self:SeekNewTarget(Missile)
		end

		local Position = Missile:GetPos()
		local HighestDot = 0
		local CurrentDot, Target

		for Entity, Data in pairs(Radar.Targets) do
			local TargetPos = Data.Position
			local Distance  = Position:DistToSqr(TargetPos)

			if Distance >= self.MinDistance and self:CheckConeLOS(Missile, Position, TargetPos, self.ViewConeCos) then
				CurrentDot = self.GetDirectionDot(Missile, TargetPos)

				if CurrentDot > HighestDot then
					HighestDot = CurrentDot
					Target = Entity
				end
			end
		end

		self.ForcedPos = nil

		return Target or self:SeekNewTarget(Missile)
	end

	function Guidance:GetTargetPosition(Radar, Target)
		if not Radar then return end
		if not Target then return end

		local Targets = Radar.Targets
		local Data    = Targets[Target]

		return Data and Data.Position
	end

	function Guidance:GetGuidance(Missile)
		self:PreGuidance(Missile)

		local Override = self:ApplyOverride(Missile)

		if Override then return Override end

		local Radar = self:GetRadar("TGT-Radar")

		if IsValid(self.Target) then
			local Position = self.ForcedPos or self:GetTargetPosition(Radar, self.Target)

			if Position and self:CheckConeLOS(Missile, Missile:GetPos(), Position, self.ViewConeCos) then
				return { TargetPos = Position, ViewCone = self.ViewCone }
			end
		end

		self.Target = self:FindNewTarget(Missile, Radar)

		if not self.Target then return {} end

		local Position = self.ForcedPos or self:GetTargetPosition(Radar, self.Target)

		return { TargetPos = Position, ViewCone = self.ViewCone }
	end
end
