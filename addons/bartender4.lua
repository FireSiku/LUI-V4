-- ####################################################################################################################
-- ##### Setup and Locals #############################################################################################
-- ####################################################################################################################

local _, LUI = ...
local module = LUI:GetModule("Addons")
local element = module:NewModule("Bartender4")
local L = LUI.L

-- ####################################################################################################################
-- ##### Module Functions #############################################################################################
-- ####################################################################################################################

function element:DisableMod(addon, name)
	addon.db:GetNamespace(name).profile.enabled = false
	addon:GetModule(name):Disable()
end

function element:DisableBar(db, id)
	local configBar = db:GetNamespace("ActionBars").profile.actionbars
	configBar[id].enable = false
end

function element:CenterBarTemplate(db, id, yOffset)
	local configBar = db:GetNamespace("ActionBars").profile.actionbars
	configBar[id].enabled = true
	configBar[id].scale = 1
	configBar[id].padding = 4
	configBar[id].position.x = -243
	configBar[id].position.y = yOffset
	configBar[id].position.point = "BOTTOM"
end

function element:SetupNamespace(db, name, point, x, y, scale, padding, rows)
	local config = db:GetNamespace(name).profile
	config.position.point = point
	config.position.x = x
	config.position.y = y
	config.scale = scale
	config.padding = padding
	config.rows = rows
end

-- ####################################################################################################################
-- ##### Addon Support: Install #######################################################################################
-- ####################################################################################################################

function element:Install()
	local Bartender4 = LibStub("AceAddon-3.0"):GetAddon("Bartender4")
	local db = Bartender4.db
	-- Make sure Bartender4 is using the same profile name as LUI.
	db:SetProfile(LUI.db:GetCurrentProfile())

	-- First, the three main bars in the middle, from bottom to top.
	element:CenterBarTemplate(db, 1, 62)
	element:CenterBarTemplate(db, 6, 102)
	element:CenterBarTemplate(db, 5, 142)

	-- If I do Sidebars, these two will be used
	element:DisableBar(db, 3)
	element:DisableBar(db, 4)

	-- Disable other bars we don't need.
	element:DisableBar(db, 2)
	element:DisableBar(db, 7)
	element:DisableBar(db, 8)
	element:DisableBar(db, 9)
	element:DisableBar(db, 10)

	-- Move the Pet bar and Extra Action to the side.
	element:SetupNamespace(db, "PetBar", "BOTTOMRIGHT", -195, 295, 1, 2, 2)
	element:SetupNamespace(db, "ExtraActionBar", "BOTTOMRIGHT", -285, 295, 1)
	--element:SetupNamespace(db, "Vehicle", "BOTTOMRIGHT", -355, 295, 1)

	-- Disable some modules
	element:DisableMod(Bartender4, "BagBar")
	element:DisableMod(Bartender4, "MicroMenu")
	element:DisableMod(Bartender4, "StanceBar")
	element:DisableMod(Bartender4, "BlizzardArt")

	--[[ Preset Example from Bartender4
	config = db:GetNamespace("ActionBars").profile
	config.actionbars[1].padding = 6
	SetBarLocation( config.actionbars[1], "BOTTOM", -256, 41.75 )
	config.actionbars[2].enabled = false
	config.actionbars[3].padding = 5 --]]

	Bartender4:UpdateModuleConfigs()
	module:SetInstalled("Bartender4")
end

-- ####################################################################################################################
-- ##### Framework Events #############################################################################################
-- ####################################################################################################################

function element:OnInitialize()
end

function element:OnEnable()
end

function element:OnDisable()
end
