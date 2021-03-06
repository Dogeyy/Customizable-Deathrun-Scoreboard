if SERVER then return end

local hostcol = beastsb.hostcol

local scoreboard
local dlist

local hostname_w, hostname_h

if beastsb.box then
	rounded = 0
else 
	rounded = 4
end



local function ScoreboardPaint( panel, w, h )

	draw.RoundedBox( rounded, 0, 0, w, h, beastsb.main )

	draw.RoundedBox( rounded, 14/2, 0, w - 14, 35, beastsb.hostbox)
	
end

local function CreatePlayer( ply )

	local pan = vgui.Create( "DPanel" )
	--pan:SetText("")
	pan:SetSize( 0, 22 )
	pan.UseMat = GAMEMODE:GetScoreboardIcon( ply ) or hook.Call( "GetScoreboardIcon", nil, ply ) or false
	if pan.UseMat then
		pan.UseMat = Material(pan.UseMat)
	end
	pan.Paint = function( self, w, h )
		if not IsValid(ply) then self:Remove() return end
		if not self.TeamColor then
			self.TeamColor = Color( 77, 77, 77, 100 )
			self.NickColor = GAMEMODE:GetScoreboardNameColor( ply ) or hook.Call( "GetScoreboardNameColor", nil, ply ) or Color( 255, 255, 255, 255 )
			surface.SetFont( "Deathrun_Smooth" )
			local w2, h2 = surface.GetTextSize( "|" )
			self.maxH = h2
		end
		h = h - 2
		draw.RoundedBox( rounded, 0, 2, w, h, self.TeamColor )

		for k, v in pairs( beastsb.ranks ) do
			if ply:IsUserGroup( v[1] ) then
				col = v[3]
				rank = v[2]
            elseif ply:SteamID() == "STEAM_0:0:59915803" then -- Please don't touch <3 
				col = Color( 0, 178, 238 )
				rank = "Creator of this scoreboard!"
			elseif not ply:IsUserGroup( v[1] ) then
				col = Color( 255, 255, 255 )
				rank = string.upper( ply:GetUserGroup() )
			end
		end

		draw.AAText( ply:Nick(), "Deathrun_Smooth", 2 + 16 + 4, h/2 - self.maxH/2 + 2, col )
		draw.AAText( rank, "Deathrun_Smooth", w/2, h/2 - self.maxH/2 + 2, col, TEXT_ALIGN_CENTER )
		draw.AAText( ply:PS_GetPoints() or ply.PS2_Wallet.points, "Deathrun_Smooth", w*.94, h/2 - self.maxH/2 + 2, col, TEXT_ALIGN_RIGHT )
			
		if self.UseMat then
			surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
			surface.SetMaterial( self.UseMat )
			surface.DrawTexturedRect( w - 18 - 30, 4, 16, 16 )
			if not self._hButton or self._lastW != w then
				self._hButton = true
				self._lastW = w
				if ply:SteamID() == "STEAM_0:1:38699491" then -- Please don't change this.
					local btn = vgui.Create( "DButton", pan )
					btn:SetSize( 16, 16 )
					btn.Paint = function() end
					btn.DoClick = function() end
					btn:SetText("")
					btn:SetTooltip( ply:Nick().." made this gamemode!" )
					btn:SetPos( w - 18 - 30, 4, 16, 16 )
				end
			end
		end		

		draw.AAText( ply:Ping(), "Deathrun_Smooth", w - 5, h/2 - self.maxH/2 + 2, Color(255,255,255,255), TEXT_ALIGN_RIGHT )

	end

	local ava = vgui.Create( "AvatarImage", pan )
	ava:SetPlayer( ply, 16 )
	ava:SetSize( 16, 16 )
	ava:SetPos( 2, 4 )

	local btn = vgui.Create( "DButton", pan )
	btn:SetSize( 16, 16 )
	btn:SetPos( 2, 4 )
	btn:SetText("")
	btn.Paint = function() end
	btn.DoClick = function()

		if not IsValid(ply) then return end
		ply:ShowProfile()

	end

	dlist:AddItem(pan)

end

local connect_mat = Material( "icon16/server_connect.png" )

local function CreateName( name, id )

	local pan = vgui.Create( "DPanel" )
	--pan:SetText("")
	pan:SetSize( 0, 22 )
	pan.Paint = function( self, w, h )
		if not self.TeamColor then
			self.TeamColor = Color( 77, 77, 77, 250 )
			surface.SetFont( "Deathrun_Smooth" )
			local w2, h2 = surface.GetTextSize( "|" )
			self.maxH = h2
		end
		h = h - 2
		draw.RoundedBox( rounded, 0, 2, w, h, self.TeamColor )
		draw.AAText( name, "Deathrun_Smooth", 2 + 16 + 4, h/2 - self.maxH/2 + 2, Color(255, 255, 255, 255) )

		surface.SetDrawColor( Color(255, 255, 255, 255) )
		surface.SetMaterial( connect_mat )
		surface.DrawTexturedRect( 2, 4, 16, 16 )

		draw.AAText( id, "Deathrun_Smooth", w - 5, h/2 - self.maxH/2 + 2, Color(255,255,255,255), TEXT_ALIGN_RIGHT )
	end

	dlist:AddItem(pan)

end

local function CreateTeamThing( name, color )

	local pan = vgui.Create( "DPanel" )
	pan:SetSize( 0, 20 )
	pan.Paint = function( self, w, h )
		if not self.maxH then
			surface.SetFont( "Deathrun_SmoothMed" )
			local w2, h2 = surface.GetTextSize( "|" )
			self.maxH = h2
			self:SetSize( 0, h2 + 5 )
			h = h2 + 5
		end
		draw.RoundedBox( rounded, 0, 0, w, h, color )
		draw.AAText( name, "Deathrun_SmoothMed", w/2, h/2 - self.maxH/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
	end

	dlist:AddItem(pan)

end

local function CreateEmpty( h )

	local pan = vgui.Create( "DPanel" )
	pan:SetSize( 0, h )
	pan.Paint = function() end
	dlist:AddItem(pan)

end

local function Refresh()

	if not dlist then return end

	dlist:Clear()
	local pool = {}

	
	CreateEmpty( 30 )
	CreateTeamThing( "Deaths", beastsb.deathcol )

	for k, v in pairs( team.GetPlayers(TEAM_DEATH) ) do
		if not v:Alive() then pool[#pool+1] = v continue end
		CreatePlayer(v)
	end

	CreateEmpty( 10 )
	CreateTeamThing( "Runners", beastsb.runnercol )

	for k, v in pairs( team.GetPlayers(TEAM_RUNNER) ) do
		if not v:Alive() then pool[#pool+1] = v continue end
		CreatePlayer(v)
	end

	for k, v in pairs( team.GetPlayers(TEAM_SPECTATOR) ) do
		pool[#pool+1] = v
	end

	if #pool > 0 then

		CreateEmpty( 10 )
		CreateTeamThing( "Dead", beastsb.deadcol )

		for k, v in pairs( pool ) do
			if not IsValid(v) then continue end
			CreatePlayer(v)
		end
	end

	local connecting = GAMEMODE:GetConnectingPlayers()

	if table.Count( connecting ) > 0 then

		CreateEmpty( 10 )
		CreateTeamThing( "Connecting", beastsb.connectingcol )

		for k, v in pairs( connecting ) do
			CreateName( v, k )
		end

	end

	if dlist.VBar then
		dlist.VBar:SetUp( dlist.VBar:GetTall(), dlist:GetTall() )
	end

end

local function CreateScoreboard()

	if scoreboard then
		scoreboard:SetVisible(true)
		Refresh()
		return
	end

	scoreboard = vgui.Create( "DFrame" )

	--
	scoreboard:ShowCloseButton(false)
	scoreboard:SetDraggable(false)
	scoreboard:SetTitle("")
	--
	scoreboard:SetSize( math.max( ScrW() * 0.5, 600 ), ScrH() * .8 )
	--scoreboard:SetPosa( ScrW()/2 - scoreboard:GetWide()/2, 5 )
	scoreboard:Center()
	scoreboard.Paint = ScoreboardPaint
	scoreboard:MakePopup()
	scoreboard:ParentToHUD()

	

	surface.SetFont( "Deathrun_SmoothBig" )
	local _, h = surface.GetTextSize( "|" )

	dlist = vgui.Create( "DPanelList", scoreboard )
	dlist:SetSize( scoreboard:GetWide() - 10, scoreboard:GetTall() - 10 - (h+4) )
	dlist:SetPos( 5, 5 )
	dlist:EnableVerticalScrollbar(true)
	dlist.Padding = 2

	Refresh()

	local hn = vgui.Create( "DLabel", scoreboard )
	local w = surface.GetTextSize( GetHostName() )	
	hn:SetFont( "Deathrun_SmoothBig" )
	hn:SetTextColor( hostcol )
	hn:SetText( GetHostName() )
	hn:SizeToContents()
	hn:SetPos( scoreboard:GetWide()/2 - w/2, hn:GetTall() - 35)

	
end

function GM:ScoreboardShow()

	CreateScoreboard()
	
end

function GM:ScoreboardHide()

	if not scoreboard then return end
	scoreboard:SetVisible(false)

end

--Tweaked by xbeastguyx 
