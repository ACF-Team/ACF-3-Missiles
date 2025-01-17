local ACF             = ACF
local Clock           = ACF.Utilities.Clock
local Contraption     = ACF.Contraption
local Countermeasures = ACF.Classes.Countermeasures
local NextUpdate      = 0
local Entities        = {}
local Ancestors       = {}

local Whitelist  = {
	-- Garry's Mod entities
	gmod_wheel                 = true,
	gmod_hoverball             = true,
	gmod_thruster              = true,
	gmod_light                 = true,
	gmod_emitter               = true,
	gmod_button                = true,
	phys_magnet                = true,
	-- Wiremod entities
	gmod_wire_cameracontroller = true,
	gmod_wire_expression2      = true,
	gmod_wire_egp_hud          = true,
	gmod_wire_eyepod           = true,
	gmod_wire_gate             = true,
	gmod_wire_light            = true,
	gmod_wire_pod              = true,
	gmod_wire_thruster         = true,
	-- Starfall entities
	starfall_hud               = true,
	starfall_processor         = true,
	starfall_screen            = true,
	-- ACF entities
	acf_ammo                   = true,
	acf_computer               = true,
	acf_engine                 = true,
	acf_fueltank               = true,
	acf_gearbox                = true,
	acf_gun                    = true,
	acf_rack                   = true,
	acf_radar                  = true,
	-- I shouldn't have to explain this
	player                     = true,
}

local function GetAncestor(Entity)
	local Ancestor = Contraption.GetAncestor(Entity)

	if not IsValid(Ancestor) then return end
	if Ancestor == Entity then return end
	if Ancestor.DoNotTrack then return end

	return Ancestor
end

local function UpdateValues(Entity)
	if not IsValid(Entity) then return end

	local PhysObj  = Entity:GetPhysicsObject()
	local Velocity = Entity:GetVelocity()
	local PrevPos  = Entity.Position
	local Position

	if IsValid(PhysObj) then
		Position = Entity:LocalToWorld(PhysObj:GetMassCenter())
	else
		Position = Entity:GetPos()
	end

	-- Entities being moved around by SetPos will have a velocity of 0
	-- By using the difference between positions we can get a proper value
	if Velocity:LengthSqr() == 0 and PrevPos then
		Velocity = (Position - PrevPos) / Clock.DeltaTime
	end

	Entity.Position = Position
	Entity.Velocity = Velocity
end

hook.Add("OnEntityCreated", "ACF Entity Tracking", function(Entity)
	if not IsValid(Entity) then return end
	if not Whitelist[Entity:GetClass()] then return end

	Entities[Entity] = true

	Entity:CallOnRemove("ACF Entity Tracking", function()
		Entities[Entity] = nil
	end)
end)

hook.Add("PlayerSpawnedVehicle", "ACF Entity Tracking", function(_, Entity)
	if not IsValid(Entity) then return end

	Entities[Entity] = true

	Entity:CallOnRemove("ACF Entity Tracking", function()
		Entities[Entity] = nil
	end)
end)

hook.Add("ACF_OnTick", "ACF Entity Tracking", function()
	for Ancestor in pairs(Ancestors) do
		UpdateValues(Ancestor)
	end
end)

local function GetAncestorEntities()
	if Clock.CurTime < NextUpdate then return Ancestors end

	local Previous = {}
	local Checked  = {}

	for K in pairs(Ancestors) do Previous[K] = true end

	for K in pairs(Entities) do
		local Ancestor = GetAncestor(K)

		if Ancestor and not Checked[Ancestor] then
			if not Ancestors[Ancestor] then
				UpdateValues(Ancestor)

				Ancestors[Ancestor] = true

				Ancestor:CallOnRemove("ACF Ancestor Tracking", function()
					Ancestors[Ancestor] = nil
				end)
			end

			Previous[Ancestor] = nil
			Checked[Ancestor] = true
		end
	end

	for K in pairs(Previous) do
		Ancestors[K] = nil

		K.Position = nil
		K.Velocity = nil

		K:RemoveCallOnRemove("ACF Ancestor Tracking")
	end

	NextUpdate = Clock.CurTime + math.Rand(3, 5)

	return Ancestors
end

function ACF.GetEntitiesInCone(Position, Direction, Degrees)
	local Result = {}

	for Entity in pairs(GetAncestorEntities()) do
		if not IsValid(Entity) then continue end

		if Countermeasures.ConeContainsPos(Position, Direction, Degrees, Entity:GetPos()) then
			Result[Entity] = true
		end
	end

	return Result
end

function ACF.GetEntitiesInSphere(Position, Radius)
	local Result = {}
	local RadiusSqr = Radius * Radius

	for Entity in pairs(GetAncestorEntities()) do
		if not IsValid(Entity) then continue end

		if Position:DistToSqr(Entity:GetPos()) <= RadiusSqr then
			Result[Entity] = true
		end
	end

	return Result
end
