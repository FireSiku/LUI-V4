--[[
	Project....: LUI
	File.......: layout.lua
	Description: This file is part of the core, and keeps all the layout and theme/colors stuff.
	Version....: 4.0
	Rev Date...: 19/08/12 [dd/mm/yy]
]]

local addonName, LUI = ...

local module = LUI:NewModule("Layout") -- Create module
local db, layoutDB
local L = LUI.L

local NS = LibStub("LibSerialize")
local LibC = LibStub:GetLibrary("LibCompress")
local LibCE = LibC:GetAddonEncodeTable()

local bypassList = { "Api", "Layout", }

--local Serializer=LibStub("LibSerialize");  -- get it
--String = Serializer:Serialize(Data); -- serialize those Data into a String
--Data = Serializer:DeSerialize(String); -- deserialize that String back into Data

module.defaults = {
	global = {
		layouts = {
			["*"] = {},
		},
	},

	profile = {
		currentTheme = "Default",
	},
}
function module:OnInitialize()
	LUI:RegisterModule(module)
end

function module:OnEnable()
	db = module.db.profile
	layoutDB = module.db.global.layouts
end

------------------------------------------------------
-- / LAYOUT SAVING TEST FUNCS / --
------------------------------------------------------

local layoutText = ""
local layoutTextNameFormat = L["Layout_TextLength"]

local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if type(orig) == 'table' then
        copy = {}
        for k, v in pairs(orig) do
            copy[k] = deepcopy(v)
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

local function bypassModule(name)
	for k,v in pairs(bypassList) do
		if v == name then
			return true
		end
	end
	return false
end

function LUI:OnLayoutSave()
	--return dbLayout
end

--CommonStrings V2. This time it deepcopies the table AND converts it.
function LUI:ToCommonStrings(orig)
	local CS = LUI.ReverseStrings
	local data
	if type(orig) == 'table' then
		data = {}
		for k, v in pairs(orig) do
			if CS[k] then data[CS[k]] = LUI:ToCommonStrings(v)
			else data[k] = LUI:ToCommonStrings(v)
			end
		end
	else
		if CS[orig] then data = CS[orig]
		else data = orig
		end
	end
	return data
end

function LUI:FromCommonStrings(orig)
	local CS = LUI.CommonStrings
	local data
	if type(orig) == 'table' then
		data = {}
		for k, v in pairs(orig) do
			if CS[k] then data[CS[k]] = LUI:FromCommonStrings(v)
			else data[k] = LUI:FromCommonStrings(v)
			end
		end
	else
		if CS[orig] then data  = CS[orig]
		else data = orig
		end
	end
	return data
end

local function ModuleColorsToString(target)
	if target.Colors then
		for k, v in pairs(target.Colors) do
			target.Colors[k] = LUI:LUIColorToString(v)
		end
	end
	return target
end

local disableOptimize = false -- TestVar. Disable the optimization of the string.
function LUI:SaveLayout(layoutName, layoutDesc, layoutAuthor)
	--Create the layout table, fill basic info
	local layoutTable = {
		meta = {
			name = layoutName,
			author = layoutAuthor,
			desc = layoutDesc,
		},
	}

	
	--Check that the CommonStrings are loaded.
	if not LUI.CommonStrings then LUI:GenerateCommonStrings() end

	--Set up Core table.
	layoutTable["LUI"] = LUI:OnLayoutSave()

	--ToDo: Filter out default values out of the table before compressing it.
	--This can wait until modules are in place so we can see how much space we're actually saving.
	for name, module in self:IterateModules() do
		if module.db and module.db.profile and not bypassModule(name) then
			if module.OnLayoutSave and (not disableOptimize) then
				layoutTable[name] = module:OnLayoutSave(deepcopy(module.db.profile))
			else
				layoutTable[name] = deepcopy(module.db.profile)
			end
			if (not disableOptimize) then 
				ModuleColorsToString(layoutTable[name]) 
			end
		end
	end

	layoutDB[layoutName] = nil
	layoutDB[layoutName] = layoutTable

	--This is only for debug purposes. Actual serialization will be in the import function
	local data = layoutTable
	if (not disableOptimize) then data = LUI:ToCommonStrings(layoutTable) end
	local one = NS:Serialize(data)
	--local two = LibC:CompressHuffman(one)
	--local final = LibCE:Encode(two)
	layoutText = one
end

function LUI:LoadLayout(layoutName)

	--ResetProfileHere
	local one = LibCE:Decode(layoutText)
	local two = LibC:Decompress(one)
	layoutText = two
	--[[
	local data = NS:DeSerialize(layoutText)
	local layoutTable = LUI:FromCommonStrings(data)
	--If the module had a LayoutSave call, try to call LayoutLoad to revert the changes.
	for name, module in self:IterateModules() do
		if module.OnLayoutSave and not bypassModule(name) then
			if module.OnLayoutLoad then
				layoutTable[name] = module:OnLayoutLoad(layoutTable[name])
			end
		end
	end

	LUI:PrintTable(layoutTable)
	--]]
end

module.order = 2
function module:LoadOptions()
	local options = {
		Header = { name = L["Layout_Name"], type = "header", order = 1, },
		SaveLayout = module:NewExecute(L["Layout_SaveLayout_Name"], L["Layout_SaveLayout_Desc"], 2,
					function(info)
						LUI:SaveLayout("Test", "Siku", "Default Layout")
					end),
		LoadLayout = module:NewExecute(L["Layout_LoadLayout_Name"], L["Layout_LoadLayout_Desc"], 3,
					function(info)
						LUI:LoadLayout()
					end),
		LayoutString = {
			type = "input", order = 5, width = "full", multiline = 20,
			name = function() return format(layoutTextNameFormat, strlen(layoutText)) end,
			get = function() return layoutText end,
			set = function() end,
		},
	}

	return options
end
