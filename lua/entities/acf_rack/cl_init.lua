-- cl_init.lua

include ("shared.lua")

local function GetOverlayText(Entity)
	local WireName	= Entity:GetNWString("WireName")
	local GunType	= Entity:GetNWString("GunType")
	local Ammo		= Entity:GetNWInt("Ammo")
	local FireRate	= math.Round(Entity:GetNWFloat("Interval"), 2)
	local Reload	= math.Round(Entity:GetNWFloat("Reload"), 2)
	local Bonus		= math.floor(Entity:GetNWFloat("ReloadBonus") * 100)
	local Status	= Entity:GetNWString("Status")

	local Text = (WireName ~= "" and "- " .. WireName .. " -\n" or "") ..
				GunType .. " (" .. Ammo .. " left) \n" ..
				"Fire interval: " .. FireRate .. " sec\n" ..
				"Reload interval: " .. Reload .. " sec" .. (Bonus > 0 and (" (-" .. Bonus .. "%)") or "") ..
				((Status and Status ~= "") and ("\n - " .. Status .. " - ") or "")

	if CPPI and not game.SinglePlayer() then
		local Owner = Entity:CPPIGetOwner()

		if IsValid(Owner) then
			Text = Text .. "\n(" .. Owner:GetName() .. ")"
		end
	end

	return Text
end

local function DrawWorldTip(Entity)
	if Entity ~= LocalPlayer():GetEyeTrace().Entity then return end
	if EyePos():Distance(Entity:GetPos()) > 256 then return end

	AddWorldTip(Entity:EntIndex(), GetOverlayText(Entity), 0.5, Entity:GetPos(), Entity)
end

function ENT:Draw()
	self:DrawModel()

	DrawWorldTip(self)
	Wire_Render(self)
end
