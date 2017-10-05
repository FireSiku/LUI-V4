-- API file that handles the backend of all addon-support files.

------------------------------------------------------
-- / SETUP AND LOCALS / --
------------------------------------------------------
local addonname, LUI = ...
local module = LUI:NewModule("Addons")
local L = LUI.L
local db

local addonStorage = {}

--Defaults
module.defaults = {   
	profile = {
		installed = {
		},
	},
}

------------------------------------------------------
-- / MODULE FUNCTIONS / --
------------------------------------------------------

------------------------------------------------------
-- / FRAMEWORK FUNCTIONS / --
------------------------------------------------------
function module:OnInitialize()
	LUI:RegisterModule(module)
	--Set EnabledState based on addons that are loaded.
	for name, element in module:IterateModules() do
		if IsAddOnLoaded(name) then
			element:SetEnabledState(true)
			addonStorage[name] = element
		else
			element:SetEnabledState(false)
		end
	end
end

function module:OnEnable()
	db = module:GetDB()
	for name, element in module:IterateModules() do
		-- Explicit nil check because false should have a different result
		if db.installed[name] == nil then
			StaticPopupDialogs["LUI_ADDON"..name] = {
				text = format("LUI detected you installed %s and has preset configuration available. Do you want LUI to apply these settings?", name),
				button1 = YES,
				button2 = NO,
				OnAccept = element.Install,
				OnCancel = function() db.installed[name] = false end,
				timeout = 0,
				whileDead = true,
			}
			StaticPopup_Show ("LUI_ADDON"..name)
		end
	end
end

function module:OnDisable()
end