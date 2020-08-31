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
local colorGet, colorSet = Opt.ColorGetSet(db.Colors)

local function InfoTextGroup(name, order)
    local group = Opt:Group(name, nil, order, nil, nil, nil, Opt.GetSet(db[name]))
    group.args.Header = Opt:Header(name, 1)
    group.args.Enable = Opt:Toggle("Enable", nil, 2)
	group.args.X = Opt:Input("X Value", nil, 3)

    return group
end

-- ####################################################################################################################
-- ##### Options Tables ###############################################################################################
-- ####################################################################################################################
Opt.options.args.Infotext = Opt:Group("Infotexts", nil, nil, "tab", Opt.IsModDisabled, nil, Opt.GetSet(db))
Opt.options.args.Infotext.handler = module

local Infotext = {
	Header = Opt:Header("Infotext", 1),
	Settings = Opt:Group("Individual Settings", nil, 2),
	General = Opt:Group("Global Settings", nil, 3),
}

Infotext.General.args = {
	Title = Opt:Color("Title Color", nil, 2, false, nil, nil, nil, colorGet, colorSet),
	Hint = Opt:Color("Hint Color", nil, 3, false, nil, nil, nil, colorGet, colorSet),
	--Infotext = Opt:FontMenu("Infotext Font", nil, 4),
}

local count = 10
for name, obj in module:IterateModules() do
    Infotext.Settings.args[name] = InfoTextGroup(name, count)
    count = count + 1
end

Opt.options.args.Infotext.args = Infotext