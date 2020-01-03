include ("shared.lua")

function GetOverlayText(Entity)
	local Text		= Entity:GetNWString("Name", "")
	local Degrees	= Entity:GetNWFloat("ConeDegs", 0) * 2
	local Range		= Entity:GetNWFloat("Range", 0)
	local Status	= Entity:GetNWString("Status", "")

	if Degrees > 0 then
		Text = Text .. "\nScanning angle: " .. math.Round(Degrees, 2) .. " deg"
	end

	if Range > 0 then
		Text = Text .. "\nDetection range: " .. math.Round(Range / 39.37 , 2) .. " m"
	end

	if Status ~= "" then
		Text = Text .. "\n(" .. Status .. ")"
	end

	return Text
end

function DrawWorldTip(Entity)
	if Entity ~= LocalPlayer():GetEyeTrace().Entity then return end
	if EyePos():Distance(Entity:GetPos()) > 256 then return end

	AddWorldTip(Entity:EntIndex(), GetOverlayText(Entity), 0.5, Entity:GetPos(), Entity)
end

function ENT:Draw()
	self:DrawModel()

	DrawWorldTip(self)
	Wire_Render(self)
end

function ACFRadarGUICreate(Table)
	acfmenupanel:CPanelText("Name", Table.name)

	acfmenupanel.CData.DisplayModel = vgui.Create("DModelPanel", acfmenupanel.CustomDisplay)
	acfmenupanel.CData.DisplayModel:SetModel(Table.model)
	acfmenupanel.CData.DisplayModel:SetCamPos(Vector(250, 500, 250))
	acfmenupanel.CData.DisplayModel:SetLookAt(Vector())
	acfmenupanel.CData.DisplayModel:SetFOV(20)
	acfmenupanel.CData.DisplayModel:SetSize(acfmenupanel:GetWide(), acfmenupanel:GetWide())
	acfmenupanel.CData.DisplayModel.LayoutEntity = function() end

	acfmenupanel.CustomDisplay:AddItem(acfmenupanel.CData.DisplayModel)

	acfmenupanel:CPanelText("ClassDesc", ACF.Classes.Radar[Table.class].desc)
	acfmenupanel:CPanelText("GunDesc", Table.desc)
	acfmenupanel:CPanelText("ViewCone", "View cone : " .. (Table.viewcone or 180) * 2 .. " degrees")
	acfmenupanel:CPanelText("ViewRange", "View range : " .. (Table.range and (math.Round(Table.range / 39.37, 1) .. " m") or "Unlimited"))
	acfmenupanel:CPanelText("Weight", "Weight : " .. Table.weight .. " kg")
	acfmenupanel:CPanelText("GunParentable", "\nThis radar can be parented.")

	acfmenupanel.CustomDisplay:PerformLayout()
end
