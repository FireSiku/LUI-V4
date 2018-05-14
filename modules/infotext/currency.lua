-- Currency Infotext

------------------------------------------------------
-- / SETUP AND LOCALS / --
------------------------------------------------------
local _, LUI = ...
local module = LUI:GetModule("Infotext")
local element = module:NewElement("Currency", "AceEvent-3.0", "AceHook-3.0")
local L = LUI.L

-- local copies
local wipe, format, tconcat = wipe, format, table.concat
local GetBackpackCurrencyInfo = GetBackpackCurrencyInfo
local GetCurrencyListSize = GetCurrencyListSize
local GetCurrencyListInfo = GetCurrencyListInfo

-- Constants
local MAX_WATCHED_TOKENS = MAX_WATCHED_TOKENS
local CURRENCY_FORMAT = "%d\124T%s:0:0:0:0\124t"
local CURRENCY = CURRENCY

-- locals
local currencyString = {}

 -- Defaults

------------------------------------------------------
-- / MODULE FUNCTIONS / --
------------------------------------------------------
function element:GetCurrencyString()
	wipe(currencyString)
	for i = 1, MAX_WATCHED_TOKENS do
		local name, count, icon = GetBackpackCurrencyInfo(i)
		if name then
			currencyString[i] = format(CURRENCY_FORMAT,count,icon)
		end
	end
	return tconcat(currencyString, " ")
end

function element:UpdateCurrency()
	--Make sure you are watching at least one currency
	if GetBackpackCurrencyInfo(1) then
		element.text = element:GetCurrencyString()
	else
		element.text = CURRENCY
	end
end

-- Click: Open Currency Frame
function element.OnClick(frame_, button_)
	ToggleCharacter("TokenFrame")
end

function element.OnTooltipShow(GameTooltip)
	element:TooltipHeader(CURRENCY)

	for i = 1, GetCurrencyListSize() do
		local name, isHeader, _, _, isWatched, count = GetCurrencyListInfo(i)
		if isHeader then
			--Do not add an empty space for the first header.
			if i > 1 then GameTooltip:AddLine(" ") end
			GameTooltip:AddLine(name)
		elseif name then
			local r, g, b = 1, 1, 1
			if isWatched then r, g, b = 0.5, 1, 0.5 end
			if count and count ~= 0 then
				GameTooltip:AddDoubleLine(name, count, r,g,b, r,g,b)
			else
				--TODO: Ability to not show those at all.
				GameTooltip:AddDoubleLine(name, "--", r,g,b, r,g,b)
			end
		end
	end

	element:AddHint(L["InfoCurrency_Hint_Any"])
end


------------------------------------------------------
-- / API FUNCTIONS / --
------------------------------------------------------
function element:OnCreate()
	element:RegisterEvent("CURRENCY_DISPLAY_UPDATE", "UpdateCurrency")
	element:SecureHook("BackpackTokenFrame_Update", "UpdateCurrency")
	element:UpdateCurrency()
end
