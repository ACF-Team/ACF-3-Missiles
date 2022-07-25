
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local ACF = ACF

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
local UnlinkSound = "physics/metal/metal_box_impact_bullet%s.wav"
local MaxDistance = ACF.LinkDistance * ACF.LinkDistance
local TraceData	  = { start = true, endpos = true, mask = MASK_SOLID_BRUSHONLY }
local Indexes	  = {}
local Unused	  = {}
local IndexCount  = 0
local TraceLine	  = util.TraceLine
local TimerExists = timer.Exists
local TimerCreate = timer.Create
local TimerRemove = timer.Remove
local HookRun     = hook.Run

-- TODO: Optimize this so the entries are only cleared when the target is no longer detected by the radar
local function ClearTargets(Entity)
	local TargetInfo = Entity.TargetInfo
	local Targets = Entity.Targets

	for Target in pairs(Targets) do
		Targets[Target] = nil
	end

	for _, List in pairs(TargetInfo) do
		for Index in ipairs(List) do
			List[Index] = nil
		end
	end
end

local function ResetOutputs(Entity)
	if Entity.TargetCount == 0 then return end

	local TargetInfo = Entity.TargetInfo

	ClearTargets(Entity)

	Entity.TargetCount = 0

	WireLib.TriggerOutput(Entity, "Detected", 0)
	WireLib.TriggerOutput(Entity, "ClosestDistance", 0)
	WireLib.TriggerOutput(Entity, "IDs", TargetInfo.ID)
	WireLib.TriggerOutput(Entity, "Owner", TargetInfo.Owner)
	WireLib.TriggerOutput(Entity, "Position", TargetInfo.Position)
	WireLib.TriggerOutput(Entity, "Velocity", TargetInfo.Velocity)
	WireLib.TriggerOutput(Entity, "Distance", TargetInfo.Distance)
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

local function GetEntityIndex(Entity)
	if Indexes[Entity] then return Indexes[Entity] end

	if next(Unused) then
		local Index = next(Unused)

		Indexes[Entity] = Index
		Unused[Index] = nil
	else
		IndexCount = IndexCount + 1

		Indexes[Entity] = IndexCount
	end

	local EntID = Indexes[Entity]

	Entity:CallOnRemove("Radar Index", function()
		Indexes[Entity] = nil
		Unused[EntID] = true
	end)

	return EntID
end

local function GetEntityOwner(Owner, Entity)
	-- If the server is competitive and the radar owner doesn't has permissions on this entity then return Unknown
	if ACF.Gamemode == 3 and not Entity:CPPICanTool(Owner) then
		return "Unknown"
	end

	local EntOwner = Entity:CPPIGetOwner()

	if not IsValid(EntOwner) then
		EntOwner = EntOwner == game.GetWorld() and "World" or "Unknown"
	else
		EntOwner = EntOwner:GetName()
	end

	return EntOwner
end

local function ScanForEntities(Entity)
	ClearTargets(Entity)

	if not Entity.GetDetected then return end

	local Detected = Entity:GetDetected()

	local Origin = Entity:LocalToWorld(Entity.Origin)
	local TargetInfo = Entity.TargetInfo
	local Targets = Entity.Targets
	local Closest = math.huge
	local Count = 0

	local IDs = TargetInfo.ID
	local Own = TargetInfo.Owner
	local Position = TargetInfo.Position
	local Velocity = TargetInfo.Velocity
	local Distance = TargetInfo.Distance

	for Ent in pairs(Detected) do
		local EntPos = Ent.Position or Ent:GetPos()

		if CheckLOS(Origin, EntPos) then
			local Spread = VectorRand(-Entity.Spread, Entity.Spread)
			local EntVel = Ent.Velocity or Ent:GetVelocity()
			local Owner = GetEntityOwner(Entity.Owner, Ent)
			local Index = GetEntityIndex(Ent)

			EntPos = EntPos + Spread
			EntVel = EntVel + Spread
			Count = Count + 1

			local EntDist = Origin:Distance(EntPos)

			Targets[Ent] = {
				Index = Index,
				Owner = Owner,
				Position = EntPos,
				Velocity = EntVel,
				Distance = EntDist,
				Spread   = Spread,
			}

			IDs[Count] = Index
			Own[Count] = Owner
			Position[Count] = EntPos
			Velocity[Count] = EntVel
			Distance[Count] = EntDist

			if EntDist < Closest then
				Closest = EntDist
			end
		end
	end

	Closest = Closest < math.huge and Closest or 0

	WireLib.TriggerOutput(Entity, "ClosestDistance", Closest)
	WireLib.TriggerOutput(Entity, "IDs", IDs)
	WireLib.TriggerOutput(Entity, "Owner", Own)
	WireLib.TriggerOutput(Entity, "Position", Position)
	WireLib.TriggerOutput(Entity, "Velocity", Velocity)
	WireLib.TriggerOutput(Entity, "Distance", Distance)
	WireLib.TriggerOutput(Entity, "Detected", Count)

	if Count ~= Entity.TargetCount then
		if Count > Entity.TargetCount then
			Entity:EmitSound(Entity.SoundPath, 70, 100, ACF.Volume)
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
			local Sound = UnlinkSound:format(math.random(1, 3))

			Entity:EmitSound(Sound, 70, 100, ACF.Volume)
			Link:EmitSound(Sound, 70, 100, ACF.Volume)

			Entity:Unlink(Link)
		end
	end
end

ACF.AddInputAction("acf_radar", "Active", function(Entity, Value)
	SetActive(Entity, tobool(Value))
end)

--===============================================================================================--

do -- Spawn and Update functions
	local Classes  = ACF.Classes
	local WireIO   = ACF.Utilities.WireIO
	local Entities = Classes.Entities
	local Sensors  = Classes.Sensors
	local Inputs   = { "Active (If set to a non-zero value, attempts to start the radar activation.)" }

	local Outputs = {
		"Scanning (Returns 1 if the radar is currently scanning.)",
		"Detected (Returns the amount of targets detected by the radar.)",
		"ClosestDistance (Returns the distance in inches of the closest target detected by the radar.)",
		"IDs (Returns a list of IDs from all the detected targets.) [ARRAY]",
		"Owner (Returns a list of owner names from all the detected targets.) [ARRAY]",
		"Position (Returns a list of position vectors from all the detected targets.) [ARRAY]",
		"Velocity (Returns a list of velocity vectors from all the detected targets.) [ARRAY]",
		"Distance (Returns a list of distances from all the detected targets.) [ARRAY]",
		"Think Delay (Returns the amount of time in seconds between each scan.)",
		"Entity (The radar itself.) [ENTITY]"
	}

	local function VerifyData(Data)
		if not Data.Radar then
			Data.Radar = Data.Sensor or Data.Id
		end

		local Class = Classes.GetGroup(Sensors, Data.Radar)

		if not Class or Class.Entity ~= "acf_radar" then
			Data.Radar = "SmallDIR-TGT"

			Class = Classes.GetGroup(Sensors, "SmallDIR-TGT")
		end

		do -- External verifications
			if Class.VerifyData then
				Class.VerifyData(Data, Class)
			end

			HookRun("ACF_VerifyData", "acf_radar", Data, Class)
		end
	end

	local function UpdateRadar(Entity, Data, Class, Radar)
		local Tick  = engine.TickInterval()
		local Delay = Radar.ThinkDelay

		Entity.ACF = Entity.ACF or {}
		Entity.ACF.Model = Radar.Model -- Must be set before changing model

		Entity:SetModel(Radar.Model)

		Entity:PhysicsInit(SOLID_VPHYSICS)
		Entity:SetMoveType(MOVETYPE_VPHYSICS)

		local OriginAttach = Entity:LookupAttachment(Radar.Origin)
		local AttachData = Entity:GetAttachment(OriginAttach)

		-- Storing all the relevant information on the entity for duping
		for _, V in ipairs(Entity.DataStore) do
			Entity[V] = Data[V]
		end

		Entity.Name         = Radar.Name
		Entity.ShortName    = Radar.Name
		Entity.EntType      = Class.Name
		Entity.ClassType    = Class.ID
		Entity.ClassData    = Class
		Entity.SoundPath    = Class.Sound or ACF.DefaultRadarSound
		Entity.DefaultSound = Entity.SoundPath
		Entity.ConeDegs     = Radar.ViewCone
		Entity.Range        = Radar.Range
		Entity.SwitchDelay  = Radar.SwitchDelay
		Entity.ThinkDelay   = math.Round(Delay / Tick) * Tick -- Uses a timer, so has to be tied to CurTime/tickrate
		Entity.GetDetected  = Radar.Detect or Class.Detect
		Entity.Origin       = AttachData and Entity:WorldToLocal(AttachData.Pos) or Vector()

		WireIO.SetupInputs(Entity, Inputs, Data, Class, Radar)
		WireIO.SetupOutputs(Entity, Outputs, Data, Class, Radar)

		Entity:SetNWString("WireName", "ACF " .. Entity.Name)

		WireLib.TriggerOutput(Entity, "Think Delay", Entity.ThinkDelay)

		ACF.Activate(Entity, true)

		Entity.ACF.Model		= Radar.Model
		Entity.ACF.LegalMass	= Radar.Mass

		local Phys = Entity:GetPhysicsObject()
		if IsValid(Phys) then Phys:SetMass(Radar.Mass) end
	end

	function MakeACF_Radar(Player, Pos, Angle, Data)
		VerifyData(Data)

		local Class = Classes.GetGroup(Sensors, Data.Radar)
		local RadarData = Class.Lookup[Data.Radar]
		local Limit = Class.LimitConVar.Name

		if not Player:CheckLimit(Limit) then return false end

		local Radar = ents.Create("acf_radar")

		if not IsValid(Radar) then return end

		Radar:SetPlayer(Player)
		Radar:SetAngles(Angle)
		Radar:SetPos(Pos)
		Radar:Spawn()

		Player:AddCleanup("acf_radar", Radar)
		Player:AddCount(Limit, Radar)

		Radar.Owner       = Player -- MUST be stored on ent for PP
		Radar.Active      = false
		Radar.Scanning    = false
		Radar.TargetCount = 0
		Radar.Spread      = 0
		Radar.Weapons     = {}
		Radar.Targets     = {}
		Radar.DataStore   = Entities.GetArguments("acf_radar")
		Radar.TargetInfo  = {
			ID = {},
			Owner = {},
			Position = {},
			Velocity = {},
			Distance = {}
		}

		UpdateRadar(Radar, Data, Class, RadarData)

		if Class.OnSpawn then
			Class.OnSpawn(Radar, Data, Class, RadarData)
		end

		HookRun("ACF_OnEntitySpawn", "acf_radar", Radar, Data, Class, RadarData)

		WireLib.TriggerOutput(Radar, "Entity", Radar)

		Radar:UpdateOverlay(true)

		do -- Mass entity mod removal
			local EntMods = Data and Data.EntityMods

			if EntMods and EntMods.mass then
				EntMods.mass = nil
			end
		end

		CheckLegal(Radar)

		TimerCreate("ACF Radar Clock " .. Radar:EntIndex(), 3, 0, function()
			if not IsValid(Radar) then return end

			CheckDistantLinks(Radar, "Weapons")
		end)

		return Radar
	end

	Entities.Register("acf_missileradar", MakeACF_Radar, "Radar") -- Backwards compatibility
	Entities.Register("acf_radar", MakeACF_Radar, "Radar")

	ACF.RegisterLinkSource("acf_radar", "Weapons")

	------------------- Updating ---------------------

	function ENT:Update(Data)
		if self.Active then return false, "Turn off the radar before updating it!" end

		VerifyData(Data)

		local Class    = Classes.GetGroup(Sensors, Data.Radar)
		local Radar    = Class.Lookup[Data.Radar]
		local OldClass = self.ClassData

		if OldClass.OnLast then
			OldClass.OnLast(self, OldClass)
		end

		HookRun("ACF_OnEntityLast", "acf_radar", self, OldClass)

		ACF.SaveEntity(self)

		UpdateRadar(self, Data, Class, Radar)

		ACF.RestoreEntity(self)

		if Class.OnUpdate then
			Class.OnUpdate(self, Data, Class, Radar)
		end

		HookRun("ACF_OnEntityUpdate", "acf_radar", self, Data, Class, Radar)

		self:UpdateOverlay(true)

		net.Start("ACF_UpdateEntity")
			net.WriteEntity(self)
		net.Broadcast()

		return true, "Radar updated successfully!"
	end
end

--===============================================================================================--
-- Meta Funcs
--===============================================================================================--

function ENT:ACF_OnDamage(Bullet, Trace)
	local HitRes = ACF.PropDamage(Bullet, Trace)

	self.Spread = ACF.MaxDamageInaccuracy * (1 - math.Round(self.ACF.Health / self.ACF.MaxHealth, 2))

	return HitRes
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

local Text = "%s\n\n%s\nDetection range: %s\nScanning angle: %s degrees"

function ENT:UpdateOverlayText()
	local Status, Range, Cone

	if self.TargetCount > 0 then
		Status = self.TargetCount .. " target(s) detected"
	elseif not self.Active then
		Status = "Idle"
	else
		Status = self.Scanning and "Active" or "Activating"
	end

	Range = self.Range and math.Round(self.Range / 39.37 , 2) .. " meters" or "Infinite"
	Cone = self.ConeDegs and math.Round(self.ConeDegs, 2) or 360

	return Text:format(Status, self.EntType, Range, Cone)
end

function ENT:OnRemove()
	local OldClass = self.ClassData

	if OldClass.OnLast then
		OldClass.OnLast(self, OldClass)
	end

	HookRun("ACF_OnEntityLast", "acf_radar", self, OldClass)

	for Weapon in pairs(self.Weapons) do
		self:Unlink(Weapon)
	end

	if Radars[self] then
		Radars[self] = nil
	end

	timer.Remove("ACF Radar Clock " .. self:EntIndex())

	WireLib.Remove(self)
end
