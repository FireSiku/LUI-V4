--[[
	Module.....: Bars
	Description: Replace the action bars and surrounding graphics. Bartender Lite.
]]
-- ####################################################################################################################
-- ##### Setup and Locals #############################################################################################
-- ####################################################################################################################

local _, LUI = ...
local module = LUI:NewModule("Bars")
module.conflicts = "Bartender4"
local L = LUI.L

-- ####################################################################################################################
-- ##### Default Settings #############################################################################################
-- ####################################################################################################################

module.defaults = {
	profile = {
		General = {
			Scale = 1,
		},
		Backgrounds = {
			Frame = "Blizzard Tooltip",
		},
		Borders = {
			Frame = "glow",
		},
	},
}

-- ####################################################################################################################
-- ##### Module Functions #############################################################################################
-- ####################################################################################################################

-- ####################################################################################################################
-- ##### Module Setup #################################################################################################
-- ####################################################################################################################

function module:SetBars()
	--Re-Parent the Bar3-6
	MultiBarLeft:SetParent(UIParent)
	MultiBarRight:SetParent(UIParent)
	MultiBarBottomLeft:SetParent(UIParent)
	MultiBarBottomRight:SetParent(UIParent)

	--MainMenuBarArtFrame:SetAlpha(0)

	--[[for i = 1, 12 do
		button = _G["ActionButton"..i]
		button:SetParent(UIParent)
	end]]

	--Bar1 does not have a parent bar, so we make one.
	local ActionBar1 = CreateFrame("Frame", "ActionBar1", UIParent)
	ActionBar1:SetSize(500, 38)
	ActionBar1:SetPoint("BOTTOM", 0, 30)

	ActionBar1:SetBackdrop({
		bgFile = module:FetchBackground("Frame"),
		edgeFile = module:FetchBorder("Frame"),
		edgeSize = 5,
	})
	for i = 1, 12 do
		local button = _G["ActionButton"..i]
		button:SetParent(ActionBar1)
		button:ClearAllPoints()
		if i == 1 then
			button:SetPoint("BOTTOMLEFT")
		else
			button:SetPoint("LEFT", _G["ActionButton"..i-1], "RIGHT", 6, 0)
		end
	end
	local ActionBar5 = CreateFrame("Frame", "ActionBar5", UIParent)
	ActionBar5:SetSize(500, 38)
	ActionBar5:SetPoint("BOTTOMLEFT", ActionButton1, "TOPLEFT")
	MultiBarBottomLeft:SetParent(ActionBar5)
	MultiBarBottomLeft:SetAllPoints(ActionBar5)

	--MultiBarBottomLeft:ClearAllPoints()
	--MultiBarBottomLeft:SetPoint("BOTTOMLEFT", ActionButton1, "TOPLEFT", 0, 0)

	--Hide the art
	MainMenuBarArtFrame.OrigShow = MainMenuBarArtFrame.Show
	MainMenuBarArtFrame.Show = MainMenuBarArtFrame.Hide
	MainMenuBarArtFrame:Hide()
	MainMenuBar.Show = MainMenuBar.Hide
	--MainMenuBar:Hide()
end

-- ####################################################################################################################
-- ##### Framework Events #############################################################################################
-- ####################################################################################################################

module.enableButton = true

function module:OnInitialize()
	LUI:RegisterModule(module, true)
end

function module:OnEnable()
	module:SetBars()
end

function module:OnDisable()
end
