include("shared.lua")

local HideInfo = ACF.HideInfoBubble
local Components = ACF.Classes.Components

function ENT:Initialize()
	self:Update()

	self.BaseClass.Initialize(self)
end

function ENT:Update()
	local Id = self:GetNW2String("ID")
	local Class = ACF.GetClassGroup(Components, Id)
	local Data = Class.Lookup[Id]

	if self.OnLast then
		self:OnLast()
	end

	self.OnUpdate = Data.OnUpdateCL or Class.OnUpdateCL
	self.OnLast = Data.OnLastCL or Class.OnLastCL
	self.OnThink = Data.OnThinkCL or Class.OnThinkCL
	self.OnDraw = Data.OnDrawCL or Class.OnDrawCL

	if self.OnUpdate then
		self:OnUpdate(Class, Data)
	end
end

function ENT:Draw()
	self:DoNormalDraw(false, HideInfo())

	Wire_Render(self)

	if self.GetBeamLength and (not self.GetShowBeam or self:GetShowBeam()) then
		-- Every SENT that has GetBeamLength should draw a tracer. Some of them have the GetShowBeam boolean
		Wire_DrawTracerBeam(self, 1, self.GetBeamHighlight and self:GetBeamHighlight() or false)
	end

	if self.OnDraw then
		self:OnDraw()
	end
end

function ENT:Think()
	self:NextThink(ACF.CurTime)

	if self.OnThink then
		self:OnThink()
	end

	self.BaseClass.Think(self)

	return true
end