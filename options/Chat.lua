-- ####################################################################################################################
-- ##### Setup and Locals #############################################################################################
-- ####################################################################################################################

---@type Opt
local optName, Opt = ...
local LUI = LibStub("AceAddon-3.0"):GetAddon("LUI4")
-- local module = LUI:GetModule("Chat")
-- local db = module.db.profile
local L = LUI.L

-- ####################################################################################################################
-- ##### Utility Functions ############################################################################################
-- ####################################################################################################################


-- ####################################################################################################################
-- ##### Options Tables ###############################################################################################
-- ####################################################################################################################

Opt.options.args.Chat = Opt:Group("Chat", nil, nil, "tab", true, nil, Opt.GetSet(db))
Opt.options.args.Chat.handler = module
local Chat = {

}

Opt.options.args.Chat.args = Chat