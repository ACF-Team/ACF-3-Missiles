local Text = "View Cone : %s degrees\nView Range : %s\nMass : %s kg\n\nThis entity can be fully parented."

function ACF.CreateRadarMenu(Data, Menu)
	local ViewCone = (Data.ViewCone or 180) * 2
	local ViewRange = Data.ViewRange and (math.Round(Data.ViewRange / 39.37, 2) .. " m") or "Unlimited"

	Menu:AddLabel(Text:format(ViewCone, ViewRange, Data.Mass))

	ACF.WriteValue("PrimaryClass", "acf_radar")
end
