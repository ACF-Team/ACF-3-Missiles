local Guidance = ACF.RegisterGuidance("GPS Guided", "Radio (MCLOS)")

Guidance.desc = "This guidance package allows you to guide the munition to a desired point in the map."

function Guidance:OnLaunched(Missile)
	Guidance.BaseClass.OnLaunched(self, Missile)

	self.NextUpdate = ACF.CurTime
end

function Guidance:GetGuidance()
	local Computer = self:GetComputer()

	if not IsValid(Computer) then return {} end
	if not Computer.Active then return {} end

	if ACF.CurTime >= self.NextUpdate then
		self.NextUpdate = ACF.CurTime + 5
		self.LastPos = self.Source.TargetPos
	end

	return { TargetPos = self.LastPos }
end
