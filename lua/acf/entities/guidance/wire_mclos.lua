local ACF       = ACF
local Guidances = ACF.Classes.Guidances
local Guidance  = Guidances.Register("Wire (MCLOS)", "Radio (MCLOS)")

function Guidance:Configure(Missile)
	Guidance.BaseClass.Configure(self, Missile)

	self.WireLength = 31496 * 31496 -- Missile.WireLength * Missile.WireLength or 31496
end

function Guidance:GetDisplayConfig()
	return {
		["Wire Length"] = math.Round(self.WireLength ^ 0.5 * 0.0254, 2) .. " meters"
	}
end

if CLIENT then
	Guidance.Description = "This guidance package allows you to manually control the direction of the missile."
else
	local SnapSound = "physics/metal/sawblade_stick%s.wav"

	Guidance.IsWire = true

	function Guidance:OnLaunched(Missile)
		Guidance.BaseClass.OnLaunched(self, Missile)

		local LastFired = self.Source.LastFired

		if IsValid(LastFired) and LastFired.GuidanceData.IsWire then
			LastFired.GuidanceData:SnapRope(LastFired)
		end

		self.Rope = constraint.CreateKeyframeRope(Vector(), 0.1, "cable/cable2", nil, self.Source, self.InPos, 0, Missile, self.OutPos, 0)
		self.Rope:SetKeyValue("Width", 0.1)
	end

	function Guidance:OnRange(Missile)
		if not IsValid(self.Source) then return false end

		local From = self.Source:LocalToWorld(self.InPos)
		local To = Missile:LocalToWorld(self.OutPos)

		return From:DistToSqr(To) <= self.WireLength
	end

	function Guidance:SnapRope(Missile)
		if not Missile.Launched then return end
		if self.WireSnapped then return end

		self.WireSnapped = true

		if IsValid(self.Rope) then
			self.Rope:Remove()
			self.Rope = nil

			if IsValid(self.Source) then
				self.Source:EmitSound(SnapSound:format(math.random(3)), nil, nil, ACF.Volume)
			end
		end
	end

	function Guidance:GetGuidance(Missile)
		if self.WireSnapped then return {} end
		if not (self:OnRange(Missile) and self:CheckLOS(Missile)) then
			self:SnapRope(Missile)

			return {}
		end

		local Pitch, Yaw = self:CheckComputer()

		if not Pitch then return {} end
		if Pitch == 0 and Yaw == 0 then return {} end

		local Direction = Angle(Pitch, Yaw):Forward() * 12000

		return { TargetPos = Missile:LocalToWorld(Direction) }
	end

	function Guidance:OnRemoved(Missile)
		self:SnapRope(Missile)
	end
end
