--- Devapi is responsible for all API related to the option panel.
-- @classmod OptionsMixin

-- ####################################################################################################################
-- ##### Setup and Locals #############################################################################################
-- ####################################################################################################################

local addonname, LUI = ...
local module = LUI:GetModule("API")
local element = module:NewModule("Options")
local Media = LibStub("LibSharedMedia-3.0")
local L = LUI.L

-- local copies
local strlower, strsub = strlower, strsub
local pairs, tonumber, tostring = pairs, tonumber, tostring
local getmetatable, setmetatable = getmetatable, setmetatable

-- constants
local LSM_DCONTROL_BACKGROUND = "LSM30_Background"
local LSM_DCONTROL_STATUSBAR = "LSM30_Statusbar"
local LSM_DCONTROL_BORDER = "LSM30_Border"
local LSM_DCONTROL_SOUND = "LSM30_Sound"
--local LSM_DCONTROL_FONT = "LSM30_Font"

-- Mixin Table
local OptionsMixin = {} -- Embed Prototype

function LUI:EmbedOptions(target)
	for k, v in pairs(OptionsMixin) do
		target[k] = v
	end
end

-- ####################################################################################################################
-- ##### Utility Functions #############################################################################################
-- ####################################################################################################################

--- Forces a refresh on the options panel.
-- There is a bug that is sometimes causing some items to not properly appear.
-- Instead of simply calling NotifyChange, we queue it to happen 0.01 later, fixing all issues.
-- An immediately perceivable example is the four colors in ExpBar module options.
-- OnUpdate does not happen while the frame is hidden, therefore it does not have an effect on performance.
local notify = CreateFrame("Frame")
notify.time = 0
notify:SetScript("OnUpdate", function(self, elapsed)
	self.time = self.time + elapsed
	if self.time > 0.01 then
		self.time = 0
		LibStub("AceConfigRegistry-3.0"):NotifyChange(addonname)
		self:Hide()
	end
end)
notify:Hide()

local function NotifyChange()
	notify:Show()
end

--- Creates a new option table.
-- @tparam optiontype stype The type of option as defined by Ace3.
-- @string sname Displayed name of the option.
-- @string sdesc The description in the toolip.
-- @number sorder Number that defines in which order options will appear.
-- @treturn table The newly created option table
local function SetVals(stype, sname, sdesc, sorder)
	local t = {type = stype, order = sorder, name = sname, desc = sdesc}
	return t
end

--- Handle the width/disable/hidden states of all option wrappers.
-- @tparam table t An option table
-- @tparam "double"|"half"|"full"|"normal" width How wide the option needs to be.
-- @tparam func|method|bool disabled Make the option disabled but visible
-- @tparam func|method|bool hidden Make the option hidden from view.
local function SetState(t, width, disabled, hidden)
	t.width = width
	t.disabled = disabled
	t.hidden = hidden
end

--- Validate a number
-- @param info Ace3 info table
-- @number num
-- @return true if num is a number, nil otherwise
local function IsNumber(info_, num)
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

--- Inject new options and/or abuse the info table.
-- Hooking Order because it's the least likely to be a dynamic function
-- @tparam table t An option table
-- @func func A function that receive the option's info table and parent's table
local function OptionHook(t, func)
	local order = t.order
	t.order = function(info)
		local parent = GetParentTable(info)
		func(info, parent)
		NotifyChange()
		--Make sure this function never gets called again or referenced again.
		info.option.order = order
		return order
	end
end

local function SetFunc(self, info, ...)
	local meta = getmetatable(info.option)
	if meta and meta.setfunc then
		if type(meta.setfunc) == "function" then
			meta.setfunc(info, ...)
		elseif type(meta.setfunc) == "string" then
			info.handler[meta.setfunc](self, info, ...)
		end
	end
end

-- The only way to get additional parameters to pass to get/set without Ace3 throwing a fit is to use a metatable
-- This function allows you to grab this information,optionally requires it to be a certain type.
-- Returns the value of the entry if it exists (and is valid) or nil otherwise.
local function CheckMeta(info, entry, datatype)
	local meta = getmetatable(info.option)
	if meta and meta[entry] then
		if datatype and type(meta[entry]) == datatype then
			return meta[entry]
		elseif not datatype then
			return meta[entry]
		end
	end
end

--- Set the metatable for options based on the meta param.
-- No further modifications of the table should happen after the call, as we're reusing existing tables.
-- Set uniqueTable to true if you need to apply modifications to the table after this call.
-- uniqueTable also prevents the setmetatable call which will need to be called later on (after modifications).
local function SetupMeta(t, meta, uniqueTable)
	local metaTable
	if type(meta) == "table" then
		--Override the get/set for the particular option.
		--Since their job is done, we dont need to add them to the metatable.
		if meta.get then
			t.get = meta.get
			meta.get = nil
		end
		if meta.set then
			t.set = meta.set
			meta.set = nil
		end
		--We don't need to set a metatable for an empty table.
		if LUI:Count(meta) > 0 then
			metaTable = meta
		end
	--If the parameter was a function or string (method), call them at the end of Set.
	elseif type(meta) == "function" then metaTable = { setfunc = meta }
	elseif type(meta) == "string" then metaTable = { setfunc = meta }
	else
		if uniqueTable then metaTable = {} end
	end
	if metaTable then
		if not uniqueTable then setmetatable(t, metaTable) end
		return metaTable
	end
end

local function ShadowOption()
	local t = SetVals("description", "", nil, 500)
	SetState(t, nil, true, true)
	return t
end

------------------------------------------------------
-- / OPTIONS API - API FUNCTIONS / --
------------------------------------------------------

--- API Functions
-- @section apifunc

--- Forces a refresh on the options panel.
-- This should only be used when modifying the option panel externally.
function OptionsMixin:RefreshOptionsPanel()
	NotifyChange()
end

------------------------------------------------------
-- / OPTIONS API - GET/SET FUNCS / --
------------------------------------------------------
--@local here

function OptionsMixin:getter(info)
	local parent = CheckMeta(info, "parent", "string") or info[#info-1]
	local scope = CheckMeta(info, "scope", "string") or "profile"
	local root = CheckMeta(info, "root", "boolean")
	local db = self:GetDB(scope, (not root) and parent)
	local value = db[info[#info]]
	--HACK: Inputs cannot display numbers. Have to convert to string.
	if info.option.type == "input" then return tostring(value) end
	return value
end

function OptionsMixin:setter(info, value, ...)
	local parent = CheckMeta(info, "parent", "string") or info[#info-1]
	local scope = CheckMeta(info, "scope", "string") or "profile"
	local root = CheckMeta(info, "root", "boolean")
	local db = self:GetDB(scope, (not root) and parent)

	--HACK: Inputs always return value as a string.
	if CheckMeta(info, "isNumber") then value = tonumber(value) end

	db[info[#info]] = value
	SetFunc(self, info, value, ...)
end

-- Drop most of the useless bullshit of getter/setter
function OptionsMixin:GenericGetter(info)
	local db = self:GetDB("profile", info[#info-1])
	local value = db[info[#info]]
	--Inputs cannot display numbers. Have to convert to string.
	if info.option.type == "input" then return tostring(value) end
	return value
end

function OptionsMixin:GenericSetter(info, value, ...)
	local db = self:GetDB("profile", info[#info-1])
	-- Make sure not to save a number as a string
	if tonumber(value) then
		value = tonumber(value)
	end
	db[info[#info]] = value
	SetFunc(self, info, value, ...)
end

function OptionsMixin:RootGetter(info)
	local db = self:GetDB()
	local value = db[info[#info]]
	--Inputs cannot display numbers. Have to convert to string.
	if info.option.type == "input" then return tostring(value) end
	return value
end

function OptionsMixin:RootSetter(info, value, ...)
	local db = self:GetDB()
	-- Make sure not to save a number as a string
	if tonumber(value) then
		value = tonumber(value)
	end
	db[info[#info]] = value
	SetFunc(self, info, value, ...)
end

--Color Get/Set are specific to colors and ignore most meta params.
-- They check for the color directly into db.Colors
function OptionsMixin:ColorGetter(info)
	local db = self:GetDB("profile", "Colors")
	local c = db[info[#info]]
	return c.r, c.g, c.b, c.a
end

local function shortNum(num) return format(tonumber(num) < 1 and "%.2f" or "%d", tonumber(num)) end
function OptionsMixin:ColorSetter(info, r, g, b, a)
	local db = self:GetDB("profile", "Colors")
	local c = db[info[#info]]
	c.r, c.g, c.b, c.a = shortNum(r), shortNum(g), shortNum(b), shortNum(a)
	if not info.option.hasAlpha then c.a = nil end
	SetFunc(self, info, c.r, c.g, c.b, c.a)
end

-- ####################################################################################################################
-- ##### OptionsMixin: Groups #########################################################################################
-- ####################################################################################################################

--- Option Generating Functions
-- @section optionapi

--[[ args:
	name (string|function) - Display name for the option
	desc (string|function) - description for the option
		- the default value of the option will be added to the description (see func)
	order (number|function) - relative position of item (default = 100, 0=first, -1=last)
	meta (function|table|boolean) - Used as a jack-of-all-trades parameter to combine many lesser-used parameters together.
		- (table) - every key will add extra functionality, listed below.
		- (boolean) - If true, the option will be given at the root of the db.
		- (function) - if a function is given, it will be called at the end of option's Set
	width (string) - "double", "half", "full", "normal"
		- "double", "half" - increase/decrease the size of the option
		- "full" - make the option the full width of the window (or section of the window the option is in)
		- "normal" - use the default widget width (useful to overwrite widgets that default to "full")
	disabled (function|boolean) - disabled but visible
	hidden (function|boolean) - hidden (but usable if you can get to it, i.e. via commandline) --]]
--[[ meta params:
	- Additional keys that can be added to modify the behavior of the get/set functions.
	output (string) - Define the output type for db values, used by setter.
		- Valid strings are "string", "number", "boolean"
	scope (string) - Define the scope of the AceDB datatype being used for an option.
	root (boolean) - If true, the option will be at the root of the db. (Bypass parent)
		- Same as giving a boolean in the meta arg
	parent (string) - Specify a name of the parent db table, bypass default value.
	setfunc (func) - If present, given function will be called at the end of option's Set.
		- Same as giving a function in the meta arg.
--]]

--- Template for functions (not real function).
-- The first 3 params are always (name, desc, order), unless stated otherwise.
-- The last 4 params are always (meta, width, disabled, hidden), unless stated otherwise.
-- @function OptionsMixin:NewOption
-- @tparam string|function name Display name for the option
-- @tparam string|function desc Description for the option (appears in a tooltip)
-- @tparam number order Relative position of the option. (0 = first, -1 = last)
-- @param ... Any specified parameter
-- @tparam boolean|table|function|method meta Used as jack-of-all-trades parameters
--                                            to combine many lesser-used or situational additional parameters.
-- @tparam "double"|"half"|"full"|"normal" width How wide the option needs to be.
-- @tparam function|method|bool disabled Make the option disabled but visible
-- @tparam function|method|bool hidden Make the option hidden from view.

function OptionsMixin:NewGroup(name, order, childGroups, inline, get, set, args, disabled, hidden)
	local t = SetVals("group", name, nil, order)
	t.childGroups = childGroups
	t.inline = inline
	-- if get is a table, skip to args and move other params two spaces
	if type(get) == "table" then
		t.args = get
		SetState(t, nil, set, args)
	else
		-- TODO: Once all modules are updated to using NewGroup, get rid of getter/setter
		--       Also clean up the whole meta thing since rootMeta will be obsolete.
		if type(get) == "function" or type(get) == "string" then
			t.get = get
		else
			t.get = "getter"
		end
		if type(set) == "function" or type(set) == "string" then
			t.set = set
		else
			t.set = "setter"
		end

		t.args = args
		SetState(t, nil, disabled, hidden)
	end

	return t
end

--This is similar to a NewGroup but the Getter/Setter will fetch from db[name] instead of db[groupname][name]
function OptionsMixin:NewRootGroup(name, order, childGroups, inline, args, disable, hidden)
	return self:NewGroup(name, order, childGroups, inline, "RootGetter", "RootSetter", args, disable, hidden)
end

local function IsAdvancedLocked() return false end -- To change when i get a value set up.
function OptionsMixin:NewAdvancedGroup(args)
	--args["AdvHeader"] = OptionsMixin:NewDesc("This tab is used
	return self:NewGroup(L["API_Advanced"], 100, nil, nil, args, IsAdvancedLocked, IsAdvancedLocked)
end

--- Generate a Header line. This function ignores the desc and meta parameters.
-- @function OptionsMixin:NewHeader
-- @param ...
function OptionsMixin:NewHeader(name, order, width, disabled, hidden)
	local t = SetVals("header", name, nil, order)
	SetState(t, width, disabled, hidden)
	return t
end

-- ####################################################################################################################
-- ##### OptionsMixin: Simple Widgets #################################################################################
-- ####################################################################################################################

--- Generate a line break for options formatting. Does not have most normal parameters.
-- An empty full description only produces a line break.
-- @function OptionsMixin:NewLineBreak
-- @param order, hidden
function OptionsMixin:NewLineBreak(order, hidden)
	local t = self:NewDesc("", order, "full", nil, hidden)
	return t
end

--- Generate a Description text block. This function ignores the desc and meta parameters.
-- @function OptionsMixin:NewDesc
-- @param ...
function OptionsMixin:NewDesc(name, order, width, disabled, hidden)
	local t = SetVals("description", name, nil, order)
	t.fontSize = "medium"
	SetState(t, width or "full", disabled, hidden)
	return t
end

--- Generate a Checkbox option
-- @function OptionsMixin:NewToggle
-- @param ...
function OptionsMixin:NewToggle(name, desc, order, meta, width, disabled, hidden)
	local t = SetVals("toggle", name, desc, order)

	meta = SetupMeta(t, meta)
	if meta and meta.disabledTooltip then
		OptionHook(t, function(info, parent)
			local new = info[#info].."DisabledDesc"
			parent[new] = self:NewDesc(meta.disabledTooltip, order+0.1, "full", nil, function() return not disabled() end)
		end)
	end

	SetState(t, width or "full", disabled, hidden)
	return t
end

--- Generate an executable button. This function ignores the meta parameter.
-- @function OptionsMixin:NewExecute
-- @param ...
-- @func func The function to call when the button is pressed.
-- @param ...
function OptionsMixin:NewExecute(name, desc, order, func, width, disabled, hidden)
	local t = SetVals("execute", name, desc, order)
	t.func = func

	SetState(t, width, disabled, hidden)
	return t
end

--- Generate an Enable button as seen in the Modules pane.
-- @function OptionsMixin:NewEnableButton
-- @param ...
-- @func enableFunc Bool function to determine Enable/Disable state.
-- @func func The function to call when the button is pressed.
-- @param ...
function OptionsMixin:NewEnableButton(name, desc, order, enableFunc, func, width, disabled, hidden)
	local function nameFunc()
		return format("%s: %s", name, (enableFunc()) and L["API_BtnEnabled"] or L["API_BtnDisabled"])
	end
	local t = self:NewExecute(nameFunc, desc, order, func, width, disabled, hidden)
	return t
end

-- ####################################################################################################################
-- ##### OptionsMixin: User Input Widgets ############################################################################
-- ####################################################################################################################

--- Generate an input box.
-- @function OptionsMixin:NewInput
-- @param ...
function OptionsMixin:NewInput(name, desc, order, meta, width, disabled, hidden)
	local t = SetVals("input", name, desc, order)

	SetupMeta(t, meta)
	SetState(t, width, disabled, hidden)
	return t
end

--- Generate an input box that only accept numbers.
-- @function OptionsMixin:NewInputNumber
-- @param ...
function OptionsMixin:NewInputNumber(name, desc, order, meta, width, disabled, hidden)
	local t = SetVals("input", name, desc, order)
	--t.validate = IsNumber
	t.pattern = "%d"
	t.usage = L["API_InputNumber"]

	local metaTable = SetupMeta(t, meta, true)
	metaTable.isNumber = true
	setmetatable(t, metaTable)
	SetState(t, width, disabled, hidden)
	return t
end

--[[ slider args:
	smin (number) - Soft minimal value of the slider, represented in the UI
	smax (number) - Soft maximal value of the slider, represented in the UI
	step (number) - Useful step size for the slider.
	isPercent (boolean) - If true, will display 1.0 as 100%
	You can also set absolute minimum, maximal and step sizes via Meta
		- By default, the absolutes are the same as the UI.
--]]

--- Generate a value slider.
-- @function OptionsMixin:NewSlider
-- @param ...
-- @number smin Minimal value for the slider, represented in the UI
-- @number smax Maximal value for the slider, represented in the UI
-- @number step How much is a tick of the slider worth
-- @bool isPercent If true, the slider value will display 1.0 as 100%
-- @param ...
function OptionsMixin:NewSlider(name, desc, order, smin, smax, step, isPercent, meta, width, disabled, hidden)
	local t = SetVals("range", name, desc, order)
	t.isPercent = isPercent
	t.softMin, t.softMax, t.bigStep = smin, smax, step

	meta = SetupMeta(t, meta)
	t.min = meta and meta.min or smin
	t.max = meta and meta.max or smax
	t.step = meta and meta.step or step

	SetState(t, width, disabled, hidden)
	return t
end

-- Wrapper of Slider for the purpose of Scaling Sliders
-- Ranges: 50-200, Absolutes: 25-300.

--- Generate a scaling slider
-- @function OptionsMixin:NewScale
-- @param ...
function OptionsMixin:NewScale(name, desc, order, meta, width, disabled, hidden)
	local t = self:NewSlider(name, desc, order, 0.5, 2.5, 0.05, true, meta, width, disabled, hidden)
	t.min, t.max, t.step = 0.25, 3, 0.01

	return t
end

--- Generate a dropdown menu
-- @function OptionsMixin:NewSelect
-- @param ...
-- @tparam table|boolean values A table containing the options given in the dropdown
-- @param dcontrol If you want to specify a specialized LibSharedMedia dropdown control.
-- @param ...
function OptionsMixin:NewSelect(name, desc, order, values, dcontrol, meta, width, disabled, hidden)
	-- TODO: Sort out the confusing nature of dcontrol (possibly split it using new wrappers)
	local t = SetVals("select", name, desc, order)

	if values == true then
		values = Media:HashTable(strlower(strsub(dcontrol, 7)))
	end
	t.dialogControl = dcontrol
	t.values = values

	SetupMeta(t, meta)
	SetState(t, width, disabled, hidden)
	return t
end

-- ####################################################################################################################
-- ##### OptionsMixin: SharedMedia Widgets ############################################################################
-- ####################################################################################################################

-- Specialized LSM Selects
function OptionsMixin:NewTexBackground(name, desc, order, meta, width, disabled, hidden)
	local t = self:NewSelect(name, desc, order, true, LSM_DCONTROL_BACKGROUND, meta, width, disabled, hidden)
	return t
end
function OptionsMixin:NewTexBorder(name, desc, order, meta, width, disabled, hidden)
	local t = self:NewSelect(name, desc, order, true, LSM_DCONTROL_BORDER, meta, width, disabled, hidden)
	return t
end
function OptionsMixin:NewTexStatusBar(name, desc, order, meta, width, disabled, hidden)
	local t = self:NewSelect(name, desc, order, true, LSM_DCONTROL_STATUSBAR, meta, width, disabled, hidden)
	return t
end
function OptionsMixin:NewSound(name, desc, order, meta, width, disabled, hidden)
	local t = self:NewSelect(name, desc, order, true, LSM_DCONTROL_SOUND, meta, width, disabled, hidden)
	return t
end

-- ####################################################################################################################
-- ##### OptionsMixin: Position Widgets ###############################################################################
-- ####################################################################################################################

---TODO: Add NewBackdrop, should feature Header, Background, Border, BorderSize, BackdropColor, BackdropBorderColor

function OptionsMixin:NewPosition(name, order, isXY, meta, width, disabled, hidden)
	--TODO: Function should be using custom sliders instead.
	local t = ShadowOption()
	OptionHook(t, function(info, parent)
		--TODO; Add meta params to customize those.
		local XTable = (isXY) and "X" or info[#info].."X"
		local YTable = (isXY) and "Y" or info[#info].."Y"
		local XDesc = format(L["API_XValue_Desc"], name)..L["API_XValue_Note"]
		local YDesc = format(L["API_YValue_Desc"], name)..L["API_YValue_Note"]
		parent[XTable] = self:NewInputNumber(L["API_XValue_Name"], XDesc, order+0.1, meta, width, disabled, hidden)
		parent[YTable] = self:NewInputNumber(L["API_YValue_Name"], YDesc, order+0.2, meta, width, disabled, hidden)
		parent[info[#info].."Break"] = self:NewLineBreak(order+0.3, hidden)
		t = nil
	end)
	return t
end

-- ####################################################################################################################
-- ##### OptionsMixin: Color Widgets ##################################################################################
-- ####################################################################################################################

--[[ color args:
	hasAlpha (boolean) - if true, there will be a transparency slider on
--]]

--- Generate a color box
-- @function OptionsMixin:NewColor
-- @param ...
-- @bool hasAlpha Wether the color supports an alpha channel or not.
-- @param ...
function OptionsMixin:NewColor(name, desc, order, hasAlpha, meta, width, disabled, hidden)
	local t = SetVals("color", name, desc, order)
	t.hasAlpha = hasAlpha
	t.get, t.set = "ColorGetter", "ColorSetter"

	SetupMeta(t, meta)
	SetState(t, width, disabled, hidden)
	return t
end

-- Generate a Color / Dropdown combo, the dropdown selection determines the color bypass. (Theme, Class, Spec, etc)
-- TODO/EXAMINE: Should we use Color's alpha slider or use a separate alpha slider considering theme/class
-- Width arg not respected.
function OptionsMixin:NewColorMenu(name, order, hasAlpha, meta, width_, disabled, hidden)
	local t = ShadowOption()
	OptionHook(t, function(info, parent)
		local opt = info[#info]
		local optMenu = opt.."Menu"
		local db = self:GetDB("profile", "Colors")
		parent[opt] = self:NewColor(name, nil, order+0.2, hasAlpha, meta, nil, disabled, hidden)
		parent[optMenu] = self:NewSelect(name, nil, order+0.1, LUI.ColorTypes, nil, meta, nil, disabled, hidden)
		--Custom get/set for the dropdown menu
		parent[optMenu].get = function()
			return db[opt].t
		end
		parent[optMenu].set = function(set_info, value)
			db[opt].t = value
			SetFunc(self, set_info, value)
		end
		parent[opt.."Break"] = self:NewLineBreak(order+0.3, hidden)

		--Setting true prevent the setmetatable call and make sure we get a table.
		local mt = SetupMeta(t, meta, true)
		if mt and mt.setfunc then
			if type(mt.setfunc) == "function" then
				LUI:AddColorCallback(tostring(mt.setfunc), mt.setfunc)
			elseif type(mt.setfunc) == "string" then
				LUI:AddColorCallback(tostring(self)..mt.setfunc, self[mt.setfunc])
			end
		end
	end)

	return t
end

--[[Keeping as note for later. If we were to make a function to either show color wheel or alpha slider based on menu.
function(info)
	local parent = GetParentTable(info)
	local optName = info[#info]

	--If i were to use this function on both opt and optAlpha, would need to get opt out of optAlpha.
	--Easy way to do that would be changing the color wheel from opt to optColor and then subtract 5 letters from name.
	local opt = strsub(optName, 1, -6)
	local curOpt = strsub(optName, -5)

	--How to get self out of the info table?
	local db = self:GetDB("profile", "Colors")

	--Alpha Slider should be hidden when under Custom/Individual, displayed all other cases.
	if curOpt == "Alpha" then
		return (db[opt].t == "Custom")
	elseif curOpt == "Color" then
		return not (db[opt].t == "Custom")
	end
end
--]]
