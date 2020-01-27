
DEFINE_BASECLASS("base_wire_entity")

ENT.PrintName		= "Optical Computer"
ENT.Author			= "Polymorphic Turtle"
ENT.Category		= "ACF"
ENT.Spawnable		= true
ENT.WireDebugName	= "Optical Computer"

local TraceLine = util.TraceLine
local TraceData = { start = true, endpos = true, filter = true }

function ENT:Initialize()
	self.Filter = { self }

	self.BaseClass.Initialize(self)
end

function ENT:GetTrace()
	TraceData.start = self:LocalToWorld(Vector())
	TraceData.endpos = self:LocalToWorld(Vector(50000))
	TraceData.filter = self.Filter

	return TraceLine(TraceData)
end