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
local module = LUI:NewModule("Experience Bar", "AceHook-3.0")
local L = LUI.L
local db

local mixinData = {}
local barsList = {}
local mainBarList = {}
local mainBarsCreated

-- ####################################################################################################################
-- ##### Default Settings #############################################################################################
-- ####################################################################################################################

module.defaults = {
	profile = {
		Width = 475,
		Height = 12,
		X = 0,
		Y = 6,
		Point = "BOTTOM",
		RelativePoint = "BOTTOM",
		ShowRested = false,
		ShowText = true,
		ShowAzerite = true,
		Precision = 2,
		TextX = -2,
		TextY = 0,
		Spacing = 10,
		ExpBarFill = "Gradient",
		ExpBarBg = "Minimalist",
		Colors = {
			Experience = { r = 0.6,  g = 0.6,  b = 1,    a = 1,   t = "Class", },
			Reputation = { r = 0.2,  g = 0.2,  b = 0.2,  a = 1,   t = "Class", },
			Azerite =    { r = 0.2,  g = 0.2,  b = 0.2,  a = 1,   t = "Class", },
			Honor =      { r = 0.18, g = 0.18, b = 0.18, a = 0.8, t = "Class", },
		},
		Fonts = {
			Text = { Name = "NotoSans-SCB", Size = 14, Flag = "NONE" },
		},
	},
}

-- ####################################################################################################################
-- ##### InfoBarDataMixin #############################################################################################
-- ####################################################################################################################

local InfoBarDataMixin = {
	barMin = 0,
	barValue = 0,
	barMax = 1,
}

-- Override this function to update values whenever events are fired.
function InfoBarDataMixin:Update()
	self.barMin = 0
	self.barValue = 0
	self.barMax = 1
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

-- ####################################################################################################################
-- ##### InfoBarMixin #################################################################################################
-- ####################################################################################################################

local InfoBarMixin = {}

function InfoBarMixin:UpdateBar(event, ...)
	if self:IsVisible() then
		self:Update(event, ...)
		self:SetMinMaxValues(self.barMin, self.barMax)
		self:SetValue(self.barValue)
		self:UpdateText()
	end
end

function InfoBarMixin:UpdateText()
	if self.ShouldDisplayPercentText() then
		local percentBar = self.barValue / self.barMax * 100
		local percentText = format("%."..db.Precision.."f%%", percentBar)
		return self.text:SetText(format("%s %s", percentText, self:GetDataText() or ""))
	end
	return self.text:SetText(self:GetDataText())
end

function InfoBarMixin:UpdateVisibility()
	if self:ShouldBeVisible() then
		self:Show()
	else
		self:Hide()
	end
end

function InfoBarMixin:UpdateTextVisibility()
	if db.ShowText then
		self.text:Show()
	else
		self.text:Hide()
	end
end

function InfoBarMixin:SetBarColor(r, g, b)
	local mult = 0.4 -- Placeholder for LUI:GetBGMultiplier
	self:SetStatusBarColor(r, g, b)
	self.bg:SetVertexColor(r * mult, g * mult, b * mult)
end

function InfoBarMixin:RegisterEvents()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	if not self.BAR_EVENTS then return end
	for i, event in ipairs(self.BAR_EVENTS) do
		self:RegisterEvent(event)
	end
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

	local bar = CreateFrame("StatusBar", name, UIParent)
	bar:SetFrameStrata("HIGH")
	bar:SetSize(db.Width, db.Height)
	bar:SetStatusBarTexture(module:FetchStatusBar("ExpBarFill"))

	local bg = bar:CreateTexture(nil, "BORDER")
	bg:SetTexture(module:FetchStatusBar("ExpBarFill"))
	bg:SetAllPoints(bar)
	bar.bg = bg

	local text = module:SetFontString(bar, name.."Text", "Text", "OVERLAY", "LEFT")
	text:SetPoint("RIGHT", bar, "RIGHT", db.TextX, db.TextY)
	text:SetTextColor(1, 1, 1)
	text:SetShadowColor(0, 0, 0)
	text:SetShadowOffset(1.25, -1.25)
	bar.text = text

	Mixin(bar, InfoBarMixin, mixinData[dataMixin])
	bar:SetScript("OnEvent", bar.UpdateBar)
	bar:RegisterEvents()
	
	bar:SetBarColor(module:RGB("Experience"))
	bar:UpdateTextVisibility()
	bar:UpdateVisibility()
	bar:UpdateBar()

	tinsert(barsList, bar)
	return bar
end

-- ####################################################################################################################
-- ##### Main Bar #####################################################################################################
-- ####################################################################################################################

function module:IterateMainBars()
	local i, n = 0, #mainBarList
	return function()
		i = i + 1
		if i <= n then
			return mainBarList[i]
		end
	end
end

function module:SetMainBar()

	local anchor = CreateFrame("Frame", "LUI_MainExpBar", UIParent)
	anchor:SetPoint(db.Point, UIParent, db.RelativePoint, db.X, db.Y)
	anchor:SetSize(db.Width, db.Height)
	
	anchor:RegisterEvent("PLAYER_ENTERING_WORLD");
	anchor:RegisterEvent("UPDATE_EXPANSION_LEVEL");
	anchor:RegisterEvent("UPDATE_FACTION");
	anchor:RegisterEvent("ENABLE_XP_GAIN");
	anchor:RegisterEvent("DISABLE_XP_GAIN");
	anchor:RegisterEvent("ZONE_CHANGED");
	anchor:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	anchor:RegisterUnitEvent("UNIT_LEVEL", "player")
	anchor:SetScript("OnEvent", function() module:UpdateMainBarVisibility() end)
	module:SecureHook(StatusTrackingBarManager, "UpdateBarsShown", "UpdateMainBarVisibility")

	local expBar = module:CreateBar("LUI_InfoBarsExp", "Experience")
	local repBar = module:CreateBar("LUI_InfoBarsRep", "Reputation")
	local honorBar = module:CreateBar("LUI_InfoBarsHonor", "Honor")
	local azeriteBar = module:CreateBar("LUI_InfoBarsAzerite", "Azerite")
	mainBarList = {expBar, repBar, honorBar, azeriteBar}

	for bar in module:IterateMainBars() do
		bar:SetPoint("RIGHT", anchor, "RIGHT")
	end

	module.anchor = anchor
	module.ExpBar = expBar
	module.RepBar = repBar
	module.HonorBar = honorBar
	module.AzeriteBar = azeriteBar
	mainBarsCreated = true
end

function module:UpdateMainBarVisibility()
	local barLeft, barRight

	-- Check which bars can be visible at the moment
	local expShown = module.ExpBar:ShouldBeVisible()
	local repShown = module.RepBar:ShouldBeVisible()
	local honorShown = module.HonorBar:ShouldBeVisible()
	local apShown = module.AzeriteBar:ShouldBeVisible()
	
	-- Decide which bars should be ultimately shown.
	if expShown then
		barRight = module.ExpBar
		if apShown then
			barLeft = module.AzeriteBar
		elseif honorShown then
			barLeft = module.HonorBar
		elseif repShown then
			barLeft = module.RepBar
		end
	elseif apShown then
		barRight = module.AzeriteBar
		if honorShown then
			barLeft = module.HonorBar
		elseif repShown then
			barLeft = module.RepBar
		end
	elseif honorShown then
		barRight = module.HonorBar
		if repShown then
			barLeft = module.RepBar
		end
	elseif repShown then
		barRight = module.RepBar
	end

	-- Force the main bars to be hidden.
	for bar in module:IterateMainBars() do
		bar:Hide()
	end

	-- Adjust size and visibility
	if barRight then
		barRight:ClearAllPoints()
		barRight:SetReverseFill(false)
		barRight:SetPoint("RIGHT", module.anchor, "RIGHT")
		barRight.text:SetPoint("RIGHT", barRight, "RIGHT", db.TextX, db.TextY)
		barRight:Show()
		if barLeft then
			local halfWidth = (db.Width - db.Spacing) * 0.5
			barRight:SetWidth(halfWidth)
			barLeft:SetWidth(halfWidth)
			barLeft:ClearAllPoints()
			barLeft:SetReverseFill(true)
			barLeft:SetPoint("LEFT", module.anchor, "LEFT")
			barLeft.text:SetPoint("LEFT", barLeft, "LEFT", -db.TextX, db.TextY)
			barLeft:Show()
		else
			barRight:SetWidth(db.Width)
		end
	end
end

-- ####################################################################################################################
-- ##### Module Refresh ###############################################################################################
-- ####################################################################################################################

function module:RefreshColors()
	for bar in module:IterateMainBars() do
		bar:SetBarColor(module:RGB("Experience"))
	end
end

function module:Refresh()
	module.anchor:SetPoint(db.Point, UIParent, db.RelativePoint, db.X, db.Y)
	module.anchor:SetSize(db.Width, db.Height)
	for bar in module:IterateMainBars() do
		bar:SetStatusBarTexture(module:FetchStatusBar("ExpBarFill"))
		bar.bg:SetTexture(module:FetchStatusBar("ExpBarFill"))
		bar:UpdateTextVisibility()
		bar:UpdateText()
	end
	module:UpdateMainBarVisibility()
end

-- ####################################################################################################################
-- ##### Framework Events #############################################################################################
-- ####################################################################################################################

module.enableButton = true

function module:OnInitialize()
	LUI:RegisterModule(module)
	db = module.db.profile
end

function module:OnEnable()
	if not mainBarsCreated then
		module:SetMainBar()
	end
	module:UpdateMainBarVisibility()
end

function module:OnDisable()
	module.anchor:Hide()
end
