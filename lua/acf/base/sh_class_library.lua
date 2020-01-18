
local Classes = {}
local Queued = {}
local Loaded = {}

local function CreateInstance(Class)
	local New = {}

	setmetatable(New, { __index = Class })

	if New.OnCalled then
		New:OnCalled()
	end

	return New
end

local function QueueBaseClass(Name, Base)
	if not Queued[Base] then
		Queued[Base] = { [Name] = true }
	else
		Queued[Base][Name] = true
	end
end

local function AttachMetaTable(Class, Name, Base)
	local OldMeta = getmetatable(Class) or {}

	if Base then
		local BaseClass = Classes[Base]

		if BaseClass then
			Class.BaseClass = BaseClass
			OldMeta.__index = BaseClass
		else
			QueueBaseClass(Name, Base)
		end
	end

	OldMeta.__call = function()
		return CreateInstance(Class)
	end

	setmetatable(Class, OldMeta)

	Loaded[Class] = true
end

local function RegisterClass(Name, Base, Destiny)
	if not Classes[Name] then
		Classes[Name] = {}
	end

	local Class = Classes[Name]
	Class.Name = Name

	AttachMetaTable(Class, Name, Base)

	if Queued[Name] then
		local Current

		for K in pairs(Queued[Name]) do
			Current = Classes[K]

			AttachMetaTable(Current, Current.Name, Name)
		end

		Queued[Name] = nil
	end

	if Destiny then
		Destiny[Name] = Class
	end

	return Class
end

function ACF.RegisterFuse(Name, Base)
	return RegisterClass(Name, Base, ACF.Fuse)
end

function ACF.RegisterGuidance(Name, Base)
	return RegisterClass(Name, Base, ACF.Guidance)
end

function ACF.RegisterCountermeasure(Name, Base)
	return RegisterClass(Name, Base, ACF.Countermeasure)
end

ACF.RegisterClass = RegisterClass

hook.Add("Initialize", "ACF Init Classes", function()
	for K in pairs(Loaded) do
		if K.OnLoaded then
			K:OnLoaded()
		end
	end

	Loaded = nil

	hook.Remove("Initialize", "ACF Init Classes")
end)