include("shared.lua")

language.Add("Cleanup_acf_rack", "ACF Racks")
language.Add("Cleaned_acf_rack", "Cleaned up all ACF Racks")
language.Add("SBoxLimit__acf_rack", "You've hit the ACF Rack limit!")

local HideInfo = ACF.HideInfoBubble

function ENT:Draw()
	self.BaseClass.DoNormalDraw(self, false, HideInfo())

	Wire_Render(self)

	if self.GetBeamLength and (not self.GetShowBeam or self:GetShowBeam()) then
		-- Every SENT that has GetBeamLength should draw a tracer. Some of them have the GetShowBeam boolean
		Wire_DrawTracerBeam(self, 1, self.GetBeamHighlight and self:GetBeamHighlight() or false)
	end
end
