------------------------------------------------------
-- / SETUP AND LOCALS / --
------------------------------------------------------
local addonname, LUI = ...
local module = LUI:NewModule("Panels")
local L = LUI.L
local db

--Defaults
module.defaults = {   
	profile = {
		Textures = {
			ChatBG = {
				Anchored = true,
				TexMode = 1,
				Texture = "panel_corner.tga",
				Point = "TOPRIGHT",
				Parent = "ChatFrame1",
				RelativePoint = "TOPRIGHT",
				CustomTexCoords = false,
				HorizontalFlip = true,
				VerticalFlip = false,
				Width = 409,
				Height = 182,
				Order = 1,
				X = 3,
				Y = 4,
				Left = 0,
				Right = 1,
				Up = 0,
				Down = 1,
			},
		--[[	TestBG = {
				Anchored = true,
				TexMode = 1,
				Texture = "panel_corner.tga",
				Point = "TOPLEFT",
				Parent = "ObjectiveTrackerFrame",
				RelativePoint = "TOPLEFT",
				CustomTexCoords = false,
				HorizontalFlip = false,
				VerticalFlip = false,
				Width = 409,
				Height = 182,
				Order = 2,
				X = -25,
				Y = -2,
				Left = 0,
				Right = 1,
				Up = 0,
				Down = 1,
			},]]
			["Top Bar"] = {
				Anchored = false,
				TexMode = 1,
				Texture = "bar_top.tga",
				Point = "BOTTOM",
				Parent = "UIParent",
				RelativePoint = "BOTTOM",
				CustomTexCoords = false,
				HorizontalFlip = false,
				VerticalFlip = false,
				Width = 702,
				Height = 36,
				Order = 3,
				X = 0,
				Y = 120,
				Left = 0,
				Right = 1,
				Up = 0,
				Down = 1,
			},
			['*'] = {
				Anchored = true,
				TexMode = 1,
				Texture = "panel_corner.tga",
				Point = "CENTER",
				Parent = "UIParent",
				RelativePoint = "CENTER",
				CustomTexCoords = false,
				HorizontalFlip = false,
				VerticalFlip = false,
				Width = 400,
				Height = 300,
				Order = 100,
				X = 0,
				Y = 0,
				Left = 0,
				Right = 1,
				Up = 0,
				Down = 1,
			},
		},
		Colors = {
			ChatBG = { r = 0.12, g = 0.12,  b = 0.12, a = 0.5, t = "Class", },
			["Top Bar"] = { r = 0.12, g = 0.12,  b = 0.12, a = 0.5, t = "Class", },
			['*'] = { r = 0.12, g = 0.12,  b = 0.12, a = 1, t = "Class", },
		}
	},
}


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

-- Table to keep info about preset textures. First four are tex coords (Left, Right, Up, Down), next two are Width/Length of the visible texture.
local LUI_TEXTURES_INFO = {
	["left_border.tga"] =         {20/1024,  595/1024, 231/512, 492/512, 575, 261},
	["left_border_back.tga"] =    {20/1024,  595/1024, 231/512, 492/512, 575, 261},
	["panel_corner.tga"] =        {22/512,   372/512,  12/256,  183/256, 350, 85 },
	["panel_corner_border.tga"] = {14/512,   341/512,  5/256,   145/256, 327, 140},
	["panel_center_border.tga"] = {10/256,   246/256,  9/256,   168/256, 236, 159},
	["bar_top.tga"] =             {161/1024, 863/1024, 13/64,   52/64,   702, 34 },
}

--Table to hold all panels frames.
local setPanels = {}
--Mixin Object for panels.
local PanelMixin = {}

-- LUI Textures Directory
local LUI_TEX_DIR = "Interface\\AddOns\\LUI\\media\\textures\\"

------------------------------------------------------
-- / PANELS FUNCTIONS / --
------------------------------------------------------
function PanelMixin:GetParent()
	--TODO: Add support for LibWindow for proper texture scaling when not anchored.
	if self.db.Anchored then return _G[self.db.Parent]
	else return UIParent
	end
end

function PanelMixin:GetTexture()
	-- TODO: Add support for various texture directories in the future.
	if db.TexMode == 3 then return self.db.Texture
	else return LUI_TEX_DIR..self.db.Texture
	end
end

function PanelMixin:GetTexCoord()
	--PH: Grab TexCoord valuess from db entries
	local left, right, up, down = self.db.Left, self.db.Right, self.db.Up, self.db.Down

	if LUI_TEXTURES_INFO[self.db.Texture] then
		local coord = LUI_TEXTURES_INFO[self.db.Texture]
		left, right, up, down = coord[1], coord[2], coord[3], coord[4]
	end

	local hFlip = self.db.HorizontalFlip
	local vFlip = self.db.VerticalFlip
	
	if hFlip and vFlip then
		--Flip Horizontally and Vertically
		return right, left, down, up
	elseif hFlip and not vFlip then
		--Flip Horizontally only
		return right, left, up, down
	elseif vFlip and not hFlip then
		--Flip Vertically only
		return left, right, down, up
	else
		--Do not flip
		return left, right, up, down
	end
end

function PanelMixin:Refresh()
	local db = self.db
	local parent = _G[db.Parent]
	local r, g, b, a = module:AlphaColor(self.name)

	self:SetPoint(db.Point, parent, db.RelativePoint, db.X, db.Y)
	self:SetSize(db.Width, db.Height)
	self:SetParent(parent)
	self:SetAlpha(a)

	self.tex:SetTexture(self:GetTexture())
	self.tex:SetTexCoord(self:GetTexCoord())
	self.tex:SetDesaturated(true)
	self.tex:SetVertexColor(r, g, b)

end
------------------------------------------------------
-- / MODULE FUNCTIONS / --
------------------------------------------------------

function module:CreateNewPanel(name, db)
	local panel = CreateFrame("Frame", "LUIPanel_"..name, UIParent)
	
	local tex = panel:CreateTexture(nil, "BACKGROUND")
	tex:SetPoint("TOPLEFT", panel, "TOPLEFT")
	tex:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT")
	setPanels[name] = panel
	panel.name = name
	panel.tex = tex
	panel.db = db
	
	--Add the mixin
	for k, v in pairs(PanelMixin) do
		panel[k] = v
	end

	panel:Refresh()
	return panel
end

function module:setPanels()
	module.panelList = {}
	for k, v in pairs(db.Textures) do
		table.insert(module.panelList, k)
	end
	sort(module.panelList, function(a, b)
		return db.Textures[a].Order < db.Textures[b].Order
	end)

	for name, db in pairs(module:GetDB().Textures) do
		local frame = module:CreateNewPanel(name, db)
	end
end

------------------------------------------------------
-- / FRAMEWORK FUNCTIONS / --
------------------------------------------------------

-- info[#info-1] inside an PanelOptionGroup returns the texture's name, setPanels[name] returns the frame
local function IsAnchorParentDisabled(info) return not setPanels[info[#info-1]].db.Anchored end
local function IsTexCoordsHidden(info) return not setPanels[info[#info-1]].db.CustomTexCoords end
local function IsTextureInputHidden(info) return setPanels[info[#info-1]].db.TexMode == 1 end
local function IsTextureSelectHidden(info) return setPanels[info[#info-1]].db.TexMode ~= 1 end
local function GetOptionTexCoords(info) return setPanels[info[#info-1]]:GetTexCoord() end
local function GetOptionImageTexture(info) return setPanels[info[#info-1]]:GetTexture() end
local function RefreshPanel(info) return setPanels[info[#info-1]]:Refresh() end

-- LUI preset textures have their tex coords provided. 
local function IsCustomTexCoordsHidden(info)
	return PRESET_LUI_TEXTURES[setPanels[info[#info-1]].db.Texture]
end

-- Due to the way the Panel DB is handled, it needs its own get/set
function module:PanelGetter(info, ...)
	local panel = setPanels[info[#info-1]]
	local optionName = info[#info]
	local value = panel.db[optionName]
	--Inputs cannot display numbers. Have to convert to string.
	if info.option.type == "input" then return tostring(value) end
	return value
end

function module:PanelSetter(info, value, ...)
	-- Make sure not to save a number as a string
	if tonumber(value) then
		value = tonumber(value)
	end
	
	local panel = setPanels[info[#info-1]]
	local optionName = info[#info]

	panel.db[optionName] = value
	panel:Refresh()
end

-- Template for panel option menu
function module:NewPanelOptionGroup(name, order)
	-- Need new Get/Set for TextureSelect since you cant have two options named Texture.
	local texSelectMeta = {
		get = function(info)
			return setPanels[info[#info-1]].db.Texture
		end,
		set = function(info, value)
			local panel = setPanels[info[#info-1]]
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
		TextureSelect = module:NewSelect(L["Panels_Options_TextureSelect"], L["Panels_Options_TextureSelect_Desc"], 4, PRESET_LUI_TEXTURES, nil, texSelectMeta, nil, nil, IsTextureSelectHidden),
		LineBreak1 = module:NewLineBreak(5),
		Anchored = module:NewToggle(L["Panels_Options_Anchored"], L["Panels_Options_Anchored_Desc"], 6, nil, "normal"),
		Parent = module:NewInput(L["Parent"], L["Panels_Options_Parent_Desc"], 7, nil, nil, IsAnchorParentDisabled),
		HorizontalFlip = module:NewToggle(L["Panels_Options_HorizontalFlip"], L["Panels_Options_HorizontalFlip_Desc"], 8),
		VerticalFlip = module:NewToggle(L["Panels_Options_VerticalFlip"], L["Panels_Options_VerticalFlip_Desc"], 9),
		CustomTexCoords = module:NewToggle(L["Panels_Options_CustomTexCoords"], L["Panels_Options_CustomTexCoords_Desc"], 10, nil, nil, nil, IsCustomTexCoordsHidden),
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

--Value used by options
local nameInput = ""
local panelSelect = 0
module.childGroups = "tree"

function module:NewPanel(info)
	--Do not create new panel if the entry is nil or already exists
	if not nameInput or nameInput:trim() == "" then return end
	if tContains(module.panelList, nameInput) then 
		module:ModPrint("A panel by that name already exists") 
		return 
	end
	
	local panelDB =  db.Textures[nameInput]
	--Set the order so that, in theory, order values do not overlap.
	panelDB.Order = #module.panelList+1
	table.insert(module.panelList, nameInput)

	-- Create and show the new panel
	module:CreateNewPanel(nameInput, panelDB)
	
	-- Update options
	info.options.args[info[#info-1]].args[nameInput] = module:NewPanelOptionGroup(nameInput, panelDB.Order)
	LUI:RefreshOptionsPanel()
	
	module:ModPrint("Created new panel:", nameInput)
end

function module:DeletePanel(info)
	local panelName = module.panelList[panelSelect]
	if not panelName then return end
	table.remove(module.panelList, panelSelect)
	_G["LUIPanel_"..panelName]:Hide()
	db.Textures[panelName] = nil
	
	info.options.args[info[#info-1]].args[panelName] = nil
	LUI:RefreshOptionsPanel()
	module:ModPrint("Deleted panel:", panelName)
end

function module:LoadOptions()
	local nameInputMeta = { get = function(info) return nameInput end, set = function(info, value) nameInput = value end}
	local panelSelectMeta = { get = function(info) return panelSelect end, set = function(info, value) panelSelect = value end}
	local options = {
		Header = module:NewHeader(L["Panels_Name"], 1),
		nameInput = module:NewInput(L["Panels_Options_InputName"], "", 2, nameInputMeta),
		NewPanel = module:NewExecute(L["Panels_Options_NewPanel"], nil, 3, "NewPanel"),
		LineBreak = module:NewLineBreak(4),
		SelectDelete = module:NewSelect(L["Panels_Options_PanelSelect"], L["Panels_Options_PanelSelect_Desc"], 5, module.panelList, nil, panelSelectMeta),
		DeletePanel = module:NewExecute(L["Panels_Options_DeletePanel"], nil, 6, "DeletePanel"),
	}
	for i = 1, #module.panelList do
		local panelName = module.panelList[i]
		local panelDB = db.Textures[panelName]
		options[panelName] = module:NewPanelOptionGroup(panelName, panelDB.Order)
	end
	
	return options
end

function module:OnInitialize()
	LUI:RegisterModule(module)
	db = module:GetDB()
end

function module:OnEnable()
	module:setPanels()
end

function module:OnDisable()
end
