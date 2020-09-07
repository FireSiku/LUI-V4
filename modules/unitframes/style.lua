-- ####################################################################################################################
-- ##### Setup and Locals #############################################################################################
-- ####################################################################################################################

local _, LUI = ...
local module = LUI:GetModule("Unitframes")
local Media = LibStub("LibSharedMedia-3.0")
local L = LUI.L


-- ####################################################################################################################
-- ##### Module Setup #################################################################################################
-- ####################################################################################################################

-- SetStyle is called as soon as a unit is spawned.
-- This is where the basic, non-specific parts of the unitframes are made.
-- Frame is the spawned object, as returned by SpawnUnit.
-- Unit is the actual unit token as per Blizzard API (ex: "player", "target", ...)

function module.SetStyle(frame, unit, isSingle)

	--Fetch settings for the unit
	frame.db = module:GetUnitDB(unit)

	if(isSingle) then
		frame:SetSize(frame.db.HealthBar.Width, frame.db.HealthBar.Height)
	end

	-- // Health and Power Bars
	module:SetHealth(frame)
	module:SetPower(frame)

	-- // Frame Backdrop
	local backdrop = {
		bgFile = Media:Fetch("background", frame.db.Backdrop.Texture),
		edgeFile = Media:Fetch("border", frame.db.Backdrop.EdgeFile),
		edgeSize = frame.db.Backdrop.EdgeSize,
		insets = { left = 3, right = 3, top = 3, bottom = 3, },
	}
	local backdropFrame = CreateFrame("Frame", nil, frame)
	backdropFrame:SetBackdrop(backdrop)
	backdropFrame:SetBackdropColor(frame:RGB("Background"))
	backdropFrame:SetBackdropBorderColor(frame:RGB("Border"))
	backdropFrame:SetPoint("TOPLEFT", frame.Health, "TOPLEFT", -4, 4)
	backdropFrame:SetPoint("BOTTOMRIGHT", frame.Power, "BOTTOMRIGHT", 4, -5)

	-- creating a frame as anchor for icons, other texts etc
	frame.Overlay = CreateFrame("Frame", nil, frame)
	frame.Overlay:SetAllPoints(frame.Health)

	-- // Name
	local name = frame.Overlay:CreateFontString()
	local nameFont = frame.db.Fonts.NameText
	local db = frame.db.NameText
	name:SetFont(Media:Fetch("font", nameFont.Name), nameFont.Size, nameFont.Flag)
	name:SetPoint(db.Point, frame.Overlay, db.RelativePoint, db.X, db.Y)
	name:SetTextColor(frame:RGB("NameText"))
	name:SetShadowOffset(1.25, -1.25)
	name:SetShadowColor(0, 0, 0)
	name.ColorNameByClass = db.ColorNameByClass
	name.ColorClassByClass = db.ColorClassByClass
	name.ColorLevelByDifficulty = db.ColorLevelByDifficulty
	name.ShowClassification = db.ShowClassification
	name.ShortClassification = db.ShortClassification
	name.Format = db.Format
	name:Show()

	frame.Name = name
	frame:FormatName()

	-- // Dropdown
	-- Credit for this bit of code goes to Zork.
	local dropdown = CreateFrame("Frame", "oUF_LUIDropdown", UIParent, "UIDropDownMenuTemplate")
	UIDropDownMenu_Initialize(dropdown, function(self)
		local unit = self:GetParent().unit
		if not unit then return end
		local menu, name, id
		if UnitIsUnit(unit, "player") then menu = "SELF"
		elseif UnitIsUnit(unit, "vehicle") then menu = "VEHICLE"
		elseif UnitIsUnit(unit, "pet") then menu = "PET"
		elseif UnitIsPlayer(unit) then
			id = UnitInRaid(unit)
			if id then
				menu = "RAID_PLAYER"
				name = GetRaidRosterInfo(id)
			elseif UnitInParty(unit) then menu = "PARTY"
			else menu = "PLAYER"
			end
		else
			menu = "TARGET"
			name = RAID_TARGET_ICON
		end
		if menu then
			UnitPopup_ShowMenu(self, menu, unit, name, id)
		end
	end, "MENU")

	frame.menu = function(self)
		dropdown:SetParent(self)
		ToggleDropDownMenu(1, nil, dropdown, "cursor", 0, 0)
	end

	--Remove Focus from list
	for k,v in pairs(UnitPopupMenus) do
		for x,y in pairs(UnitPopupMenus[k]) do
			if y == "SET_FOCUS" then
				table.remove(UnitPopupMenus[k],x)
			elseif y == "CLEAR_FOCUS" then
				table.remove(UnitPopupMenus[k],x)
			end
		end
    end

	--Check for any unit-specific additions here
	if unit == "player" then
		module.SetClassPower(frame)
	end
	--TODO:AddClassPower Call

end

function module:SetTextElement(frame, name, parent)
	local db = frame.db[name]
	local font = frame.db.Fonts[name]
	local text = parent:CreateFontString(nil, "OVERLAY")
	text:SetFont(Media:Fetch("font", font.Name), font.Size, font.Flag)
	text:SetPoint(db.Point, parent, db.RelativePoint, db.X, db.Y)
	text:SetJustifyH("CENTER")
	text:SetTextColor(1,1,1)
	text:Show()

	return text
end

-- ####################################################################################################################
-- ##### Unitframes: Health ###########################################################################################
-- ####################################################################################################################

function module:SetHealth(frame)
	local health = CreateFrame("StatusBar", nil, frame)

	-- Position and Size
	local db = frame.db.HealthBar
	health:SetSize(db.Width, db.Height)
	health:SetStatusBarTexture(Media:Fetch("statusbar", db.Texture))
	health:SetPoint("TOPLEFT", frame, "TOPLEFT")

	--oUF Options
	health.frequentUpdates = true
	--health.colorReaction = true
	health.colorHealth = true

	-- Background
	local healthBG = health:CreateTexture(nil, "BORDER")
	healthBG:SetAllPoints(health)
	healthBG:SetTexture(Media:Fetch("statusbar", db.TextureBG))
	healthBG:SetAlpha(db.BGAlpha)
	healthBG.multiplier = 0.4

	-- Testing Absorb
	local absorbBar = CreateFrame('StatusBar', nil, health)
	absorbBar:SetPoint('TOP')
	absorbBar:SetPoint('BOTTOM')
	absorbBar:SetPoint('LEFT', health:GetStatusBarTexture(), 'RIGHT')
	absorbBar:SetWidth(health:GetWidth())
	absorbBar:SetStatusBarTexture(Media:Fetch("statusbar", db.Texture))
	absorbBar:SetAlpha(.6)

	local overAbsorbBar = CreateFrame('StatusBar', nil, health)
	overAbsorbBar:SetPoint('TOP')
	overAbsorbBar:SetPoint('BOTTOM')
	overAbsorbBar:SetPoint('LEFT', health:GetStatusBarTexture(), 'LEFT')
	overAbsorbBar:SetWidth(health:GetWidth())
	overAbsorbBar:SetStatusBarTexture(Media:Fetch("statusbar", db.Texture))
	overAbsorbBar:SetAlpha(.6)

	-- Health Text
	local healthText = module:SetTextElement(frame, "HealthText", health)
	local healthPercent = module:SetTextElement(frame, "HealthPercent", health)

	health.PostUpdate = function(health_, unit_, min, max)
		local percent = (max == 0 and 0) or 100 * (min/max)
		healthPercent:SetFormattedText("%.1f%%", percent)
		if min == max then healthPercent:Hide()
		else healthPercent:Show()
		end
	end

	-- Health Prediction
	local predictionGroup = {
		absorbBar = absorbBar,
		overAbsorb = overAbsorbBar,
		frequentUpdates = true,
	}
	function predictionGroup:PostUpdate(unit, myIncomingHeal_, otherIncomingHeal_, absorb,
										healAbsorb_, hasOverAbsorb, hasOverHealAbsorb_)
		-- By default, oUF overAbsorb is a texture, so we have to handle statusbar ourselves.
		if hasOverAbsorb then
			local health_, maxHealth = UnitHealth(unit), UnitHealthMax(unit)
			local totalAbsorb = UnitGetTotalAbsorbs(unit) or 0
			local overAbsorb = totalAbsorb - absorb
			self.overAbsorb:SetMinMaxValues(0, maxHealth)
			self.overAbsorb:SetValue(overAbsorb)
			self.overAbsorb:Show()
		end
	end

	frame:RegisterEvent('UNIT_ABSORB_AMOUNT_CHANGED', frame.UpdateAllElements)

	--Register those with oUF
	frame.Health = health
	frame.Health.bg = healthBG
	frame:Tag(healthText, '[dead][offline][LUI:health] [LUI:Absorb]')
	frame.Health.value = healthText

	frame.HealthPrediction = predictionGroup
end

-- ####################################################################################################################
-- ##### Unitframes: Power ############################################################################################
-- ####################################################################################################################

function module:SetPower(frame)
	local power = CreateFrame("StatusBar", nil, frame.Health)

	local db = frame.db.PowerBar
	power:SetSize(db.Width, db.Height)
	power:SetStatusBarTexture(Media:Fetch("statusbar", db.Texture))
	power:SetPoint("TOPLEFT", frame.Health, "BOTTOMLEFT", db.X, db.Y)
	--power.colorPower = true
	power.colorClass = true
	power.colorClassNPC = true
	power.frequentUpdates = true

	local powerBG = power:CreateTexture(nil, "BORDER")
	powerBG:SetAllPoints(power)
	powerBG:SetTexture(Media:Fetch("statusbar", db.Texture))
	powerBG:SetAlpha(db.BGAlpha)
	powerBG.multiplier = 0.4

	-- Power Text
	local powerText = module:SetTextElement(frame, "PowerText", power)
	local powerPercent = module:SetTextElement(frame, "PowerPercent", power)

	power.PostUpdate = function(self, unit_, cur_, min, max)
		min = min or 0
		local percent = (max == 0) and 0 or 100 * (min/max)
		powerText:SetFormattedText("%d", min)
		powerPercent:SetFormattedText("%.1f%%", percent)
	end

	frame.Power = power
	frame.Power.bg = powerBG
	frame.Power.value = powerText

end