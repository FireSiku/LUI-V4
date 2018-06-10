-- This module handle various UI Elements by LUI or Blizzard.

-- ####################################################################################################################
-- ##### Setup and Locals #############################################################################################
-- ####################################################################################################################

local _, LUI = ...
local module = LUI:NewModule("Experience Bar")
local L = LUI.L

-- Localize Systems
local C_Reputation = C_Reputation
local C_ArtifactUI = C_ArtifactUI
-- Localize Global Functions
local GetMaxPlayerHonorLevel = GetMaxPlayerHonorLevel
local GetWatchedFactionInfo = GetWatchedFactionInfo
local IsWatchingHonorAsXP = IsWatchingHonorAsXP
local HasArtifactEquipped = HasArtifactEquipped
local IsXPUserDisabled = IsXPUserDisabled
local UnitHonorLevel = UnitHonorLevel
local UnitHonorMax = UnitHonorMax
local CreateFrame = CreateFrame
local UnitHonor = UnitHonor
local UnitLevel = UnitLevel
local UnitXPMax = UnitXPMax
local UnitXP = UnitXP

local SHORT_REPUTATION_NAMES = {
	L["ExpBar_ShortName_Hatred"],		-- Ha
	L["ExpBar_ShortName_Hostile"],		-- Ho
	L["ExpBar_ShortName_Unfriendly"],	-- Un
	L["ExpBar_ShortName_Neutral"],		-- Ne
	L["ExpBar_ShortName_Friendly"],		-- Fr
	L["ExpBar_ShortName_Honored"],		-- Hon
	L["ExpBar_ShortName_Revered"],		-- Rev
	L["ExpBar_ShortName_Exalted"],		-- Ex
}

local MAX_LEVEL = 110

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
		BGMultiplier = 0.4,
		ShowText = true,
		Precision = 2,
		TextX = -2,
		TextY = 0,
		Spacing = 10,
		Mode1 = "Auto",
		Mode2 = "Auto",
		Colors = {
			Experience = { r = 0.6,  g = 0.6,  b = 1,    a = 1,   t = "Class", },
			Reputation = { r = 0.2,  g = 0.2,  b = 0.2,  a = 1,   t = "Class", },
			Artifact =   { r = 0.18, g = 0.18, b = 0.18, a = 0.8, t = "Class", },
			Honor =      { r = 0.18, g = 0.18, b = 0.18, a = 0.8, t = "Class", },
			Text =       { r = 1, g = 1, b = 1, },
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

-- ####################################################################################################################
-- ##### Module Functions #############################################################################################
-- ####################################################################################################################

-- Function to determine what mode the bar should be in.
function module:UpdateBarMode()
	local db = module:GetDB()

	local level = UnitLevel("player")
	local mult = db.BGMultiplier

	-- Reset the bars' visibility
	module.ExpBar:Show()
	module.ExpBar2:Show()

	-- Bar1
	-- XP Bar, Rep at level cap if watched, Honor if tracked.
	if level < MAX_LEVEL and not IsXPUserDisabled() then
		-- Exp Mode
		module.ExpBar:SetMinMaxValues(0, 100)
		module.ExpBar.mode = "Experience"
		module:UpdateXPBar(module.ExpBar)
	elseif GetWatchedFactionInfo() then
		module.ExpBar.mode = "Reputation"
		module:UpdateRepBar(module.ExpBar)
	elseif level == MAX_LEVEL and IsWatchingHonorAsXP() then
		-- Honor Mode
		module.ExpBar.mode = "Honor"
		module:UpdateHonorBar(module.ExpBar)
	else
		-- Just set mode to Exp to prevent nil issues, will be hidden anyway
		module.ExpBar.mode = "Experience"
		module.ExpBar:Hide()
	end
	local r, g, b = module:Color(module.ExpBar.mode)
	module.ExpBar:SetStatusBarColor(r, g, b)
	module.ExpBar.bg:SetVertexColor(r * mult, g * mult, b * mult)

	-- Bar2
	-- Artifact Power if an artifact is equipped, Rep if tracked under level cap.
	if HasArtifactEquipped() then
		-- Artifact Mode
		module.ExpBar2.mode = "Artifact"
		module:UpdateAPBar(module.ExpBar2)
	elseif level < MAX_LEVEL and GetWatchedFactionInfo() then
		module.ExpBar2.mode = "Reputation"
		module:UpdateRepBar(module.ExpBar2)
	else
		-- Just set mode to Exp to prevent nil issues, will be hidden anyway
		module.ExpBar2.mode = "Experience"
		module.ExpBar2:Hide()
	end
	r, g, b = module:Color(module.ExpBar2.mode)
	module.ExpBar2:SetStatusBarColor(r, g, b)
	module.ExpBar2.bg:SetVertexColor(r * mult, g * mult, b * mult)

	-- Adjust their size/anchor based on visibility.
	local shown1 = module.ExpBar:IsShown()
	local shown2 = module.ExpBar2:IsShown()
	local halfWidth = (db.Width - db.Spacing) * 0.5

	if not shown1 and not shown2 then
		--Both hidden, do nothing
		return
	elseif shown1 and shown2 then
		--Both shown, go in dual-bar mode.
		module.ExpBar:SetWidth(halfWidth)
		module.ExpBar2:SetWidth(halfWidth)
		module.ExpBar:ClearAllPoints()
		module.ExpBar2:ClearAllPoints()
		module.ExpBar:SetPoint("RIGHT", module.anchor, "RIGHT", 0, 0)
		module.ExpBar2:SetPoint("LEFT", module.anchor, "LEFT", 0, 0)
		module.ExpBar2:SetReverseFill(true)
		module.ExpBar2.text:ClearAllPoints()
		module.ExpBar2.text:SetPoint("LEFT", module.ExpBar2, "LEFT", -db.TextX, db.TextY)
	elseif shown1 and not shown2 then
		module.ExpBar:SetWidth(db.Width)
		module.ExpBar:SetAllPoints(module.anchor)
	elseif not shown1 and shown2 then
		module.ExpBar2:SetWidth(db.Width)
		module.ExpBar2:SetAllPoints(module.anchor)
		module.ExpBar2:SetReverseFill(false)
		module.ExpBar2.text:ClearAllPoints()
		module.ExpBar2.text:SetPoint("RIGHT", module.ExpBar2, "RIGHT", db.TextX, db.TextY)
	end
end

function module:UpdateXPBar(bar)
	local currXP = UnitXP("player")
	local maxXP = UnitXPMax("player")
	local percentBar = currXP * 100 / maxXP
	bar:SetValue(percentBar)

	local db = module:GetDB()
	if db.ShowText then
		bar.text:SetFormattedText("%."..db.Precision.."f%% "..L["ExpBar_Format_XP"], percentBar)
	else
		bar.text:SetText("")
	end
end

function module:UpdateRepBar(bar)
	local name, standing, barMin, barMax, barValue, factionID = GetWatchedFactionInfo()
	local repText = SHORT_REPUTATION_NAMES[standing]
	local percentBar

	--If name is nil, it shouldn't be in Rep Bar Mode.
	if not name then
		module:UpdateBarMode()
		return
	end

	-- Blizzard store reputation in an interesting way.
	-- barMin represents the minimum bound for the current standing, barMax represents the maximum bound.
	-- For example, barMin for revered is 21000 (3000+6000+12000 from Neutral to Honored), barMax is 42000.
	-- To get a 0 / 21000 representation, we have to reduce all three values by barMin.
	-- Patch 7.2 changed barMin to be equal to barMax at Exalted, so we need to handle that.

	if C_Reputation.IsFactionParagon(factionID) and barMin == barMax then
		barMin, barValue, barMax, percentBar, repText = module:GetParagonValues(factionID)
	elseif barMin == barMax then
		barMin, barMax, barValue = 0, 1, 1
		percentBar = 100
	else
		--Update display values to start at 0.
		barMax = barMax - barMin
		barValue = barValue - barMin
		barMin = 0
		percentBar = barValue * 100 / barMax
	end
	bar:SetMinMaxValues(barMin, barMax)
	bar:SetValue(barValue)

	local db = module:GetDB()
	if db.ShowText then
		bar.text:SetFormattedText("%."..db.Precision.."f%% %s" , percentBar, repText)
	else
		bar.text:SetText("")
	end
end

-- Takes: FactionID, Returns: barMin, barValue, barMax, percentBar, repText
function module:GetParagonValues(factionID)
	-- Blizzard also stores Paragon in an interesting way.
	-- currentValue is the total amount of paragon a character accrued.
	-- Need to remove threshold value out of currentValue for every reward already received.
	local currentValue, rewardThreshold, _,  rewardPending = C_Reputation.GetFactionParagonInfo(factionID)

	currentValue = (currentValue - rewardThreshold) % rewardThreshold
	local percentBar = currentValue * 100 / rewardThreshold

	if rewardPending then
		-- If there's a reward pending, the bar should be full, adjust percent value to be above 100%
		-- Also lets register for quest turn in to know when the reward isn't pending anymore.
		module:RegisterEvent("QUEST_LOG_UPDATE", "UpdateBarMode")
		return 0, rewardThreshold, rewardThreshold, percentBar + 100, L["ExpBar_ShortName_Reward"]
	else
		module:UnregisterEvent("QUEST_LOG_UPDATE")
		return 0, currentValue, rewardThreshold, percentBar, L["ExpBar_ShortName_Paragon"]
	end
end

function module:UpdateAPBar(bar)
	local _, _, _, _, totalXP, pointsSpent, _, _, _, _, _, _, tier = C_ArtifactUI.GetEquippedArtifactInfo()
    local numPoints, xp, xpNextPoint = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP(pointsSpent, totalXP, tier)

	local percentBar = xp * 100 / xpNextPoint
	bar:SetMinMaxValues(0, xpNextPoint)
	bar:SetValue(xp)
	local db = module:GetDB()
	if db.ShowText then
		if numPoints > 0 then
			bar.text:SetFormattedText("%."..db.Precision.."f%%"..L["ExpBar_Format_AP_Level"] , percentBar, numPoints)
		else
			bar.text:SetFormattedText("%."..db.Precision.."f%% "..L["ExpBar_Format_AP"] , percentBar)
		end
	else
		bar.text:SetText("")
	end
end

function module:UpdateHonorBar(bar)
	local honorCurrent = UnitHonor("player")
	local honorMax = UnitHonorMax("player")
	local honorLevel = UnitHonorLevel("player")
	local honorLevelMax = GetMaxPlayerHonorLevel()

	local percentBar
	--If honor is level capped, show a full bar.
	if honorLevel == honorLevelMax then
		bar:SetMinMaxValues(0, 1)
		bar:SetValue(1)
		percentBar = 100
	else
		bar:SetMinMaxValues(0, honorMax)
		bar:SetValue(honorCurrent)
		percentBar = honorCurrent * 100 / honorMax
	end
	local db = module:GetDB()
	if db.ShowText then
		bar.text:SetFormattedText("%."..db.Precision.."f%% "..L["ExpBar_Format_Honor"], percentBar, honorLevel)
	else
		bar.text:SetText("")
	end
end

-- ####################################################################################################################
-- ##### Module Setup #################################################################################################
-- ####################################################################################################################

function module:CreateBar(name)
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
	text:SetShadowColor(0,0,0)
	text:SetShadowOffset(1.25, -1.25)
	text:SetPoint("RIGHT", bar, "RIGHT", db.TextX, db.TextY)
	text:SetTextColor(module:Color("Text"))
	bar.text = text

	bar:Show()
	return bar
end

function module:SetBar()
	local db = module:GetDB()

	local anchor = CreateFrame("Frame", "LUI_ExpBarAnchor", UIParent)
	anchor:SetPoint(db.Point, UIParent, db.RelativePoint, db.X, db.Y)
	anchor:SetSize(db.Width, db.Height)
	module.anchor = anchor

	module.ExpBar = module:CreateBar("LUI_ExpBar")
	module.ExpBar2 = module:CreateBar("LUI_ExpBar2")

	module.ExpBar:SetAllPoints(anchor)
	--module.ExpBar2:SetPoint("BOTTOM", anchor, "TOP", 0, 2)

	module:UpdateBarMode()
end

-- ####################################################################################################################
-- ##### Module Refresh ###############################################################################################
-- ####################################################################################################################

function module:RefreshColors()
	local db = module:GetDB()
	local mult = db.BGMultiplier
	-- Bar 1
	local r1, g1, b1 = module:Color(module.ExpBar.mode)
	module.ExpBar:SetStatusBarColor(r1, g1, b1)
	module.ExpBar.bg:SetVertexColor(r1 * mult, g1 * mult, b1 * mult)
	-- Bar 2
	local r2, g2, b2 = module:Color(module.ExpBar.mode)
	module.ExpBar:SetStatusBarColor(r2, g2, b2)
	module.ExpBar.bg:SetVertexColor(r2 * mult, g2 * mult, b2 * mult)
end

function module:Refresh()
	module:UpdateBarMode()
end

-- ####################################################################################################################
-- ##### Options Menu #################################################################################################
-- ####################################################################################################################

function module:LoadOptions()
	--local showRestedMeta = {disabledTooltip = "Not Implemented Yet", setfunc = "Refresh"}
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
		Settings = module:NewGroup(L["Settings"], 2, nil, nil, {
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
		Textures = module:NewGroup(L["Textures"], 3, nil, nil, {
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
	module:SetBar()
	--Note: Kinda greedy event listeners. If tracking rep, it would check for rep again when you gain exp.
	module:RegisterEvent("PLAYER_XP_UPDATE", "UpdateBarMode")
	module:RegisterEvent("ARTIFACT_UPDATE", "UpdateBarMode")
	module:RegisterEvent("ARTIFACT_XP_UPDATE", "UpdateBarMode")
	module:RegisterEvent("UPDATE_EXHAUSTION", "UpdateBarMode")
	module:RegisterEvent("UPDATE_FACTION", "UpdateBarMode")
	module:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", "UpdateBarMode")
end

function module:OnDisable()
end
