include("shared.lua")

local ACF_GunInfoWhileSeated = GetConVar("ACF_GunInfoWhileSeated")
local LaserMaterial = Material("cable/redlaser")
local Computers = {}

function ENT:Draw()
	local HideBubble = LocalPlayer():InVehicle() and not ACF_GunInfoWhileSeated:GetBool()

	self.BaseClass.DoNormalDraw(self, false, HideBubble)
	Wire_Render(self)

	if self.GetBeamLength and (not self.GetShowBeam or self:GetShowBeam()) then
		-- Every SENT that has GetBeamLength should draw a tracer. Some of them have the GetShowBeam boolean
		Wire_DrawTracerBeam(self, 1, self.GetBeamHighlight and self:GetBeamHighlight() or false)
	end

end

-- Wire Cam Controller FLIR compatibility
if FLIR then
	local Initialize = ENT.Initialize

	local function DrawFLIRBeam(Entity)
		if not Entity:GetNW2Bool("Lasing") then return end

		local Trace = Entity:GetTrace()

		render.SetMaterial(LaserMaterial)
		render.DrawBeam(Entity:LocalToWorld(Vector()), Trace.HitPos, 15, 0, 12.5)
	end

	function ENT:Initialize()
		if FLIR then
			Computers[self] = true

			self:CallOnRemove("ACF FLIR Beam", function()
				Computers[self] = nil
			end)
		end

		Initialize(self)
	end

	hook.Add("PostDrawOpaqueRenderables", "ACF FLIR Beam", function()
		if FLIR.enabled then
			for Computer in pairs(Computers) do
				DrawFLIRBeam(Computer)
			end
		end
	end)
end