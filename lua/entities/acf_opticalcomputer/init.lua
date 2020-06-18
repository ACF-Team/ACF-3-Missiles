
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

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

local TraceLine = util.TraceLine
local TraceData = { start = true, endpos = true, filter = true }
local CheckLegal = ACF_CheckLegal
local ClassLink = ACF.GetClassLink
local ClassUnlink = ACF.GetClassUnlink
local SetupLaser = ACF.SetupLaserSource
local UnlinkSound = "physics/metal/metal_box_impact_bullet%s.wav"
local MaxDistance = ACF.RefillDistance * ACF.RefillDistance
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
	local Spread = VectorRand(-Entity.Spread, Entity.Spread)
	local HitPos = Trace.HitPos + Spread

	Entity.HitPos = HitPos
	Entity.LaserSpread = Spread

	WireLib.TriggerOutput(Entity, "HitPos", { HitPos.x, HitPos.y, HitPos.z })

	if Entity.Lasing then
		Entity.Distance = Trace.Fraction * 50000

		WireLib.TriggerOutput(Entity, "Distance", Entity.Distance)
	end

	Entity:UpdateOverlay()
end

local function CheckDistantLinks(Entity, Source)
	local Position = Entity:GetPos()

	for Link in pairs(Entity[Source]) do
		if Position:DistToSqr(Link:GetPos()) > MaxDistance then
			Entity:EmitSound(UnlinkSound:format(math.random(1, 3)), 500, 100)
			Link:EmitSound(UnlinkSound:format(math.random(1, 3)), 500, 100)

			Entity:Unlink(Link)
		end
	end
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

		Entity:TriggerInput("Lase", Entity.LaserOn and Bool)
	end,
	Lase = function(Entity, Bool)
		if Entity.Lasing == Bool then return end
		if Entity.OnCooldown then return end

		Entity.LaserOn = Bool
		Entity.Lasing = Entity.Active and Bool

		Entity:SetNW2Bool("Lasing", Entity.Lasing)

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

	self.Mass		= 65
	self.Armor		= 20
	self.Model		= "models/props_lab/monitor01b.mdl"
	self.Active		= false
	self.LaserOn	= false
	self.Lasing		= false
	self.HitPos		= Vector()
	self.Distance	= 0
	self.LaseTime	= 0
	self.MaxTime	= 20
	self.Cooldown	= 10
	self.Spread		= 0
	self.Weapons	= {}
	self.Filter		= { self }

	self.Inputs		= WireLib.CreateInputs(self, { "Active", "Lase" })
	self.Outputs	= WireLib.CreateOutputs(self, { "Lasing", "LaseTime", "Distance", "HitPos [VECTOR]", "Entity [ENTITY]" })

	SetupLaser(self, "Lasing", nil, nil, "LaserSpread", self.Filter)

	if CPPI then
		timer.Simple(0, function()
			self.Owner = self:CPPIGetOwner()
			self:SetPlayer(self.Owner)
		end)
	end

	WireLib.TriggerOutput(self, "Entity", self)

	self:SetNWString("WireName", "ACF Guidance Computer")

	local PhysObj = self:GetPhysicsObject()

	if IsValid(PhysObj) then
		PhysObj:SetMass(self.Mass)
	end

	ACF_Activate(self)

	self.ACF.LegalMass = self.Mass
	self.ACF.Model	   = self.Model

	self:UpdateOverlay()

	CheckLegal(self)

	timer.Create("ACF Computer Clock " .. self:EntIndex(), 3, 0, function()
		if IsValid(self) then
			CheckDistantLinks(self, "Weapons")
		else
			timer.Remove("ACF Computer Clock " .. self:EntIndex())
		end
	end)
end

function ENT:ACF_Activate(Recalc)
	local PhysObj = self.ACF.PhysObj
	local Count

	if PhysObj:GetMesh() then
		Count = #PhysObj:GetMesh()
	end

	if IsValid(PhysObj) and Count and Count > 100 then
		if not self.ACF.Area then
			self.ACF.Area = PhysObj:GetSurfaceArea() * 6.45
		end
	else
		local Size = self:OBBMaxs() - self:OBBMins()

		if not self.ACF.Area then
			self.ACF.Area = ((Size.x * Size.y) + (Size.x * Size.z) + (Size.y * Size.z)) * 6.45
		end
	end

	self.ACF.Ductility = self.ACF.Ductility or 0

	local Area = self.ACF.Area
	local Armour = self.Armor
	local Health = Area / ACF.Threshold
	local Percent = 1

	if Recalc and self.ACF.Health and self.ACF.MaxHealth then
		Percent = self.ACF.Health / self.ACF.MaxHealth
	end

	self.ACF.Health = Health * Percent
	self.ACF.MaxHealth = Health
	self.ACF.Armour = Armour * (0.5 + Percent / 2)
	self.ACF.MaxArmour = Armour * ACF.ArmorMod
	self.ACF.Mass = self.Mass
	self.ACF.Type = "Prop"
end

function ENT:ACF_OnDamage(Entity, Energy, FrArea, Angle, Inflictor)
	local HitRes = ACF.PropDamage(Entity, Energy, FrArea, Angle, Inflictor)

	self.Spread = ACF.MaxDamageInaccuracy * (1 - math.Round(self.ACF.Health / self.ACF.MaxHealth, 2))

	return HitRes
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

local function Overlay(Ent)
	if Ent.Disabled then
		Ent:SetOverlayText("Disabled: " .. Ent.DisableReason .. "\n" .. Ent.DisableDescription)
	else
		local Text = "%s\n\nLaser: %s\nDistance: %s m"
		local Distance = math.Round(Ent.Distance * 0.0254, 2)
		local Status

		if Ent.OnCooldown then
			Status = "Cooling down"
		else
			Status = Ent.Active and "Active" or "Idle"
		end

		Ent:SetOverlayText(Text:format(Status, Ent.Lasing and "ON" or "OFF", Distance))
	end
end

function ENT:UpdateOverlay(Instant)
	if Instant then
		return Overlay(self)
	end

	if timer.Exists("ACF Overlay Buffer" .. self:EntIndex()) then return end

	timer.Create("ACF Overlay Buffer" .. self:EntIndex(), 0.5, 1, function()
		if not IsValid(self) then return end

		Overlay(self)
	end)
end

function ENT:TriggerInput(Input, Value)
	if self.Disabled then return end

	if Inputs[Input] then
		Inputs[Input](self, tobool(Value))

		self:UpdateOverlay()
	end
end

function ENT:UpdateFilter(Filter)
	if not istable(Filter) then return end

	self.Filter = Filter
end

function ENT:GetTrace()
	TraceData.start = self:LocalToWorld(Vector())
	TraceData.endpos = self:LocalToWorld(Vector(50000))
	TraceData.filter = self.Filter

	return TraceLine(TraceData)
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

	WireLib.Remove(self)
end
