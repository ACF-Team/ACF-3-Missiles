
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ACF.RegisterClassLink("acf_radar", "acf_rack", function(Radar, Target)
	if Radar.Weapons[Target] then return false, "This rack is already linked to this radar!" end
	if Target.Radar == Radar then return false, "This rack is already linked to this radar!" end

	Radar.Weapons[Target] = true
	Target.Radar = Radar

	Radar:UpdateOverlay()
	Target:UpdateOverlay()

	return true, "Rack linked successfully!"
end)

ACF.RegisterClassUnlink("acf_radar", "acf_rack", function(Radar, Target)
	if Radar.Weapons[Target] or Target.Radar == Radar then
		Radar.Weapons[Target] = nil
		Target.Radar = nil

		Radar:UpdateOverlay()
		Target:UpdateOverlay()

		return true, "Rack unlinked successfully!"
	end

	return false, "This rack is not linked to this radar."
end)

--===============================================================================================--
-- Local Funcs and Vars
--===============================================================================================--

local Radars	  = ACF.ActiveRadars
local CheckLegal  = ACF_CheckLegal
local ClassLink	  = ACF.GetClassLink
local ClassUnlink = ACF.GetClassUnlink
local UnlinkSound = "physics/metal/metal_box_impact_bullet%s.wav"
local MaxDistance = ACF.RefillDistance * ACF.RefillDistance
local TraceData	  = { start = true, endpos = true, mask = MASK_SOLID_BRUSHONLY }
local TraceLine	  = util.TraceLine
local TimerExists = timer.Exists
local TimerCreate = timer.Create
local TimerRemove = timer.Remove

local function Overlay(Entity)
	local Text = "%s\n\n%s\nDetection range: %s\nScanning angle: %s degrees"
	local Status, Range, Cone

	if Entity.DisableReason then
		Status = "Disabled: " .. Entity.DisableReason
	elseif Entity.TargetCount > 0 then
		Status = Entity.TargetCount .. " target(s) detected"
	elseif not Entity.Active then
		Status = "Idle"
	else
		Status = Entity.Scanning and "Active" or "Activating"
	end

	Range = Entity.Range and math.Round(Entity.Range / 39.37 , 2) .. " meters" or "Infinite"
	Cone = Entity.ConeDegs and math.Round(Entity.ConeDegs, 2) or 360

	Entity:SetOverlayText(string.format(Text, Status, Entity.EntType, Range, Cone))
end

local function ClearTargets(Entity)
	for Target in pairs(Entity.Targets) do
		Entity.Targets[Target] = nil
	end
end

local function ResetOutputs(Entity)
	if Entity.TargetCount == 0 then return end

	ClearTargets(Entity)

	Entity.TargetCount = 0

	WireLib.TriggerOutput(Entity, "Detected", 0)
	WireLib.TriggerOutput(Entity, "ClosestDistance", 0)
	WireLib.TriggerOutput(Entity, "Entities", {})
	WireLib.TriggerOutput(Entity, "Position", {})
	WireLib.TriggerOutput(Entity, "Velocity", {})
end

local function SetSequence(Entity, Active)
	local SequenceName = Active and "active" or "idle"
	local Sequence = Entity:LookupSequence(SequenceName)

	Entity:ResetSequence(Sequence or 0)

	Entity.AutomaticFrameAdvance = Active
end

local function CheckLOS(Start, End)
	TraceData.start = Start
	TraceData.endpos = End

	return not TraceLine(TraceData).Hit
end

local function ScanForEntities(Entity)
	ClearTargets(Entity)

	if not Entity.GetDetected then return end

	local Detected = Entity:GetDetected()
	local Entities = {}
	local Position = {}
	local Velocity = {}

	local Origin = Entity:LocalToWorld(Entity.Origin)
	local Closest = math.huge
	local Count = 0
	local EntPos, EntVel, EntDist, Spread

	for Ent in pairs(Detected) do
		EntPos = Ent.CurPos or Ent:GetPos()
		EntVel = Ent.LastVel or Ent:GetVelocity()

		if CheckLOS(Origin, EntPos) then
			EntDist = Origin:DistToSqr(EntPos)
			Spread = VectorRand(-Entity.Spread, Entity.Spread)
			EntPos = EntPos + Spread
			EntVel = EntVel + Spread

			Count = Count + 1

			Entities[Count] = Ent
			Position[Count] = EntPos
			Velocity[Count] = EntVel

			Entity.Targets[Ent] = Spread

			if EntDist < Closest then
				Closest = EntDist
			end
		end
	end

	Closest = Closest < math.huge and Closest ^ 0.5 or 0

	WireLib.TriggerOutput(Entity, "Detected", Count)
	WireLib.TriggerOutput(Entity, "ClosestDistance", Closest)
	WireLib.TriggerOutput(Entity, "Entities", Entities)
	WireLib.TriggerOutput(Entity, "Position", Position)
	WireLib.TriggerOutput(Entity, "Velocity", Velocity)

	if Count ~= Entity.TargetCount then
		if Count > Entity.TargetCount then
			local Sound = Entity.Sound or ACFM.DefaultRadarSound

			Entity:EmitSound(Sound, 500, 100)
		end

		Entity.TargetCount = Count

		Entity:UpdateOverlay()
	end
end

local function SetScanning(Entity, Active)
	Entity.Scanning = Active

	Entity:UpdateOverlay()

	ResetOutputs(Entity)
	SetSequence(Entity, Active)

	Radars[Entity] = Active or nil

	WireLib.TriggerOutput(Entity, "Scanning", Active and 1 or 0)

	if Active then
		TimerCreate("ACF Radar Scan " .. Entity:EntIndex(), Entity.ThinkDelay, 0, function()
			if IsValid(Entity) and Entity.Scanning then
				return ScanForEntities(Entity)
			end

			TimerRemove("ACF Radar Scan " .. Entity:EntIndex())
		end)
	end
end

local function SetActive(Entity, Active)
	if Entity.Active == Active then return end

	Entity.Active = Active

	Entity:UpdateOverlay()

	if TimerExists("ACF Radar Switch " .. Entity:EntIndex()) then
		TimerRemove("ACF Radar Switch " .. Entity:EntIndex())
	end

	if not Active then return SetScanning(Entity, Active) end

	TimerCreate("ACF Radar Switch " .. Entity:EntIndex(), Entity.SwitchDelay, 1, function()
		if IsValid(Entity) then
			return SetScanning(Entity, Active)
		end
	end)
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

--===============================================================================================--

function MakeACF_Radar(Owner, Pos, Angle, Id)
	if not Owner:CheckLimit("_acf_radar") then return false end

	local RadarData = ACF.Weapons.Radar[Id]

	if not RadarData then return end

	local Radar = ents.Create("acf_radar")

	if not IsValid(Radar) then return end

	local RadarClass = ACF.Classes.Radar[RadarData.class]
	local OriginAttach = Radar:LookupAttachment(RadarData.origin)
	local AttachData = Radar:GetAttachment(OriginAttach)

	Radar:SetModel(RadarData.model)
	Radar:SetPlayer(Owner)
	Radar:SetAngles(Angle)
	Radar:SetPos(Pos)
	Radar:Spawn()

	Radar:PhysicsInit(SOLID_VPHYSICS)
	Radar:SetMoveType(MOVETYPE_VPHYSICS)

	Owner:AddCount("_acf_radar", Radar)
	Owner:AddCleanup("acfmenu", Radar)

	Radar.Id			= Id
	Radar.Owner			= Owner
	Radar.Model			= RadarData.model
	Radar.Mass			= RadarData.weight
	Radar.Name			= RadarData.name
	Radar.ShortName		= Radar.Name
	Radar.EntType 		= RadarClass.name
	Radar.ClassType		= RadarClass.type
	Radar.ConeDegs		= RadarData.viewcone
	Radar.Range 		= RadarData.range
	Radar.Armor			= 20

	Radar.Active		= false
	Radar.Scanning		= false
	Radar.SwitchDelay	= RadarData.delay
	Radar.ThinkDelay	= 0.1
	Radar.TargetCount	= 0
	Radar.Spread		= 0
	Radar.Weapons		= {}
	Radar.Targets		= {}

	Radar.Inputs		= WireLib.CreateInputs(Radar, { "Active" })
	Radar.Outputs		= WireLib.CreateOutputs(Radar, { "Scanning", "Detected", "ClosestDistance", "Entities [ARRAY]", "Position [ARRAY]", "Velocity [ARRAY]" })
	Radar.GetDetected	= RadarClass.detect
	Radar.Origin		= AttachData and Radar:WorldToLocal(AttachData.Pos) or Vector()

	Radar:SetNWString("WireName", Radar.Name)

	local PhysObj = Radar:GetPhysicsObject()

	if IsValid(PhysObj) then
		PhysObj:SetMass(Radar.Mass)
	end

	ACF_Activate(Radar)

	Radar.ACF.Model		= Radar.Model
	Radar.ACF.LegalMass	= Radar.Mass

	Radar:UpdateOverlay(true)

	CheckLegal(Radar)

	TimerCreate("ACF Radar Clock " .. Radar:EntIndex(), 3, 0, function()
		if IsValid(Radar) then
			CheckDistantLinks(Radar, "Weapons")
		else
			timer.Remove("ACF Radar Clock " .. Radar:EntIndex())
		end
	end)

	return Radar
end

-- Backwards compatibility
list.Set("ACFCvars", "acf_missileradar", {"id"})
duplicator.RegisterEntityClass("acf_missileradar", MakeACF_Radar, "Pos", "Angle", "Id")

list.Set("ACFCvars", "acf_radar", {"id"})
duplicator.RegisterEntityClass("acf_radar", MakeACF_Radar, "Pos", "Angle", "Id")
ACF.RegisterLinkSource("acf_radar", "Weapons")

--===============================================================================================--
-- Meta Funcs
--===============================================================================================--

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

function ENT:Link(Target)
	if not IsValid(Target) then return false, "Attempted to link an invalid entity." end
	if self == Target then return false, "Can't link a radar to itself." end

	local Function = ClassLink("acf_radar", Target:GetClass())

	if Function then
		return Function(self, Target)
	end

	return false, "Radars can't be linked to '" .. Target:GetClass() .. "'."
end

function ENT:Unlink(Target)
	if not IsValid(Target) then return false, "Attempted to unlink an invalid entity." end
	if self == Target then return false, "Can't unlink a radar from itself." end

	local Function = ClassUnlink("acf_radar", Target:GetClass())

	if Function then
		return Function(self, Target)
	end

	return false, "Radars can't be unlinked from '" .. Target:GetClass() .. "'."
end

function ENT:TriggerInput(_, Value)
	if self.Disabled then return end

	SetActive(self, tobool(Value))
end

function ENT:Enable()
	if not CheckLegal(self) then return end

	self.Disabled		= nil
	self.DisableReason	= nil

	if self.Inputs.Active.Path then
		self:TriggerInput("Active", self.Inputs.Active.Value)
	end

	self:UpdateOverlay()
end

function ENT:Disable()
	self:TriggerInput("Active", 0)

	self.Disabled = true
end

function ENT:UpdateOverlay(Instant)
	if Instant then
		return Overlay(self)
	end

	if TimerExists("ACF Overlay Buffer" .. self:EntIndex()) then return end

	TimerCreate("ACF Overlay Buffer" .. self:EntIndex(), 1, 1, function()
		if IsValid(self) then Overlay(self) end
	end)
end

function ENT:OnRemove()
	for Weapon in pairs(self.Weapons) do
		self:Unlink(Weapon)
	end

	if Radars[self] then
		Radars[self] = nil
	end

	WireLib.Remove(self)
end
