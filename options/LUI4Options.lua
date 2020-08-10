--- Core is responsible for handling modules and installation process.

-- ####################################################################################################################
-- ##### Setup and Locals #############################################################################################
-- ####################################################################################################################
--local optName, Option = ...
local _, LUI = ...
local optName = "LUI4Options"
local L = LUI.L

local Opt = LibStub("AceAddon-3.0"):NewAddon(optName, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")
local LSM = LibStub("LibSharedMedia-3.0")
local ACD = LibStub("AceConfigDialog-3.0")

--local LUI = LibStub("AceAddon-3.0"):GetAddon("LUI")

-- ####################################################################################################################
-- ##### Utility Functions #############################################################################################
-- ####################################################################################################################

--- Infotable Shorthands
-- Type: info.type
-- Name: info[#info]
-- Table: info.option

--- Validate a number
-- @param info Ace3 info table
-- @number num
-- @return true if num is a number, nil otherwise
local function IsNumber(info_, num) -- luacheck: ignore
	if not num or not tonumber(num) then
		return L["API_InputNumber"]
	end
	return true
end

--- Fetch the option's parent table
-- @param info Ace3 info table
-- @return The parent table
local function GetParentTable(info)
	local parentTable = info.options.args
	for i=1, #info-1 do
		parentTable = parentTable[info[i]].args
	end
	return parentTable
end

function Opt.AddConfirm(option, confirm)
	if confirm then
		local confirmType = type(confirm)
		if confirmType == "boolean" then
			option.confirm = true
		elseif confirmType == "string" then
			option.confirm = true
			option.confirmText = confirm
		elseif confirmType == "function" then
			option.confirm = confirm
		end
	end
end

-- Common Slider Values
Opt.ScaleValues = {smin = 0.5, smax = 2, bigStep = 0.05, min = 0.25, max = 4, step = 0.01, isPercent = true}
Opt.PercentValues = {min = 0, max = 1, step = 0.01, bigStep = 0.05, isPercent = true}

-- ####################################################################################################################
-- ##### Options: Generators ##########################################################################################
-- ####################################################################################################################

--- Generate Get/Set functions based on a database table.
---@param db AceDB
---@return function Get
---@return function Set
function Opt.GetSet(db)
	local get = function(info)
		local value = db[info[#info]]
		if info.type == "input" then return tostring(value) end
		return value
	end

	local set = function(info, value)
		if tonumber(value) then
			value = tonumber(value)
		end
		db[info[#info]] = value
	end
	
	return get, set
end

local function ShortNum(num) return format(num < 1 and "%.2f" or "%d", num) end
--- Generate Get/Set functions for color options based on a database table.
--- # Additionally, if handler is defined, will attempt to call RefreshColors if it exists.
---@param db AceDB
---@return function Get
---@return function Set
function Opt.ColorGetSet(db)
	local get = function(info)
		local c = db[info[#info]]
		return c.r, c.g, c.b, c.a
	end
	
	local set = function(info, r, g, b, a)
		local c = db[info[#info]]
		c.r, c.g, c.b = ShortNum(r), ShortNum(g), ShortNum(b)
		if info.option.hasAlpha then c.a = ShortNum(a) end
		if info.handler.RefreshColors then info.handler:RefreshColors() end
	end
		
	return get, set
end

-- ####################################################################################################################
-- ##### Options: Helper Functions ####################################################################################
-- ####################################################################################################################
function Opt:Group(name, desc, order, childGroups, disabled, hidden, get, set)
	return { type = "group", childGroups = childGroups, name = name, desc = desc, order = order, disabled = disabled, hidden = hidden, get = get, set = set, args = {} }
end

function Opt:Header(name, order, hidden, get, set)
	return { type = "header", name = name, order = order, hidden = hidden, get = get, set = set }
end

function Opt:Color(name, desc, order, alpha, width, disabled, hidden, get, set)
	return { type = "color", name = name, desc = desc, order = order, hasAlpha = alpha, width = width, disabled = disabled, hidden = hidden, get = get, set = set }
end

function Opt:Spacer(order, width)
	return { name = "", type = "description", order = order, width = width }
end

function Opt:Desc(name, order, fontSize, image, imageCoords, imageWidth, imageHeight, width, hidden)
	return { type = "description", name = name, order = order, fontSize = fontSize, image = image, imageCoords = imageCoords, imageWidth = imageWidth, imageHeight = imageHeight, width = width, hidden = hidden }
end

function Opt:Toggle(name, desc, order, tristate, width, disabled, hidden, get, set)
	return { type = "toggle", name = name, desc = desc, order = order, tristate = tristate, width = width, disabled = disabled, hidden = hidden, get = get, set = set }
end

function Opt:Execute(name, desc, order, func, width, disabled, hidden, get, set)
	return { type = "execute", name = name, desc = desc, order = order, func = func, width = width, disabled = disabled, hidden = hidden, get = get, set = set }
end

function Opt:Input(name, desc, order, multiline, width, disabled, hidden, validate, get, set)
	return { type = "input", name = name, desc = desc, order = order, multiline = multiline, width = width, disabled = disabled, hidden = hidden, validate = validate, get = get, set = set }
end

--[[ slider values:
	smin (number) - "Soft" minimal value of the slider, represented in the UI
	smax (number) - "Soft" maximal value of the slider, represented in the UI
	min (number) - absolute minimal value
	max (number) - absolute maximum value
	step (number) - absolute minimum step that doesnt break code
	bigStep (number) - Useful step size for the slider.
	isPercent (boolean) - If true, will display 1.0 as 100%
--]]

function Opt:Slider(name, desc, order, values, width, disabled, hidden, get, set)
	local t = { type = "range", name = name, desc = desc, order = order, width = width, disabled = disabled, hidden = hidden, get = get, set = set }
	for key, value in pairs(values) do
		t[key] = value
	end

	return t
end

function Opt:Select(name, desc, order, values, width, disabled, hidden, get, set)
	return { type = "select", name = name, desc = desc, order = order, values = values, width = width, disabled = disabled, hidden = hidden, get = get, set = set }
end

function Opt:MultiSelect(name, desc, order, values, width, disabled, hidden, get, set)
	return { type = "multiselect", name = name, desc = desc, order = order, values = values, width = width, disabled = disabled, hidden = hidden, get = get, set = set }
end

function Opt:MediaBackground(name, desc, order, width, disabled, hidden, get, set)
	return { type = "select", dialogControl = "LSM30_Background", name = name, desc = desc, order = order, width = width, disabled = disabled, hidden = hidden, get = get, set = set, values = function() return LSM:HashTable("background") end }
end

function Opt:MediaBorder(name, desc, order, width, disabled, hidden, get, set)
	return { type = "select", dialogControl = "LSM30_Border", name = name, desc = desc, order = order, width = width, disabled = disabled, hidden = hidden, get = get, set = set, values = function() return LSM:HashTable("border") end }
end

function Opt:MediaStatusbar(name, desc, order, width, disabled, hidden, get, set)
	return { type = "select", dialogControl = "LSM30_Statusbar", name = name, desc = desc, order = order, width = width, disabled = disabled, hidden = hidden, get = get, set = set, values = function() return LSM:HashTable("statusbar") end }
end

function Opt:MediaSound(name, desc, order, width, disabled, hidden, get, set)
	return { type = "select", dialogControl = "LSM30_Sound", name = name, desc = desc, order = order, width = width, disabled = disabled, hidden = hidden, get = get, set = set, values = function() return LSM:HashTable("sound") end }
end

function Opt:MediaFont(name, desc, order, width, disabled, hidden, get, set)
	return { type = "select", dialogControl = "LSM30_Font", name = name, desc = desc, order = order, width = width, disabled = disabled, hidden = hidden, get = get, set = set, values = function() return LSM:HashTable("font") end }
end

-- Special Execute for the control panel
function Opt:EnableButton(name, desc, order, enableFunc, func, width, disabled, hidden, get, set)
	local nameFunc = function()
		return format("%s: %s", name, (enableFunc() and L["API_BtnEnabled"] or L["API_BtnDisabled"]))
	end
	return self:Execute(nameFunc, desc, order, func, width, disabled, hidden, get, set)
end

-- ####################################################################################################################
-- ##### Option Templates: Color Menu #################################################################################
-- ####################################################################################################################

local function ColorMenuGetter(info)
	local db = info.handler.profile.Colors
	local c = db[info.option.name]
	if info.type == "color" then
		return c.r, c.g, c.b, c.a
	elseif info.type == "select" then
		return c.t
	elseif info.type == "range" then
		return c.a
	end
end

local function ColorMenuSetter(info, value, g, b, a)
	local db = info.handler.db.profile.Colors
	local c = db[info.option.name]
	if info.type == "color" then
		c.r, c.g, c.b, c.a = value, g, b, a
	elseif info.type == "select" then
		c.t = value
	elseif info.type == "range" then
		c.a = value
	end
end

-- Generate a Color / Dropdown combo, the dropdown selection determines the color bypass. (Theme, Class, Spec, etc)
-- TODO: Show Alpha Slider when using Theme/Class Colors. 
function Opt:ColorMenu(parent, color, desc, order, disabled)
	local hiddenFunc = function(info)
		local db = info.handler.db.profile.Colors
		local c = db[color]
		if info.type == "color" then
			return c.t == "Individual"
		elseif info.type == "range" then
			return c.t ~= "Individual"
		end
	end

	local t = self:Select(color, desc, order, LUI.ColorTypes, nil, disabled, nil, ColorMenuGetter, ColorMenuSetter)
	parent[color.."Picker"] = self:Color(color, desc, order+0.1, true, nil, disabled, hiddenFunc, ColorMenuGetter, ColorMenuSetter)
	parent[color.."Slider"] = self:Percent(color, desc, order+0.1, nil, disabled, hiddenFunc, ColorMenuGetter, ColorMenuSetter)
	parent[color.."Break"] = self:Spacer(order+0.2, "full")
	return t
end
-- ####################################################################################################################
-- ##### Options Tables ###############################################################################################
-- ####################################################################################################################

local options = {
	name = "New LUI4 Options",
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
						IntroText = {
							name = L["Core_IntroText"],
							order = 3,
							type = "description",
						},
						VerText = {
							name = format("%s: %s", GAME_VERSION_LABEL, GetAddOnMetadata("LUI4", "Version")),
							order = 3,
							type = "description",
						},
						RevText = {
							name = format(L["Core_Revision_Format"], LUI.curseVersion or "???"),
							order = 3,
							type = "description",
						},
						TestText = {
							name = "Test Toggle",
							order = 3,
							type = "toggle",
							get = function(info)
								LUI:Print("Adding to Virag")
								--ViragDevTool_AddData(info, "AceInfo")
								LUI:PrintTable(info.option)
							end
						},
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

-- ####################################################################################################################
-- ##### Framework Functions ##########################################################################################
-- ####################################################################################################################

local optionsLoaded = false
function LUI:NewOpen(force, ...)
	-- if ACD.OpenFrames.LUI and not force then
	-- 	ACD:Close(optName)
	-- else
		-- Do not open options in combat unless already opened before.
		-- TODO: Find a better way to word the arning.
		if InCombatLockdown() and not optionsLoaded then
			LUI:Print(L["Core_OpenOptionsFail"])
		else
			ACD:Open(optName, nil, ...)
			optionsLoaded = true
		end
	--end
end

function Opt:OnEnable()
	LibStub("AceConfig-3.0"):RegisterOptionsTable(optName, options)
	ACD:SetDefaultSize(optName, 900, 660)
end