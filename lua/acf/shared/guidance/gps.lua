
local Guidance = ACF.RegisterGuidance("GPS Guided", "Radio (MCLOS)")

if CLIENT then
	Guidance.desc = "This guidance package allows you to guide the munition to a desired point in the map."
else
	local ZERO = Vector()

	function Guidance:OnLaunched(Missile)
		Guidance.BaseClass.OnLaunched(self, Missile)

		self.NextUpdate = 0
	end

	function Guidance:CheckComputer()
		local Computer = self:GetComputer()

		if not Computer then return end
		if not Computer.IsGPS then return end
		if Computer.InputCoords == ZERO then return end
		if Computer.IsJammed then return end

		if ACF.CurTime >= self.NextUpdate then
			self.NextUpdate = ACF.CurTime + 5
			self.LastPos = Computer.Coordinates
		end
	end

	function Guidance:GetGuidance()
		self:CheckComputer()

		return { TargetPos = self.LastPos }
	end
end
