-- ####################################################################################################################
-- ##### Setup and Locals #############################################################################################
-- ####################################################################################################################

---@type Opt
local optName, Opt = ...
local LUI = LibStub("AceAddon-3.0"):GetAddon("LUI4")
local module = LUI:GetModule("Infotext")
local db = module.db.profile
local L = LUI.L

-- ####################################################################################################################
-- ##### Utility Functions ############################################################################################
-- ####################################################################################################################

local infotextAnchors = {
    TOP = L["Point_Top"],
    BOTTOM = L["Point_Bottom"],
}

local colorGet, colorSet = Opt.ColorGetSet(db.Colors)

local function InfoTextGroup(name, order)
    local group = Opt:Group(name, nil, order, nil, nil, nil, Opt.GetSet(db[name]))
    group.args.Header = Opt:Header(name, 1)
	group.args.X = Opt:Input(L["API_XValue_Name"], format(L["API_XValue_Desc"], "element"), 10) -- 10 so that we can add element specific options
	group.args.Y = Opt:Input(L["API_YValue_Name"], format(L["API_YValue_Desc"], "element"), 11)
	group.args.Point = Opt:Select(L["Anchor"], L["AnchorDesc"],  12, infotextAnchors)

    return group
end

-- ####################################################################################################################
-- ##### Options Tables ###############################################################################################
-- ####################################################################################################################

Opt.options.args.Infotext = Opt:Group("Infotexts", nil, nil, "tab", Opt.IsModDisabled, nil, Opt.GetSet(db))
Opt.options.args.Infotext.handler = module

local Infotext = {
	Header = Opt:Header(L["Info_Name"], 1),
	Settings = Opt:Group(L["Info_Individual_Name"], nil, 2),
	General = Opt:Group(L["Info_Global_Name"], nil, 3),
}

Infotext.General.args = {
	Title = Opt:Color(L["Info_TitleColor_Name"], nil, 2, false, nil, nil, nil, colorGet, colorSet),
	Hint = Opt:Color(L["Info_HintColor_Name"], nil, 3, false, nil, nil, nil, colorGet, colorSet),
	--Infotext = Opt:FontMenu("Infotext Font", nil, 4),
}

local count = 10
for name, obj in module:IterateModules() do
    Infotext.Settings.args[name] = InfoTextGroup(name, count)
    count = count + 1
end

-- Currency specific options
local currencyColorGet, currencyColorSet = Opt.ColorGetSet(db.Currency.Colors)
Infotext.Settings.args.Currency.args.HideEmptyCurrency = Opt:Toggle(L["InfoCurrency_Hide_Name"], L["InfoCurrency_Hide_Desc"], 2)
Infotext.Settings.args.Currency.args.Tracked = Opt:Color(L["InfoCurrency_Tracked_Name"], L["InfoCurrency_Tracked_Desc"], 3, true, "full", nil, nil, currencyColorGet, currencyColorSet)

Opt.options.args.Infotext.args = Infotext
