-- ####################################################################################################################
-- ##### Setup and Locals #############################################################################################
-- ####################################################################################################################

---@type Opt
local optName, Opt = ...
local LUI = LibStub("AceAddon-3.0"):GetAddon("LUI4")
local L = LUI.L
--local mod = LUI:GetModule("CPanel")

-- ####################################################################################################################
-- ##### Utility Functions ############################################################################################
-- ####################################################################################################################

local function GenerateModuleButtons()
    local args = {}
    for name, mod in LUI:IterateModules() do
        if mod.enableButton then
			args[name] = Opt:EnableButton(name, L["Core_ModuleClickHint"], nil,
				function() return mod:IsEnabled() end,
				function(info, btn)
					if IsShiftKeyDown() then
						mod.db:ResetProfile()
						mod:ModPrint(L["Core_ModuleReset"])
					else
						mod:Toggle()
						mod:ModPrint( (mod:IsEnabled()) and L["API_BtnEnabled"] or L["API_BtnDisabled"])
					end
				end
			)
        end
    end
    return args
end

local infotext = LUI:GetModule("Infotext")
local function GenerateInfotextButtons()
	local args = {}
	for name, obj in infotext.LDB:DataObjectIterator() do
		args[name] = Opt:EnableButton(name, nil, nil,
			function() return true end,
			function() infotext:ToggleInfotext(name) end
		)
	end
	return args
end

local addonMod = LUI:GetModule("Addons")
local function GenerateAddonSupportButtons()
	local args = {}
	args.Desc = Opt:Desc(L["CPanel_AddonDesc"], 1)
	args.Break = Opt:Spacer(2, "full")
	for name, mod in addonMod:IterateModules() do
		args[name] = Opt:Execute(format(L["CPanel_AddonReset"], name), nil, nil,
			function()
				--addonMod.db.Installed[name] = nil
				addonMod:OnEnable()
			end
		)
	end
	return args
end

-- ####################################################################################################################
-- ##### Options Tables ###############################################################################################
-- ####################################################################################################################

Opt.options.args.CPanel = Opt:Group("Control Panel", nil, 3, "tab")
Opt.options.args.CPanel.handler = LUI
local CPanel = {
	Modules = Opt:Group(L["CPanel_Modules"], nil, 1),
	Infotext = Opt:Group(L["CPanel_Infotext"], nil, 2),
	Addons = Opt:Group(L["CPanel_Addons"], nil, 3),
}

CPanel.Modules.args = GenerateModuleButtons()
CPanel.Infotext.args = GenerateInfotextButtons()
CPanel.Addons.args = GenerateAddonSupportButtons()

Opt.options.args.CPanel.args = CPanel