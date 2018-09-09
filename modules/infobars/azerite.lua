-- ####################################################################################################################
-- ##### Setup and Locals #############################################################################################
-- ####################################################################################################################

local _, LUI = ...
local module = LUI:GetModule("Experience Bar")
local L = LUI.L

local C_AzeriteItem = C_AzeriteItem

-- ####################################################################################################################
-- ##### AzeriteDataMixin #############################################################################################
-- ####################################################################################################################
local AzeriteDataMixin = module:CreateNewDataMixin("Azerite")

function AzeriteDataMixin:ShouldBeVisible()
	local db = module:GetDB()
	if db.ShowAzerite and C_AzeriteItem.HasActiveAzeriteItem() then -- luacheck: ignore
		if C_AzeriteItem.FindActiveAzeriteItem() then
			return true
		end
	end
end

function AzeriteDataMixin:GetValues()
	local itemLocation = C_AzeriteItem.FindActiveAzeriteItem()
	local currentXP, totalXP = C_AzeriteItem.GetAzeriteItemXPInfo(itemLocation)
	self.currentXP = currentXP
	self.totalXP = totalXP

	return 0, currentXP, totalXP
end

function AzeriteDataMixin:GetDataText()
	local db = module:GetDB()
	if db.ShowAbsolute then
		return format("AP (%s / %s)", self.currentXP, self.totalXP)
	end
	return "AP"
end