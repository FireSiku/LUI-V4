-- ####################################################################################################################
-- ##### Setup and Locals #############################################################################################
-- ####################################################################################################################
---@type Opt
local optName, Opt = ...
local LUI = LibStub("AceAddon-3.0"):GetAddon("LUI4")
local L = LUI.L

-- ####################################################################################################################
-- ##### Utility Functions ############################################################################################
-- ####################################################################################################################

Opt.options.args.General = Opt:Group("General", nil, 1, "tab", nil, nil, Opt.GetSet(LUI.db.profile))
Opt.options.args.General.handler = LUI
local General = Opt.options.args.General.args

General.Welcome = Opt:Group(L["Core_Welcome"], nil, 1)
General.Welcome.args = {
    IntroText = Opt:Desc(L["Core_IntroText"], 3),
    VerText = Opt:Desc(format("%s: %s", GAME_VERSION_LABEL, GetAddOnMetadata("LUI4", "Version")), 4),
    RevText = Opt:Desc(format(L["Core_Revision_Format"], LUI.curseVersion or "???"), 5),
    Header = Opt:Header("General Settings", 10),
    Master = Opt:FontMenu("Master Font", nil, 11),
}