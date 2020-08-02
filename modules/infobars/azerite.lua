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

AzeriteDataMixin.BAR_EVENTS = {
	"AZERITE_ITEM_EXPERIENCE_CHANGED",
}

function AzeriteDataMixin:ShouldBeVisible()
	local db = module.db.profile
	if db.ShowAzerite and C_AzeriteItem.HasActiveAzeriteItem() then
		if C_AzeriteItem.FindActiveAzeriteItem() then
			return true
		end
	end
end

function AzeriteDataMixin:Update()
	local itemLocation = C_AzeriteItem.FindActiveAzeriteItem()
	local currentXP, totalXP = C_AzeriteItem.GetAzeriteItemXPInfo(itemLocation)
	self.barValue = currentXP
	self.barMax = totalXP
end

function AzeriteDataMixin:GetDataText()
	local db = module.db.profile
	if db.ShowAbsolute then
		return format("AP (%s / %s)", self.barValue, self.barMax)
	end
	return "AP"
end