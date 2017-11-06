local addonname, LUI = ...
local module = LUI:GetModule("Unitframes")
local Media = LibStub("LibSharedMedia-3.0")
local L = LUI.L

-- SetStyle is called as soon as a unit is spawned. This is where the basic, non-specific parts of the unitframes are made.
-- Self is the spawned object, as returned by SpawnUnit.
-- Unit is the actual unit token as per Blizzard API (ex: "player", "target", ...)

function module.SetStyle(self, unit, isSingle)
	
	--Fetch settings for the unit
	self.db = module:GetUnitDB(unit)
	
	if(isSingle) then
		self:SetSize(self.db.Width, self.db.Height)
	end

	-- // Health Bar
	module.SetHealth(self)
	
	-- // Power Bar
	module.SetPower(self)

	-- // Frame Backdrop
	local backdrop = {
		bgFile = Media:Fetch("background", self.db.Backdrop.Texture),
		edgeFile = Media:Fetch("border", self.db.Backdrop.EdgeFile),
		edgeSize = self.db.Backdrop.EdgeSize,
		insets = { left = 3, right = 3, top = 3, bottom = 3, }, 
	}
	local backdropFrame = CreateFrame("Frame", nil, self)
	--Need to convert to :Color()
	backdropFrame:SetBackdrop(backdrop)
	backdropFrame:SetBackdropColor(self:Color("Background"))
	backdropFrame:SetBackdropBorderColor(self:Color("Border"))
	backdropFrame:SetPoint("TOPLEFT", self.Health, "TOPLEFT", -4, 4)
	backdropFrame:SetPoint("BOTTOMRIGHT", self.Power, "BOTTOMRIGHT", 4, -4)

	-- creating a frame as anchor for icons, other texts etc
	self.Overlay = CreateFrame("Frame", nil, self)
	self.Overlay:SetAllPoints(self.Health)
	
	-- // Name
	local name = self.Overlay:CreateFontString()
	local nameFont = self.db.Fonts.NameText
	local db = self.db.NameText
	name:SetFont(Media:Fetch("font", nameFont.Name), nameFont.Size, nameFont.Flag)
	name:SetPoint(db.Point, self.Overlay, db.RelativePoint, db.X, db.Y)
	name:SetTextColor(self:Color("NameText"))
	name:SetShadowOffset(1.25, -1.25)
	name:SetShadowColor(0, 0, 0)
	name.ColorNameByClass = db.ColorNameByClass
	name.ColorClassByClass = db.ColorClassByClass
	name.ColorLevelByDifficulty = db.ColorLevelByDifficulty
	name.ShowClassification = db.ShowClassification
	name.ShortClassification = db.ShortClassification
	name.Format = db.Format
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
	
	--Check for any unit-specific additions here
	
	--TODO:AddClassPower Call

end

function module.SetHealth(self)
	local health = CreateFrame("StatusBar", nil, self)
	
	-- Position and Size
	local db = self.db.HealthBar
	health:SetSize(db.Width, db.Height)
	health:SetStatusBarTexture(Media:Fetch("statusbar", db.Texture))
	health:SetPoint("TOPLEFT", self, "TOPLEFT")
	
	--oUF Options
	health.frequentUpdates = true
	--health.colorReaction = true
	health.colorHealth = true
	
	-- Background
	local healthBG = health:CreateTexture(nil, "BORDER")
	healthBG:SetAllPoints(health)
	healthBG:SetTexture(Media:Fetch("statusbar", db.TextureBG))
	healthBG:SetAlpha(db.BGAlpha)
	healthBG.multiplier = db.BGMultiplier
	
	-- Health Text
	local db = self.db.HealthText
	local fdb = self.db.Fonts.HealthText
	local healthText = health:CreateFontString(nil, "OVERLAY")
	healthText:SetFont(Media:Fetch("font", fdb.Name), fdb.Size, fdb.Flag)
	healthText:SetPoint(db.Point, self, db.RelativePoint, db.X, db.Y)
	healthText:SetJustifyH("CENTER")
	healthText:SetTextColor(1,1,1)
	healthText:Show()
	
	local db = self.db.HealthPercent
	local fdb = self.db.Fonts.HealthPercent
	local healthPercText = health:CreateFontString(nil, "OVERLAY")
	healthPercText:SetFont(Media:Fetch("font", fdb.Name), fdb.Size, fdb.Flag)
	healthPercText:SetPoint(db.Point, self, db.RelativePoint, db.X, db.Y)
	healthPercText:SetJustifyH("CENTER")
	healthPercText:SetTextColor(1,1,1)
	healthPercText:Show()
	
	health.PostUpdate = function(health, unit, min, max)
		local percent = (max == 0 and 0) or 100 * (min/max)
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

function module.SetPower(self)
	local power = CreateFrame("StatusBar", nil, self)
	
	local db = self.db.PowerBar
	power:SetSize(db.Width, db.Height)
	power:SetStatusBarTexture(Media:Fetch("statusbar", db.Texture))
	power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", db.X, db.Y)
	--power.colorPower = true
	power.colorClass = true
	power.colorClassNPC = true
	power.frequentUpdates = true
	
	local powerBG = power:CreateTexture(nil, "BORDER")
	powerBG:SetAllPoints(power)
	powerBG:SetTexture(Media:Fetch("statusbar", db.Texture))
	powerBG:SetAlpha(db.BGAlpha)
	powerBG.multiplier = db.BGMultiplier
	
	-- Power Text
	local db = self.db.PowerText
	local fdb = self.db.Fonts.PowerText
	local powerText = power:CreateFontString(nil, "OVERLAY")
	powerText:SetFont(Media:Fetch("font", fdb.Name), fdb.Size, fdb.Flag)
	powerText:SetPoint(db.Point, power, db.RelativePoint, db.X, db.Y)
	powerText:SetJustifyH("CENTER")
	powerText:SetTextColor(1,1,1)
	powerText:Show()
	
	local db = self.db.PowerPercent
	local fdb = self.db.Fonts.PowerPercent
	local powerPercText = power:CreateFontString(nil, "OVERLAY")
	powerPercText:SetFont(Media:Fetch("font", fdb.Name), fdb.Size, fdb.Flag)
	powerPercText:SetPoint(db.Point, power, db.RelativePoint, db.X, db.Y)
	powerPercText:SetJustifyH("CENTER")
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