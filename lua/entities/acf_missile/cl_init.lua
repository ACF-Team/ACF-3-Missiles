include("shared.lua")

local function RenderMotorLight(Entity, LightSize)
	if LightSize <= 0 then return end

	local Index = Entity:EntIndex()
	local Pos = Entity:GetPos() - Entity:GetForward() * 64

	ACFM_RenderLight(Index, LightSize * 175, Color(255, 128, 48), Pos)
end

function ENT:Draw()
	self:DrawModel()

	RenderMotorLight(self, self:GetNWFloat("LightSize"))
end
