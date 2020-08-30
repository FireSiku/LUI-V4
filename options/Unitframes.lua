-- ####################################################################################################################
-- ##### Setup and Locals #############################################################################################
-- ####################################################################################################################
---@type Opt
local optName, Opt = ...
local LUI = LibStub("AceAddon-3.0"):GetAddon("LUI4")
local L = LUI.L
local mod = LUI:GetModule("Unitframes")

-- ####################################################################################################################
-- ##### Utility Functions ############################################################################################
-- ####################################################################################################################

Opt.options.args.Unitframes = Opt:Group("Unitframes", nil, nil, "tab", true, nil, Opt.GetSet(mod.db.profile))
Opt.options.args.Unitframes.handler = mod
local Unitframes = Opt.options.args.Unitframes.args