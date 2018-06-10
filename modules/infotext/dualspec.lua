-- Dualspec Infotext

-- ####################################################################################################################
-- ##### Setup and Locals #############################################################################################
-- ####################################################################################################################

local _, LUI = ...
local module = LUI:GetModule("Infotext")
local element = module:NewElement("Dualspec", "AceEvent-3.0")
local L = LUI.L

-- local copies
local select, format, tconcat = select, format, table.concat
local strsplit = string.split
local PanelTemplates_GetSelectedTab = PanelTemplates_GetSelectedTab
local GetSpecializationInfoByID = GetSpecializationInfoByID
local GetLootSpecialization = GetLootSpecialization
local PanelTemplates_SetTab = PanelTemplates_SetTab
local GetSpecializationInfo = GetSpecializationInfo
local GetActiveSpecGroup = GetActiveSpecGroup
local SetActiveSpecGroup = SetActiveSpecGroup
local GetSpecialization = GetSpecialization
local GetMaxTalentTier = GetMaxTalentTier
local GetNumSpecGroups = GetNumSpecGroups
local IsShiftKeyDown = IsShiftKeyDown
local GetTalentInfo = GetTalentInfo
local ShowUIPanel = ShowUIPanel
local HideUIPanel = HideUIPanel

-- constants
local LOOT_SPECIALIZATION_DEFAULT = strsplit("(", LOOT_SPECIALIZATION_DEFAULT):trim()
local TALENT_SPEC_SECONDARY_ACTIVE = TALENT_SPEC_SECONDARY_ACTIVE
local TALENT_SPEC_PRIMARY_ACTIVE = TALENT_SPEC_PRIMARY_ACTIVE
local SELECT_LOOT_SPECIALIZATION = SELECT_LOOT_SPECIALIZATION
local TALENT_SPEC_SECONDARY = TALENT_SPEC_SECONDARY
local TALENT_SPEC_PRIMARY = TALENT_SPEC_PRIMARY
local NUM_TALENT_COLUMNS = NUM_TALENT_COLUMNS
local LEVEL_UP_DUALSPEC = LEVEL_UP_DUALSPEC
local MAX_SPECS -- Set this during OnCreate
local TALENT_TAB_TALENTS = 2
local TALENT_TAB_GLYPHS = 3
local TALENT_DELIMITER = ""
local NONE = NONE

-- locals
local specCache = {}  -- Keep information about specs.
local talentCache = {} -- Keep information about talents.
local needNewCache = false
--TOODO: Move those two cache into the DB to carry the cache through logins. (Your specs arent going to change)

-- ####################################################################################################################
-- ##### Default Settings #############################################################################################
-- ####################################################################################################################

element.defaults = {
	profile = {
		lootSpec = true,
	},
}

-- ####################################################################################################################
-- ##### Module Functions #############################################################################################
-- ####################################################################################################################

local function HasDualSpec()
	return (GetNumSpecGroups() >= 2) and true or false
end

function element:CacheSpecInfo()
	for i = 1, MAX_SPECS do
		if not specCache[i] then
			specCache[i] = {}
			local _, name, _, icon = GetSpecializationInfo(i)
			specCache[i].name = name
			specCache[i].icon = icon
		end
	end
end

function element:ToggleTalentTab(tabID)
	TalentFrame_LoadUI()
	if PlayerTalentFrame and PlayerTalentFrame:IsShown() then
		if PanelTemplates_GetSelectedTab(PlayerTalentFrame) == tabID then
			return HideUIPanel(PlayerTalentFrame)
		end
	end
	PanelTemplates_SetTab(PlayerTalentFrame, tabID)
	PlayerTalentFrame_Refresh()
	ShowUIPanel(PlayerTalentFrame)
end

function element:GetTalentString(index)
	local ok = true
	-- Check if we need to setup a new cache.
	local inactiveGroup = 3 - GetActiveSpecGroup()
	if not needNewCache and talentCache[index] then ok = false end
	if ok and index == inactiveGroup and talentCache[inactiveGroup] then ok = false end
	-- If ok is still true, scan the talents once more.
	if ok then
		if not talentCache[index] then
			talentCache[index] = {}
		end
		for row = 1, GetMaxTalentTier() do
			local indexColumn
			for column = 1, NUM_TALENT_COLUMNS do
				if select(4, GetTalentInfo(row, column, index)) then
					indexColumn = column
				end
			end
			talentCache[index][row] = indexColumn or 0
		end
		needNewCache = false
	end
	return tconcat(talentCache[index], TALENT_DELIMITER)
end

function element:UpdateTalents()
	needNewCache = true
	element:UpdateSpec()
end

function element:UpdateSpec()
	local db = module:GetDB()
	local currentSpec = specCache[GetSpecialization()]
	local specName = (currentSpec) and currentSpec.name or L["InfoDualspec_NoSpec"]
	if db.lootSpec and GetLootSpecialization() > 0 then
		local _, lootSpec = GetSpecializationInfoByID(GetLootSpecialization())
		element.text = format("%s (%s)", specName, lootSpec)
	else
		element.text = specName
	end
	--TODO: Add Icon Support
	--element.icon = currentCache.icon
	element:UpdateTooltip()
end

-- Click: Switch Talent Group
-- Right-Click: Open Talent Frame
-- Shift-Click: Open Glyph Frame (TODO)
function element.OnClick(frame_, button)
	if IsShiftKeyDown() then
		element:ToggleTalentTab(TALENT_TAB_GLYPHS)
	elseif button == "RightButton" then
		element:ToggleTalentTab(TALENT_TAB_TALENTS)
	else
		if not HasDualSpec() then return end
		SetActiveSpecGroup(3 - GetActiveSpecGroup())
	end
end

-- ####################################################################################################################
-- ##### Infotext Display #############################################################################################
-- ####################################################################################################################

function element.OnTooltipShow(GameTooltip)
	element:TooltipHeader(LEVEL_UP_DUALSPEC)

	local activeSpecGroup = GetActiveSpecGroup()
	for i = 1, GetNumSpecGroups() do
		local currentSpec = GetSpecialization(nil, nil, i)
		local talentSpec
		if i == activeSpecGroup then
			talentSpec = (i == 1) and TALENT_SPEC_PRIMARY_ACTIVE or TALENT_SPEC_SECONDARY_ACTIVE
		else
			talentSpec = (i == 1) and TALENT_SPEC_PRIMARY or TALENT_SPEC_SECONDARY
		end
		local specName = (currentSpec) and specCache[currentSpec].name or NONE
		local talentString = element:GetTalentString(i)
		GameTooltip:AddDoubleLine(format("%s:", talentSpec), format("%s (%s)", specName, talentString), 1,1,1, 1,1,1)
	end

	GameTooltip:AddLine(" ")
	local lootSpec = select(2, GetSpecializationInfoByID(GetLootSpecialization())) or LOOT_SPECIALIZATION_DEFAULT
	GameTooltip:AddDoubleLine(format("%s:", SELECT_LOOT_SPECIALIZATION), lootSpec, 1,1,1, 1,1,1)

	element:AddHint(L["InfoDualspec_Hint_Any"], L["InfoDualspec_Hint_Right"], L["InfoDualspec_Hint_Shift"])
end

-- ####################################################################################################################
-- ##### Options Menu #################################################################################################
-- ####################################################################################################################

function element:LoadOptions()
	local options = {
			lootSpec = element:NewToggle(L["InfoDualspec_LootSpec_Name"], L["InfoDualspec_LootSpec_Desc"], 1, "UpdateSpec"),
		}
	return options
end

-- ####################################################################################################################
-- ##### Framework Events #############################################################################################
-- ####################################################################################################################

function element:OnCreate()
	MAX_SPECS = GetNumSpecializations()

	element:CacheSpecInfo()
	element:RegisterEvent("PLAYER_TALENT_UPDATE", "UpdateTalents")
	element:RegisterEvent("PLAYER_LOOT_SPEC_UPDATED", "UpdateSpec")
	element:UpdateTalents()
end
