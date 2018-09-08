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
    local level = UnitLevel("player")
    if IsXPUserDisabled() then
        return false
    end
    return level < MAX_LEVEL
end

function ExperienceDataMixin:GetValues()
	local currentXP = UnitXP("player")
	local maxXP = UnitXPMax("player")

	return 0, currentXP, maxXP
end

function ExperienceDataMixin:GetDataText()
	return "XP"
end