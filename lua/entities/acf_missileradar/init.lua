
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")
include("radar_types_support.lua")

CreateConVar("sbox_max_acf_missileradar", 6)

-------------------------------[[ Local Functions ]]-------------------------------

local function IsLegal(Entity)
	if Entity:GetNoDraw() then return false, "Not drawn" end
	if not Entity:IsSolid() then return false, "Not solid" end
	if Entity.ClipData and next(Entity.ClipData) then return false, "Visually clipped" end
	if Entity:GetModel() ~= Entity.Model then return false, "Different model, should be " .. Entity.Model end

	local PhysObj = Entity:GetPhysicsObject()

	if not IsValid(PhysObj) then return false, "Invalid physics object" end
	if PhysObj:GetMass() < Entity.LegalMass then return false, "Underweight, should be " .. Entity.LegalMass .. " kg" end
	if not PhysObj:GetVolume() then return false, "Spherical collisions" end

	return true
end

local function CheckLegal(Entity)
	local Legal, Reason = IsLegal(Entity)

	Entity.DisableReason = Reason

	if not Legal then
		Entity:Disable()
		return false
	end

	timer.Simple(math.Rand(1, 5), function()
		if IsValid(Entity) then
			CheckLegal(Entity)
		end
	end)

	return true
end

local function UpdateStatus(Entity)
	if Entity.Disabled and Entity.DisableReason then
		Entity:SetNWString("Status", "Disabled: " .. Entity.DisableReason)
		return
	end

	if Entity.TargetCount > 0 then
		Entity:SetNWString("Status", Entity.TargetCount .. " target(s) detected!")
		return
	end

	Entity:SetNWString("Status", Entity.Active and "Active" or "Idle")
end

local function ResetOutputs(Entity)
	if Entity.TargetCount == 0 then return end

	Entity.TargetCount = 0

	WireLib.TriggerOutput(Entity, "Detected", 0)
	WireLib.TriggerOutput(Entity, "ClosestDistance", 0)
	WireLib.TriggerOutput(Entity, "Entities", {})
	WireLib.TriggerOutput(Entity, "Position", {})
	WireLib.TriggerOutput(Entity, "Velocity", {})

	UpdateStatus(Entity)
end

local function SetSequence(Entity, Active)
	if Entity.Disabled and Active then return end

	local SequenceName = Active and "active" or "idle"
	local Sequence = Entity:LookupSequence(SequenceName)

	Entity:ResetSequence(Sequence or 0)

	Entity.AutomaticFrameAdvance = Active
end

local function SetActive(Entity, Active)
	Entity.Active = Active

	SetSequence(Entity, Active)
	ResetOutputs(Entity)
	UpdateStatus(Entity)

	ACF.ActiveRadars[Entity] = Active or nil
end

local function HasLineOfSight(From, To, Target, Filter)
	local TraceData = {
		start = From,
		endpos = To,
		mask = MASK_SHOT,
		filter = Filter
	}

	return util.TraceLine(TraceData).Entity == Target
end

local function ScanForEntities(Entity)
	if not Entity.GetDetected then return end

	local Detected = Entity:GetDetected()
	local Entities = {}
	local Position = {}
	local Velocity = {}
	local Filter = { Entity }

	local Origin = Entity:LocalToWorld(Entity.ScanOrigin)
	local Closest = math.huge
	local Count = 0

	-- If cframe is installed, we can give it a proper filter
	if cframe then
		local FilterEnts = cframe.GetAllEntities(Entity)
		local Index = 0

		for K in pairs(FilterEnts) do
			Index = Index + 1
			Filter[Index] = K
		end
	end

	for _, Ent in ipairs(Detected) do
		if HasLineOfSight(Origin, Ent.CurPos, Ent, Filter) then
			local DistanceSqr = Origin:DistToSqr(Ent.CurPos)

			Count = Count + 1

			Entities[Count] = Ent
			Position[Count] = Ent.CurPos
			Velocity[Count] = Ent.LastVel

			if DistanceSqr < Closest then
				Closest = DistanceSqr
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

		UpdateStatus(Entity)
	end
end

-------------------------------[[ Global Functions ]]-------------------------------

function MakeACF_MissileRadar(Owner, Pos, Angle, Id)
	if not Owner:CheckLimit("_acf_missileradar") then return false end

	local RadarData = ACF.Weapons.Radar[Id]

	if not RadarData then return end

	local Radar = ents.Create("acf_missileradar")

	if not IsValid(Radar) then return end

	local Behavior = ACFM.RadarBehaviour[RadarData.class]

	Radar:SetModel(RadarData.model)
	Radar:SetAngles(Angle)
	Radar:SetPos(Pos)
	Radar:Spawn()

	Radar:PhysicsInit(SOLID_VPHYSICS)
	Radar:SetMoveType(MOVETYPE_VPHYSICS)

	Radar.Id			= Id
	Radar.Model			= RadarData.model
	Radar.LegalMass		= RadarData.weight
	Radar.ACFName		= RadarData.name
	Radar.ConeDegs		= RadarData.viewcone
	Radar.Range 		= RadarData.range
	Radar.Class 		= RadarData.class
	Radar.Owner			= Owner

	Radar.ThinkDelay	= 0.1
	Radar.UpdateDelay	= 0.5
	Radar.LastUpdate	= CurTime()
	Radar.TargetCount	= 0

	Radar.Inputs		= WireLib.CreateInputs(Radar, { "Active" })
	Radar.Outputs		= WireLib.CreateOutputs(Radar, { "Detected", "ClosestDistance", "Entities [ARRAY]", "Position [ARRAY]", "Velocity [ARRAY]" })
	Radar.GetDetected	= Behavior and Behavior.GetDetectedEnts

	local OriginAttach = Radar:LookupAttachment("missile1") -- All radars currently have this attachment
	local AttachData = Radar:GetAttachment(OriginAttach)

	Radar.ScanOrigin = AttachData and Radar:WorldToLocal(AttachData.Pos) or Vector()

	Radar:SetNWString("Name", Radar.ACFName)
	Radar:SetNWFloat("ConeDegs", Radar.ConeDegs)
	Radar:SetNWFloat("Range", Radar.Range)

	Owner:AddCount("_acf_missileradar", Radar)
	Owner:AddCleanup("acfmenu", Radar)

	local PhysObj = Radar:GetPhysicsObject()

	if IsValid(PhysObj) then
		PhysObj:SetMass(Radar.LegalMass)
	end

	CheckLegal(Radar)

	return Radar
end

list.Set("ACFCvars", "acf_missileradar", {"id"})
duplicator.RegisterEntityClass("acf_missileradar", MakeACF_MissileRadar, "Pos", "Angle", "Id")

function ENT:Think()
	if not self.Disabled and self.Active then
		ScanForEntities(self)
	end

	self:NextThink(CurTime() + self.ThinkDelay)

	return true
end

function ENT:TriggerInput(_, Value)
	if self.Disabled then return end

	SetActive(self, tobool(Value))
	CheckLegal(self)
end

function ENT:Enable()
	self.Disabled = nil

	ACF.ActiveRadars[self] = self.Active or nil

	SetSequence(self, self.Active)
	UpdateStatus(self)
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

	SetSequence(self, false)
	ResetOutputs(self)
	UpdateStatus(self)

	ACF.ActiveRadars[self] = nil
end

function ENT:OnRemove()
	if ACF.ActiveRadars[self] then
		ACF.ActiveRadars[self] = nil
	end

	WireLib.Remove(self)
end
