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
local SetSpecialization = SetSpecialization
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
local inactiveCache = {} -- Keep information about inactive specs
local needNewCache = false
--TODO: Move those >three< cache into the DB to carry the cache through logins. (Your specs arent going to change)

-- ####################################################################################################################
-- ##### Default Settings #############################################################################################
-- ####################################################################################################################

element.defaults = {
	profile = {
		lootSpec = true,
	},
}

module:MergeDefaults(element.defaults, "DualSpec")

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
	-- TODO inactiveCache initial setup here ?
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
	local currentSpecID = GetSpecialization()
	local currentSpec = specCache[currentSpecID]
	local specName = (currentSpec) and currentSpec.name or L["InfoDualspec_NoSpec"]
	if module.db.profile.lootSpec and GetLootSpecialization() > 0 then
		local _, lootSpec = GetSpecializationInfoByID(GetLootSpecialization())
		element.text = format("%s (%s)", specName, lootSpec)
	else
		element.text = specName
	end

	--TODO: Add Icon Support
	--element.icon = currentCache.icon

	inactiveCache = {} -- reset inactive cache for rebuild
	for i = 1, MAX_SPECS do -- loop through all specs
		if i ~= currentSpecID then -- not the active spec, put in inactive
			inactiveCache[#inactiveCache + 1] = i -- add to inactive cache
		end
	end

	element:UpdateTooltip()
end

-- Left-Click: Switch to inactive spec 1
-- Right-Click: Switch to inactive spec 2
-- Middle-Click: Switch to inactive spec 3 ( druid only )
-- Shift-Click: Toggle Talent Frame -- TODO causes tooltip background to turn white temporarily ??
function element.OnClick(frame_, button)
	--if IsShiftKeyDown() then
	--	element:ToggleTalentTab(TALENT_TAB_TALENTS) -- taken from original code's right click function
	if button == "LeftButton" and inactiveCache[1] then -- switch to inactive spec 1 if valid
		SetSpecialization(inactiveCache[1])
	elseif button == "RightButton" and inactiveCache[2] then -- spec 2
		SetSpecialization(inactiveCache[2])
	elseif button == "MiddleButton" and inactiveCache[3] then -- spec 3 (druid only)
		SetSpecialization(inactiveCache[3])
	end
end

-- ####################################################################################################################
-- ##### Infotext Display #############################################################################################
-- ####################################################################################################################

function element.OnTooltipShow(GameTooltip)
	element:TooltipHeader(LEVEL_UP_DUALSPEC)

	local activeSpec = GetSpecialization() -- get current spec ID
	local dualspecHint = "" -- text string with hint to be displayed

	for i = 1, MAX_SPECS do -- loop through all specs
		local specNum = (format(L["InfoDualspec_Spec_Num"], i)) -- numerate specs
		local specName = (specCache[i].name) -- list spec names

		if i == activeSpec then -- highlight active spec
			local highlight = CreateColor(1, 1, 0)
			specNum = highlight:WrapTextInColorCode(specNum)
			specName = highlight:WrapTextInColorCode(specName)
		end
		GameTooltip:AddDoubleLine(specNum, specName, 1,1,1, 1,1,1)
	end

	-- loot spec text from original code
	GameTooltip:AddLine(" ")
	local lootSpec = select(2, GetSpecializationInfoByID(GetLootSpecialization())) or LOOT_SPECIALIZATION_DEFAULT
	GameTooltip:AddDoubleLine(format("%s:", SELECT_LOOT_SPECIALIZATION), lootSpec, 1,1,1, 1,1,1)

	for i = 1, #inactiveCache do -- go through inactive specs
		dualspecHint = dualspecHint .. format(L[format("InfoDualspec_Hint_%d", i)], specCache[inactiveCache[i]].name) -- add hint for current inactive spec
		if i < #inactiveCache then dualspecHint = dualspecHint .. "\n" end -- separate lines if not last line
	end

	element:AddHint(dualspecHint) -- .. L["InfoDualspec_Hint_Shift"]
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
