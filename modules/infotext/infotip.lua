-- Infotip module, this is not supposed to be an Infotext's element.
-- This provides Infotext with a clickable frame, mainly used for Guild/Friends.

------------------------------------------------------
-- / SETUP AND LOCALS / --
------------------------------------------------------
local addonname, LUI = ...
local module = LUI:GetModule("Infotext")
local element = module:NewModule("Infotip", "AceHook-3.0")
local L = LUI.L

-- local copies
local unpack, pairs = unpack, pairs

-- constants
local CLASS_ICONS_TEXTURE = "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes"
local INFOTIP_MAXLINE_CUTOFF = 4
local INFOTIP_MIN_WIDTH = 90
local BUTTON_HEIGHT = 15
local SLIDER_WIDTH = 16
local ICON_SIZE = 13

--Find better name for these constants
local GAP = 10
local TEXT_OFFSET = 5

--Colors for the Guild/Friends, to be moved to their db when it's time.
local GF_COLORS = {
	Broadcast = {1, 0.1, 0.1},
	Title = {1, 1, 1},
	Realm = {1, 0.8, 0},
	Status = {0.7, 0.7, 0.7},
}

-- locals
local infotipStorage = {}
local highlight

------------------------------------------------------
-- / INFOTIP FUNCTIONS / --
------------------------------------------------------
local LineMxin = {}
local InfotipMixin = {}

-- What's the need for anchor already?
function LineMxin:AddTexture(anchor, offsetX)
	local tex = self:CreateTexture()
	tex:SetWidth(ICON_SIZE)
	tex:SetHeight(ICON_SIZE)
	tex:SetPoint("LEFT", anchor or self, anchor and "RIGHT" or "LEFT", offsetX, 0)
	return tex
end

function LineMxin:SetClassIcon(tex, class)
	tex:SetTexture(CLASS_ICONS_TEXTURE)
	local offset, left, right, bottom, top = 0.025, unpack(CLASS_ICON_TCOORDS[class])
	tex:SetTexCoord(left+offset, right-offset, bottom+offset, top-offset)
end

function LineMxin:AddFontString(justify, anchor, offsetX, r, g, b)
	--If anchor is a number, shift anchor and offset to be RGB
	if type(anchor) == "number" then
		r, g, b = anchor, offsetX, r
		anchor = nil
		offsetX = nil
	end
	--What kind of font is THAT?
	local fs = module:SetFontString(self, nil, "Infotip", "OVERLAY", justify)
	--local fs = self:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Med1")
	if anchor then fs:SetPoint("LEFT", anchor, "RIGHT", offsetX or GAP, 0) end
	--if justify then fs:SetJustifyH(justify) end
	if r and g and b then fs:SetTextColor(r, g, b) end
	fs:SetShadowOffset(1, -1)
	return fs
end

function LineMxin:AddHighlight()
	self:SetScript("OnEnter", element.OnLineEnter)
end

function InfotipMixin:NewLine()
	local newline = CreateFrame("Button", nil, self)
	for k, v in pairs(LineMxin) do
		newline[k] = v
	end
	newline:SetHeight(BUTTON_HEIGHT)

	newline:EnableMouseWheel(true)
	newline:RegisterForClicks("AnyUp")
	newline:SetScript("OnLeave", element.OnLineLeave)
	newline:SetScript("OnMouseWheel", element.OnLineScroll)

	newline:SetPoint("LEFT")
	newline:SetPoint("RIGHT")

	-- increase line count
	self.totalLines = self.totalLines + 1
	if self.totalLines > self.maxLines and not self.slider then
		self.slider = element:AddSlider(self)
	end

	return newline
end

function InfotipMixin:AddSeparator(anchor)
	local sep = self:NewLine()
	local sepTex = sep:CreateTexture()
	sepTex:SetTexture("Interface\\FriendsFrame\\UI-FriendsFrame-OnlineDivider")
	sepTex:SetPoint("LEFT")
	sepTex:SetPoint("RIGHT")
	if anchor then sep:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT") end
	return sep
end

function InfotipMixin:GetSliderOffset()
	return (self.hasSlider) and self.slider:GetValue() or 1
end

function InfotipMixin:UpdateTooltip()
	local frame = self.infotext:GetFrame()
	if frame:IsMouseOver() or self:IsMouseOver() then
		-- Re-update the tooltip by faking an OnEnter event.
		-- OnEvent's bool should be false if the mouse was already inside the frame
		module.OnEnterHandler(frame, false)
	end
end

function InfotipMixin:UpdateSlider(topValue)
	if self.slider then
		if topValue > self.maxLines then
			self.slider:SetMinMaxValues(1, 1 + topValue - self.maxLines)
			self.slider:Show()
			self.hasSlider = true
		else
			self.slider:Hide()
			self.hasSlider = false
		end
	end
end

------------------------------------------------------
-- / MODULE FUNCTIONS / --
------------------------------------------------------

function element.OnLineScroll(line, delta)
	local infotip = line:GetParent()
	if infotip.hasSlider then
		infotip.slider:SetValue(infotip:GetSliderOffset() - delta)
	end
end

function element.OnLineEnter(line)
	highlight:ClearAllPoints()
	highlight:SetAllPoints(line)
	highlight:Show()
end

function element.OnLineLeave(line)
	highlight:ClearAllPoints()
	highlight:Hide()
	local infotip = line:GetParent()
	if not infotip:IsMouseOver() then infotip:Hide() end
end

-- To revisit later, originally wanted a customizable minWidth. (default 300 to match V3 layout)
-- Right now its a strict minimum width to prevent frame from breaking.
function element:EnforceMinWidth(infotip, value)
	if value < infotip.minWidth then
		infotip:SetWidth(infotip.minWidth)
	end
end

--TODO: Put constants up in this bitch
function element:AddSlider(newtip)
	local slider = CreateFrame("Slider", nil, newtip)
	slider:SetWidth(SLIDER_WIDTH)
	slider:SetThumbTexture([[Interface\Buttons\UI-SliderBar-Button-Horizontal]])
	slider:SetBackdrop({
		bgFile = [[Interface\Buttons\UI-SliderBar-Background]],
		edgeFile = [[Interface\Buttons\UI-SliderBar-Border]],
		edgeSize = 8, tile = true, tileSize = 8,
		insets = {left=3, right=3, top=6, bottom=6}
	})
	slider:SetValueStep(1)
	local infotext = newtip.infotext
	slider:SetScript("OnValueChanged", function(self, value)
		if newtip:IsMouseOver() and infotext.OnSliderUpdate then
			infotext:OnSliderUpdate()
		end
	end)
	return slider
end

function element:ApplyBackdropColors()
	local modTooltip = LUI:GetModule("Tooltip")
	local isModded = (modTooltip and modTooltip:IsEnabled()) and true or false
	local colorDB = (isModded) and modTooltip:GetDB(nil, "Colors")
	for name, infotip in pairs(infotipStorage) do
		if isModded then
			infotip:SetBackdropColor(colorDB.Background.r, colorDB.Background.g, colorDB.Background.b)
			infotip:SetBackdropBorderColor(colorDB.Border.r, colorDB.Border.g, colorDB.Border.b)
		else
			infotip:SetBackdropColor(GameTooltip:GetBackdropColor())
			infotip:SetBackdropBorderColor(GameTooltip:GetBackdropBorderColor())
		end
	end
end

function element:NewInfotip(infotext)
	local name = infotext:GetName()
	local parent = infotext:GetFrame()

	local newtip = CreateFrame("Frame",format("LUIInfo_%sInfotip", name), parent)
	infotipStorage[name] = newtip
	newtip.infotext = infotext
	for k, v in pairs(InfotipMixin) do
		newtip[k] = v
	end
	
	--Set Properties
	newtip:EnableMouse(true)
	newtip:SetFrameStrata("TOOLTIP")
	newtip:SetClampedToScreen(true)

	--TODO: Add support for bottom panel infotexts.
	newtip:SetPoint("TOP", parent, "BOTTOM")

	-- Make frame looks like a tooltip.
	newtip:SetBackdrop(GameTooltip:GetBackdrop())
	element:ApplyBackdropColors()
	--Trigger the element's OnLeave when you leave the infotip
	newtip:SetScript("OnLeave", infotext.OnLeave)

	-- Load highlight texture
	highlight = newtip:CreateTexture()
	highlight:SetTexture([[Interface\QuestFrame\UI-QuestTitleHighlight]])
	highlight:SetBlendMode("ADD")

	-- Enforce Infotip minimum width.
	newtip.minWidth = INFOTIP_MIN_WIDTH
	element:SecureHook(newtip, "SetWidth", "EnforceMinWidth")
	
	-- Initialize some values
	newtip.maxHeight = 0
	newtip.maxWidth = INFOTIP_MIN_WIDTH

	-- Calculate Infotip highest numbers of possible lines.
	newtip.maxLines = floor((UIParent:GetHeight() - GAP * 2) / BUTTON_HEIGHT - INFOTIP_MAXLINE_CUTOFF)
	newtip.totalLines = 0
	
	return newtip
end

------------------------------------------------------
-- / FRAMEWORK FUNCTIONS / --
------------------------------------------------------
function element:OnEnable()
	-- Hook relevant functions from the tooltip module to maintain tooltip look.
	local modTooltip = LUI:GetModule("Tooltip")
	element:SecureHook(modTooltip, "UpdateBackdropColors", "ApplyBackdropColors")
	element:SecureHook(modTooltip, "OnEnable", "ApplyBackdropColors")
	element:SecureHook(modTooltip, "OnDisable", "ApplyBackdropColors")
end