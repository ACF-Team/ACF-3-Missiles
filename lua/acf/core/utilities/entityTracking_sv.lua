local ACF        = ACF
local Clock      = ACF.Utilities.Clock
local NextUpdate = 0
local Entities   = {}
local Ancestors  = {}

local Whitelist = {
	-- Garry's Mod entities
	gmod_wheel                 = true,
	gmod_hoverball             = true,
	gmod_thruster              = true,
	gmod_light                 = true,
	gmod_emitter               = true,
	gmod_button                = true,
	phys_magnet                = true,
	-- Vehicle entities
	prop_vehicle_jeep          = true,
	prop_vehicle_airboat       = true,
	prop_vehicle_prisoner_pod  = true,
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
}

local function GetAncestor(Entity)
	local Ancestor = ACF_GetAncestor(Entity)

	if not IsValid(Ancestor) then return end
	if Ancestor == Entity then return end
	if Ancestor.DoNotTrack then return end

	return Ancestor
end

local function GetPosition(Entity)
	local PhysObj = Entity:GetPhysicsObject()

	if not IsValid(PhysObj) then return Entity:GetPos() end

	return Entity:LocalToWorld(PhysObj:GetMassCenter())
end

hook.Add("OnEntityCreated", "ACF Entity Tracking", function(Entity)
	if IsValid(Entity) and Whitelist[Entity:GetClass()] then
		Entities[Entity] = true

		Entity:CallOnRemove("ACF Entity Tracking", function()
			Entities[Entity] = nil
		end)
	end
end)

hook.Add("ACF_OnClock", "ACF Entity Tracking", function(_, DeltaTime)
	for K in pairs(Ancestors) do
		local Previous = K.Position
		local Current  = GetPosition(K)

		K.Position = Current
		K.Velocity = (Current - Previous) / DeltaTime
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
				Ancestor.Position = GetPosition(Ancestor)
				Ancestor.Velocity = Vector()

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

		if ACFM_ConeContainsPos(Position, Direction, Degrees, Entity:GetPos()) then
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
