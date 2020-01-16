include ("shared.lua")

language.Add("Undone_acf_radar", "Undone ACF Radar")
language.Add("SBoxLimit__acf_radar", "You've hit the ACF Radar limit!")

local ACF_GunInfoWhileSeated = GetConVar("ACF_GunInfoWhileSeated")

function ENT:Draw()
	local HideBubble = LocalPlayer():InVehicle() and not ACF_GunInfoWhileSeated:GetBool()

	self.BaseClass.DoNormalDraw(self, false, HideBubble)
	Wire_Render(self)

	if self.GetBeamLength and (not self.GetShowBeam or self:GetShowBeam()) then
		-- Every SENT that has GetBeamLength should draw a tracer. Some of them have the GetShowBeam boolean
		Wire_DrawTracerBeam(self, 1, self.GetBeamHighlight and self:GetBeamHighlight() or false)
	end
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
