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
local db

--For Testing Purposes Only
_G["LUI"] = LUI
local Media = LibStub("LibSharedMedia-3.0")
local ACD = LibStub("AceConfigDialog-3.0")

--local strmatch = string.match
local strgsub = string.gsub
local format, type, select = format, type, select
local InCombatLockdown = InCombatLockdown
local GetAddOnMetadata = GetAddOnMetadata
local IsAddOnLoaded = IsAddOnLoaded

-- Constants
local GAME_VERSION_LABEL = GAME_VERSION_LABEL
local GENERAL = GENERAL

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
			MasterFont = "NotoSans-SCB",
			MasterFlag = "OUTLINE",
		},
		Snippets = {
		-- Siku TODO note: Snippet Engine. Dynamic creation and editing of LUIv3's Scripts.
		},
		Modules = {
			["*"] = true,
		},
		Installed = {
			["*"] = false,
		},
		Fonts = {
			Master = { Name = "NotoSans-SCB", Size = 12, Flag = "OUTLINE", },
		},
	},
}

-- ####################################################################################################################
-- ##### Loading Media ################################################################################################
-- ####################################################################################################################

-- REGISTER FONTS
Media:Register("font", "vibroceb", [[Interface\Addons\LUI4\media\fonts\vibroceb.ttf]])
Media:Register("font", "Prototype", [[Interface\Addons\LUI4\media\fonts\prototype.ttf]])
Media:Register("font", "NotoSans-SCB", [[Interface\AddOns\LUI4\media\fonts\NotoSans-SemiCondensedBold.ttf]])

-- REGISTER BORDERS
Media:Register("border", "glow", [[Interface\Addons\LUI4\media\borders\glow.tga]])
Media:Register("border", "Stripped", [[Interface\Addons\LUI4\media\borders\Stripped.tga]])
Media:Register("border", "Stripped_hard", [[Interface\Addons\LUI4\media\borders\Stripped_hard.tga]])
Media:Register("border", "Stripped_medium", [[Interface\Addons\LUI4\media\borders\Stripped_medium.tga]])

-- REGISTER STATUSBARS
Media:Register("statusbar", "Minimalist", [[Interface\AddOns\LUI4\media\statusbar\minimalist.tga]])
Media:Register("statusbar", "Gradient", [[Interface\AddOns\LUI4\media\statusbar\gradient.tga]])
Media:Register("statusbar", "Ruben", [[Interface\AddOns\LUI4\media\statusbar\Ruben.tga]])

LUI.blank = [[Interface\AddOns\LUI4\media\blank.tga]]

-- ####################################################################################################################
-- ##### Install Process ##############################################################################################
-- ####################################################################################################################

--Currently, if not installed, it will automatically install it.

--- Check if LUI is installed.
function LUI:CheckInstall()
	--Check for the big install
	if not db.Installed.LUI then LUI:OnInstall() end

	for name, module in self:IterateModules() do
		if (module.db and (not db.Installed[name])) then
			--If there is a module OnInstall, call it.
			if module.OnInstall and (type(module.OnInstall) == "function") then
				local installed, err = module.OnInstall()
				if installed then
					db.Installed[name] = true -- Installed correctly
				elseif err then
					-- Print Error, otherwise fails silently.
					LUI:Print(format(L["Core_ModuleInstallFail_Format"],name,err))
				end
			--If not, assume the module has no install required and proceed.
			else
				db.Installed[name] = true
				-- Print for testing purposes while we setup all modules during development.
				LUI:Print("Module "..name.." required no installation")
			end
		end
	end

end

function LUI:OnInstall()
	self.db:SetProfile(format("%s - %s", LUI.playerName, LUI.playerRealm))
	-- Got nothing to put here for now.
	db.Installed.LUI = true
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

--TODO: Handle of chat command is a mess that need fixing.
--Future: Make it so that modules can handle chat command through /lui [moduleName] [setting] [value]
function LUI:ChatCommand(input)
	if not input or input:trim() == "" then
		LoadAddOn("LUI4Options")
		self:NewOpen()
	else
		local mod, cmd = self:GetArgs(input, 2)
		local value = strgsub(input, mod, ""):trim()
		if cmd then
			if (cmdList.commands[mod]) then
				-- Call the function that will handle the command.
				cmdList.handler[mod][cmdList.commands[mod]](self, value)
			else
				self:NewOpen()
			end
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
function LUI:RegisterModule(module)
	local mName = module:GetName()

	--If a module hasn't been installed yet and should be disabled by default, disable it.
	--Otherwise, modules are enabled by default, and db.modules[name] should be true.
	if module.defaultDisabled and not db.Installed[mName] then
		db.Modules[mName] = false
	end
	module:SetEnabledState(db.Modules[mName])

	if module.defaults then
		module.db = self.db:RegisterNamespace(mName, module.defaults)

		-- Register Callbacks
		--TODO: Recheck Register Callbacks
		--if type(module.Refresh) == "function" then
		--	module.db.RegisterCallback(module, "OnProfileChanged", LUI.RefreshModule, module)
		--	module.db.RegisterCallback(module, "OnProfileCopied", LUI.RefreshModule, module)
		--	module.db.RegisterCallback(module, "OnProfileReset", LUI.RefreshModule, module)
		--end
	end
end

-- ####################################################################################################################
-- ##### Framework Events #############################################################################################
-- ####################################################################################################################

function LUI:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("LUI4DB", LUI.defaults, true)
	self.db.RegisterCallback(self, "OnProfileChanged", "Refresh")
	self.db.RegisterCallback(self, "OnProfileCopied", "Refresh")
	self.db.RegisterCallback(self, "OnProfileReset", "Refresh")
	db = self.db.profile

	LUI:EmbedModule(LUI)
	self:RegisterChatCommand("lui", "ChatCommand")
end

function LUI:OnEnable()
	LUI:CheckInstall()

	local font = db.Fonts.Master
	LUI.MasterFont = CreateFont("LUIMasterFont")
	LUI.MasterFont:SetFont(font.Name, font.Size, font.Flag)
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