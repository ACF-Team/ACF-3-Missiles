local Guidance = ACF.RegisterGuidance("Anti-missile", "Anti-radiation")

Guidance.desc = "This guidance package uses a radar to detect missiles and guides the munition towards the most centered one it can find."

function Guidance:GetRadar(Type)
	if not IsValid(self.Source) then return end

	local Radar = self.Source.Radar

	if not IsValid(Radar) then return end
	if not Radar.Scanning then return end
	if Radar.ClassType ~= Type then return end

	return Radar
end

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

function Guidance:OnLaunched(Missile)
	self.Target = self:FindNewTarget(Missile, self:GetRadar("AM"))
end

function Guidance:GetGuidance(Missile)
	local Radar = self:GetRadar("AM")

	if not Radar then return {} end

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
