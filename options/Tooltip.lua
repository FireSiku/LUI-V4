-- ####################################################################################################################
-- ##### Setup and Locals #############################################################################################
-- ####################################################################################################################
---@type Opt
local optName, Opt = ...
local LUI = LibStub("AceAddon-3.0"):GetAddon("LUI4")
local module = LUI:GetModule("Tooltip")
local db = module.db.profile
local L = LUI.L

-- ####################################################################################################################
-- ##### Utility Functions ############################################################################################
-- ####################################################################################################################
local colorGet, colorSet = Opt.ColorGetSet(db.Colors)

local function DisableIfTooltipsHidden()
    return db.HideCombat
end

-- ####################################################################################################################
-- ##### Options Tables ###############################################################################################
-- ####################################################################################################################
Opt.options.args.Tooltip = Opt:Group("Tooltip", nil, nil, "tab", Opt.IsModDisabled, nil, Opt.GetSet(db))
Opt.options.args.Tooltip.handler = module
local Tooltip = {
    Header = Opt:Header(L["Tooltip_Name"], 1),
    HideCombat = Opt:Toggle(L["Tooltip_HideCombat_Name"], L["Tooltip_HideCombat_Desc"], 2, nil, "double"),
	HideCombatSkills = Opt:Toggle(L["Tooltip_HideCombatSkills_Name"], L["Tooltip_HideCombatSkills_Desc"], 3, nil, "double", DisableIfTooltipsHidden),
	HideCombatUnit = Opt:Toggle(L["Tooltip_HideCombatUnit_Name"], L["Tooltip_HideCombatUnit_Desc"], 4, nil, "double", DisableIfTooltipsHidden),
	HideUF = Opt:Toggle(L["Tooltip_HideUF_Name"], L["Tooltip_HideUF_Desc"], 5, nil, "double"),
	HidePVP = Opt:Toggle(L["Tooltip_HidePVP_Name"], L["Tooltip_HidePVP_Desc"], 6, nil, "double"),
    ShowSex = Opt:Toggle(L["Tooltip_ShowSex_Name"], L["Tooltip_ShowSex_Desc"], 7),
    Scale = Opt:Slider(L["Tooltip_Scale_Name"], L["Tooltip_Scale_Desc"], 8, Opt.ScaleValues),

    -- Cursor = Opt:Toggle(L["Tooltip_Cursor_Name"], L["Tooltip_Cursor_Desc"], 1),
	-- PosDesc = module:NewDesc(L["Tooltip_PosDesc"], 2),
	-- Positions = module:NewPosition(L["Tooltip_Positions"], 3, true, true),

    AppHeader = Opt:Header("Appeareance", 10),
    HealthBar = Opt:MediaStatusbar(L["Tooltip_HealthBar_Name"], L["Tooltip_HealthBar_Desc"], 11),
    BorderSize = Opt:Slider(L["Tooltip_BorderSize_Name"], L["Tooltip_BorderSize_Desc"], 12, {min = 1, max = 30, step = 1}),
    Guild = Opt:Color(GUILD, nil, 12, false, nil, nil, nil, colorGet, colorSet),
    MyGuild = Opt:Color(L["Tooltip_MyGuild"], nil, 12, false, nil, nil, nil, colorGet, colorSet),
    SpacerHB = Opt:Spacer(13, "full"),
    BorderTexture = Opt:MediaBorder(L["Tooltip_BorderTex_Name"], L["BorderDesc"], 14, "double"),
    --Border = Opt:ColorMenu(Tooltip, "Border", nil, 15),
    BorderColorType = Opt:Select("Border Color", nil, 15, LUI.ColorTypes, nil, nil, nil, function(info) return db.Colors.Border.t end, function(info, value) db.Colors.Border.t = value end),
    Border = Opt:Color("Individual Color", nil, 16, true, nil, nil, nil, colorGet, colorSet),
    SpacerBD = Opt:Spacer(17, "full"),
    BgTexture = Opt:MediaBackground(L["Tooltip_BackgroundTex_Name"], L["BackgroundDesc"], 18, "double"),
    BgColorType = Opt:Select("Background Color", nil, 19, LUI.ColorTypes, nil, nil, nil, function(info) return db.Colors.Background.t end, function(info, value) db.Colors.Background.t = value end),
    Background = Opt:Color("Individual Color", nil, 20, true, nil, nil, nil, colorGet, colorSet),
    --Background = Opt:ColorMenu(Tooltip, "Background", nil, 18),
    SpacerBG = Opt:Spacer(21, "full"),
}

Opt.options.args.Tooltip.args = Tooltip