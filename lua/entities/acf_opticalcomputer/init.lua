
AddCSLuaFile("shared.lua")

include("shared.lua")

ACF.RegisterClassLink("acf_opticalcomputer", "acf_rack", function(Computer, Target)
	if Computer.Weapons[Target] then return false, "This rack is already linked to this computer!" end
	if Target.Computer == Computer then return false, "This rack is already linked to this computer!" end

	Computer.Weapons[Target] = true
	Target.Computer = Computer

	Computer:UpdateOverlay()
	Target:UpdateOverlay()

	return true, "Rack linked successfully!"
end)

ACF.RegisterClassUnlink("acf_opticalcomputer", "acf_rack", function(Computer, Target)
	if Computer.Weapons[Target] or Target.Computer == Computer then
		Computer.Weapons[Target] = nil
		Target.Computer = nil

		Computer:UpdateOverlay()
		Target:UpdateOverlay()

		return true, "Rack unlinked successfully!"
	end

	return false, "This rack is not linked to this computer."
end)

ACF.RegisterLinkSource("acf_opticalcomputer", "Weapons")

--===============================================================================================--
-- Local Funcs and Vars
--===============================================================================================--

local ActiveLasers = ACF.ActiveLasers
local CheckLegal = ACF_CheckLegal
local ClassLink = ACF.GetClassLink
local ClassUnlink = ACF.GetClassUnlink
local TraceLine = util.TraceLine
local TraceData = { start = true, endpos = true, filter = true }
local ZeroHitPos = { 0, 0, 0 }

local function ResetOutputs(Entity)
	Entity.HitPos = Vector()
	Entity.Distance = 0

	WireLib.TriggerOutput(Entity, "Lasing", 0)
	WireLib.TriggerOutput(Entity, "Distance", 0)
	WireLib.TriggerOutput(Entity, "HitPos", ZeroHitPos)

	timer.Remove("ACF Outputs Update" .. Entity:EntIndex())
end

local function UpdateOutputs(Entity)
	local Trace = Entity:GetTrace()
	local HitPos = Trace.HitPos

	Entity.HitPos = HitPos

	WireLib.TriggerOutput(Entity, "HitPos", { HitPos[1], HitPos[2], HitPos[3] })

	if Entity.Lasing then
		local Distance = Trace.StartPos:Distance(HitPos)

		Entity.Distance = Distance

		ActiveLasers[Entity] = HitPos

		WireLib.TriggerOutput(Entity, "Distance", Distance)
	end

	Entity:UpdateOverlay()
end

local Inputs = {
	Active = function(Entity, Bool)
		if Entity.Active == Bool then return end

		Entity.Active = Bool

		if Bool then
			timer.Create("ACF Outputs Update" .. Entity:EntIndex(), 0.15, 0, function()
				if not IsValid(Entity) then return end

				UpdateOutputs(Entity)
			end)
		else
			ResetOutputs(Entity)
		end

		Entity:TriggerInput("Lase", Entity.LaserOn)
	end,
	Lase = function(Entity, Bool)
		if Entity.Lasing == Bool then return end
		if Entity.OnCooldown then return end

		Entity.LaserOn = Bool
		Entity.Lasing = Entity.Active and Bool

		if not Entity.Lasing then
			ActiveLasers[Entity] = nil
		end

		WireLib.TriggerOutput(Entity, "Lasing", Entity.Lasing and 1 or 0)
	end
}

--===============================================================================================--
-- Meta Funcs
--===============================================================================================--

function ENT:Initialize()
	self:SetModel("models/props_lab/monitor01b.mdl")

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)

	self.LegalMass	= 65
	self.Model		= "models/props_lab/monitor01b.mdl"
	self.Active		= false
	self.LaserOn	= false
	self.Lasing		= false
	self.HitPos		= Vector()
	self.Distance	= 0
	self.LaseTime	= 0
	self.MaxTime	= 20
	self.Cooldown	= 10
	self.Filter		= { self }
	self.Weapons	= {}

	self.Inputs		= WireLib.CreateInputs(self, { "Active", "Lase" })
	self.Outputs	= WireLib.CreateOutputs(self, { "Lasing", "LaseTime", "Distance", "HitPos [VECTOR]", "Entity [ENTITY]" })

	WireLib.TriggerOutput(self, "Entity", self)

	local PhysObj = self:GetPhysicsObject()

	if IsValid(PhysObj) then
		PhysObj:SetMass(self.LegalMass)
	end

	ACF_Activate(self)

	self.ACF.LegalMass = self.LegalMass
	self.ACF.Model	   = self.Model

	self:UpdateOverlay()

	CheckLegal(self)
end

function ENT:Enable()
	if not CheckLegal(self) then return end

	self.Disabled	   = nil
	self.DisableReason = nil

	if self.Inputs.Active.Path then
		self:TriggerInput("Active", self.Inputs.Active.Value)
	end

	if self.Inputs.Lase.Path then
		self:TriggerInput("Lase", self.Inputs.Lase.Value)
	end

	self:UpdateOverlay()
end

function ENT:Disable()
	self:TriggerInput("Active", 0)
	self:TriggerInput("Lase", 0)

	self.Disabled = true

	self:UpdateOverlay()
end

function ENT:Link(Target)
	if not IsValid(Target) then return false, "Attempted to link an invalid entity." end
	if self == Target then return false, "Can't link a computer to itself." end

	local Function = ClassLink(self:GetClass(), Target:GetClass())

	if Function then
		return Function(self, Target)
	end

	return false, "Computers can't be linked to '" .. Target:GetClass() .. "'."
end

function ENT:Unlink(Target)
	if not IsValid(Target) then return false, "Attempted to unlink an invalid entity." end
	if self == Target then return false, "Can't unlink a computer from itself." end

	local Function = ClassUnlink(self:GetClass(), Target:GetClass())

	if Function then
		return Function(self, Target)
	end

	return false, "Computers can't be unlinked from '" .. Target:GetClass() .. "'."
end

function ENT:UpdateOverlay()
	if timer.Exists("ACF Overlay Buffer" .. self:EntIndex()) then return end

	timer.Create("ACF Overlay Buffer" .. self:EntIndex(), 0.5, 1, function()
		if not IsValid(self) then return end

		local Text = "%s\n\nLaser: %s\nDistance: %s m"
		local Distance = math.Round(self.Distance * 0.0254, 2)
		local Status

		if self.DisableReason then
			Status = "Disabled: " .. self.DisableReason
		elseif self.OnCooldown then
			Status = "Cooling down"
		else
			Status = self.Active and "Active" or "Idle"
		end

		self:SetOverlayText(string.format(Text, Status, self.Lasing and "ON" or "OFF", Distance))
	end)
end

function ENT:GetTrace()
	TraceData.start = self:GetPos()
	TraceData.endpos = self:GetForward() * 50000
	TraceData.filter = self.Filter

	return TraceLine(TraceData)
end

function ENT:TriggerInput(Input, Value)
	if self.Disabled then return end

	if Inputs[Input] then
		Inputs[Input](self, tobool(Value))

		self:UpdateOverlay()
	end
end

function ENT:Think()
	if self.Lasing or self.LaseTime > 0 then
		self.LaseTime = math.max(self.LaseTime + (self.Lasing and 0.15 or -0.15), 0)

		if self.LaseTime >= self.MaxTime then
			self:TriggerInput("Lase", 0)

			self.OnCooldown	= true
			self.LaseTime	= 0
			self.Distance	= 0

			WireLib.TriggerOutput(self, "Distance", 0)

			self:UpdateOverlay()

			timer.Simple(self.Cooldown, function()
				if not IsValid(self) then return end

				self.OnCooldown = nil

				if self.Inputs.Lase.Path then
					self:TriggerInput("Lase", self.Inputs.Lase.Value)
				end

				self:UpdateOverlay()
			end)
		end

		WireLib.TriggerOutput(self, "LaseTime", self.LaseTime)
	end

	self:NextThink(CurTime() + 0.15)

	return true
end

function ENT:PreEntityCopy()
	if next(self.Weapons) then
		local Entities = {}

		for Weapon in pairs(self.Weapons) do
			Entities[#Entities + 1] = Weapon:EntIndex()
		end

		duplicator.StoreEntityModifier(self, "ACFWeapons", Entities)
	end

	-- wire dupe info
	self.BaseClass.PreEntityCopy(self)
end

function ENT:PostEntityPaste(Player, Ent, CreatedEntities)
	local EntMods = Ent.EntityMods

	if EntMods.ACFWeapons then
		for _, EntID in pairs(EntMods.ACFWeapons) do
			self:Link(CreatedEntities[EntID])
		end

		EntMods.ACFWeapons = nil
	end

	-- Wire dupe info
	self.BaseClass.PostEntityPaste(self, Player, Ent, CreatedEntities)
end

function ENT:OnRemove()
	for Weapon in pairs(self.Weapons) do
		self:Unlink(Weapon)
	end

	if ActiveLasers[self] then
		ActiveLasers[self] = nil
	end

	WireLib.Remove(self)
end
