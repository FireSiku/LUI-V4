-- ####################################################################################################################
-- ##### Setup and Locals #############################################################################################
-- ####################################################################################################################

---@type Opt
local optName, Opt = ...
local LUI = LibStub("AceAddon-3.0"):GetAddon("LUI4")
local module = LUI:GetModule("Micromenu")
local db = module.db.profile
local L = LUI.L

-- ####################################################################################################################
-- ##### Utility Functions ############################################################################################
-- ####################################################################################################################

local dropDirections = {
    LEFT = L["Point_Left"],
    RIGHT = L["Point_Right"],
}
local colorGet, colorSet = Opt.ColorGetSet(db.Colors)

-- ####################################################################################################################
-- ##### Options Tables ###############################################################################################
-- ####################################################################################################################

Opt.options.args.Micromenu = Opt:Group("Micromenu", nil, nil, "tab", Opt.IsModDisableda1, nil, Opt.GetSet(db))
Opt.options.args.Micromenu.handler = module

local Micromenu = {
    Header = Opt:Header(L["Micro_Name"], 1),
	HideShop = Opt:Toggle("Hide Blizzard Store", nil, 2),
	Spacing = Opt:Slider(L["Spacing"], L["MicroOptions_Spacing_Desc"], 3, { min = -10, max = 10, step = 1}),
    PositionHeader = Opt:Header(L["Position"], 4),
    X = Opt:Input("X Value", nil, 5),
    Y = Opt:Input("Y Value", nil, 6),
	--Position = Opt:Position(L["Micro_Name"], 5, true),
	Point = Opt:Select(L["Anchor"], nil,  7, LUI.Points),
	Direction = Opt:Select(L["MicroOptions_Direction_Name"], L["MicroOptions_Direction_Desc"], 8, dropDirections),
	ColorHeader = Opt:Header(L["Colors"], 10),
    Micromenu = Opt:Color(L["Micro_Name"], nil, 12, true, nil, nil, nil, colorGet, colorSet),
    Background = Opt:Color(L["Background"], nil, 13, true, nil, nil, nil, colorGet, colorSet),
}

Opt.options.args.Micromenu.args = Micromenu