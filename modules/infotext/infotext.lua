-- This module handle various Infotext by LUI or other addons.
-- It's job is to provide a LDB Display for any addon that wishes to have one and our own displays too.
-- This module also serves as both an access to LDB and access to Ace features for its elements.

------------------------------------------------------
-- / SETUP AND LOCALS / --
------------------------------------------------------
local _, LUI = ...
local module = LUI:NewModule("Infotext")
local LDB = LibStub:GetLibrary("LibDataBroker-1.1")
module.RegisterLDBCallback = LDB.RegisterCallback
module.LDB = LDB
local L = LUI.L
local db

local select, pairs = select, pairs

-- constants
local INFOPANEL_TEXTURE = "Interface\\AddOns\\LUI4\\media\\textures\\infopanel"

-- local variables
local elementFrames = {} -- Holds all the LDB frames.
local elementStorage = {} -- Will hold the infotext's elements for iteration.
local InfoMixin = {} -- Prototype for element functions.

--TODO: Improve Support
--Unsupported data fields: value, suffix, label, icon, tooltip
local supportedTypes = {
	["data source"] = true,
	["launcher"] = true,
}

--[[ Infotext left:
function module:SetDualSpec()  -- Need Icon setup
function module:SetGuild()     -- Need Clickable Tootlips (Infotip)
function module:SetFriends()   -- Need Clickable Tooltips (Infotip)
--]]

local defaultPositions = 0

--Defaults
module.defaults = {
	profile = {
		['**'] = {
			Enable = true, -- Placeholder
			Y = 0,
			X = 0,
		},
		General = {
			AllowY = false,
		},
		Colors = {
			Title =  { r = 0.4,  g = 0.8,   b = 1,            },
			Hint =   { r = 0,    g = 1,     b = 0,            },
			Panels = { r = 0.12, g = 0.58,  b = 0.89, a = 0.5, t = "Class", },
		},
		Fonts = {
			Infotext = { Name = "vibroceb",  Size = 12, Flag = "OUTLINE", },
			Infotip =  { Name = "prototype", Size = 12, Flag = "NONE",    },
		},
	},
}
------------------------------------------------------
-- / InfoMixin FUNCTIONS / --
------------------------------------------------------
function InfoMixin:GetName()
	return LDB:GetNameByDataObject(self)
end

function InfoMixin:GetFrame()
	return elementFrames[self:GetName()]
end

function InfoMixin:TooltipHeader(headerName, handleGT)
	--TODO: Change anchor to support more choices later on.
	if handleGT then
		GameTooltip:SetOwner(self:GetFrame(), "ANCHOR_BOTTOM")
		GameTooltip:ClearLines()
	end
	--Make sure the header ends with a colon
	if headerName:sub(-1) ~= ":" then
		headerName = headerName..":"
	end
	GameTooltip:AddLine(headerName, module:Color("Title"))
	GameTooltip:AddLine(" ")
end

function InfoMixin:AddHint(...)
	local r, g, b = module:Color("Hint")
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(L["Info_Hint"], r, g, b)
	for i=1, select("#", ...) do
		GameTooltip:AddLine(select(i, ...), r, g, b)
	end
end

function InfoMixin:AddUpdate(func, delay)
	local frame = self:GetFrame()
	frame.time = 0
	--Check if func is a methodname or function reference
	local method = type(func) == "string" and true or false
	--Set up the update script
	frame:SetScript("OnUpdate", function(frame, elapsed)
		frame.time = frame.time + elapsed
		if frame.time > delay then
			frame.time = 0
			if method then
				self[func](self)
			else
				func()
			end
		end
	end)
end

function InfoMixin:ResetUpdateTimer()
	local frame = self:GetFrame()
	frame.time = 0
end

function InfoMixin:UpdateTooltip()
	local frame = self:GetFrame()
	if frame:IsMouseOver() and GameTooltip:GetOwner() == frame then
		-- Re-update the tooltip by faking an OnEnter event.
		-- OnEvent's bool should be false if the mouse was already inside the frame
		module.OnEnterHandler(frame, false)
	end
end

------------------------------------------------------
-- / MODULE FUNCTIONS / --
------------------------------------------------------

function module:GetAnchor(position)
	return _G[format("LUIInfotext_%sAnchor", position:lower())]
end

--This is actually a dummy anchor frame.
local function SetInfoPanels()
	local topAnchor = module:GetAnchor("top")
	local bottomAnchor = module:GetAnchor("bottom")
	if not topAnchor then
		topAnchor = CreateFrame("Frame", "LUIInfotext_topAnchor", UIParent)
		topAnchor:SetSize(1, 1)
		topAnchor:SetFrameStrata("HIGH")
		topAnchor:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, -1)

		local topPanelTex = CreateFrame("Frame", "LUIInfotext_topPanel", topAnchor)
		topPanelTex:SetSize(32, 32)
		topPanelTex:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 8)
		topPanelTex:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, 8)
		topPanelTex:SetFrameStrata("BACKGROUND")
		topPanelTex:SetBackdrop({
			bgFile = INFOPANEL_TEXTURE,
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			edgeSize = 1,
			insets = {left = 0, right = 0, top = 0, bottom = 0}
		})
		topPanelTex:SetBackdropColor(module:AlphaColor("Panels"))
		topPanelTex:SetBackdropBorderColor(0, 0, 0, 0)
		topPanelTex:Show()
	end
	if not bottomAnchor then
		bottomAnchor = CreateFrame("FRAME", "LUIInfotext_bottomAnchor", UIParent)
		bottomAnchor:SetSize(1, 1)
		bottomAnchor:SetFrameStrata("HIGH")
		bottomAnchor:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 4)
	end
	topAnchor:Show()
	bottomAnchor:Show()
end

-- Unlike other modules, the infotexts elements needs to be LDB DataObjects so we cant use Ace :NewModule()
-- The choices were to make an Ace module and clone LDB functionality, or an LDB object that has Ace functionality.
-- The former requires to clone both LDB Object and LDB Display functionality to support actual LDBs.
-- Went with the latter one, thus the need to keep memory of Elements created through this function.
-- :NewElement is only called for LUI infotexts.
function module:NewElement(name, ...)
	local element = LDB:NewDataObject(name, {type = "data source", text = name})
	for k, v in pairs(InfoMixin) do
		element[k] = v
	end
	-- Add Embeddable Ace Libraries.
	for i=1, select("#", ...) do
		LibStub(select(i, ...)):Embed(element)
	end
	elementStorage[name] = element
	element.GetParent = function()
		return self:GetName(), self
	end
	return element
end

--Override the module iterator
function module:IterateModules()
	return pairs(elementStorage)
end

function module:IsPositionSet(name)
	return (db[name].X ~= 0) and true or false
end

------------------------------------------------------
-- / LDB HANDLING / --
------------------------------------------------------

--This is used on the creation of any LDB Object
function module:DataObjectCreated(name, element)
	--LUI:Print("Object Created:", name, "("..element.type..")",not supportedTypes[element.type] and "(unsupported)" or "")
	if not supportedTypes[element.type] then return end
	
	local topAnchor = module:GetAnchor("top")
	local frame = CreateFrame("Button", "LUIInfo_"..name, topAnchor)
	elementFrames[name] = frame
	frame.name = name
	frame.element = element

	frame.text = module:SetFontString(frame, frame:GetName().."Text", "Infotext", "OVERLAY", "LEFT")
	frame.text:SetTextColor(1,1,1)
	frame.text:SetShadowColor(0,0,0)
	frame.text:SetShadowOffset(1.25, -1.25)

	frame:RegisterForClicks("AnyUp")
	frame:SetScript("OnClick", module.OnClickHandler)
	frame:SetScript("OnEnter", module.OnEnterHandler)
	frame:SetScript("OnLeave", module.OnLeaveHandler)

	--Do some element based stuff here
	if elementStorage[name] then LUI:EmbedModule(element) end
	if element.OnCreate then element:OnCreate(frame) end
	
	if module:IsPositionSet(name) then
		local anchor = module:GetAnchor("top")
		frame:SetParent(anchor)
		-- To remove "or 0" when nil issue is fixed.
		frame.text:SetPoint("TOPLEFT", anchor, "TOPLEFT", db[name].X, db[name].Y or 0)
	else
		local anchor = module:GetAnchor("bottom")
		frame:SetParent(anchor)
		defaultPositions = defaultPositions + 1
		local defaultX = -100 + (145 * defaultPositions)
		frame.text:SetPoint("BOTTOMLEFT", anchor, "BOTTOMLEFT", defaultX, db[name].Y)
	end
	frame:SetAllPoints(frame.text)

	frame.text:SetText(element.text)
	frame:Show()

	--This allow me to unregister callbacks based on element instead of filtering using the global one.
	module:RegisterLDBCallback("LibDataBroker_AttributeChanged_"..name, "AttributeChanged")
end

function module:AttributeChanged(event_, name, attr, value, element_)
	local frame = elementFrames[name]
	if attr == "text" then
		frame.text:SetText(value)
	end
	--if not ph[name] then LUI:Print("Attribute Changed:", name, attr, "("..value..")") end
end

function module.OnClickHandler(self, ...)
	local element = self.element
	if element.OnClick then element.OnClick(self, ...) end
end

function module.OnEnterHandler(self, ...)
	--TODO: Have a way to not show them in combat.
	local element = self.element
	if element.OnEnter then
		element.OnEnter(self, ...)
	elseif element.OnTooltipShow then
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
		GameTooltip:ClearLines()
		element.OnTooltipShow(GameTooltip)
		GameTooltip:Show()
	end
end

function module.OnLeaveHandler(self, ...)
	local element = self.element
	if element.OnLeave then
		element.OnLeave(self, ...)
	elseif element.OnTooltipShow then
		GameTooltip:Hide()
	end
end

function module:IsInfotextEnabled(name)
	return db[name].Enable
end

function module:ShowInfotext(name)
	elementFrames[name]:Show()
	db[name].Enable = true
end

function module:HideInfotext(name)
	elementFrames[name]:Hide()
	db[name].Enable = false
end

function module:ToggleInfotext(name)
	local frame = elementFrames[name]
	if frame:IsShown() then
		frame:Hide()
		db[name].Enable = false
	else
		frame:Show()
		db[name].Enable = true
	end
end
------------------------------------------------------
-- / FRAMEWORK FUNCTIONS / --
------------------------------------------------------

module.enableButton = true

-- Objects that are disabled shouldn't clog your option tabs.
local function IsInfotextGroupHidden(info) return not db[info[#info]].Enable end
local function IsYPositionHidden(info) return (info[#info] == "Y") and not db.General.AllowY or false end

-- Template for infotext option menus
function module:NewInfotextOptionGroup(name, order, childGroups_)

	local optionGroup = module:NewGroup(name, order, nil, nil, {
		Header = module:NewHeader(L["Settings"], 1),
		Position = module:NewPosition(L["Position"], 2, true, nil, nil, nil, IsYPositionHidden),
	}, nil, IsInfotextGroupHidden)

	-- LUI's infotexts can also optionally have extra options if they contain a LoadOptions function.
	if elementStorage[name] and elementStorage[name].LoadOptions then
		local element = elementStorage[name]
		LUI:EmbedOptions(element)
		optionGroup.args[name] = {
			type = "group",
			inline = true,
			handler = element,
			name = "Module-Specific Options",
			order = 20,
			args = element:LoadOptions(),
		}
	end

	return optionGroup
	--[[return module:NewGroup(name, order, nil, nil, "PanelGetter", "PanelSetter", {
		TexHead = module:NewHeader(L["Texture"], 1),
		ImageDesc = {
			type = "description", name = " ", order = 2, image = GetOptionImageTexture,
			imageWidth = 256, imageHeight = 128, imageCoords = GetOptionTexCoords,
		},
		TexMode = module:NewSelect(L["Panels_Options_Category"], nil, 3, TEX_MODE_SELECT),
		Texture = module:NewInput(L["Texture"], L["Panels_Options_Texture_Desc"], 4, nil, nil, nil, IsTextureInputHidden),
		TextureSelect = module:NewSelect(L["Panels_Options_TextureSelect"], L["Panels_Options_TextureSelect_Desc"], 4,
		                                 PRESET_LUI_TEXTURES, nil, texSelectMeta, nil, nil, IsTextureSelectHidden),
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
	}) --]]
end

function module:LoadOptions()
	local options = {
		Header = {
			name = "Infotext",
			type = "header",
			order = 1,
		},
		General = {
			name = "General",
			type = "group",
			order = 2,
			args = {
			},
		},
	}
	
	local orderCount = 10
	for name, element_ in pairs(elementFrames) do
		options[name] = module:NewInfotextOptionGroup(name, orderCount)
		orderCount = orderCount + 1
	end
	--[[
	for elementName, element in module:IterateModules() do
		if element.LoadOptions then
			LUI:EmbedOptions(element)
			options[elementName] = {
				type = "group",
				handler = element,
				name = element.optionsName or elementName,
				order = element.order or 10,
				childGroups = element.childGroups or "tab",
				args = element:LoadOptions(),
			}
		end
	end ]]--

	return options
end

function module:OnInitialize()
	LUI:RegisterModule(module)
end

function module:OnEnable()
	db = module:GetDB()
	SetInfoPanels()

	-- Make sure all objects created before the callback gets properly initialized.
	for name, element in LDB:DataObjectIterator() do
		if not elementFrames[name] then
			self:DataObjectCreated(name, element)
		end
	end

	module:RegisterLDBCallback("LibDataBroker_DataObjectCreated", "DataObjectCreated")
end

function module:OnDisable()
	LUIInfotext_topAnchor:Hide()
	LUIInfotext_bottomAnchor:Hide()
end
