ACFM_RoundDisplayFuncs = ACFM_RoundDisplayFuncs or {}
ACFM_CrateTextFuncs = ACFM_CrateTextFuncs or {}

local function checkIfDataIsMissile(BulletData)
	local class = ACF.Weapons.Guns[BulletData.Id]

	if not (class and class.gunclass) then return end

	class = ACF.Classes.GunClass[class.gunclass]

	return class.type and class.type == "missile"
end

local function configConcat(tbl)
	local toConcat = {}

	for K, V in pairs(tbl) do
		toConcat[#toConcat + 1] = tostring(K) .. ": " .. tostring(V)
	end

	return table.concat(toConcat, "\n")
end

local function ModifyRoundDisplayFuncs()
	for K, V in pairs(ACF.RoundTypes) do
		local OldDisplayData = ACFM_RoundDisplayFuncs[K]

		if not OldDisplayData then
			ACFM_RoundDisplayFuncs[K] = V.getDisplayData
			OldDisplayData = V.getDisplayData
		end

		if OldDisplayData then
			V.getDisplayData = function(BulletData)
				if not checkIfDataIsMissile(BulletData) then
					return OldDisplayData(BulletData)
				end

				-- NOTE: if these replacements cause side-effects somehow, move to a masking-metatable approach

				local MuzzleVel = BulletData.MuzzleVel

				BulletData.MuzzleVel = 0
				BulletData.SlugPenMul = ACF_GetGunValue(BulletData.Id, "penmul")

				local DisplayData = OldDisplayData(BulletData)

				BulletData.MuzzleVel = MuzzleVel

				return DisplayData
			end
		end
	end
end

local function ModifyCrateTextFuncs()
	for K, V in pairs(ACF.RoundTypes) do
		local OldCrateText = ACFM_CrateTextFuncs[K]

		if not OldCrateText then
			ACFM_CrateTextFuncs[K] = V.cratetxt
			OldCrateText = V.cratetxt
		end

		if OldCrateText then
			V.cratetxt = function(BulletData)
				local CrateText = OldCrateText(BulletData)

				if not checkIfDataIsMissile(BulletData) then
					return CrateText
				end

				local Crate = Entity(BulletData.Crate)
				local Display = "\n\n%s %s\n%s"
				local Guidance, Fuse, Text

				if IsValid(Crate) then
					Guidance = Crate.RoundData7 or BulletData.Data7
					Fuse = Crate.RoundData8 or BulletData.Data8
				end

				if Guidance then
					Guidance = ACFM_CreateConfigurable(Guidance, ACF.Guidance, nil, "Guidance")

					if Guidance and Guidance.Name ~= "Dumb" then
						Guidance:Configure(Crate)

						Text = configConcat(Guidance:GetDisplayConfig())
						CrateText = CrateText .. Display:format(Guidance.Name, "guidance", Text)
					end
				end

				if Fuse then
					Fuse = ACFM_CreateConfigurable(Fuse, ACF.Fuse, nil, "fuses")

					if Fuse then
						Fuse:Configure(Crate)

						Text = configConcat(Fuse:GetDisplayConfig())
						CrateText = CrateText .. Display:format(Fuse.Name, "fuse", Text)
					end
				end

				return CrateText
			end
		end
	end
end

local function ModifyRoundBaseGunpowder()
	local oldGunpowder = ACFM_ModifiedRoundBaseGunpowder and oldGunpowder or ACF_RoundBaseGunpowder

	ACF_RoundBaseGunpowder = function(PlayerData, Data, ServerData, GUIData)
		PlayerData, Data, ServerData, GUIData = oldGunpowder(PlayerData, Data, ServerData, GUIData)

		Data.Id = PlayerData.Id

		return PlayerData, Data, ServerData, GUIData
	end

	ACFM_ModifiedRoundBaseGunpowder = true
end

timer.Simple(1, function()
	ModifyRoundBaseGunpowder()
	ModifyRoundDisplayFuncs()
	ModifyCrateTextFuncs()
end)
