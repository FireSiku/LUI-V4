-- ####################################################################################################################
-- ##### Setup and Locals #############################################################################################
-- ####################################################################################################################

local _, LUI = ...
local module = LUI:GetModule("Experience Bar")
local L = LUI.L

-- ####################################################################################################################
-- ##### HonorDataMixin #############################################################################################
-- ####################################################################################################################
local HonorDataMixin = module:CreateNewDataMixin("Honor")

HonorDataMixin.BAR_EVENTS = {
	"HONOR_XP_UPDATE",
	"CVAR_UPDATE",
	"ZONE_CHANGED",
	"ZONE_CHANGED_NEW_AREA",
}

function HonorDataMixin:ShouldBeVisible()
	return IsWatchingHonorAsXP() or C_PvP.IsActiveBattlefield() or IsInActiveWorldPVP()
end

function HonorDataMixin:Update()
	local honorCurrent = UnitHonor("player")
	local honorMax = UnitHonorMax("player")

	self.barValue = honorCurrent
	self.barMax = honorMax
end

function HonorDataMixin:GetDataText()
	return "Honor"
end