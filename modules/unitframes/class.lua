-- Unitframe file to contain all the class bar and most class-specific code.

-- ####################################################################################################################
-- ##### Setup and Locals #############################################################################################
-- ####################################################################################################################

local _, LUI = ...
local module = LUI:GetModule("Unitframes")
local class = LUI.playerClass
local db

local Media = LibStub("LibSharedMedia-3.0")

-- Spec constants
local SPEC_MAGE_ARCANE = 1
local SPEC_MONK_WINDWALKER = 3
local SPEC_PALADIN_RETRIBUTION = 3
local MAX_RUNES = 6

-- The minimum of a ressource a given class can have
local BASE_COUNT = {
	MAGE = 4,
	MONK = 5,
	PALADIN = 5,
	ROGUE = 5,
	WARLOCK = 5,
	DRUID = 5,
}
-- The maximum of a ressource a given class can have
local MAX_COUNT = {
	MAGE = 4,
	MONK = 6,
	PALADIN = 5,
	ROGUE = 8,
	WARLOCK = 5,
	DRUID = 5,
}

-- Events that should trigger a re-counting of ressources
local CLASS_EVENTS = {
	MONK = {"PLAYER_TALENT_UPDATE"},
	ROGUE = {"PLAYER_TALENT_UPDATE" },
}

-- ####################################################################################################################
-- ##### Module Functions #############################################################################################
-- ####################################################################################################################

-- This is the function that determines ClassPower visibility
local function IsPowerActive(classPower)
	local spec = GetSpecialization()

	if class == "ROGUE" then return true
	elseif class == "WARLOCK" then return true
	elseif class == "MAGE" and spec == SPEC_MAGE_ARCANE then return true
	elseif class == "MONK" and spec == SPEC_MONK_WINDWALKER then return true
	elseif class == "PALADIN" and spec == SPEC_PALADIN_RETRIBUTION then return true
	else
		classPower:Hide()
		return false
	end
end

-- Local function near the top of the file because it pertains to class balance.
-- This is the function where we take the base amount of ressource a class can have
-- and check for spells and talents that may increase those numbers.
local function GetCount(classPower_, event_)
	local count = BASE_COUNT[class]

	if class == "MONK" then
		local _, _, _, ascension = GetTalentInfo(3, 2, GetActiveSpecGroup())
		if ascension then count = count + 1 end
	elseif class == "ROGUE" then
		--Check for Strategem, increase CPoints to 6.
		if select(4, GetTalentInfo(3, 1, 1)) then count = 6
		--Check for Anticipation, increase CPoints to 8.
		elseif select(4, GetTalentInfo(3, 2, 1)) then count = 8
		end
	end

	return count
end

local function GetBarWidth(count)
	-- Take the width of the class bar and divide it up in equally sized textures.
	-- To prevents the bar from going above the width, we need to take the spacing into account.
	if not count then count = 1 end
	return (db.Width - (db.Padding * (count - 1))) / count
end

-- ####################################################################################################################
-- ##### Module Setup #################################################################################################
-- ####################################################################################################################

-- For the entire file, self will be used to refer to the unitframe as those functions are called from the style creation.
-- This function is the entry point of the file, it's where we determined if any bars need creation.
function module.SetClassPower(self)
	-- Use the same settings for ClassPower, Rune Bars and such.
	db = self.db.ClassPowerBar

	-- If a class has an entry in BASE_COUNT, it means it uses a ressource.
	if BASE_COUNT[class] then
		module.SetClassBar(self)
	elseif class == "DEATHKNIGHT" then
		module.SetRuneBar(self)
	end
end

function module.SetClassBar(self)
	local classPower = {}
	local barTexture = Media:Fetch("statusbar", db.Texture)
	local bgTexture = Media:Fetch("statusbar", db.TextureBG)
	
    for i = 1, 10 do
        local bar = CreateFrame('StatusBar', nil, self.Health)

        -- Position and size.
		bar:SetSize(db.Width/10, db.Height)
		bar:SetStatusBarTexture(barTexture)
		if i == 1 then
			bar:SetPoint("BOTTOMLEFT", self, "TOPLEFT", db.X, db.Y)
		else
			bar:SetPoint("TOPLEFT", classPower[i-1], "TOPRIGHT", db.Padding, 0)
		end

		-- Background
		local bg = bar:CreateTexture(nil, "BACKGROUND")
		bg:SetTexture(bgTexture)
		bg:SetAllPoints()
		bg.multiplier = 0.35
		bar.bg = bg
		
        classPower[i] = bar
	end

	function classPower.PostUpdate(self, cur, max, hasChanged, powerType)
		local barSize
		if hasChanged then
			barSize = (db.Width - db.Padding * (max - 1)) / max
		end
		if not cur then
			module.backdropFrame:SetPoint("TOPLEFT", self.__owner.Health, "TOPLEFT", -4, 4)
		else
			module.backdropFrame:SetPoint("TOPLEFT", self.__owner.ClassPower[1], "TOPLEFT", -4, 4)
			for i = 1, max do
				self[i]:Show()
				if barSize then
					self[i]:SetSize(barSize, db.Height)
				end
			end
		end
	end

	-- Register with oUF
	self.ClassPower = classPower
end



-- classPower is a frame with two parts.
-- The frame itself is used as a background and also as a parent for the textures.
-- It's also an array that holds textures for oUF to use for combo points of various kinds.
-- Issue: While oUF's classIcon will deal with the visibility of the textures,
-- it does not take the background into account.
function module.SetClassIcon(self)
	local classPower = CreateFrame("Frame", nil, self)
	classPower:SetFrameStrata("BACKGROUND")
	classPower:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
	})
	classPower:SetBackdropColor(0, 0, 0)
	classPower:SetSize(db.Width, db.Height)
	classPower:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", db.X, db.Y)
	self.ClassIcons = classPower

	for i = 1, MAX_COUNT[class] do
		local bar = classPower:CreateTexture(classPower:GetDebugName()..i, "ARTWORK")
		bar:SetTexture(self.element:FetchStatusBar("ClassPower"))
		if i == 1 then
			bar:SetPoint("TOPLEFT", self, "TOPLEFT", 0, db.Height)
		else
			bar:SetPoint("TOPLEFT", classPower[i-1], "TOPRIGHT", db.Padding, 0)
		end

		bar:SetColorTexture(module:RGB(class))
		classPower[i] = bar
	end

	--Function needs to be inside SetClassPower to benefits from closure.
	local function PowerCount(classPower, event, ...)
		if not IsPowerActive(classPower) then return end
		local count = GetCount(classPower, event, ...)

		local barWidth = GetBarWidth(count)
		for i = 1, MAX_COUNT[class] do
			local bar = classPower[i]
			bar:SetSize(barWidth, db.Height)
			bar:Show()
			if i > count then
				bar:Hide()
			end
		end
		classPower:Show()
	end

	classPower:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
	if CLASS_EVENTS[class] then
		for i = 1, #CLASS_EVENTS[class] do
			classPower:RegisterEvent(CLASS_EVENTS[class][i])
		end
	end
	classPower:SetScript("OnEvent", PowerCount)
	PowerCount(classPower)

	-- This is apparently requires to get the class ressource to change colors.
	function classPower.UpdateTexture(self)
		local r, g, b
		if class == "MONK" then r, g, b = module:RGB("CHI")
		elseif class == "MAGE" then r, g, b = module:RGB("ARCANE_CHARGES")
		elseif class == "PALADIN" then r, g, b = module:RGB("HOLY_POWER")
		elseif class == "WARLOCK" then r, g, b = module:RGB("SOUL_SHARDS")
		elseif class == "ROGUE" then r, g, b = module:RGB("COMBO_POINTS")
		elseif class == "DRUID" then r, g, b = module:RGB("COMBO_POINTS")
		end
		for i = 1, #self do
			local icon = self[i]
			icon:SetDesaturated(true)
			icon:SetVertexColor(r, g, b)
		end
	end
end

-- RuneBar is an array of statusbars.
function module.SetRuneBar(self)
	local runeBar = CreateFrame("Frame", nil, self)
	runeBar:SetFrameStrata("BACKGROUND")
	--runeBar:SetBackdrop({
	--	bgFile = "Interface/Tooltips/UI-Tooltip-Background",
	--})
	--runeBar:SetBackdropColor(0, 0, 0)
	runeBar:SetSize(db.Width, db.Height)
	runeBar:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", db.X, db.Y)
	self.Runes = runeBar

	local barWidth = GetBarWidth(MAX_RUNES)
	for i = 1, MAX_RUNES do
		runeBar[i] = CreateFrame("StatusBar", runeBar:GetDebugName()..i, runeBar)
		runeBar[i]:SetSize(barWidth, db.Height)
		runeBar[i]:SetStatusBarTexture(self.element:FetchStatusBar("ClassPower"))
		if i == 1 then
			runeBar[i]:SetPoint("TOPLEFT", self, "TOPLEFT", 0, db.Height)
		else
			runeBar[i]:SetPoint("TOPLEFT", runeBar[i-1], "TOPRIGHT", db.Padding, 0)
		end
	end
end
