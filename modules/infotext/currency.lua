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

-- ####################################################################################################################
-- ##### Module Functions #############################################################################################
-- ####################################################################################################################

function element:GetCurrencyString()
	wipe(currencyString)
	for i = 1, MAX_WATCHED_TOKENS do
		local info = C_CurrencyInfo.GetBackpackCurrencyInfo(i)
		if info.name and info.discovered then
			currencyString[i] = format(CURRENCY_FORMAT, info.quantity, info.iconFielID, 0, 0)
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

	for i = 1, C_CurrencyInfo.GetCurrencyListSize() do
		local info = C_CurrencyInfo.GetCurrencyListInfo(i)
		if info.isHeader then
			--Do not add an empty space for the first header.
			if i > 1 then GameTooltip:AddLine(" ") end
			GameTooltip:AddLine(info.name)
		elseif info.discovered and info.name then
			local r, g, b = 1, 1, 1
			if info.isShowInBackpack then r, g, b = 0.5, 1, 0.5 end
			if info.quantity and info.quantity ~= 0 then
				GameTooltip:AddDoubleLine(info.name, info.quantity, r,g,b, r,g,b)
			else
				--TODO: Ability to not show those at all.
				GameTooltip:AddDoubleLine(info.name, "--", r,g,b, r,g,b)
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
