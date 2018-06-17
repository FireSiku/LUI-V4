-- Color Picker UI Element. Adds a few feature to the color picker to make it more accurate.

-- ####################################################################################################################
-- ##### Setup and Locals #############################################################################################
-- ####################################################################################################################

local _, LUI = ...
local module = LUI:GetModule("UI Elements")
local element = module:NewModule("ColorPicker", "AceHook-3.0")

--Element Variables
local ColorTextBoxes = { "R", "G", "B", "A"}
local colorPickerBonusHeight = 40
local colorBuffer = {}
local editingText

--Localized variables

-- ####################################################################################################################
-- ##### Module Functions #############################################################################################
-- ####################################################################################################################

 -- self: ColorPickerFrame
function element.ColorPickerFrameShow(self)
	OldColorSwatch:SetColorTexture(self:GetColorRGB())
	element:UpdateColorTexts()

	if ColorPickerFrame.hasOpacity then
		ColorPickerBoxA:Show()
		ColorPickerBoxLabelA:Show()
	else
		ColorPickerBoxA:Hide()
		ColorPickerBoxLabelA:Hide()
	end
end

--See if those are truly needed)
function element:ColorPickerFrameColorSelect()
	if not editingText then element:UpdateColorTexts() end
end
function element:OpacitySliderFrameValueChanged()
	if not editingText then element:UpdateColorTexts() end
end

function element:ColorPickerCopyClick(btn_)
	colorBuffer.r,  colorBuffer.g, colorBuffer.b = ColorPickerFrame:GetColorRGB()

	ColorPickerPaste:Enable()
	CopyColorSwatch:SetColorTexture(colorBuffer.r, colorBuffer.g, colorBuffer.b)
	CopyColorSwatch:Show()

	--Add Alpha to buffer only if color supports alpha.
	colorBuffer.a = ColorPickerFrame.hasOpacity and OpacitySliderFrame:GetValue() or nil
end

function element:ColorPickerPasteClick(btn_)
	ColorPickerFrame:SetColorRGB(colorBuffer.r, colorBuffer.g, colorBuffer.b)
	ColorSwatch:SetColorTexture(colorBuffer.r, colorBuffer.g, colorBuffer.b)

	--Transfer the alpha only if the new color supports alpha
	if ColorPickerFrame.hasOpacity and colorBuffer.a then
		OpacitySliderFrame:SetValue(colorBuffer.a)
	end
end

function element:UpdateColorTexts()
	local r, g, b = ColorPickerFrame:GetColorRGB()
	ColorPickerBoxR:SetText(string.format("%.2f", r))
	ColorPickerBoxG:SetText(string.format("%.2f", g))
	ColorPickerBoxB:SetText(string.format("%.2f", b))
	if OpacitySliderFrame:IsShown() then
		local a = 1 - OpacitySliderFrame:GetValue()
		ColorPickerBoxA:SetText(string.format("%.2f", a))
	end
end

function element:UpdateColor(box)
	local r, g, b = ColorPickerFrame:GetColorRGB()
	local id = box:GetID()

	if     id == 1 then r = tonumber(box:GetText()) or 0
	elseif id == 2 then g = tonumber(box:GetText()) or 0
	elseif id == 3 then b = tonumber(box:GetText()) or 0
	end

	editingText = true
	ColorPickerFrame:SetColorRGB(r, g, b)
	ColorSwatch:SetColorTexture(r, g, b)
	editingText = nil
end

function element:UpdateAlpha(box)
	local a = tonumber(box:GetText()) or 1
	if a > 1 then a = 1 end

	editingText = true
	OpacitySliderFrame:SetValue(1 - a)
	editingText = nil
end

-- ####################################################################################################################
-- ##### Framework Events #############################################################################################
-- ####################################################################################################################

function element:OnEnable()
	--local db = module.db.profile.ColorPicker

	element:HookScript(ColorPickerFrame, "OnShow", "ColorPickerFrameShow")
	element:HookScript(ColorPickerFrame, "OnColorSelect", "ColorPickerFrameColorSelect")
	element:HookScript(OpacitySliderFrame, "OnValueChanged", "OpacitySliderFrameValueChanged")

	ColorPickerFrame:SetHeight(ColorPickerFrame:GetHeight() + colorPickerBonusHeight)

	--Move the Color Swatch a bit to give room to the other swatches.
	ColorSwatch:ClearAllPoints()
	ColorSwatch:SetPoint("TOPLEFT", ColorPickerFrame, "TOPLEFT", 230, -45)

	local w, h = ColorSwatch:GetSize()

	--Old Swatch
	local OldColorSwatch = ColorPickerFrame:CreateTexture("OldColorSwatch")
	OldColorSwatch:SetSize(w * 0.75, h * 0.75)
	OldColorSwatch:SetColorTexture(0, 0, 0)
	OldColorSwatch:SetDrawLayer("BORDER")
	OldColorSwatch:SetPoint("BOTTOMLEFT", ColorSwatch, "TOPRIGHT", - w / 2, - h / 3)

	--Copy Swatch
	local CopyColorSwatch = ColorPickerFrame:CreateTexture("CopyColorSwatch")
	CopyColorSwatch:SetSize(w, h)
	CopyColorSwatch:SetColorTexture(0, 0, 0)
	CopyColorSwatch:Hide()

	local ColorPickerCopy = CreateFrame("Button", "ColorPickerCopy", ColorPickerFrame, "UIPanelButtonTemplate")
	ColorPickerCopy:SetText("Copy")
	ColorPickerCopy:SetSize(70, 20)
	--ColorPickerCopy:SetScale(.8)
	ColorPickerCopy:SetPoint("TOPLEFT", ColorSwatch, "BOTTOMLEFT", -15, -5)
	ColorPickerCopy:SetScript("OnClick", element.ColorPickerCopyClick)

	local ColorPickerPaste = CreateFrame("Button", "ColorPickerPaste", ColorPickerFrame, "UIPanelButtonTemplate")
	ColorPickerPaste:SetText("Paste")
	ColorPickerPaste:SetSize(70, 22)
	--ColorPickerPaste:SetScale(.8)
	ColorPickerPaste:SetPoint("TOPLEFT", ColorPickerCopy, "BOTTOMLEFT", 0, -7)
	ColorPickerPaste:SetScript("OnClick", element.ColorPickerPasteClick)
	ColorPickerPaste:Disable()

	--Now that Copy/Paste buttons are set, we can set CopySwatch points.
	CopyColorSwatch:SetPoint("LEFT", ColorSwatch, "LEFT")
	CopyColorSwatch:SetPoint("TOP", ColorPickerPaste, "BOTTOM", 0, -5)

	--Opacity Slider is hooked to the ColorSwatch, so we have to readjust it.
	--DEV: Removed CopyColor anchor as it felt undeeded, adjusted other point for same result.
	OpacitySliderFrame:ClearAllPoints();
	OpacitySliderFrame:SetPoint("RIGHT", ColorPickerFrame, "RIGHT", -35, 26);

	--Color Texts
	for i = 1, #ColorTextBoxes do
		local box = CreateFrame("EditBox", "ColorPickerBox"..ColorTextBoxes[i], ColorPickerFrame, "InputBoxTemplate")
		box:SetSize(56,24)
		box:SetID(i)
		box:SetFrameStrata("DIALOG")
		box:SetAutoFocus(false)
		box:SetJustifyH("RIGHT")
		box:SetMaxLetters(4)

		local label = box:CreateFontString("ColorPickerBoxLabel"..ColorTextBoxes[i], "ARTWORK", "GameFontNormalSmall")
		label:SetTextColor(1,1,1)
		label:SetPoint("RIGHT", box, "LEFT", -5, 0)
		label:SetText(ColorTextBoxes[i])

		box:SetScript("OnEscapePressed", function(self) self:ClearFocus() element:UpdateColorTexts() end)
		box:SetScript("OnEnterPressed", function(self) self:ClearFocus() element:UpdateColorTexts() end)
		if i == 4 then box:SetScript("OnTextChanged", function(self) element:UpdateAlpha(self) end)
		else box:SetScript("OnTextChanged", function(self) element:UpdateColor(self) end)
		end

		box:SetScript("OnTextSet", function(self) self:ClearFocus() end)

	end

	ColorPickerBoxB:SetPoint("TOP", ColorPickerPaste, "BOTTOM", -15, -45)
	ColorPickerBoxG:SetPoint("RIGHT", ColorPickerBoxB, "LEFT", -25, 0)
	ColorPickerBoxR:SetPoint("RIGHT", ColorPickerBoxG, "LEFT", -25, 0)
	ColorPickerBoxA:SetPoint("LEFT", ColorPickerBoxB, "RIGHT", 25, 0)


	--Allow the frame to be movable
	local mover = CreateFrame("Frame", nil, ColorPickerFrame)
	mover:SetPoint("TOPLEFT", ColorPickerFrame, "TOP", -60, 0)
	mover:SetPoint("BOTTOMRIGHT", ColorPickerFrame, "TOP", 60, -18)
	mover:EnableMouse(true)
	mover:SetScript("OnMouseDown", function() ColorPickerFrame:StartMoving() end)
	mover:SetScript("OnMouseUp", function() ColorPickerFrame:StopMovingOrSizing() end)
	ColorPickerFrame:SetUserPlaced(true)
	ColorPickerFrame:EnableKeyboard(false)
end