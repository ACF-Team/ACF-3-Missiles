
AddCSLuaFile("shared.lua")
include("shared.lua")

-------------------------------[[ Local Functions ]]-------------------------------

local function CheckLegal(Entity)
	if Entity.Disabled then return end

	local PhysObj = Entity:GetPhysicsObject()

	if IsValid(PhysObj) and PhysObj:GetMass() < Entity.LegalMass then
		PhysObj:SetMass(Entity.LegalMass)

		Entity:Disable()
	end

	-- Next legality check
	if not Entity.Disabled then
		timer.Simple(math.Rand(1, 5), function()
			if IsValid(Entity) then
				CheckLegal(Entity)
			end
		end)
	end
end

local function ResetOutputs(Entity)
	Wire_TriggerOutput(Entity, "Distance", 0)
	Wire_TriggerOutput(Entity, "HitPos", { 0, 0, 0 })
end

local function GetTrace(Entity, Filter)
	local TraceFilter = { Entity }

	if Filter and next(Filter) then
		for K, V in ipairs(Filter) do
			TraceFilter[K + 1] = V
		end
	end

	return util.QuickTrace(Entity:GetPos(), Entity:GetForward() * 50000, TraceFilter)
end

-------------------------------[[ Global Functions ]]-------------------------------

function ENT:Initialize()
	self:SetModel("models/props_lab/monitor01b.mdl")
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)

	self.LegalMass = 65
	self.Inputs = WireLib.CreateInputs(self, { "Active" })
	self.Outputs = WireLib.CreateOutputs(self, { "Entity [ENTITY]", "Distance", "HitPos [VECTOR]" })

	Wire_TriggerOutput(self, "Entity", self)

	local PhysObj = self:GetPhysicsObject()

	if IsValid(PhysObj) then
		PhysObj:SetMass(self.LegalMass)
	end

	CheckLegal(self)
end

function ENT:TriggerInput(_, Value)
	self.Active = tobool(Value)

	if not self.Active then
		ResetOutputs(self)
	end
end

function ENT:Think()
	if not self.Disabled and self.Active then
		local Trace = GetTrace(self)
		local HitPos = Trace.HitPos
		local Distance = Trace.StartPos:Distance(HitPos)

		Wire_TriggerOutput(self, "Distance", Distance)
		Wire_TriggerOutput(self, "HitPos", { HitPos[1], HitPos[2], HitPos[3] })
	end

	self:NextThink(CurTime() + 0.15)

	return true
end

function ENT:Enable()
	self.Disabled = nil

	CheckLegal(self)
end

function ENT:Disable()
	self.Disabled = true

	ResetOutputs(self)

	-- ACF.IllegalDisableTime hasn't been implemented yet
	timer.Simple(ACF.IllegalDisableTime or 30, function()
		if IsValid(self) then
			self:Enable()
		end
	end)
end

ENT.GetTrace = GetTrace
