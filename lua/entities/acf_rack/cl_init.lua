-- cl_init.lua

include ("shared.lua")

ENT.RenderGroup = RENDERGROUP_OPAQUE


function ENT:Draw()
	self:DoNormalDraw()
	self:DrawModel()
	Wire_Render(self)
end

function ENT:DoNormalDraw()
	if self ~= LocalPlayer():GetEyeTrace().Entity then return end
	if EyePos():Distance(self:GetPos()) > 256 then return end
	if self:GetOverlayText() == "" then return end

	AddWorldTip(self:EntIndex(), self:GetOverlayText(), 0.5, self:GetPos(), self)
end
