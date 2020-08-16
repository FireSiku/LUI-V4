-- ####################################################################################################################
-- ##### Setup and Locals #############################################################################################
-- ####################################################################################################################
---@type Opt
local optName, Opt = ...
local LUI = LibStub("AceAddon-3.0"):GetAddon("LUI4")
local L = LUI.L
--local mod = LUI:GetModule("Cooldown")

-- ####################################################################################################################
-- ##### Utility Functions ############################################################################################
-- ####################################################################################################################

--Opt.options.args.ActionBars = Opt:Group("Cooldown", nil, nil, "tab", true, nil, Opt.GetSet(mod.db.profile))
Opt.options.args.ActionBars = Opt:Group("Cooldown", nil, nil, "tab", true)
Opt.options.args.ActionBars.handler = nil
local ActionBars = Opt.options.args.ActionBars.args