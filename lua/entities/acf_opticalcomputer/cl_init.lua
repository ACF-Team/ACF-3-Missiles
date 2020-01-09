include("shared.lua")

local ACF_GunInfoWhileSeated = GetConVar("ACF_GunInfoWhileSeated")

function ENT:Draw()
	local HideBubble = LocalPlayer():InVehicle() and not ACF_GunInfoWhileSeated:GetBool()

	self.BaseClass.DoNormalDraw(self, false, HideBubble)
	Wire_Render(self)

	if self.GetBeamLength and (not self.GetShowBeam or self:GetShowBeam()) then
		-- Every SENT that has GetBeamLength should draw a tracer. Some of them have the GetShowBeam boolean
		Wire_DrawTracerBeam(self, 1, self.GetBeamHighlight and self:GetBeamHighlight() or false)
	end
end