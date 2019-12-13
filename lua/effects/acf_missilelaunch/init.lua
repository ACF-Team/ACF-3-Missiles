
/*---------------------------------------------------------
	Initializes the effect. The data is a table of data
	which was passed from the server.
 ---------------------------------------------------------*/
function EFFECT:Init( data )

	local Gun = data:GetEntity()
	local Sound = Gun:GetNWString( "Sound" )
	local Propellant = data:GetScale()
	local Attachment = data:GetAttachment()

	local Class = Gun:GetNWString( "Class" )

	if CLIENT and not IsValidSound( Sound ) then
		Sound = ACF.Classes["GunClass"][Class]["sound"]
	end

	if Gun:IsValid() and Propellant > 0 then
		local SoundPressure = (Propellant * 1000) ^ 0.5

		sound.Play(Sound, Gun:GetPos(), math.Clamp(SoundPressure, 75, 127), 100) --wiki documents level tops out at 180, but seems to fall off past 127

		if not ((Class == "MG") or (Class == "RAC")) then
			sound.Play( Sound, Gun:GetPos() , math.Clamp(SoundPressure,75,127), 100)

			if SoundPressure > 127 then
				sound.Play( Sound, Gun:GetPos() , math.Clamp(SoundPressure-127,1,127), 100)
			end
		end

		local Muzzle = Gun:GetAttachment( Attachment ) or { Pos = Gun:GetPos(), Ang = Gun:GetAngles() }
		Muzzle.Ang = (-Muzzle.Ang:Forward()):Angle()

		ParticleEffect( ACF.Classes["GunClass"][Class]["muzzleflash"], Muzzle.Pos, Muzzle.Ang, Gun )
	end
end


/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think( )
	return false
end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render()
end
