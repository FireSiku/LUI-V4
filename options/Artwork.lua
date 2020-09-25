-- ####################################################################################################################
-- ##### Setup and Locals #############################################################################################
-- ####################################################################################################################
---@type Opt
local optName, Opt = ...
local LUI = LibStub("AceAddon-3.0"):GetAddon("LUI4")
-- local module = LUI:GetModule("Artwork")
-- local db = module.db.profile
local L = LUI.L

-- ####################################################################################################################
-- ##### Utility Functions ############################################################################################
-- ####################################################################################################################


-- ####################################################################################################################
-- ##### Options Table ################################################################################################
-- ####################################################################################################################
Opt.options.args.Artwork = Opt:Group("Artwork", nil, nil, "tab", true, nil, Opt.GetSet(db))
Opt.options.args.Artwork.handler = module
local Artwork = {

}

Opt.options.args.Artwork.args = Artwork

--[[
    -- Template for panel option menu
function module:NewPanelOptionGroup(name, order)
	-- Need new Get/Set for TextureSelect since you cant have two options named Texture.
	local texSelectMeta = {
		get = function(info)
			return setPanels[ info[#info-1] ].db.Texture
		end,
		set = function(info, value)
			local panel = setPanels[ info[#info-1] ]
			panel.db.Texture = value
			panel:Refresh()
		end,
	}
	return module:NewGroup(name, order, nil, nil, "PanelGetter", "PanelSetter", {
		TexHead = module:NewHeader(L["Texture"], 1),
		ImageDesc = {
			type = "description", name = " ", order = 2, image = GetOptionImageTexture,
			imageWidth = 256, imageHeight = 128, imageCoords = GetOptionTexCoords,
		},
		TexMode = module:NewSelect(L["Panels_Options_Category"], nil, 3, TEX_MODE_SELECT),
		Texture = module:NewInput(L["Texture"], L["Panels_Options_Texture_Desc"], 4, nil, nil, nil, IsTextureInputHidden),
		TextureSelect = module:NewSelect(L["Panels_Options_TextureSelect"], L["Panels_Options_TextureSelect_Desc"],
		                                4, PRESET_LUI_TEXTURES, nil, texSelectMeta, nil, nil, IsTextureSelectHidden),
		LineBreak1 = module:NewLineBreak(5),
		Anchored = module:NewToggle(L["Panels_Options_Anchored"], L["Panels_Options_Anchored_Desc"], 6, nil, "normal"),
		Parent = module:NewInput(L["Parent"], L["Panels_Options_Parent_Desc"], 7, nil, nil, IsAnchorParentDisabled),
		HorizontalFlip = module:NewToggle(L["Panels_Options_HorizontalFlip"], L["Panels_Options_HorizontalFlip_Desc"], 8),
		VerticalFlip = module:NewToggle(L["Panels_Options_VerticalFlip"], L["Panels_Options_VerticalFlip_Desc"], 9),
		CustomTexCoords = module:NewToggle(L["Panels_Options_CustomTexCoords"], L["Panels_Options_CustomTexCoords_Desc"],
		                                    10, nil, nil, nil, IsCustomTexCoordsHidden),
		Left = module:NewInput(L["Point_Left"], nil, 11, nil, "half", nil, IsTexCoordsHidden),
		Right = module:NewInput(L["Point_Right"], nil, 12, nil, "half", nil, IsTexCoordsHidden),
		Up = module:NewInput(L["Point_Up"], nil, 13, nil, "half", nil, IsTexCoordsHidden),
		Down = module:NewInput(L["Point_Down"], nil, 14, nil, "half", nil, IsTexCoordsHidden),
		SettingsHeader = module:NewHeader(L["Settings"], 15),
		Width = module:NewInputNumber(L["Width"], nil, 16),
		Height = module:NewInputNumber(L["Height"], nil, 17),
		LineBreak2 = module:NewLineBreak(18),
		[(name)] = module:NewColorMenu(L["Color"], 19, true, RefreshPanel),
		PosHeader = module:NewHeader(L["Position"], 20),
		Point = module:NewSelect(L["Anchor"], nil, 21, LUI.Points),
		RelativePoint = module:NewSelect(L["Anchor"], nil, 22, LUI.Points),
		LineBreak3 = module:NewLineBreak(23),
		Position = module:NewPosition(L["Position"], 24, true),
	})
end

function module:NewPanel(info)
	--Do not create new panel if the entry is nil or already exists
	if not nameInput or nameInput:trim() == "" then return end
	if tContains(module.panelList, nameInput) then
		module:ModPrint("A panel by that name already exists")
		return
	end
	
	local panelDB = db.Textures[nameInput]
	--Set the order so that, in theory, order values do not overlap.
	panelDB.Order = #module.panelList+1
	table.insert(module.panelList, nameInput)

	-- Create and show the new panel
	module:CreateNewPanel(nameInput, panelDB)

	-- Update options
	info.options.args[ info[#info-1] ].args[nameInput] = module:NewPanelOptionGroup(nameInput, panelDB.Order)
	LUI:RefreshOptionsPanel()

	module:ModPrint("Created new panel:", nameInput)
end

function module:DeletePanel(info)
	local panelName = module.panelList[panelSelect]
	if not panelName then return end
	table.remove(module.panelList, panelSelect)
	_G["LUIPanel_"..panelName]:Hide()

	db.Textures[panelName] = nil
	-- Get the parent node and remove panel options.
	info.options.args[ info[#info-1] ].args[panelName] = nil
	LUI:RefreshOptionsPanel()
	module:ModPrint("Deleted panel:", panelName)
end

function module:LoadOptions()
	local nameInputMeta = {
		get = function(info_) return nameInput end,
		set = function(info_, value) nameInput = value end
	}
	local panelSelectMeta = {
		get = function(info_) return panelSelect end,
		set = function(info_, value) panelSelect = value end
	}
	local options = {
		Header = module:NewHeader(L["Panels_Name"], 1),
		nameInput = module:NewInput(L["Panels_Options_InputName"], "", 2, nameInputMeta),
		NewPanel = module:NewExecute(L["Panels_Options_NewPanel"], nil, 3, "NewPanel"),
		LineBreak = module:NewLineBreak(4),
		SelectDelete = module:NewSelect(L["Panels_Options_PanelSelect"], L["Panels_Options_PanelSelect_Desc"],
		                                    5, module.panelList, nil, panelSelectMeta),
		DeletePanel = module:NewExecute(L["Panels_Options_DeletePanel"], nil, 6, "DeletePanel"),
	}
	for i = 1, #module.panelList do
		local panelName = module.panelList[i]
		local panelDB = db.Textures[panelName]
		options[panelName] = module:NewPanelOptionGroup(panelName, panelDB.Order)
	end

	return options
end
]]