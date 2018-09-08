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
	return true
end

function HonorDataMixin:GetValues()
	local honorCurrent = UnitHonor("player")
	local honorMax = UnitHonorMax("player")
	local honorLevel = UnitHonorLevel("player")
	local honorLevelMax = GetMaxPlayerHonorLevel()

	-- If honor is capped, show a full bar
	if honorLevel == honorLevelMax then
		return 0, 1, 1
	end

	return 0, honorCurrent, honorMax
end

function HonorDataMixin:GetDataText()
	return "Honor"
end