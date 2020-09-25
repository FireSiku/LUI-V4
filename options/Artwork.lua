-- ####################################################################################################################
-- ##### Setup and Locals #############################################################################################
-- ####################################################################################################################
---@type Opt
local optName, Opt = ...
local LUI = LibStub("AceAddon-3.0"):GetAddon("LUI4")
local module = LUI:GetModule("Artwork")
local db = module.db.profile
local L = LUI.L

local TEX_MODE_SELECT = {
	L["Panels_TexMode_LUI"],
	L["Panels_TexMode_CustomLUI"],
	L["Panels_TexMode_Custom"],
}

local PRESET_LUI_TEXTURES = {
	["left_border.tga"] = L["Panels_Tex_Border_Screen"],
	["left_border_back.tga"] = L["Panels_Tex_Border_ScreenBack"],
	["panel_solid.tga"] = L["Panels_Tex_Panel_Solid"] ,
	["panel_corner.tga"] = L["Panels_Tex_Panel_Corner"],
	["panel_center.tga"] = L["Panels_Tex_Panel_Center"],
	["panel_corner_border.tga"] = L["Panels_Tex_Border_Corner"],
	["panel_center_border.tga"] = L["Panels_Tex_Border_Center"],
	["bar_top.tga"] = L["Panels_Tex_Bar_Top"],
}

local nameInput

-- ####################################################################################################################
-- ##### Utility Functions ############################################################################################
-- ####################################################################################################################
-- info[#info-1] inside an PanelOptionGroup returns the texture's name, setPanels[name] returns the frame
local function IsAnchorParentDisabled(info) return not db.Textures[info[#info-1]].Anchored end
local function IsTexCoordsHidden(info) return not db.Textures[info[#info-1]].CustomTexCoords end
local function IsTextureInputHidden(info) return db.Textures[info[#info-1]].TexMode == 1 end
local function IsTextureSelectHidden(info) return db.Textures[info[#info-1]].TexMode ~= 1 end
-- local function GetOptionTexCoords(info) return setPanels[info[#info-1]]:GetTexCoord() end
-- local function GetOptionImageTexture(info) return setPanels[info[#info-1]]:GetTexture() end
-- local function RefreshPanel(info) return setPanels[info[#info-1]]:Refresh() end

-- LUI preset textures have their tex coords provided.
local function IsCustomTexCoordsHidden(info)
	return PRESET_LUI_TEXTURES[db.Textures[info[#info-1]].Texture]
end

local function CreatePanelGroup(name)
	local texDB = db.Textures[name]
	local group = Opt:Group(name, nil, 10, nil, nil, nil, Opt.GetSet(texDB))
	LUI:Print(group)
	group.args = {
		TextureHeader = Opt:Header(L["Texture"], 1),
		--ImageDesc = Opt:Desc("", 2, nil, GetOptionImageTexture, GetOptionTexCoords, 256, 128),
		TexMode = Opt:Select(L["Panels_Options_Category"], nil, 3, TEX_MODE_SELECT),
		Texture = Opt:Input(L["Texture"], L["Panels_Options_Texture_Desc"], 4, nil, nil, nil, IsTextureInputHidden),
		TextureSelect = Opt:Select(L["Panels_Options_TextureSelect"], L["Panels_Options_TextureSelect_Desc"], 4, PRESET_LUI_TEXTURES, nil, nil, IsTextureSelectHidden,
			function(info) return texDB.Texture end, function(info, value) texDB.Texture = value end),
		LineBreak1 = Opt:Spacer(5),
		Anchored = Opt:Toggle(L["Panels_Options_Anchored"], L["Panels_Options_Anchored_Desc"], 6, nil, "normal"),
		Parent = Opt:Input(L["Parent"], L["Panels_Options_Parent_Desc"], 7, nil, nil, IsAnchorParentDisabled),
		LineBreak = Opt:Spacer(8),
		HorizontalFlip = Opt:Toggle(L["Panels_Options_HorizontalFlip"], L["Panels_Options_HorizontalFlip_Desc"], 8),
		VerticalFlip = Opt:Toggle(L["Panels_Options_VerticalFlip"], L["Panels_Options_VerticalFlip_Desc"], 9),
		CustomTexCoords = Opt:Toggle(L["Panels_Options_CustomTexCoords"], L["Panels_Options_CustomTexCoords_Desc"], 10, nil, nil, nil, IsCustomTexCoordsHidden),
		Left = Opt:Input(L["Point_Left"], nil, 11, nil, "half", nil, IsTexCoordsHidden),
		Right = Opt:Input(L["Point_Right"], nil, 12, nil, "half", nil, IsTexCoordsHidden),
		Up = Opt:Input(L["Point_Up"], nil, 13, nil, "half", nil, IsTexCoordsHidden),
		Down = Opt:Input(L["Point_Down"], nil, 14, nil, "half", nil, IsTexCoordsHidden),
		SettingsHeader = Opt:Header(L["Settings"], 15),
		Width = Opt:InputNumber(L["Width"], nil, 16),
		Height = Opt:InputNumber(L["Height"], nil, 17),
		LineBreak2 = Opt:Spacer(18),
		--[(name)] = Opt:ColorMenu(L["Color"], 19, true, RefreshPanel),
		PosHeader = Opt:Header(L["Position"], 20),
		Point = Opt:Select(L["Anchor"], nil, 21, LUI.Points),
		RelativePoint = Opt:Select(L["Anchor"], nil, 22, LUI.Points),
		LineBreak3 = Opt:Spacer(23),
		--Position = Opt:Position(L["Position"], 24, true),
	}
	return group
end

local function IsNewPanelDisabled(info)
	if not nameInput or nameInput:trim() == "" then return true end
	if tContains(module.panelList, nameInput) then return true end
end

local function CreateNewPanel(info)
	local panelDB = db.Textures[nameInput]
	--Set the order so that, in theory, order values do not overlap.
	panelDB.Order = #module.panelList+1
	table.insert(module.panelList, nameInput)

	-- Create and show the new panel
	module:CreateNewPanel(nameInput, panelDB)

	-- Update options
	LUI:Print("Name: ", nameInput)
	info.options.args[ info[#info-1] ].args[nameInput] = CreatePanelGroup(nameInput)
	LUI:RefreshOptionsPanel()

	module:ModPrint("Created new panel:", nameInput)
end

-- local function DeleteNewPanel(info)
-- 	local panelName = module.panelList[panelSelect]
-- 	if not panelName then return end
-- 	table.remove(module.panelList, panelSelect)
-- 	_G["LUIPanel_"..panelName]:Hide()

-- 	db.Textures[panelName] = nil
-- 	-- Get the parent node and remove panel options.
-- 	info.options.args[ info[#info-1] ].args[panelName] = nil
-- 	LUI:RefreshOptionsPanel()
-- 	module:ModPrint("Deleted panel:", panelName)
-- end

-- ####################################################################################################################
-- ##### Options Table ################################################################################################
-- ###################################################################################################################w#
Opt.options.args.Artwork = Opt:Group("Artwork", nil, nil, "tab", nil, nil, Opt.GetSet(db))
Opt.options.args.Artwork.handler = module
local Artwork = {
	Header = Opt:Header("Artwork", 1),
	Custom = Opt:Group("Custom Panels", nil, 2, "tree"),
	Builtin = Opt:Group("LUI Panels", nil, 3, "tree", nil, true),
}

Artwork.Custom.args.NewDesc = Opt:Desc("Create New Panel:", 1, nil, nil, nil, nil, nil, "normal")
Artwork.Custom.args.NameInput = Opt:Input("Panel Name", nil, 2, nil, nil, nil, nil, nil, function() return nameInput or "" end, function(_, value) nameInput = value end)
Artwork.Custom.args.NewPanel = Opt:Execute("Create", nil, 3, CreateNewPanel, nil, IsNewPanelDisabled)
for i = 1, #module.panelList do
	local name = module.panelList[i]
	Artwork.Custom.args[name] = CreatePanelGroup(name)
end

Opt.options.args.Artwork.args = Artwork