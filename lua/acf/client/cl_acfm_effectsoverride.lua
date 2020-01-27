



local Overrides =
{
	FLR = function(self, Bullet)
		local setPos = Bullet.SimPos

		if math.abs(setPos.x) > 16000 or math.abs(setPos.y) > 16000 or setPos.z < -16000 then
			self:Remove()

			return
		end

		if setPos.z < 16000 then
			self:SetPos(setPos) --Moving the effect to the calculated position
			self:SetAngles(Bullet.SimFlight:Angle())
		end

		if Bullet.Tracer then
			Bullet.Tracer:Finish()
			Bullet.Tracer = nil
		end

		local curtime = CurTime()
		local cutoutTime = curtime - 1

		if not self.FlareCutout then
			local frArea = 3.1416 * (Bullet.Caliber * 0.5) * (Bullet.Caliber * 0.5)
			local burnRate = frArea * ACFM.FlareBurnMultiplier
			local burnDuration = Bullet.FillerMass / burnRate

			local jitter = util.SharedRandom( "FlareJitter", 0, 0.4, self.CreateTime * 10000 )

			cutoutTime = self.CreateTime + burnDuration + jitter

			if self.FlareEffect then
				ACFM_RenderLight(self.Index, 1024, nil, setPos)
			end
		end

		if not self.FlareEffect and curtime < cutoutTime then
			if not self.FlareCutout then
				ParticleEffectAttach( "acfm_flare", PATTACH_ABSORIGIN_FOLLOW, self, 0 )
				self.FlareEffect = true
			end
		elseif not self.FlareCutout and curtime >= cutoutTime then
			self:StopParticles()
			self.FlareCutout = true
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
