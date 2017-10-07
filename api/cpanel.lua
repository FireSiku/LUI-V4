-- This module handle various easily enabling/disabling various modules and elements by LUI and its modules.

------------------------------------------------------
-- / SETUP AND LOCALS / --
------------------------------------------------------
local addonname, LUI = ...
local module = LUI:NewModule("Control Panel")
local L = LUI.L
local db

-- defaults
module.defaults = {
	profile = {
		--Empty
	},
}
------------------------------------------------------
-- / MODULE FUNCTIONS / --
------------------------------------------------------
function module:ModuleIterator()
	local args = {}
	for modName, mod in LUI:IterateModules() do
		if mod.enableButton then
			args[modName] = module:NewEnableButton(modName, L["Core_ModuleClickHint"], nil,
				function() return mod:IsEnabled() end, --enableFunc
				function()
					if IsShiftKeyDown() then
						mod.db:ResetProfile()
						mod:ModPrint(L["Core_ModuleReset"])
					else
						mod:Toggle()
						mod:ModPrint( (mod:IsEnabled()) and L["API_BtnEnabled"] or L["API_BtnDisabled"])
					end
				end)
		end
	end
	return args
end

function module:InfotextIterator()
	local args = {}
	local infotext = LUI:GetModule("Infotext")
	for name, dataObj in infotext.LDB:DataObjectIterator() do
		args[name] = module:NewEnableButton(name, nil, nil,
			function() return infotext:IsInfotextEnabled(name) end,
			function()
				infotext:ToggleInfotext(name)
			end)
	end
	return args
end

function module:AddonSupportIterator()
	local args = {}
	local addonMod = LUI:GetModule("Addons")
	args["Desc"] = module:NewDesc(L["CPanel_AddonDesc"], 1)
	args["Break"] = module:NewLineBreak(2)
	for name, mod in addonMod:IterateModules() do
		args[name] = module:NewExecute(format(L["CPanel_AddonReset"], name), nil, nil, 
			function() 
				addonMod:GetDB().installed[name] = nil
				addonMod:OnEnable()
			end)
	end
	return args
end

------------------------------------------------------
-- / FRAMEWORK FUNCTIONS / --
------------------------------------------------------
module.name = "Control Panel"
module.order = 5

function module:OnInitialize()
	LUI:RegisterModule(module)
	
end

function module:OnEnable()
	db = module.db.profile
end

function module:LoadOptions()
	local options = {
		Modules = module:NewGroup(L["CPanel_Modules"], 1, nil, nil, module:ModuleIterator()),
		Infotext = module:NewGroup(L["CPanel_Infotext"], 2, nil, nil, module:InfotextIterator()),
		Addons = module:NewGroup(L["CPanel_Addons"], 3, nil, nil, module:AddonSupportIterator()),
	}
	return options
end
