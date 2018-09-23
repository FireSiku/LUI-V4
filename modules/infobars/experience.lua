-- ####################################################################################################################
-- ##### Setup and Locals #############################################################################################
-- ####################################################################################################################

local _, LUI = ...
local module = LUI:GetModule("Experience Bar")
local L = LUI.L

-- ####################################################################################################################
-- ##### ExperienceDataMixin #############################################################################################
-- ####################################################################################################################
local ExperienceDataMixin = module:CreateNewDataMixin("Experience")

ExperienceDataMixin.BAR_EVENTS = {
    "PLAYER_XP_UPDATE",
}

function ExperienceDataMixin:ShouldBeVisible()
    if IsXPUserDisabled() then
        return false
    end

    return not IsPlayerAtEffectiveMaxLevel()
end

function ExperienceDataMixin:GetValues()
	local currentXP = UnitXP("player")
	local maxXP = UnitXPMax("player")

	return 0, currentXP, maxXP
end

function ExperienceDataMixin:GetDataText()
	return "XP"
end