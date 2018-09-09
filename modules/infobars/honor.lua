-- ####################################################################################################################
-- ##### Setup and Locals #############################################################################################
-- ####################################################################################################################

local _, LUI = ...
local module = LUI:GetModule("Info Bars")
local L = LUI.L

-- ####################################################################################################################
-- ##### HonorDataMixin #############################################################################################
-- ####################################################################################################################
local HonorDataMixin = module:CreateNewDataMixin("Honor")

function HonorDataMixin:ShouldBeVisible()
	return IsWatchingHonorAsXP() or InActiveBattlefield() or IsInActiveWorldPVP()
end

function HonorDataMixin:GetValues()
	local honorCurrent = UnitHonor("player")
	local honorMax = UnitHonorMax("player")

	return 0, honorCurrent, honorMax
end

function HonorDataMixin:GetDataText()
	return "Honor"
end