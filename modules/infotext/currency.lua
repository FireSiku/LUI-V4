-- Currency Infotext

-- ####################################################################################################################
-- ##### Setup and Locals #############################################################################################
-- ####################################################################################################################

local _, LUI = ...
local module = LUI:GetModule("Infotext")
local element = module:NewElement("Currency", "AceEvent-3.0", "AceHook-3.0")
local L = LUI.L

-- local copies
local wipe, format, tconcat = wipe, format, table.concat
local C_CurrencyInfo = C_CurrencyInfo

-- Constants
local MAX_WATCHED_TOKENS = MAX_WATCHED_TOKENS
local CURRENCY_FORMAT = "%d\124T%s:%d:%d:2:0\124t"
local CURRENCY = CURRENCY

-- locals
local currencyString = {}

-- ####################################################################################################################
-- ##### Default Settings #############################################################################################
-- ####################################################################################################################

element.defaults = {
	profile = {
		Point = "TOP",
		X = 750,
		HideEmptyCurrency = false,
		Colors = {
			Tracked = { r = 0.5, g = 1, b = 0.5 },
		},
	},
}

module:MergeDefaults(element.defaults, "Currency")

-- ####################################################################################################################
-- ##### Module Functions #############################################################################################
-- ####################################################################################################################

function element:GetCurrencyString()
	wipe(currencyString)
	for i = 1, MAX_WATCHED_TOKENS do
		local info = C_CurrencyInfo.GetBackpackCurrencyInfo(i)
		if info and info.name then
			currencyString[i] = format(CURRENCY_FORMAT, info.quantity, info.iconFileID, 0, 0)
		end
	end
	return tconcat(currencyString, " ")
end

function element:UpdateCurrency()
	--Make sure you are watching at least one currency
	if C_CurrencyInfo.GetBackpackCurrencyInfo(1) then
		element.text = element:GetCurrencyString()
	else
		element.text = CURRENCY
	end
end

-- Click: Open Currency Frame
function element.OnClick(frame_, button_)
	ToggleCharacter("TokenFrame")
end

-- ####################################################################################################################
-- ##### Infotext Display #############################################################################################
-- ####################################################################################################################

function element.OnTooltipShow(GameTooltip)
	element:TooltipHeader(CURRENCY)

	local db = module:GetDB("Currency")
	
	local firstHeader = true

	for i = 1, C_CurrencyInfo.GetCurrencyListSize() do
		local info = C_CurrencyInfo.GetCurrencyListInfo(i)
		if info.isHeader then
			-- Only display header if expanded
			if info.isHeaderExpanded then
				--Do not add an empty space for the first header.
				if not firstHeader then
					GameTooltip:AddLine(" ")
				else
					firstHeader = false
				end
				GameTooltip:AddLine(info.name)
			end
		elseif info.name then
			local r, g, b = 1, 1, 1
			if info.isShowInBackpack then r, g, b = element:RGB("Tracked") end
			if info.quantity and info.quantity ~= 0 then
				GameTooltip:AddDoubleLine(info.name, info.quantity, r,g,b, r,g,b)
			else
				if not db.HideEmptyCurrency then
					GameTooltip:AddDoubleLine(info.name, "--", r,g,b, r,g,b)
				end
			end
		end
	end

	element:AddHint(L["InfoCurrency_Hint_Any"])
end

-- ####################################################################################################################
-- ##### Framework Events #############################################################################################
-- ####################################################################################################################

function element:OnCreate()
	element:RegisterEvent("CURRENCY_DISPLAY_UPDATE", "UpdateCurrency")
	element:SecureHook("BackpackTokenFrame_Update", "UpdateCurrency")
	element:UpdateCurrency()
end
