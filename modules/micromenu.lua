------------------------------------------------------
-- / SETUP AND LOCALS / --
------------------------------------------------------
local _, LUI = ...
local module = LUI:NewModule("Micromenu")
local L = LUI.L

local format = format

-- Local variables
local microStorage = {}

-- List of buttons, starting from the right.
local microList = {
	"Bags",  -- Setting should be first, but textures not ready yet
	"Settings",
	-- "Bags",
	"Store",
	"Collections",
	"LFG",
	"EJ",
	"PVP",
	"Guild",
	"Quests",
	"Achievements",
	"Talents",
	"Spellbook",
	"Player",
}

-- Constants
local TEXTURE_PATH_FORMAT = "Interface\\AddOns\\LUI4\\media\\textures\\micro_%s.tga"
local BACKGROUND_TEXTURE_PATH = "Interface\\AddOns\\LUI4\\media\\textures\\micro_background.tga"
local RIGHT_TEXTURE_SIZE_WIDTH = 46
local LEFT_TEXTURE_SIZE_WIDTH = 48
local TEXTURE_SIZE_HEIGHT = 28
local TEXTURE_SIZE_WIDTH = 33
local ALERT_ALPHA_MULT = 0.7

-- the clickable area is only 27x24
-- Wide buttons clickable area: 42x24
local WIDE_TEXTURE_CLICK_HEIGHT = 24
local WIDE_TEXTURE_CLICK_WIDTH = 42
local TEXTURE_CLICK_HEIGHT = 24
local TEXTURE_CLICK_WIDTH = 27

-- Level Requirements
local TALENT_LEVEL_REQ = 10
local PVP_LEVEL_REQ = 10
local LFG_LEVEL_REQ = 15

-- Defaults
module.defaults = {
	profile = {
		HideShop = false,
		ColorMatch = true,
		Spacing = 1,
		Point = "TOPRIGHT",
		Direction = "RIGHT",
		X = -15,
		Y = -18,
		Colors = {
			Background = { r = 0.12, g = 0.12,  b = 0.12, a = 1, t = "Class", },
			Micromenu = { r = 0.12, g = 0.58,  b = 0.89, a = 1, t = "Class", },
		},
	},
}

------------------------------------------------------
-- / MODULE FUNCTIONS / --
------------------------------------------------------

-- Function to attach the alert frame to point to micromenu buttonsw
function module:HookAlertFrame(name, anchor)
	local r, g, b, a = module:AlphaColor("Micromenu")
	local alertFrame      = _G[name.."MicroButtonAlert"]
	local alertFrameBg    = _G[name.."MicroButtonAlertBg"]
	local alertFrameArrow = _G[name.."MicroButtonAlertArrow"]
	local alertFrameGlow  = _G[name.."MicroButtonAlertGlow"]

	alertFrame:ClearAllPoints()
	alertFrame:SetPoint("TOP", anchor, "BOTTOM", 0, -12)
	alertFrameBg:SetGradientAlpha("VERTICAL", r/4, g/4, b/4, 1, 0, 0, 0, 1)
	alertFrameArrow:ClearAllPoints()
	alertFrameArrow:SetPoint("BOTTOM", alertFrame, "TOP", 0, -10)
	alertFrameArrow:SetDesaturated(true)
	alertFrameArrow:SetVertexColor(r, g, b, a * ALERT_ALPHA_MULT)
	alertFrameGlow:SetVertexColor(r, g, b, a * ALERT_ALPHA_MULT)
	alertFrameGlow:SetDesaturated(true)
	alertFrameGlow:ClearAllPoints()
	alertFrameGlow:SetAllPoints(alertFrameArrow)
	module:SetAlertFrameColors(name)
end

-- Function to change the color of an alert frame to match micromenu.
local gAlertGlows = {"TopLeft", "TopRight", "BottomLeft", "BottomRight", "Top", "Bottom", "Left", "Right"}
function module:SetAlertFrameColors(name)
	local r, g, b, a = module:AlphaColor("Micromenu")
	_G[name.."MicroButtonAlertBg"]:SetGradientAlpha("VERTICAL", r/4, g/4, b/4, 1, 0, 0, 0, 1)
	_G[name.."MicroButtonAlertArrow"]:SetVertexColor(r, g, b, a * ALERT_ALPHA_MULT)
	_G[name.."MicroButtonAlertGlow"]:SetVertexColor(r, g, b, a * ALERT_ALPHA_MULT)
	for i = 1, #gAlertGlows do
		local tex = _G[name.."MicroButtonAlertGlow"..gAlertGlows[i]]
		tex:SetDesaturated(true)
		tex:SetVertexColor(r, g, b)
	end
end

function module:TogglePanel(panel)
	if panel:IsShown() then
		HideUIPanel(panel)
	else
		ShowUIPanel(panel)
	end
end

------------------------------------------------------
-- / BUTTON FUNCTIONS / --
------------------------------------------------------

function module:SetSettings(button)
	--Need Localization
	button.title = L["Options"]
	button.left = L["MicroSettings_Left"]
	button.right = L["MicroSettings_Right"]
	button.clicker:SetScript("OnClick", function(self, btn)
		if btn == "RightButton" then
			--WoW Option Panel
			module:TogglePanel(GameMenuFrame)
		else
			--LUI Option Panel
			LUI:Open()
		end
	end)

	--TODO: Lets not use hungry OnUpdate handlers for the Clicker's alpha.
	--      Make a function to easily hook frames OnShow/OnHide
	--Due to LUI Options having no name, we cant use a simple hook, to remove when we find elegant fix.
	button.clicker:SetScript("OnUpdate", function(self)
		if self.Hover then return end
		if GameMenuFrame:IsShown() or LibStub("AceConfigDialog-3.0").OpenFrames.LUI then
			self:SetAlpha(1)
		else
			self:SetAlpha(0)
		end
	end)
end

function module:SetBags(button)
	button.title = L["Bags_Name"]
	button.left = L["MicroBags_Any"]
	button.clicker:SetScript("OnClick", function(self, btn_)
		ToggleAllBags()
	end)
	--Adjust for wide clicker
	button.isWide = true
	button:SetWidth(RIGHT_TEXTURE_SIZE_WIDTH)
	button.clicker:SetSize(WIDE_TEXTURE_CLICK_WIDTH , WIDE_TEXTURE_CLICK_HEIGHT)
	button.tex:SetTexCoord(LUI:GetCoordAtlas("MicroBtn_Right"))
end

function module:SetStore(button)
	button.title = L["MicroStore_Name"]
	button.left = L["MicroStore_Any"]
	button.clicker:SetScript("OnClick", function(self, btn_)
		ToggleStoreUI()
	end)
end

function module:SetCollections(button)
	button.title = L["MicroCollect_Name"]
	button.left = L["MicroCollect_Any"]
	button.clicker:SetScript("OnClick", function(self, btn_)
		ToggleCollectionsJournal()
	end)

	module:HookAlertFrame("Collections", button)
end

--This button could use some updating. Right click opening Premade Groups
function module:SetLFG(button)
	button.title = L["MicroLFG_Name"]
	button.left = L["MicroLFG_Left"]
	button.right = L["MicroLFG_Right"]
	button.level = LFG_LEVEL_REQ
	button.clicker:SetScript("OnClick", function(self, btn)
		if btn == "RightButton" then
			--Raid Browser
			ToggleRaidBrowser()
		else
			--Dungeon Finder
			ToggleLFDParentFrame()
		end
	end)
end

function module:SetEJ(button)
	button.title = L["MicroEJ_Name"]
	button.left = L["MicroEJ_Any"]
	button.clicker:SetScript("OnClick", function(self, btn_)
		ToggleEncounterJournal()
	end)

	module:HookAlertFrame("EJ", button)
end

--This could be set up much nicer. Possibly add Premade Group to right click
function module:SetPVP(button)
	button.title = L["MicroPVP_Name"]
	button.left = L["MicroPVP_Any"]
	button.level = PVP_LEVEL_REQ

	button.clicker:SetScript("OnClick", function(self, btn_)
		TogglePVPUI()
	end)
end

function module:SetGuild(button)
	button.title = L["MicroGuild_Name"]
	button.left = L["MicroGuild_Left"]
	button.right = L["MicroGuild_Right"]

	button.clicker:SetScript("OnClick", function(self, btn)
		if btn == "RightButton" then
			ToggleFriendsFrame()
		else
			--Those panels may not be loaded before we call them, so deal with that.
			if IsInGuild() then
				GuildFrame_LoadUI()
				module:TogglePanel(GuildFrame)
			else
				LookingForGuildFrame_LoadUI()
				module:TogglePanel(LookingForGuildFrame)
			end
		end
	end)
end

function module:SetQuests(button)
	button.title = L["MicroQuest_Name"]
	button.left = L["MicroQuest_Any"]
	button.clicker:SetScript("OnClick", function(self, btn_)
		module:TogglePanel(WorldMapFrame)
	end)
end

function module:SetAchievements(button)
	button.title = L["MicroAch_Name"]
	button.left = L["MicroAch_Any"]
	button.clicker:SetScript("OnClick", function(self, btn_)
		ToggleAchievementFrame()
	end)
end

function module:SetTalents(button)
	button.title = L["MicroTalents_Name"]
	button.left = L["MicroTalents_Any"]
	button.level = TALENT_LEVEL_REQ
	button.clicker:SetScript("OnClick", function(self, btn_)
		TalentFrame_LoadUI()
		module:TogglePanel(PlayerTalentFrame)
	end)

	module:HookAlertFrame("Talent", button)
end

function module:SetSpellbook(button)
	button.title = L["MicroSpell_Name"]
	button.left = L["MicroSpell_Any"]
	button.clicker:SetScript("OnClick", function(self, btn_)
		module:TogglePanel(SpellBookFrame)
	end)
end

function module:SetPlayer(button)
	button.title = L["MicroPlayer_Name"]
	button.left = L["MicroPlayer_Any"]
	button.clicker:SetScript("OnClick", function(self, btn_)
		module:TogglePanel(CharacterFrame)
	end)
	--Adjust for wide clicker
	button.isWide = true
	button.clicker:SetSize(WIDE_TEXTURE_CLICK_WIDTH , WIDE_TEXTURE_CLICK_HEIGHT)
	button:SetWidth(LEFT_TEXTURE_SIZE_WIDTH)
	button.tex:SetTexCoord(LUI:GetCoordAtlas("MicroBtn_Left"))
end
------------------------------------------------------
-- / MICROMENU SETUP / --
------------------------------------------------------
function module:SetMicromenuAnchors()
	local db = module:GetDB()
	if db.HideShop then
		microStorage["Store"]:Hide()
	else
		microStorage["Store"]:Show()
	end

	local firstAnchor, previousAnchor
	for i = 1, #microList do
		local button = microStorage[microList[i]]
		button:ClearAllPoints()
		if i == 1 then
			button:SetPoint(db.Point, UIParent, db.Point, db.X, db.Y)
			firstAnchor = button
			previousAnchor = button
		elseif not button:IsShown() then
			-- Do Nothing
		else
			--We do some arithmetic on the db.Spacing so that users dont get confused.
			--Users will expect positive Spacing numbers to be better, instead of looking at it like an Offset.
			button:SetPoint(db.Direction, previousAnchor, LUI.Opposites[db.Direction], -(db.Spacing-2), 0)
			previousAnchor = button
		end
	end

	local point = "TOP"..db.Direction
	module.background:ClearAllPoints()
	module.background:SetPoint(point, firstAnchor, point)
	module.background:SetPoint(LUI.Opposites[point], previousAnchor, LUI.Opposites[point])
end

function module:SetMicromenu()
	local r, g, b, a_ = module:AlphaColor("Micromenu")
	local db = module:GetDB()
	-- Note: V3 micromenu_anchor refers to the arrow that open/close the menu. NOT an actual anchor point.
	-- micromenu_button seems to points to the background behind the buttons.

	--Reusable backdrop table
	local clickerBackdrop = {
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = nil, tile = false, tileSize = 0, edgeSize = 1,
		insets = {left = 0, right = 0, top = 0, bottom = 0}
	}

	--Create reusable functions for OnEnter/OnLeave
	local function OnEnterFunc(self)
		self:SetAlpha(1)
		self.Hover = true
		GameTooltip:SetOwner(self, "ANCHOR_NONE ", 40, -100)
		local parent = self:GetParent()
		GameTooltip:SetText(parent.title)
		if parent.left then GameTooltip:AddLine(parent.left, 1, 1, 1) end
		if parent.right then GameTooltip:AddLine(parent.right, 1, 1, 1) end
		if parent.level and UnitLevel("player") < parent.level then
			GameTooltip:AddLine(format(L["Micro_PlayerReq"],parent.level), LUI:NegativeColor())
		end
		GameTooltip:Show()
	end

	local function OnLeaveFunc(self)
		self:SetAlpha(0)
		self.Hover = nil
		GameTooltip:Hide()
	end

	--Create Micromenu background
	local background = CreateFrame("Frame", "LUIMicromenu_Background", UIParent)
	background:SetBackdrop({
		bgFile = BACKGROUND_TEXTURE_PATH,
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = false, tilseSize = 0, edgeSize = 1,
		insets = { left = 0, right = 0, top = 0, bottom = 0 }
	})
	background:SetFrameStrata("BACKGROUND")
	background:SetBackdropColor(module:AlphaColor((db.ColorMatch) and "Micromenu" or "Background"))
	background:SetBackdropBorderColor(0, 0, 0, 0)
	module.background = background

	--Create Micromenu buttons
	for i = 1, #microList do
		local name = microList[i]
		local button = CreateFrame("Frame", "LUIMicromenu_"..name, UIParent)
		button:SetSize(TEXTURE_SIZE_WIDTH, TEXTURE_SIZE_HEIGHT)

		button.tex = button:CreateTexture(nil, "ARTWORK")
		button.tex:SetAllPoints()
		button.tex:SetTexture(format(TEXTURE_PATH_FORMAT,strlower(name)))
		button.tex:SetTexCoord(LUI:GetCoordAtlas("MicroBtn_Default"))
		button.tex:SetVertexColor(r, g, b)

		-- Make a button for the clickable area of the texture with black background.
		button.clicker = CreateFrame("Button", nil, button)
		button.clicker:SetSize(TEXTURE_CLICK_WIDTH , TEXTURE_CLICK_HEIGHT)
		button.clicker:RegisterForClicks("AnyUp")
		button.clicker:SetBackdrop(clickerBackdrop)
		button.clicker:SetPoint("CENTER", button, "CENTER", -1, 0)
		button.clicker:SetBackdropColor(0, 0, 0, 1)
		button.clicker:SetAlpha(0)
		--Push down the clicker frame so it doesn't go above the texture.
		button.clicker:SetFrameLevel(button:GetFrameLevel()-1)

		-- See if there's a function for per-button instructions.
		if module["Set"..name] then
			module["Set"..name](self, button)
		end

		--Add generic OnEnter/OnLeave using information from the functions.
		button.clicker:SetScript("OnEnter", OnEnterFunc)
		button.clicker:SetScript("OnLeave", OnLeaveFunc)
		microStorage[name] = button
	end

	module:SetMicromenuAnchors()
end

------------------------------------------------------
-- / FRAMEWORK FUNCTIONS / --
------------------------------------------------------
module.enableButton = true

function module:Refresh()
	module:SetMicromenuAnchors()
	module:SetAlertFrameColors("EJ")
	module:SetAlertFrameColors("Talent")
	module:SetAlertFrameColors("Collections")

	local db = module:GetDB()
	module.background:SetBackdropColor(module:AlphaColor((db.ColorMatch) and "Micromenu" or "Background"))
	local r, g, b, a_ = module:AlphaColor("Micromenu")
	for i = 1, #microList do
		local button = microStorage[microList[i]]
		button.tex:SetVertexColor(r, g, b)
	end
end

function module:LoadOptions()
	local dropDirections = {
		LEFT = L["Point_Left"],
		RIGHT = L["Point_Right"],
	}
	local db = module:GetDB()
	local colorMatchHide = function() return db.ColorMatch end

	local options = {
		Header = module:NewHeader(L["Micro_Name"], 1),
		HideShop = module:NewToggle("Hide Blizzard Store", nil, 2, "SetMicromenuAnchors"),
		Spacing = module:NewSlider(L["Spacing"], L["MicroOptions_Spacing_Desc"], 3, -10, 10, 1, false, "SetMicromenuAnchors"),
		PositionHeader = module:NewHeader(L["Position"], 4),
		Position = module:NewPosition(L["Micro_Name"], 5, true, "SetMicromenuAnchors"),
		Point = module:NewSelect(L["Anchor"], nil, 6, LUI.Points, nil, "SetMicromenuAnchors"),
		Direction = module:NewSelect(L["MicroOptions_Direction_Name"], L["MicroOptions_Direction_Desc"],
		                             7, dropDirections, nil, "SetMicromenuAnchors"),
		ColorHeader = module:NewHeader(L["Colors"], 10),
		ColorMatch = module:NewToggle(L["MicroOptions_ColorMatch_Name"], L["MicroOptions_ColorMatch_Desc"] , 11, "Refresh"),
		Micromenu = module:NewColorMenu(L["Micro_Name"], 12, true, "Refresh"),
		Background = module:NewColorMenu(L["Background"], 13, true, "Refresh", nil, nil, colorMatchHide),
	}
	return options
end

function module:OnInitialize()
	LUI:RegisterModule(module)
end

function module:OnEnable()
	module:SetMicromenu()
end

function module:OnDisable()
end
