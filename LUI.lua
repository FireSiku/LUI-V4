--- Core is responsible for handling modules and installation process.
-- Should be first thing loaded.
-- @module LUI

-- ####################################################################################################################
-- ##### Setup and Locals #############################################################################################
-- ####################################################################################################################
local addonName, LUI = ...
LUI = LibStub("AceAddon-3.0"):NewAddon(LUI, addonName, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")
LUI.L = LibStub("AceLocale-3.0"):GetLocale(addonName)
LUI:SetDefaultModuleLibraries("AceEvent-3.0")
local L = LUI.L

--For Testing Purposes Only
_G["LUI"] = LUI

local Media = LibStub("LibSharedMedia-3.0")
local ACD = LibStub("AceConfigDialog-3.0")

--local strmatch = string.match
local strgsub = string.gsub
local format, type = format, type
local ipairs, select = ipairs, select
local InCombatLockdown = InCombatLockdown
local GetAddOnMetadata = GetAddOnMetadata
local IsAddOnLoaded = IsAddOnLoaded

-- Constants
local GAME_VERSION_LABEL = GAME_VERSION_LABEL
local GENERAL = GENERAL


local LIVE_BUILD = "25195" -- 7.2.0 Apr 27th. Need to keep updated every patch.
local LIVE_TOC = 70300
-- Check the TOC number and then compare builds. Live version can end up with a build higher than Beta.
local _, CURRENT_BUILD, _, CURRENT_TOC = GetBuildInfo()
if CURRENT_TOC > LIVE_TOC then
	LUI.PTR = true
elseif CURRENT_BUILD > LIVE_BUILD then
	LUI.PTR = true
end

local OPTION_PANEL_WIDTH = 775
local OPTION_PANEL_HEIGHT = 550

-- Some calls are used in half the modules and result never changes, store them for convenience.
LUI.playerClass = select(2, UnitClass("player"))
LUI.playerRace = select(2, UnitRace("player"))
LUI.playerFaction = UnitFactionGroup("player")
LUI.playerName =  UnitName("player")
LUI.playerRealm = GetRealmName()
LUI.playerFullName = format("%s-%s", LUI.playerName, LUI.playerRealm)
LUI.otherFaction = (LUI.playerFaction == "Alliance") and "Horde" or "Alliance"

-- ####################################################################################################################
-- ##### Default Settings #############################################################################################
-- ####################################################################################################################

LUI.defaults = {

	profile = {
		General = {
			IsConfigured = false, -- Currently unused, will be when Install process is done
			BlizzFrameScale = 1, -- Not sure if we'll use that, or if it's going to be part of scripts.
			ModuleMessages = true,
		},
		Snippets = {
		-- Siku TODO note: Snippet Engine. Dynamic creation and editing of LUIv3's Scripts.
		},
		modules = {
			["*"] = true,
		},
		installed = {
			["*"] = false,
		},
	},
}

-- ####################################################################################################################
-- ##### Loading Media ################################################################################################
-- ####################################################################################################################

-- REGISTER FONTS
Media:Register("font", "vibrocen", [[Interface\Addons\LUI4\media\fonts\vibrocen.ttf]])
Media:Register("font", "vibroceb", [[Interface\Addons\LUI4\media\fonts\vibroceb.ttf]])
Media:Register("font", "Prototype", [[Interface\Addons\LUI4\media\fonts\prototype.ttf]])
Media:Register("font", "neuropol", [[Interface\AddOns\LUI4\media\fonts\neuropol.ttf]])
Media:Register("font", "AvantGarde_LT_Medium", [[Interface\AddOns\LUI4\media\fonts\AvantGarde_LT_Medium.ttf]])
Media:Register("font", "Arial Narrow", [[Interface\AddOns\LUI4\media\fonts\ARIALN.TTF]])

-- REGISTER BORDERS
Media:Register("border", "glow", [[Interface\Addons\LUI4\media\borders\glow.tga]])
Media:Register("border", "Stripped", [[Interface\Addons\LUI4\media\borders\Stripped.tga]])
Media:Register("border", "Stripped_hard", [[Interface\Addons\LUI4\media\borders\Stripped_hard.tga]])
Media:Register("border", "Stripped_medium", [[Interface\Addons\LUI4\media\borders\Stripped_medium.tga]])

-- REGISTER STATUSBARS
Media:Register("statusbar", "oUF LUI", [[Interface\AddOns\LUI4\media\statusbar\oUF_LUI.tga]])
Media:Register("statusbar", "LUI_Gradient", [[Interface\AddOns\LUI4\media\statusbar\gradient.tga]])
Media:Register("statusbar", "LUI_Minimalist", [[Interface\AddOns\LUI4\media\statusbar\Minimalist.tga]])
Media:Register("statusbar", "Ruben", [[Interface\AddOns\LUI4\media\statusbar\Ruben.tga]])

LUI.blank = [[Interface\AddOns\LUI4\media\blank]]

-- ####################################################################################################################
-- ##### Install Process ##############################################################################################
-- ####################################################################################################################

--Currently, if not installed, it will automatically install it.

--- Check if LUI is installed.
function LUI:CheckInstall()
	local db = LUI:GetDB()
	--Check for the big install
	if not db.installed.LUI then LUI:OnInstall() end

	for name, module in self:IterateModules() do
		--module.db = self.db:RegisterNamespace(mName, module.defaults)
		if (module.db) and (module.db.profile) and (not db.installed[name]) then
			--If there is a module OnInstall, call it.
			if module.OnInstall and (type(module.OnInstall) == "function") then
				local installed, err = module.OnInstall()
				if installed then
					db.installed[name] = true -- Installed correctly
				elseif err then
					-- Print Error, otherwise fails silently.
					LUI:Print(format(L["Core_ModuleInstallFail_Format"],name,err))
				end
			--If not, assume the module has no install required and proceed.
			else
				db.installed[name] = true
				-- Print for testing purposes while we setup all modules during development.
				LUI:Print("Module "..name.." required no installation")
			end
		end
	end

end

function LUI:OnInstall()
	self.db:SetProfile(format("%s - %s", LUI.playerName, LUI.playerRealm))
	-- Got nothing to put here for now.
	self.db.profile.installed.LUI = true
	--Also placeholder print. Possibly?
	LUI:Print(L["Core_InstallSucess"])
end

-- ####################################################################################################################
-- ##### Options Menu #################################################################################################
-- ####################################################################################################################

local cmdList = {
	handler = {
		["dev"] = LUI,
		["load"] = LUI,
	},
	commands = {
		["dev"] = "DevCommands",
		["load"] = "LoadProfile",
	},
}

function LUI:LoadOptions()

	-- Only creates and load the options table in memory when needed. There's no need for a huge options table sitting
    -- in  the memory of a user that only opens the options panel once every week.
	if not LUI.options then

		--Pattern will match "r" followed by a number, a svn rev.
		-- local revision = LUI.revision
		-- if revision then revision = strmatch(revision,"r%d+") end

		LUI.options = {
			name = "LUI",
			type = "group",
			get = "getter",
			set = "setter",
			handler = LUI,
			args = {
				General = {
					name = GENERAL,
					order = 1,
					type = "group",
					childGroups = "tab",
					args = {
						Welcome = {
							name = L["Core_Welcome"],
							type = "group",
							order = 1,
							args = {
								IntroText = LUI:NewDesc(L["Core_IntroText"],3),

								VerText = LUI:NewDesc(format("%s: %s", GAME_VERSION_LABEL, GetAddOnMetadata(addonName, "Version")), 4),
								RevText = LUI:NewDesc(format(L["Core_Revision_Format"], LUI.curseVersion or "???"), 5),
							},
						},
					},
				},
				Space = {
					name = "",
					order = 8,
					type = "group",
					disabled = true,
					args = {},
				},
				Modules = {
					name = L["Core_ModuleMenu"],
					order = 9,
					type = "group",
					disabled = true,
					args = {},
				},
			},
		}

		LUI.options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(LUI.db)
		LUI.options.args.profiles.order = 4

		for modName, module in LUI:IterateModules() do
			-- Load the module's :LoadOptions() into the options table
			-- If a module related to an addon has an option table but the addon isnt loaded, do not load it in.
			local ok = true
			if module.addon and (not IsAddOnLoaded(module.addon)) then ok = false end
			if module.LoadOptions and ok then
				LUI:EmbedOptions(module)
				LUI.options.args[modName] = {
					type = "group",
					handler = module,
					name = module.optionsName or modName,
					order = module.order or 10,
					childGroups = module.childGroups or "tab",
					disabled = function() return not module:IsEnabled() end,
					args = module:LoadOptions(),
				}
			end
		end
	end

	return LUI.options
end

local optionsLoaded = false
function LUI:Open(force, ...)
	if ACD.OpenFrames.LUI and not force then
		ACD:Close(addonName)
	else
		-- Do not open options in combat unless already opened before.
		-- TODO: Find a better way to word the arning.
		if InCombatLockdown() and not optionsLoaded then
			LUI:Print(L["Core_OpenOptionsFail"])
		else
			ACD:Open(addonName, nil, ...)
			optionsLoaded = true
		end
	end
end

--TODO: Handle of chat command is a mess that need fixing.
--Future: Make it so that modules can handle chat command through /lui [moduleName] [setting] [value]
function LUI:ChatCommand(input)
	if not input or input:trim() == "" then
		self:Open()
	else
		local mod, cmd = self:GetArgs(input, 2)
		local value = strgsub(input, mod, ""):trim()
		if cmd then
			if (cmdList.commands[mod]) then
				-- Call the function that will handle the command.
				cmdList.handler[mod][cmdList.commands[mod]](self, value)
			end
		else
			-- Use Quick module menu function
			self:Open()
		end
	end
end

function LUI:DevCommands(cmd,value)
	LUI:Print("DevCommands: ",self,cmd,value)
	--/lui dev installed moduleName
	--Reverts the installed state of a certain module (or all of them)
	if cmd == "installed" then
		LUI:Print(format(L["Core_Dev_RevertState_Format"], value))
	elseif cmd == "save" then
		LUI:SaveLayout("Test", "Siku", "This is going to be the default layout")
	elseif cmd == "load" then
		LUI:LoadLayout(value)
	end
end

function LUI:LoadProfile(value)
	local profileList = LUI.db:GetProfiles()
	if tContains(profileList, value) then
		LUI:Print(format(L["Core_LoadProfileSucess_Format"],value))
		LUI.db:SetProfile(value)
	else
		LUI:Print(format(L["Core_LoadProfileFail_Format"],value))
	end
end

-- ####################################################################################################################
-- ##### Module Handling ##############################################################################################
-- ####################################################################################################################

--Function that will create a namespace for each module.
-- module - Ace Object from :NewModule
function LUI:RegisterModule(module)
	local db = LUI:GetDB()
	local mName = module:GetName()

	--If a module hasn't been installed yet and should be disabled by default, disable it.
	--Otherwise, modules are enabled by default, and db.modules[name] should be true.
	if module.defaultDisabled and not db.installed[mName] then
		db.modules[mName] = false
	end
	module:SetEnabledState(db.modules[mName])

	LUI:EmbedModule(module)
	--Register DB Namespace
	--TODO: Allow for DB-less modules.
	if not module.defaults then
		LUI:Print("Cant Proceed, Module ["..mName.."] has no database")
		return
	end

	--Merge Defaults from elements.
	for name, element in module:IterateModules() do
		if element.defaults then
			for i, scope in ipairs(LUI.DB_TYPES) do
				if element.defaults[scope] then
					if not module.defaults[scope] then module.defaults[scope] = {} end
					module.defaults[scope][name] = LUI:CopyTable(element.defaults[scope], module.defaults[scope][name])
				end
			end
		end
	end
	module.db = self.db:RegisterNamespace(mName, module.defaults)

	-- Register Callbacks
	--TODO: Recheck Register Callbacks
	--if type(module.Refresh) == "function" then
	--	module.db.RegisterCallback(module, "OnProfileChanged", LUI.RefreshModule, module)
	--	module.db.RegisterCallback(module, "OnProfileCopied", LUI.RefreshModule, module)
	--	module.db.RegisterCallback(module, "OnProfileReset", LUI.RefreshModule, module)
	--end
end

-- ####################################################################################################################
-- ##### Framework Events #############################################################################################
-- ####################################################################################################################

function LUI:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("LUI4DB", LUI.defaults, true)
	self.db.RegisterCallback(self, "OnProfileChanged", "Refresh")
	self.db.RegisterCallback(self, "OnProfileCopied", "Refresh")
	self.db.RegisterCallback(self, "OnProfileReset", "Refresh")

	for k, v in pairs(self.db.profile.modules) do
		LUI:Print("Init", k, v)
	end

	--Setup Options:
	LUI:EmbedModule(LUI)
	LUI:EmbedOptions(LUI)
	LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, self.LoadOptions)
	ACD:SetDefaultSize(addonName, OPTION_PANEL_WIDTH, OPTION_PANEL_HEIGHT)

	self:RegisterChatCommand(addonName, "ChatCommand")
end

function LUI:OnEnable()
	LUI:CheckInstall()
end

function LUI:Refresh()
	if not IsLoggedIn() then return end -- in case of db callbacks fires before OnEnable function

	--Failsafe calling OnEnable/OnDisable on Profile change to
	for name_, module in self:IterateModules() do
		local db = module.db
		if db and db.profile and db.profile.Enable ~= nil then
			module[db.profile.Enable and "Enable" or "Disable"](module)
		end
	end
end
