--[[
	Module.....: Minimap
	Elements...: None
	Description: Replace the default minimap.
]]
------------------------------------------------------
-- / SETUP AND LOCALS / --
------------------------------------------------------
local addonname, LUI = ...
local module = LUI:NewModule("Minimap")
local L = LUI.L
local db

-- Constants
local MINIMAP_LABEL = MINIMAP_LABEL

local MAIL_ICON_TEXTURE = "Interface\\AddOns\\LUI\\media\\mail.tga"
local MINIMAP_SQUARE_TEXTURE_MASK = "Interface\\ChatFrame\\ChatFrameBackground"
local MINIMAP_ROUND_TEXTURE_MASK = "Textures\\MinimapMask"
local ICON_LOCATION = {
		Mail = "BOTTOMLEFT",
		BG = "BOTTOMRIGHT",
		LFG = "TOPRIGHT",
		GMTicket = "TOPLEFT",
}
local COORD_FORMAT_LIST = {
		[0] = "%d, %d",
		[1] = "%.1f, %.1f",
		[2] = "%.2f, %.2f",
}

-- local variables
local MINIMAP_SIZE = 140      -- Base size for the minimap, based on default minimap.
local minimapShape = "ROUND"  -- Shape of the minimap, used for GetMinimapShape() community api.
local oldDefault = {}         -- Keep information on default minimap

--Defaults
module.defaults = {
	profile = {
		General = {
			Scale = 1,
			coordPrecision = 1,
			alwaysShowText = false,
			hideMissingCoord = true,
			showTextures = true,
		},
		Position = {
			X = -24,
			Y = -80,
			--RelativePoint = "TOPRIGHT",
			Point = "TOPRIGHT",
			Locked = false,
			Scale = 1,
		},
		Fonts = {
			Minimap = { Name = "vibroceb", Size = 12, Flag = "OUTLINE", },
		},
		Colors = {
			Minimap = { r = 0.21, g = 0.22, b = 0.23, a = 1, t = "Class", },
		},
	},
}

------------------------------------------------------
-- / LOCAL FUNCTIONS / --
------------------------------------------------------

-- For others mods with a minimap button, community API to know minimap shape.
function GetMinimapShape() return minimapShape end

------------------------------------------------------
-- / MODULE FUNCTIONS / --
------------------------------------------------------

function module:HideDefaultMinimap()

	-- Hide Several Frames surrounding minimap
	MinimapCluster:Hide()  --Minimap Original Parent, contains ZoneText, InstanceDifficulties
	MinimapBorder:Hide()           --Borders
	MinimapZoomIn:Hide()           --Zoom
	MinimapZoomOut:Hide()
	MiniMapWorldMapButton:Hide()   --World Map
	MiniMapVoiceChatFrame:Hide()   --Voice Chat
	TimeManagerClockButton:Hide()  --Clock
	MiniMapTracking:Hide()         --Tracking
	GameTimeFrame:Hide()           --Calendar

	--Change Minimap's Parent:
	oldDefault.scale = Minimap:GetScale()
	oldDefault.parent = Minimap:GetParent()
	Minimap:SetParent(UIParent)

	--Turn the Minimap into a square
	Minimap:SetMaskTexture(MINIMAP_SQUARE_TEXTURE_MASK)
	minimapShape = "SQUARE"

	-- Change textures around, keep old textures around.
	oldDefault.NorthTag = MinimapNorthTag:GetTexture()
	MinimapNorthTag:SetTexture(nil)	--North Arrow

	-- Move Mail icon
	MiniMapMailFrame:ClearAllPoints()
	MiniMapMailFrame:SetPoint(ICON_LOCATION.Mail, Minimap, 3, 4)
	MiniMapMailBorder:Hide()
	oldDefault.Mail = MiniMapMailIcon:GetTexture()
	MiniMapMailIcon:SetTexture(MAIL_ICON_TEXTURE)

	--Size and Position

	local point, relativeTo, relativePoint, xOff, yOff = Minimap:GetPoint(1)
	oldDefault.point = point
	oldDefault.relativeTo = relativeTo
	oldDefault.relativePoint = relativePoint
	oldDefault.X = xOff
	oldDefault.Y = yOff
	oldDefault.width = Minimap:GetWidth()
	oldDefault.height = Minimap:GetHeight()

end

function module:RestoreDefaultMinimap()

	-- Show Several Frames surrounding minimap
	MinimapCluster:Show()          --Minimap Original Parent
	MinimapBorder:Show()           --Border
	MinimapZoomIn:Show()           --Zoom
	MinimapZoomOut:Show()
	MiniMapWorldMapButton:Show()   --World Map
	TimeManagerClockButton:Show()  --Clock
	MiniMapTracking:Show()         --Tracking
	GameTimeFrame:Show()           --Calendar
	MinimapNorthTag:SetTexture(oldDefault.NorthTag)	--North Arrow

	--Revert Minimap Parent
	Minimap:SetParent(oldDefault.parent)
	Minimap:SetScale(oldDefault.scale)

	--Turn the Minimap back into a circle
	Minimap:EnableMouseWheel(false)
	Minimap:SetMaskTexture(MINIMAP_ROUND_TEXTURE_MASK)
	minimapShape = "ROUND"

	--Show Voice Chat if the feature is enabled
	MiniMapVoiceChatFrame:Hide()  -- PH: Doing them a favor keeping it hidden.

	-- Move Mail icon
	--MiniMapMailFrame:ClearAllPoints()
	MiniMapMailBorder:Show()
	MiniMapMailIcon:SetTexture(oldDefault.Mail)

	--Remove module centric frames
	LUIMinimapZone:Hide()
	LUIMinimapCoord:Hide()
	LUIMinimapBorder:Hide()
	for i = 1, 8 do
		_G["LUIMinimapTexture"..i]:Hide()
	end

	--Reset Position and Size
	Minimap:ClearAllPoints()
	Minimap:SetPoint(oldDefault.point, oldDefault.relativeTo, oldDefault.relativePoint, oldDefault.X, oldDefault.Y)
	Minimap:SetSize(oldDefault.width, oldDefault.height)
end

function module:SetMinimap()

	--Enable Scroll Zooming
	Minimap:EnableMouseWheel(true)
	--The default minimap does not have mousewheel scrolling.
	Minimap:SetScript("OnMouseWheel", function(self, delta)
		if module:IsEnabled() then
			if delta > 0 then
				MinimapZoomIn:Click()
			elseif delta < 0 then
				MinimapZoomOut:Click()
			end
		end
	end)
	
	module:SetMinimapSize()
	module:SetMinimapPosition()
	
	--Make sure not to create the frames more than once.
	-- Set Zone Text
	local minimapZone = CreateFrame("Frame", "LUIMinimapZone", Minimap)
	minimapZone:SetSize(0, 20)
	minimapZone:SetPoint("TOPLEFT", Minimap, 2, -2)
	minimapZone:SetPoint("TOPRIGHT",Minimap, -2. -2)

	local minimapZoneText = module:SetFontString(minimapZone, "LUIMinimapZoneText", "Minimap", "Overlay", "CENTER", "MIDDLE")
	minimapZoneText:SetPoint("CENTER", 0, 0)
	minimapZoneText:SetHeight(db.Fonts.Minimap.Size)
	minimapZoneText:SetWidth(minimapZone:GetWidth()-6)	--Why 6?

	--Add pvp coloring later. Make customizable.
	minimapZone:SetScript("OnUpdate", function(self)
		minimapZoneText:SetText(GetMinimapZoneText())
	end)

	-- Set Coord Text
	local minimapCoord = CreateFrame("Frame", "LUIMinimapCoord", Minimap)
	minimapCoord:SetSize(40, 20)
	minimapCoord:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", 2, 2)

	local minimapCoordText = module:SetFontString(minimapCoord, "LUIMinimapCoordText", "Minimap", "Overlay", "LEFT", "MIDDLE")
	minimapCoordText:SetPoint("LEFT", -1, 0)
	minimapCoordText:SetText("00,00")

	minimapCoord:SetScript("OnUpdate", function(self)
		local x , y = GetPlayerMapPosition("player")
		-- Inside dungeons, the call can fail and x and y will be nil
		if not x then x, y = 0, 0 end
		if db.General.hideMissingCoord and x == 0 and y == 0 then
			minimapCoordText:SetText("")
		else
			minimapCoordText:SetFormattedText(COORD_FORMAT_LIST[db.General.coordPrecision], x*100, y*100)
		end
	end)

	module:ToggleMinimapText()	-- Refresh the Show/Hide for those two.

	--Script to add text when you mouseover the minimap
	Minimap:SetScript("OnEnter",function()
		--Since its a Minimap script, make sure the module is enabled
		if module:IsEnabled() then
			LUIMinimapZone:Show()
			LUIMinimapCoord:Show()
		end
	end)
	Minimap:SetScript("OnLeave",function()
		if not db.General.alwaysShowText then
			LUIMinimapZone:Hide()
			LUIMinimapCoord:Hide()
		end
	end)

	Minimap:SetScript("OnMouseUp", function(self, button)
		--Right Click shows the Tracking dropdown, only if module is enabled.
		if button == "RightButton" and module:IsEnabled() then
			ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, self)
		else Minimap_OnClick(self)
		end
	end)

	--Create other frames around the minimap
	module:SetMinimapFrames()
	

	--Prevent these initialization functions from running again.
	function module:SetMinimap()
		module:SetMinimapPosition()
		module:SetMinimapAgain()
	end
end

--If module is disabled and re-enabled, call this instead to prevent re-initializing everything
function module:SetMinimapAgain()
	Minimap:EnableMouseWheel(true)
	module:ToggleMinimapText()
	module:ToggleMinimapTextures()

	--When you call SetParent, all children strata are equal to the parent. This puts the textures back in the backgroun.
	LUIMinimapBorder:SetFrameStrata("BACKGROUND")
	for i = 1, 8 do
		_G["LUIMinimapTexture"..i]:SetFrameStrata("BACKGROUND")
	end
end

--Set Frames surrounding the minimap.
function module:SetMinimapFrames()
	--Setting up values
	local borderBackdrop = {
		bgFile="Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile="Interface\\AddOns\\LUI\\media\\statusbar\\glowTex.tga",
		tile=0, tileSize=0, edgeSize=7,
		insets={left=0, right=0, top=0, bottom=0}
	}

	local r, g, b, a = module:AlphaColor("Minimap")
	local texOffX = { -7, 7, 7, -7, -10, 10, 10, -10 }
	local texOffY = { -7, -7, 7, 7, -10, -10, 10, 10 }
	local texPoint = { "BOTTOMLEFT", "BOTTOMRIGHT", "TOPRIGHT", "TOPLEFT" }

	--Create Border
	local minimapBorder = CreateFrame("Frame", "LUIMinimapBorder", Minimap)
	minimapBorder:SetSize(143,143)
	minimapBorder:SetFrameStrata("BACKGROUND")
	minimapBorder:SetPoint("CENTER", Minimap, "CENTER", 0, 0)
	minimapBorder:SetBackdrop(borderBackdrop)
	minimapBorder:SetBackdropColor(0,0,0,0)
	minimapBorder:SetBackdropBorderColor(0,0,0,1) -- 0,0,0,1 in v3

	--Create Corner Textures (Tex1-Tex4)
	local textureBackdrop = {
		bgFile="Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile="Interface\\AddOns\\LUI\\media\\statusbar\\glowTex.tga",
		tile=0, tileSize=0, edgeSize=6,
		insets={left=3, right=3, top=3, bottom=3}
	}
	for i = 1, 4 do
		local minimapTex = CreateFrame("Frame", "LUIMinimapTexture"..i, Minimap)
		minimapTex:SetSize(50,50)
		minimapTex:SetFrameStrata("BACKGROUND")
		minimapTex:SetPoint(texPoint[i], Minimap, texPoint[i], texOffX[i], texOffY[i])
		minimapTex:SetBackdrop(textureBackdrop)
		minimapTex:SetBackdropColor(0,0,0,0)
		minimapTex:SetBackdropBorderColor(r,g,b,a)
	end

	--Create Shadow Textures (Tex1-Tex4)
	local shadowBackdrop = {
		bgFile="Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile="Interface\\AddOns\\LUI\\media\\statusbar\\glowTex.tga",
		tile=0, tileSize=0, edgeSize=4,
		insets={left=3, right=3, top=3, bottom=3}
	}
	for i = 5, 8 do
		local minimapTex = CreateFrame("Frame", "LUIMinimapTexture"..i, Minimap)
		minimapTex:SetSize(56,56)
		minimapTex:SetFrameStrata("BACKGROUND")
		minimapTex:SetPoint(texPoint[i-4], Minimap, texPoint[i-4], texOffX[i], texOffY[i])
		minimapTex:SetFrameLevel(minimapTex:GetFrameLevel()-1)
		minimapTex:SetBackdrop(shadowBackdrop)
		minimapTex:SetBackdropColor(0,0,0,0)
		minimapTex:SetBackdropBorderColor(0,0,0,1)
	end
	
	-- Move Garrison icon
	GarrisonLandingPageMinimapButton:ClearAllPoints();
	GarrisonLandingPageMinimapButton:SetSize(32,32);
	GarrisonLandingPageMinimapButton:SetPoint(ICON_LOCATION.Mail, Minimap, 3, 12)
	
	MiniMapMailFrame:HookScript("OnShow", function(self)
		GarrisonLandingPageMinimapButton:SetPoint("BOTTOMLEFT", MiniMapMailFrame, "TOPLEFT", 0, -4)
	end)
	MiniMapMailFrame:HookScript("OnHide", function(self)
		GarrisonLandingPageMinimapButton:SetPoint(ICON_LOCATION.Mail, Minimap, 3, 12)
	end)
end

function module:SetMinimapSize()
	LUI:RegisterConfig(Minimap, db.Position)
	LUI:RestorePosition(Minimap)
end

function module:SetMinimapPosition()
	LUI:RestorePosition(Minimap)
end

function module:SetColors()
	local r, g, b, a = module:AlphaColor("Minimap")
	for i = 1, 4 do
		_G["LUIMinimapTexture"..i]:SetBackdropBorderColor(r,g,b,a)
	end
end

function module:ToggleMinimapText()
	if db.General.alwaysShowText then
		LUIMinimapZone:Show()
		LUIMinimapCoord:Show()
	else
		LUIMinimapZone:Hide()
		LUIMinimapCoord:Hide()
	end
end

function module:ToggleMinimapTextures()
	if db.General.showTextures then
		LUIMinimapBorder:Show()
		for i = 1, 8 do
			_G["LUIMinimapTexture"..i]:Show()
		end
	else
		LUIMinimapBorder:Hide()
		for i = 1, 8 do
			_G["LUIMinimapTexture"..i]:Hide()
		end
	end
end

------------------------------------------------------
-- / FRAMEWORK FUNCTIONS / --
------------------------------------------------------

module.enableButton = true

function module:LoadOptions()
	local options = {
		Header = module:NewHeader(MINIMAP_LABEL, 1),
		General = module:NewGroup(L["Settings"], 2, nil, nil, {
			alwaysShowText = module:NewToggle(L["Minimap_AlwaysShowText_Name"], L["Minimap_AlwaysShowText_Desc"], 1, "ToggleMinimapText"),
			showTextures = module:NewToggle(L["Minimap_ShowTextures_Name"], L["Minimap_ShowTextures_Desc"], 2, "ToggleMinimapTextures"),
			coordPrecision = module:NewSlider(L["Minimap_CoordPrecision_Name"], L["Minimap_CoordPrecision_Desc"], 4, 0, 2, 1),
			LineBreak = module:NewLineBreak(9),
			Minimap = module:NewColorMenu(L["Minimap_BorderColor_Name"], 10, true, "SetColors"),
		}),
		Position = module:NewGroup(L["Position"], 3, nil, nil, {
			Position = module:NewPosition(L["Position"], 1, true, "SetMinimapSize"),
			Point = module:NewSelect(L["Anchor"], nil, 2, LUI.Points, nil, "SetMinimapSize"),
			Scale = module:NewSlider(L["Minimap_Scale_Name"], L["Minimap_Scale_Desc"], 5, 0.5, 2.5, 0.25, true, "SetMinimapSize"),
		}),
	}
	return options
end

function module:OnInitialize()
	LUI:RegisterModule(module, true)
end

function module:OnEnable()
	db = module:GetDB()
	module:HideDefaultMinimap()
	module:SetMinimap()
end

function module:OnDisable()
	module:RestoreDefaultMinimap()
end