
local Guidance = ACF.RegisterGuidance("Anti-radiation", "Laser")

Guidance.MinDistance = 38750 -- Squared, ~5 meters

function Guidance:Configure(Missile)
	Guidance.BaseClass.Configure(self, Missile)

	self.SeekCone = Missile.SeekCone or 10
	self.SeekConeCos = math.cos(math.rad(self.SeekCone))
end

function Guidance:GetDisplayConfig()
	return {
		Seeking = math.Round(self.SeekCone * 2, 2) .. " degrees",
		Tracking = math.Round(self.ViewCone * 2, 2) .. " degrees"
	}
end

if CLIENT then
	Guidance.desc = "This guidance package will detect an active radar infront of itself and guide the munition towards it."
else
	local Radars = ACF.ActiveRadars

	function Guidance:FindNewTarget(Missile)
		if not next(Radars) then return end

		local Position = Missile:GetPos()
		local HighestDot = 0
		local CurrentDot, RadarPos, Distance, Target

		for Radar in pairs(Radars) do
			RadarPos = Radar:LocalToWorld(Radar.Origin)
			Distance = Position:DistToSqr(RadarPos)

			if Distance >= self.MinDistance and self:CheckConeLOS(Missile, Position, RadarPos, self.SeekConeCos) then
				CurrentDot = self.GetDirectionDot(Missile, RadarPos)

				if CurrentDot > HighestDot then
					HighestDot = CurrentDot
					Target = Radar
				end
			end
		end

		return Target
	end

	function Guidance:OnLaunched(Missile)
		self.Target = self:FindNewTarget(Missile)
	end

	function Guidance:GetGuidance(Missile)
		if IsValid(self.Target) then
			local Position = Missile:GetPos()
			local RadarPos = self.Target:GetPos()
			local HasLOS = self:CheckConeLOS(Missile, Position, RadarPos, self.ViewConeCos)

			if HasLOS and self.Target.Active then
				return { TargetPos = RadarPos, ViewCone = self.ViewCone }
			end
		end

		self.Target = self:FindNewTarget(Missile)

		if not self.Target then return {} end

		return { TargetPos = self.Target:GetPos(), ViewCone = self.ViewCone }
	end
end
