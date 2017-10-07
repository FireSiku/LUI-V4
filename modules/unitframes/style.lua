local addonname, LUI = ...
local module = LUI:GetModule("Unitframes")
local L = LUI.L

-- SetStyle is called as soon as a unit is spawned. This is where the basic, non-specific parts of the unitframes are made.
-- Self is the spawned object, as returned by SpawnUnit.
-- Unit is the actual unit token as per Blizzard API (ex: "player", "target", ...)

--The goal of this is that I fetch the module by the same unit name, grabs its db, do all the generic layout stuff
--once that's done, call the element:SetSpecificStyle function 

function module.SetStyle(self, unit, isSingle)
	
	--Fetch settings from unit module
	local element = module:GetModule(unit)
	self.db = element:GetDB()
	self.element = element
	
	if(isSingle) then
		self:SetSize(self.db.Width, self.db.Height)
	end
	
	-- // Frame Backdrop
	local backdrop = {
		bgFile = element:FetchBackground("Frame"),
		edgeFile = element:FetchBorder("Frame"),
		edgeSize = self.db.Border.EdgeSize,
		insets = {
			left = self.db.Border.Insets.Left,
			right = self.db.Border.Insets.Right,
			top = self.db.Border.Insets.Top,
			bottom = self.db.Border.Insets.Bottom,
		},
	}
	self:SetBackdrop(backdrop)
	--Need to convert to :Color()
	self:SetBackdropColor(element:AlphaColor("Background"))
	self:SetBackdropBorderColor(element:AlphaColor("Border"))
	
	-- // Health Bar
	module.SetHealth(self, element)
	
	-- // Power Bar
	module.SetPower(self, element)

	-- creating a frame as anchor for icons, texts etc
	self.Overlay = CreateFrame("Frame", nil, self)
	self.Overlay:SetAllPoints(self.Health)
	
	local name = element:SetFontString(self.Overlay, nil, "NameText")
	element:RefreshFontString(name, "NameText")
	name:SetPoint(self.db.Texts.Name.Point, self.Health, self.db.Texts.Name.RelativePoint, self.db.Texts.Name.X, self.db.Texts.Name.Y)
	name:SetShadowOffset(1.25, -1.25)
	name:SetShadowColor(0, 0, 0)
	name.ColorNameByClass = self.db.Texts.Name.ColorNameByClass
	name.ColorClassByClass = self.db.Texts.Name.ColorClassByClass
	name.ColorLevelByDifficulty = self.db.Texts.Name.ColorLevelByDifficulty
	name.ShowClassification = self.db.Texts.Name.ShowClassification
	name.ShortClassification = self.db.Texts.Name.ShortClassification
	name.Format = self.db.Texts.Name.Format
	name:Show()
	
	self.Name = name
	self:FormatName()
	
	-- // Dropdown
	-- Credit for this bit of code goes to Zork. 
	local dropdown = CreateFrame("Frame", "oUF_LUI_Dropdown", UIParent, "UIDropDownMenuTemplate")
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
	self.menu = function(self)
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
	
	--Check for any unit-specific additions
	if element.SetUnitStyle then
		element.SetUnitStyle(self, unit, isSingle)
	end
	
end

function module.SetHealth(self, element)
	local health = CreateFrame("StatusBar", nil, self)
	
	-- Position and Size
	local db = self.db.Bars.Health
	health:SetSize(db.Width, db.Height)
	health:SetStatusBarTexture(element:FetchStatusBar("Health"))
	health:SetPoint("TOPLEFT", self, "TOPLEFT")
	
	--oUF Options
	health.frequentUpdates = true
	--health.colorReaction = true
	health.colorHealth = true
	
	-- Background
	local healthBG = health:CreateTexture(nil, "BORDER")
	healthBG:SetAllPoints(health)
	healthBG:SetTexture(element:FetchStatusBar("HealthBG"))
	healthBG:SetAlpha(db.BGAlpha)
	healthBG.multiplier = db.BGMultiplier
	
	-- Health Text
	local db = self.db.Texts.Health
	local healthText = element:SetFontString(health, nil, "HealthText", "OVERLAY", "CENTER")
	healthText:SetPoint(db.Point, self, db.RelativePoint, db.X, db.Y)
	healthText:SetTextColor(1,1,1)
	healthText:Show()
	
	local db = self.db.Texts.HealthPercent
	local healthPercText = element:SetFontString(health, nil, "HealthPerc", "OVERLAY", "CENTER")
	healthPercText:SetPoint(db.Point, self, db.RelativePoint, db.X, db.Y)
	healthPercText:SetTextColor(1,1,1)
	healthPercText:Show()
	
	health.PostUpdate = function(health, unit, min, max)
		local percent = max == 0 and 0 or 100 * (min/max)
		healthPercText:SetFormattedText("%.1f%%", percent)
		if min == max then healthPercText:Hide()
		else healthPercText:Show()
		end
	end

	self:RegisterEvent('UNIT_ABSORB_AMOUNT_CHANGED', self.UpdateAllElements)
	
	--Register those with oUF
	self.Health = health
	self.Health.bg = healthBG
	self:Tag(healthText, '[dead][offline][LUI:health] [LUI:Absorb]')
	self.Health.value = healthText
end

function module.SetPower(self, element)
	local power = CreateFrame("StatusBar", nil, self)
	
	local db = self.db.Bars.Power
	power:SetSize(db.Width, db.Height)
	power:SetStatusBarTexture(element:FetchStatusBar("Power"))
	power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", db.X, db.Y)
	--power.colorPower = true
	power.colorClass = true
	power.colorClassNPC = true
	power.frequentUpdates = true
	
	local powerBG = power:CreateTexture(nil, "BORDER")
	powerBG:SetAllPoints(power)
	powerBG:SetTexture(element:FetchStatusBar("PowerBG"))
	powerBG:SetAlpha(db.BGAlpha)
	powerBG.multiplier = db.BGMultiplier
	
	-- Power Text
	local db = self.db.Texts.Power
	local powerText = element:SetFontString(power, nil, "PowerText", "OVERLAY", "CENTER")
	powerText:SetPoint(db.Point, power, db.RelativePoint, db.X, db.Y)
	powerText:SetTextColor(1,1,1)
	powerText:Show()
	
	local db = self.db.Texts.PowerPercent
	local powerPercText = element:SetFontString(power, nil, "PowerPerc", "OVERLAY", "CENTER")
	powerPercText:SetPoint(db.Point, power, db.RelativePoint, db.X, db.Y)
	powerPercText:SetTextColor(1,1,1)
	powerPercText:Show()
	
	power.PostUpdate = function(self, unit, cur, min, max)
		min = min or 0
		local percent = (max == 0) and 0 or 100 * (min/max)
		powerText:SetFormattedText("%d", min)
		powerPercText:SetFormattedText("%.1f%%", percent)
	end
	
	self.Power = power
	self.Power.bg = powerBG
	self.Power.value = powerText
	
end
