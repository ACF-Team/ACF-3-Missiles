



local Overrides =
{
	FLR = function(Effect, Bullet)
		local Position = Bullet.SimPos

		if math.abs(Position.x) > 16000 or math.abs(Position.y) > 16000 or Position.z < -16000 then
			Effect.Kill = true

			return
		end

		if Position.z < 16000 then
			Effect:SetPos(Position) --Moving the effect to the calculated position
			Effect:SetAngles(Bullet.SimFlight:Angle())
		end

		if IsValid(Bullet.Tracer) then
			Bullet.Tracer:Finish()
		end

		local Time = CurTime()
		local CutoutTime = Time - 1

		if not Effect.FlareCutout then
			local FlareArea = 3.1416 * (Bullet.Caliber * 0.5) * (Bullet.Caliber * 0.5)
			local BurnRate = FlareArea * ACFM.FlareBurnMultiplier
			local Duration = Bullet.FillerMass / BurnRate
			local Jitter = util.SharedRandom("FlareJitter", 0, 0.4, Effect.CreateTime * 10000)

			CutoutTime = Effect.CreateTime + Duration + Jitter

			if Effect.FlareEffect then
				ACFM_RenderLight(Effect.Index, 1024, nil, Position)
			end
		end

		if not Effect.FlareEffect and Time < CutoutTime then
			if not Effect.FlareCutout then
				ParticleEffectAttach( "acfm_flare", PATTACH_ABSORIGIN_FOLLOW, Effect, 0 )
				Effect.FlareEffect = true
			end
		elseif not Effect.FlareCutout and Time >= CutoutTime then
			Effect:StopParticles()
			Effect.FlareCutout = true
		end
	end
}

hook.Add("ACF_BulletEffect", "ACF Missiles Custom Effects", function(AmmoType)
	local Custom = Overrides[AmmoType]

	if Custom then
		return Custom
	end
end)

function ACFM_CanEmitLight(lightSize)
	local minLightSize = GetConVar("ACFM_MissileLights"):GetFloat()

	if minLightSize == 0 then return false end
	if minLightSize == 1 then return true end

	return minLightSize < lightSize
end

function ACFM_RenderLight(idx, lightSize, colour, pos)
	if not ACFM_CanEmitLight(lightSize) then return end

	local dlight = DynamicLight( idx )

	if dlight then
		local size = lightSize
		local c = colour or Color(255, 128, 48)

		dlight.Pos = pos
		dlight.r = c.r
		dlight.g = c.g
		dlight.b = c.b
		dlight.Brightness = 2 + math.random() * 1
		dlight.Decay = size * 15
		dlight.Size = size * 0.66 + math.random() * (size * 0.33)
		dlight.DieTime = CurTime() + 1
	end
end
