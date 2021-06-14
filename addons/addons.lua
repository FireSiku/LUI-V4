-- API file that handles the backend of all addon-support files.

-- ####################################################################################################################
-- ##### Setup and Locals #############################################################################################
-- ####################################################################################################################

local _, LUI = ...
local module = LUI:NewModule("Addons")
local L = LUI.L
local db

-- ####################################################################################################################
-- ##### Default Settings #############################################################################################
-- ####################################################################################################################

module.defaults = {
	profile = {
		Installed = {
			["*"] = false,
		},
	},
}

-- ####################################################################################################################
-- ##### Module Functions #############################################################################################
-- ####################################################################################################################

function module:SetInstalled(name, bool)
	db.Installed[name] = bool or true
end

-- ####################################################################################################################
-- ##### Framework Events #############################################################################################
-- ####################################################################################################################
--TODO: Redesign to simplify things. Create a specialized Data Provider Mixin for supported addons.

function module:OnInitialize()
	LUI:RegisterModule(module)
	db = module.db.profile

	--Set EnabledState based on addons that are loaded.
	for name, element in module:IterateModules() do
		if IsAddOnLoaded(name) then
			element:SetEnabledState(true)
		else
			element:SetEnabledState(false)
		end
	end
end

function module:OnEnable()
	--Todo: Redesign to use internal loop
	for name, element in module:IterateModules() do
		-- Explicit nil check because false should have a different result
		if db.Installed[name] == nil then
			StaticPopupDialogs["LUI_ADDON"..name] = {
				text = format("LUI detected you installed %s and has preset configuration available."
				               .. " Do you want LUI to apply these settings?", name),
				button1 = YES,
				button2 = NO,
				OnAccept = element.Install,
				OnCancel = function()
					module:SetInstalled(name, false)
				end,
				timeout = 0,
				whileDead = true,
			}
			StaticPopup_Show ("LUI_ADDON"..name)
		end
	end
end

function module:OnDisable()
end
