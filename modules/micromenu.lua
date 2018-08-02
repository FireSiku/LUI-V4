-- ####################################################################################################################
-- ##### Setup and Locals #############################################################################################
-- ####################################################################################################################

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

-- ####################################################################################################################
-- ##### Default Settings #############################################################################################
-- ####################################################################################################################

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

-- ####################################################################################################################
-- ##### MicroButton Definitions ######################################################################################
-- ####################################################################################################################

local microDefinitions = {

	{ -- [2] Currently 1 due to workaround.
		name = "Bags",
		title = L["Bags_Name"],
		any = L["MicroBags_Any"],
		isWide = "Right",
		OnClick = function(self, btn_)
			ToggleAllBags()
		end,
	},

	{ -- [1]
		name = "Settings",
		title = L["Options"],
		left = L["MicroSettings_Left"],
		right = L["MicroSettings_Right"],
		OnClick = function(self, btn)
			if btn == "RightButton" then
				--WoW Option Panel
				module:TogglePanel(GameMenuFrame)
			else
				--LUI Option Panel
				LUI:Open()
			end
		end,
		--TODO: Lets not use hungry OnUpdate handlers for the Clicker's alpha.
		--      Make a function to easily hook frames OnShow/OnHide
		--Due to LUI Options having no name, we cant use a simple hook, to remove when we find elegant fix.
		OnUpdate = function(self)
			if self.Hover then return end
			if GameMenuFrame:IsShown() or LibStub("AceConfigDialog-3.0").OpenFrames.LUI then
				self:SetAlpha(1)
			else
				self:SetAlpha(0)
			end
		end
	},

	{ -- [3]
		name = "Store",
		title = L["MicroStore_Name"],
		any = L["MicroStore_Any"],
		OnClick = function(self, btn_)
			ToggleStoreUI()
		end,
	},

	{ -- [4]
		name = "Collections",
		alertFrame = "Collections",
		title = L["MicroCollect_Name"],
		any = L["MicroCollect_Any"],
		OnClick = function(self, btn_)
			ToggleCollectionsJournal()
		end,
	},

	-- This button could use some updating. Right click opening Premade Groups for example.
	{ -- [5]
		name = "LFG",
		level = LFG_LEVEL_REQ,
		title = L["MicroLFG_Name"],
		left = L["MicroLFG_Left"],
		right = L["MicroLFG_Right"],
		OnClick = function(self, btn)
			if btn == "RightButton" then
				ToggleRaidBrowser() --Raid Browser
			else
				ToggleLFDParentFrame() --Dungeon Finder
			end
		end,
	},

	{ -- [6]
		name = "EJ",
		alertFrame = "EJ",
		title = L["MicroEJ_Name"],
		any = L["MicroEJ_Any"],
		OnClick = function(self, btn_)
			ToggleEncounterJournal()
		end,
	},

	--This could be set up much nicer. Possibly add Premade PVP Group to right click
	{ -- [7]
		name = "PVP",
		level = PVP_LEVEL_REQ,
		title = L["MicroPVP_Name"],
		any = L["MicroPVP_Any"],
		OnClick = function(self, btn_)
			TogglePVPUI()
		end,
	},

	{ -- [8]
		name = "Guild",
		title = L["MicroGuild_Name"],
		left = L["MicroGuild_Left"],
		right = L["MicroGuild_Right"],
		--luacheck: globals LookingForGuildFrame
		OnClick = function(self, btn)
			if btn == "RightButton" then
				ToggleFriendsFrame()
			else
				--Those panels may not be loaded before we call them, so deal with that.
				if IsInGuild() then
					ToggleGuildFrame()
					module:TogglePanel(GuildFrame)
				else
					LookingForGuildFrame_LoadUI()
					module:TogglePanel(LookingForGuildFrame)
				end
			end
		end,
	},

	{ -- [9]
		name = "Quests",
		title = L["MicroQuest_Name"],
		any = L["MicroQuest_Any"],
		OnClick = function(self, btn_)
			module:TogglePanel(WorldMapFrame)
		end,
	},

	{ -- [10]
		name = "Achievements",
		title = L["MicroAch_Name"],
		any = L["MicroAch_Any"],
		OnClick = function(self, btn_)
			ToggleAchievementFrame()
		end,
	},

	{ -- [11]
		name = "Talents",
		alertFrame = "Talent",
		level = TALENT_LEVEL_REQ,
		title = L["MicroTalents_Name"],
		any = L["MicroTalents_Any"],
		OnClick = function(self, btn_)
			TalentFrame_LoadUI()
			module:TogglePanel(PlayerTalentFrame)
		end,
	},
	
	{ -- [12]
		name = "Spellbook",
		title = L["MicroSpell_Name"],
		any = L["MicroSpell_Any"],
		OnClick = function(self, btn_)
			module:TogglePanel(SpellBookFrame)
		end,
	},

	{ -- [13]
		name = "Player",
		isWide = "Left",
		title = L["MicroPlayer_Name"],
		any = L["MicroPlayer_Any"],
		OnClick = function(self, btn_)
			module:TogglePanel(CharacterFrame)
		end,
	},
}

-- ####################################################################################################################
-- ##### Module Functions #############################################################################################
-- ####################################################################################################################

-- Function to attach the alert frame to point to micromenu buttonsw
function module:HookAlertFrame(name, anchor)
	local r, g, b, a = module:RGBA("Micromenu")
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
	local r, g, b, a = module:RGBA("Micromenu")
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

-- ####################################################################################################################
-- ##### MicroButton Creation #########################################################################################
-- ####################################################################################################################
local MicroButtonClickerMixin = {}

function MicroButtonClickerMixin:OnEnter()
	self:SetAlpha(1)
	self.Hover = true
	GameTooltip:SetOwner(self, "ANCHOR_NONE ", 40, -100)

	local parent = self:GetParent()
	GameTooltip:SetText(parent.title)
	if parent.any then GameTooltip:AddLine(parent.any, 1, 1, 1) end
	if parent.left then GameTooltip:AddLine(parent.left, 1, 1, 1) end
	if parent.right then GameTooltip:AddLine(parent.right, 1, 1, 1) end
	if parent.level and UnitLevel("player") < parent.level then
		GameTooltip:AddLine(format(L["Micro_PlayerReq"], parent.level), LUI:NegativeColor())
	end

	GameTooltip:Show()
end

function MicroButtonClickerMixin:OnLeave()
	self:SetAlpha(0)
	self.Hover = nil
	GameTooltip:Hide()
end

MicroButtonClickerMixin.clickerBackdrop = {
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = nil, tile = false, tileSize = 0, edgeSize = 1,
	insets = {left = 0, right = 0, top = 0, bottom = 0}
}

function module:NewMicroButton(buttonData)
	local r, g, b, a_ = module:RGBA("Micromenu")
	local name = buttonData.name
	
	local button = CreateFrame("Frame", "LUIMicromenu_"..name, UIParent)
	button:SetSize(TEXTURE_SIZE_WIDTH, TEXTURE_SIZE_HEIGHT)
	Mixin(button, buttonData)

	button.tex = button:CreateTexture(nil, "ARTWORK")
	button.tex:SetAllPoints()
	button.tex:SetTexture(format(TEXTURE_PATH_FORMAT,strlower(name)))
	button.tex:SetTexCoord(LUI:GetCoordAtlas("MicroBtn_Default"))
	button.tex:SetVertexColor(r, g, b)

	-- Make a button for the clickable area of the texture with black background.
	button.clicker = CreateFrame("Button", nil, button)
	button.clicker:SetSize(TEXTURE_CLICK_WIDTH , TEXTURE_CLICK_HEIGHT)
	button.clicker:RegisterForClicks("AnyUp")
	button.clicker:SetBackdrop(MicroButtonClickerMixin.clickerBackdrop)
	button.clicker:SetPoint("CENTER", button, "CENTER", -1, 0)
	button.clicker:SetBackdropColor(0, 0, 0, 1)
	button.clicker:SetAlpha(0)
	--Push down the clicker frame so it doesn't go above the texture.
	button.clicker:SetFrameLevel(button:GetFrameLevel()-1)

	-- Handle some definition-based info
	if button.OnClick then
		button.clicker:SetScript("OnClick", button.OnClick)
	end
	if button.OnUpdate then
		button.clicker:SetScript("OnUpdate", button.OnUpdate)
	end
	if button.alertFrame then
		module:HookAlertFrame(button.alertFrame, button)
	end
	if button.isWide then
		local width = (button.isWide == "Right" and RIGHT_TEXTURE_SIZE_WIDTH) or LEFT_TEXTURE_SIZE_WIDTH
		button:SetWidth(width)
		button.clicker:SetSize(WIDE_TEXTURE_CLICK_WIDTH , WIDE_TEXTURE_CLICK_HEIGHT)
		button.tex:SetTexCoord(LUI:GetCoordAtlas("MicroBtn_"..button.isWide))
	end

	button.clicker:SetScript("OnEnter", MicroButtonClickerMixin.OnEnter)
	button.clicker:SetScript("OnLeave", MicroButtonClickerMixin.OnLeave)
	return button
end

-- ####################################################################################################################
-- ##### Module Setup #################################################################################################
-- ####################################################################################################################

function module:SetMicromenuAnchors()
	local db = module:GetDB()
	-- TODO: Have a more defined system for hiding buttons.
	if db.HideShop then
		microStorage[3]:Hide()
	else
		microStorage[3]:Show()
	end

	local firstAnchor, previousAnchor
	for i = 1, #microStorage do
		local button = microStorage[i]
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
	local db = module:GetDB()
	-- Note: V3 micromenu_anchor refers to the arrow that open/close the menu. NOT an actual anchor point.
	-- micromenu_button seems to points to the background behind the buttons.

	--Create Micromenu background
	local background = CreateFrame("Frame", "LUIMicromenu_Background", UIParent)
	background:SetBackdrop({
		bgFile = BACKGROUND_TEXTURE_PATH,
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = false, tilseSize = 0, edgeSize = 1,
		insets = { left = 0, right = 0, top = 0, bottom = 0 }
	})
	background:SetFrameStrata("BACKGROUND")
	background:SetBackdropColor(module:RGBA((db.ColorMatch) and "Micromenu" or "Background"))
	background:SetBackdropBorderColor(0, 0, 0, 0)
	module.background = background

	--Create Micromenu buttons
	for i = 1, #microDefinitions do
		table.insert(microStorage, module:NewMicroButton(microDefinitions[i]))
	end

	module:SetMicromenuAnchors()
end

-- ####################################################################################################################
-- ##### Module Refresh ###############################################################################################
-- ####################################################################################################################

function module:Refresh()
	module:SetMicromenuAnchors()
	module:SetAlertFrameColors("EJ")
	module:SetAlertFrameColors("Talent")
	module:SetAlertFrameColors("Collections")

	local db = module:GetDB()
	module.background:SetBackdropColor(module:RGBA((db.ColorMatch) and "Micromenu" or "Background"))
	local r, g, b, a_ = module:RGBA("Micromenu")
	for i = 1, #microList do
		local button = microStorage[microList[i]]
		button.tex:SetVertexColor(r, g, b)
	end
end

-- ####################################################################################################################
-- ##### Options Menu #################################################################################################
-- ####################################################################################################################

module.enableButton = true

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

-- ####################################################################################################################
-- ##### Framework Events #############################################################################################
-- ####################################################################################################################

function module:OnInitialize()
	LUI:RegisterModule(module)
end

function module:OnEnable()
	module:SetMicromenu()
end

function module:OnDisable()
end
