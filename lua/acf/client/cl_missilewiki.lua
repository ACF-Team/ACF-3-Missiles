local PANEL = {}
local MIN_X, MIN_Y = 800, 600

function PANEL:Init()
	self:SetSize(MIN_X, MIN_Y)

	self.ModelView = vgui.Create('DModelPanel', self)
	self.ModelView:SetSize(80, 80)
	self.ModelView:SetPos(20, 30)
	self.ModelView:SetModel('models/missiles/bgm_71e.mdl')
	self.ModelView.LayoutEntity = function() end
	self.ModelView:SetFOV(45)

	local viewent = self.ModelView:GetEntity()
	local boundmin, boundmax = viewent:GetRenderBounds()
	local dist = boundmin:Distance(boundmax) * 1.1
	local centre = boundmin + (boundmax - boundmin) * 0.5

	self.ModelView:SetCamPos( centre + Vector( 0, dist, 0 ) )
	self.ModelView:SetLookAt( centre )

	self.CloseButton = vgui.Create('DButton', self)
	self.CloseButton:SetSize(40, 15)
	self.CloseButton:SetPos(580, 440)
	self.CloseButton:SetText('Close')
	self.CloseButton.DoClick = function() self:Close() end

	self.HTML = vgui.Create('DHTML', self)
	self.HTML:SetSize(450, 400)
	self.HTML:SetPos(120, 30)
	self.HTML:SetHTML('Fetching Info....')

	self.Tree = vgui.Create('DTree', self)
	self.Tree:SetSize(80, 230)
	self.Tree:SetPos(20, 200)

	self:SetVisible(true)
	self:Center()
	self:SetSizable(true)
	self:SetTitle('')
	self:MakePopup()
	self:ShowCloseButton(false)
	self:SetDeleteOnClose(false)

	self:InvalidateLayout()
end

function PANEL:SetText(txt)
	self.HTML:SetHTML('<body bgcolor="#f0f0f0"><font face="Helvetica" color="#0f0f0f">' .. txt .. '</font></body>')
end

function PANEL:SetList(HTML, StartPage)
	self.Tree:Clear()

	if not HTML or not next(HTML) then
		self:SetText('Failed to load the ACF Missiles Wiki.  If this continues, please inform us at https://github.com/TwistedTail/ACF-3-Missiles')
		return
	end

	for K, V in pairsByKeys(HTML) do
		local Node = self.Tree:AddNode(K)

		Node.DoClick = function()
			self.HTML:SetHTML(V)
		end

		if K == StartPage then
			self.HTML:SetHTML(V)
		end
	end
end

function PANEL:PerformLayout()
	local X, Y = self:GetSize()

	if X < MIN_X then
		X = MIN_X
		self:SetWide(MIN_X)
	end

	if Y < MIN_Y then
		Y = MIN_Y
		self:SetTall(MIN_Y)
	end

	local Wide, Tall, padding = 10, 30, 10
	local SidebarWide = 160
	local InitTall = Tall

	self.CloseButton:SetPos(X - (self.CloseButton:GetWide() + 3), 3)

	self.ModelView:SetPos(Wide, Tall)
	self.ModelView:SetWide(SidebarWide)

	Tall = Tall + self.ModelView:GetTall() + padding

	self.Tree:SetPos(Wide, Tall)
	self.Tree:SetSize(SidebarWide, Y - (Tall + padding))

	Wide = Wide + SidebarWide + padding

	self.HTML:SetPos(Wide, InitTall)
	self.HTML:SetSize(X - (Wide + padding), Y - (InitTall + padding))
end

derma.DefineControl('ACFMissile_Wiki', 'Wiki for ACF Missiles', PANEL, 'DFrame')
