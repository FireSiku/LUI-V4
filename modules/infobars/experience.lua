-- ####################################################################################################################
-- ##### Setup and Locals #############################################################################################
-- ####################################################################################################################

local _, LUI = ...
local module = LUI:GetModule("Info Bars")
local L = LUI.L

-- ####################################################################################################################
-- ##### ExperienceDataMixin #############################################################################################
-- ####################################################################################################################
local ExperienceDataMixin = module:CreateNewDataMixin("Experience")

function ExperienceDataMixin:ShouldBeVisible()
    if IsXPUserDisabled() then
        return false
    end

    local level = UnitLevel("player")
    local expansionLevel = GetExpansionLevel()
    local maxLevel = GetMaxLevelForExpansionLevel(expansionLevel)
    return level < maxLevel
end

function ExperienceDataMixin:GetValues()
	local currentXP = UnitXP("player")
	local maxXP = UnitXPMax("player")

	return 0, currentXP, maxXP
end

function ExperienceDataMixin:GetDataText()
	return "XP"
end