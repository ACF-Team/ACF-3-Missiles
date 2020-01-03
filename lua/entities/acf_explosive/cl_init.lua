include ("shared.lua")

--[[]
function ENT:Draw()
	self:DoNormalDraw()
	self:DrawModel()
	Wire_Render(self)
end

function ENT:DoNormalDraw()
	local drawbubble = self:GetNWBool("VisInfo", false)

	if not drawbubble then return end
	if not (LocalPlayer():GetEyeTrace().Entity == self and EyePos():Distance(self:GetPos()) < 256) then return end

	local tooltip = self:GetOverlayText()

	if (tooltip ~= "") then
		AddWorldTip(self:EntIndex(), tooltip, 0.5, self:GetPos(), self)
	end
end

function ENT:GetOverlayText()
	local roundID = self:GetNWString("RoundId", "Unknown ID")
	local roundType = self:GetNWString("RoundType", "Unknown Type")
	local filler = self:GetNWFloat("FillerVol", 0)

	local blast = (filler / 2) ^ 0.33 * 5 * 10 * 0.2

	local ret = {
		roundID,
		" (",
		roundType,
		")\n",
		filler,
		" cm^3 HE Filler\n",
		blast,
		" m Blast Radius",
	}

	return table.concat(ret)
end
]]--

local ACF_GunInfoWhileSeated = CreateClientConVar("ACF_GunInfoWhileSeated", 0, true, false)

function ENT:Draw()
	local Player = LocalPlayer()
	local HideBubble = IsValid(Player) and Player:InVehicle() and not ACF_GunInfoWhileSeated:GetBool()

	self.BaseClass.DoNormalDraw(self, false, HideBubble)
	Wire_Render(self)

	if self.GetBeamLength and (not self.GetShowBeam or self:GetShowBeam()) then
		-- Every SENT that has GetBeamLength should draw a tracer. Some of them have the GetShowBeam boolean
		Wire_DrawTracerBeam(self, 1, self.GetBeamHighlight and self:GetBeamHighlight() or false)
	end
end