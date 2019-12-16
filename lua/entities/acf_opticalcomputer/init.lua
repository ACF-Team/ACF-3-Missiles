
AddCSLuaFile("shared.lua")
include("shared.lua")

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

function ENT:Initialize()
	self:SetModel("models/props_lab/monitor01b.mdl")
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)

	self.LegalMass = 65
	self.Inputs = WireLib.CreateInputs(self, { "Active" })
	self.Outputs = WireLib.CreateOutputs(self, { "Entity [ENTITY]", "Distance" })

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
		Wire_TriggerOutput(self, "Distance", 0)
	end
end

function ENT:Think()
	if not self.Disabled and self.Active then
		local Trace = self:GetTrace()
		local Distance = Trace.StartPos:Distance(Trace.HitPos)

		Wire_TriggerOutput(self, "Distance", Distance)
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

	Wire_TriggerOutput(self, "Distance", 0)

	-- ACF.IllegalDisableTime hasn't been implemented yet
	timer.Simple(ACF.IllegalDisableTime or 30, function()
		if IsValid(self) then
			self:Enable()
		end
	end)
end

function ENT:GetTrace()
	return util.QuickTrace(self:GetPos(), self:GetForward() * 50000, self)
end
