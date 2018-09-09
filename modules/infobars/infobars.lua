--[[
	This module handle experience bars of all sorts.
	By default it will serves as an experience bar under the action bars
	This main bar will split off in two if you are watching a reputation or honor.
	[Rep  <--] [-->   XP]

	Honor takes priority over faction reputations.
	If displaying Azerite is enabled, it becomes AP / XP.
	At max level, the XP bar is fully replaced by a rep/honor tracking bar. Hidden if not tracking either of them.
	
	Upcoming new feautre: Letting users create an additional customizable tracking bar.

	This file handles the handling of the bars, XP/Rep data handling should be in their own files.
]]

-- ####################################################################################################################
-- ##### Setup and Locals #############################################################################################
-- ####################################################################################################################

local _, LUI = ...
local module = LUI:NewModule("Info Bars")
local L = LUI.L

-- ####################################################################################################################
-- ##### Default Settings #############################################################################################
-- ####################################################################################################################

module.defaults = {
	profile = {
		Width = 475,
		Height = 12,
		X = 0,
		Y = 6,
		Point = "CENTER",
		RelativePoint = "CENTER",
		ShowRested = false,
		BGMultiplier = 0.4,
		ShowText = true,
		ShowAzerite = true,
		Precision = 2,
		TextX = -2,
		TextY = 0,
		Spacing = 10,
		Colors = {
			Experience = { r = 0.6,  g = 0.6,  b = 1,    a = 1,   t = "Class", },
			Reputation = { r = 0.2,  g = 0.2,  b = 0.2,  a = 1,   t = "Class", },
			Honor =      { r = 0.18, g = 0.18, b = 0.18, a = 0.8, t = "Class", },
		},
		Fonts = {
			Text = { Name = "Prototype", Size = 13, Flag = "NONE" },
		},
		StatusBars = {
			ExpBar = "LUI_Gradient",
			Background = "LUI_Minimalist",
		},
	},
}

local mixinData = {}

-- ####################################################################################################################
-- ##### InfoBarDataMixin #############################################################################################
-- ####################################################################################################################

local InfoBarDataMixin = {}

-- Override this function to provides min, curr and max values to the host bar.
function InfoBarDataMixin:GetValues()
	return 0, 0, 1
end

function InfoBarDataMixin:ShouldBeVisible()
	return false
end

-- Override this function to disable displaying percentage text
function InfoBarDataMixin:ShouldDisplayPercentText()
	return true
end

-- Override this function to determine text being displayed
function InfoBarDataMixin:GetDataText()
	return "No Data"
end

-- Override this function to show a tooltip when hovering the bar
function InfoBarDataMixin:HasTooltip()
	return false
end

-- Override this function to fill tooltip text
function InfoBarDataMixin:SetTooltipInfo(tooltip) -- luacheck: ignore
end

module.InfoBarDataMixin = InfoBarDataMixin

-- ####################################################################################################################
-- ##### InfoBarMixin #################################################################################################
-- ####################################################################################################################

local InfoBarMixin = {}

function InfoBarMixin:UpdateBar()
	local min, curr, max = self:GetValues()
	self:SetMinMaxValues(min, max)
	self:SetValue(curr)
end

function InfoBarMixin:UpdateText()
	if self.ShouldDisplayPercentText() then
		local db = module:GetDB()
		local min_, curr, max = self:GetValues()
		local percentBar = curr / max * 100
		local percentText = format("%."..db.Precision.."f%%", percentBar)
		return self.text:SetText(format("%s %s", percentText, self:GetDataText()))
	end
	return self.text:SetText(self:GetDataText())
end

function InfoBarMixin:SetBarColor(r, g, b)
	local mult = 0.4 -- Placeholder
	self:SetStatusBarColor(r, g, b)
	self.bg:SetVertexColor(r * mult, g * mult, b * mult)
end

-- ####################################################################################################################
-- ##### Module Setup #################################################################################################
-- ####################################################################################################################

-- Connects an element with a DataMixin together.
function module:CreateNewDataMixin(name)
	local newMixin = CreateFromMixins(InfoBarDataMixin)
	mixinData[name] = newMixin
	return newMixin
end

function module:CreateBar(name, dataMixin)
	if not dataMixin or not mixinData[dataMixin] then
		error("Usage: CreateBar(name, dataMixin): dataMixin is not valid")
	end

	local db = module:GetDB()

	local bar = CreateFrame("StatusBar", name, UIParent)
	bar:SetFrameStrata("HIGH")
	bar:SetSize(db.Width, db.Height)
	bar:SetStatusBarTexture(module:FetchStatusBar("ExpBar"))

	local bg = bar:CreateTexture(nil, "BORDER")
	bg:SetTexture(module:FetchStatusBar("ExpBar"))
	bg:SetAllPoints(bar)
	bar.bg = bg

	local text = module:SetFontString(bar, name.."Text", "Text", "OVERLAY", "LEFT")
	text:SetPoint("RIGHT", bar, "RIGHT", db.TextX, db.TextY)
	text:SetTextColor(1, 1, 1)
	text:SetShadowColor(0, 0, 0)
	text:SetShadowOffset(1.25, -1.25)
	bar.text = text

	Mixin(bar, InfoBarMixin, mixinData[dataMixin])

	bar:SetBarColor(module:RGB("Experience"))

	if bar:ShouldBeVisible() then
		bar:UpdateText()
		bar:UpdateBar()
		bar:Show()
	else
		bar:Hide()
	end

	return bar
end

function module:SetMainBar()
	local db = module:GetDB()

	local anchor = CreateFrame("Frame", "LUI_MainExpBar", UIParent)
	anchor:SetPoint(db.Point, UIParent, db.RelativePoint, db.X, db.Y)
	anchor:SetSize(db.Width, db.Height)
	module.anchor = anchor

	module.ExpBar = module:CreateBar("LUI_InfoBarsExp", "Experience")
	module.RepBar = module:CreateBar("LUI_InfoBarsRep", "Reputation")
	module.HonorBar = module:CreateBar("LUI_InfoBarsHonor", "Honor")
	module.AzeriteBar = module:CreateBar("LUI_InfoBarsAzerite", "Azerite")

	module.ExpBar:SetAllPointsanchor)
	module.RepBar:SetPoint("BOTTOM", module.ExpBar, "TOP", 0, 5)
	module.HonorBar:SetPoint("BOTTOM", module.RepBar, "TOP", 0, 5)
	module.AzeriteBar:SetPoint("BOTTOM", module.HonorBar, "TOP", 0, 5)
end

-- ####################################################################################################################
-- ##### Module Refresh ###############################################################################################
-- ####################################################################################################################

function module:RefreshColors()
end

function module:Refresh()
end

-- ####################################################################################################################
-- ##### Options Menu #################################################################################################
-- ####################################################################################################################

function module:LoadOptions()
	local modeList = {
		Auto = L["ExpBar_Mode_Auto"],
		Experience = L["ExpBar_Mode_Experience"],
		Reputation = L["ExpBar_Mode_Reputation"],
		Artifact = L["ExpBar_Mode_Artifact"],
		Honor = L["ExpBar_Mode_Honor"],
		None = L["ExpBar_Mode_None"]
	}

	local options = {
		Header = module:NewHeader(L["ExpBar_Name"], 1),
		Settings = module:NewRootGroup(L["Settings"], 2, nil, nil, {
			--ShowRested = module:NewToggle("Show Rested XP", nil, 2, showRestedMeta, nil, function() return true end),
			ShowText = module:NewToggle(L["ExpBar_Options_ShowText"] , nil, 3, "Refresh", "normal"),
			Precision = module:NewSlider(L["Precision"], nil, 4, 0, 3, 1, false, "Refresh"),
			Spacing = module:NewSlider(L["Spacing"], L["ExpBar_Options_Spacing_Desc"], 5, 0, 20, 1, false, "Refresh"),
			Mode1 = module:NewSelect(format(L["ExpBar_Options_BarMode_Format"], 1), L["ExpBar_Options_BarMode_Desc"],
			                            6, modeList, nil, "Refresh"),
			Mode2 = module:NewSelect(format(L["ExpBar_Options_BarMode_Format"], 2), L["ExpBar_Options_BarMode_Desc"],
			                            6, modeList, nil, "Refresh"),
			PositionHeader = module:NewHeader(L["Position"], 10),
			Position = module:NewPosition(L["ExpBar_Name"], 11, true, "Refresh"),
			Point = module:NewSelect(L["Anchor"], nil, 12, LUI.Points, nil, "Refresh"),
			RelativePoint = module:NewSelect(L["Relative Anchor"], nil, 13, LUI.Points, nil, "Refresh"),
			TextPositionHeader = module:NewHeader(L["ExpBar_Options_TextPosition"], 14),
			Text = module:NewPosition(L["ExpBar_Options_Text"], 15, nil, "Refresh"),
		}),
		Textures = module:NewRootGroup(L["Textures"], 3, nil, nil, {
			ColorHeader = module:NewHeader(L["Colors"], 20),
			BGMultiplier = module:NewSlider(L["API_BGMultiplier"], L["API_BGMultiplier_Desc"],
			                                    21, 0, 1, 0.05, true, "RefreshColors"),
			LineBreak = module:NewLineBreak(21.5),
			Experience = module:NewColorMenu(L["ExpBar_Mode_Experience"], 22, true, "RefreshColors"),
			Reputation = module:NewColorMenu(L["ExpBar_Mode_Reputation"], 23, true, "RefreshColors"),
			Artifact = module:NewColorMenu(L["ExpBar_Mode_Artifact"], 24, true, "RefreshColors"),
			Honor = module:NewColorMenu(L["ExpBar_Mode_Honor"], 25, true, "RefreshColors"),
		}),
	}

	return options
end

-- ####################################################################################################################
-- ##### Framework Events #############################################################################################
-- ####################################################################################################################

module.enableButton = true

function module:OnInitialize()
	LUI:RegisterModule(module)
end

function module:OnEnable()
	module:SetMainBar()
end

function module:OnDisable()
end