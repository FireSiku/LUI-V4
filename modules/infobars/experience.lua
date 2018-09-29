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

function ExperienceDataMixin:Update()
	local currentXP = UnitXP("player")
    local maxXP = UnitXPMax("player")

    self.barValue = currentXP
    self.barMax = maxXP
end

function ExperienceDataMixin:GetDataText()
	return "XP"
end