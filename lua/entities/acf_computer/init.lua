
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

ACF.RegisterClassLink("acf_computer", "acf_rack", function(Computer, Target)
	if Computer.Weapons[Target] then return false, "This rack is already linked to this computer!" end
	if Target.Computer == Computer then return false, "This rack is already linked to this computer!" end

	Computer.Weapons[Target] = true
	Target.Computer = Computer

	Computer:UpdateOverlay()
	Target:UpdateOverlay()

	return true, "Rack linked successfully!"
end)

ACF.RegisterClassUnlink("acf_computer", "acf_rack", function(Computer, Target)
	if Computer.Weapons[Target] or Target.Computer == Computer then
		Computer.Weapons[Target] = nil
		Target.Computer = nil

		Computer:UpdateOverlay()
		Target:UpdateOverlay()

		return true, "Rack unlinked successfully!"
	end

	return false, "This rack is not linked to this computer."
end)

--===============================================================================================--
-- Local Funcs and Vars
--===============================================================================================--

local CheckLegal	= ACF_CheckLegal
local ClassLink		= ACF.GetClassLink
local ClassUnlink	= ACF.GetClassUnlink
local Components	= ACF.Classes.Components
local Inputs		= ACF.GetInputActions("acf_computer")
local UnlinkSound	= "physics/metal/metal_box_impact_bullet%s.wav"
local MaxDistance	= ACF.RefillDistance * ACF.RefillDistance

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

--===============================================================================================--

do -- Spawn and update function
	local function VerifyData(Data)
		if Data.Component then -- Entity was created via menu tool
			Data.Id = Data.Component
		end

		local Class = ACF.GetClassGroup(Components, Data.Id)

		if not Class or Class.Entity ~= "acf_computer" then
			Data.Id = "CPR-LSR"
		end
	end

	local function GetInputList(Class, Computer)
		local Count = 0
		local List = {}

		if istable(Class.Inputs) then
			for _, V in ipairs(Class.Inputs) do
				Count = Count + 1
				List[Count] = V
			end
		end

		if istable(Computer.Inputs) then
			for _, V in ipairs(Computer.Inputs) do
				Count = Count + 1
				List[Count] = V
			end
		end

		return List
	end

	local function GetOutputList(Class, Computer)
		local Count = 1
		local List = { "Entity [ENTITY]" }

		if istable(Class.Outputs) then
			for _, V in ipairs(Class.Outputs) do
				Count = Count + 1
				List[Count] = V
			end
		end

		if istable(Computer.Outputs) then
			for _, V in ipairs(Computer.Outputs) do
				Count = Count + 1
				List[Count] = V
			end
		end

		return List
	end

	local function UpdateComputer(Entity, Data, Class, Computer)
		local InputList = GetInputList(Class, Computer)
		local OutputList = GetOutputList(Class, Computer)

		Entity:SetModel(Computer.Model)

		Entity:PhysicsInit(SOLID_VPHYSICS)
		Entity:SetMoveType(MOVETYPE_VPHYSICS)

		if Entity.OnLast then
			Entity:OnLast()
		end

		-- Storing all the relevant information on the entity for duping
		for _, V in ipairs(Entity.DataStore) do
			Entity[V] = Data[V]
		end

		Entity.Name			= Computer.Name
		Entity.ShortName	= Entity.Id
		Entity.EntType		= Class.Name
		Entity.Class		= Computer.ClassID
		Entity.OnUpdate		= Computer.OnUpdate or Class.OnUpdate
		Entity.OnLast		= Computer.OnLast or Class.OnLast
		Entity.OverlayTitle	= Computer.OnOverlayTitle or Class.OnOverlayTitle
		Entity.OverlayBody	= Computer.OnOverlayBody or Class.OnOverlayBody
		Entity.OnDamaged	= Computer.OnDamaged or Class.OnDamaged
		Entity.OnEnabled	= Computer.OnEnabled or Class.OnEnabled
		Entity.OnDisabled	= Computer.OnDisabled or Class.OnDisabled
		Entity.OnThink		= Computer.OnThink or Class.OnThink
		Entity.Inputs		= WireLib.CreateInputs(Entity, InputList)
		Entity.Outputs		= WireLib.CreateOutputs(Entity, OutputList)

		Entity:SetNWString("WireName", "ACF " .. Computer.Name)
		Entity:SetNW2String("ID", Entity.Id)

		WireLib.TriggerOutput(Entity, "Entity", Entity)

		ACF_Activate(Entity, true)

		Entity.ACF.LegalMass	= Computer.Mass
		Entity.ACF.Model		= Computer.Model

		local Phys = Entity:GetPhysicsObject()
		if IsValid(Phys) then Phys:SetMass(Computer.Mass) end

		if Entity.OnUpdate then
			Entity:OnUpdate(Data, Class, Computer)
		end

		if Entity.OnDamaged then
			Entity:OnDamaged()
		end

		Entity:UpdateOverlay(true)
	end

	function MakeACF_Computer(Player, Pos, Angle, Data)
		VerifyData(Data)

		local Class = ACF.GetClassGroup(Components, Data.Id)
		local Computer = Class.Lookup[Data.Id]
		local Limit = Class.LimitConVar.Name

		if not Player:CheckLimit(Limit) then return false end

		local Entity = ents.Create("acf_computer")

		if not IsValid(Entity) then return end

		Entity:SetPlayer(Player)
		Entity:SetAngles(Angle)
		Entity:SetPos(Pos)
		Entity:Spawn()

		Player:AddCleanup("acfmenu", Entity)
		Player:AddCount(Limit, Entity)

		Entity.Owner		= Player -- MUST be stored on ent for PP
		Entity.Weapons		= {}
		Entity.DataStore	= ACF.GetEntClassVars("acf_computer")

		UpdateComputer(Entity, Data, Class, Computer)

		CheckLegal(Entity)

		timer.Create("ACF Computer Clock " .. Entity:EntIndex(), 3, 0, function()
			if not IsValid(Entity) then return end

			CheckDistantLinks(Entity, "Weapons")
		end)

		return Entity
	end

	ACF.RegisterEntityClass("acf_opticalcomputer", MakeACF_Computer, "Id") -- Backwards compatibility
	ACF.RegisterEntityClass("acf_computer", MakeACF_Computer, "Id")
	ACF.RegisterLinkSource("acf_computer", "Weapons")

	------------------- Updating ---------------------

	function ENT:Update(Data)
		VerifyData(Data)

		local Class = ACF.GetClassGroup(Components, Data.Id)
		local Computer = Class.Lookup[Data.Id]

		ACF.SaveEntity(self)

		UpdateComputer(self, Data, Class, Computer)

		ACF.RestoreEntity(self)

		net.Start("ACF_UpdateEntity")
			net.WriteEntity(self)
		net.Broadcast()

		return true, "Computer updated successfully!"
	end
end

function ENT:ACF_OnDamage(Entity, Energy, FrArea, Angle, Inflictor)
	local HitRes = ACF.PropDamage(Entity, Energy, FrArea, Angle, Inflictor)

	--self.Spread = ACF.MaxDamageInaccuracy * (1 - math.Round(self.ACF.Health / self.ACF.MaxHealth, 2))
	if self.OnDamaged then
		self:OnDamaged()
	end

	return HitRes
end

function ENT:Enable()
	if not CheckLegal(self) then return end

	self.Disabled	   = nil
	self.DisableReason = nil

	if self.OnEnabled then
		self:OnEnabled()
	end

	self:UpdateOverlay()
end

function ENT:Disable()
	if self.OnDisabled then
		self:OnDisabled()
	end

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

local function Overlay(Entity)
	local Title = Entity.OverlayTitle and Entity:OverlayTitle()
	local Body = Entity.OverlayBody and Entity:OverlayBody()

	if Entity.Disabled then
		Title = "Disabled: " .. Entity.DisableReason
	elseif not Title then
		Title = "Idle"
	end

	Body = Body and ("\n\n" .. Body) or ""

	Entity:SetOverlayText(Title .. Body)
end

function ENT:UpdateOverlay(Instant)
	if Instant then
		return Overlay(self)
	end

	if timer.Exists("ACF Overlay Buffer" .. self:EntIndex()) then return end

	timer.Create("ACF Overlay Buffer" .. self:EntIndex(), 0.5, 1, function()
		if IsValid(self) then
			Overlay(self)
		end
	end)
end

function ENT:TriggerInput(Name, Value)
	if self.Disabled then return end

	local Action = Inputs[Name]

	if Action then
		Action(self, Value)

		self:UpdateOverlay()
	end
end

function ENT:Think()
	if self.OnThink then
		self:OnThink()
	end

	self:NextThink(ACF.CurTime)

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

	if self.OnLast then
		self:OnLast()
	end

	timer.Remove("ACF Computer Clock " .. self:EntIndex())

	WireLib.Remove(self)
end
