
AddCSLuaFile("shared.lua")
include("shared.lua")

local function CheckLegal(Entity)
	local PhysObj = Entity:GetPhysicsObject()

	if IsValid(PhysObj) and PhysObj:GetMass() < Entity.LegalMass then
		PhysObj:SetMass(Entity.LegalMass)

		Entity:Disable()
	end
end

function ENT:Initialize()
	self:SetModel("models/props_lab/monitor01b.mdl")
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)

	self.LegalMass = 65

	local PhysObj = self:GetPhysicsObject()

	if IsValid(PhysObj) then
		PhysObj:SetMass(self.LegalMass)
	end
end

function ENT:Think()
	if not self.Disabled then
		CheckLegal(self)
	end

	self:NextThink(CurTime() + math.Rand(1, 5))

	return true
end

function ENT:Enable()
	self.Disabled = nil

	CheckLegal(self)
end

function ENT:Disable()
	self.Disabled = true

	-- ACF.IllegalDisableTime hasn't been implemented yet
	timer.Simple(ACF.IllegalDisableTime or 30, function()
		if IsValid(self) then
			self:Enable()
		end
	end)
end
