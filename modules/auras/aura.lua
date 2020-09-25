--[[
	Module.....: Aura
	Description: Replace the default buffs/debuffs
]]

-- ####################################################################################################################
-- ##### Setup and Locals #############################################################################################
-- ####################################################################################################################

local _, LUI = ...
local module = LUI:NewModule("Auras")
local L = LUI.L
local db

local headerStorage = {}

-- Prototype Tables
local Header = {}
local Aura = {}
local WeaponEnchant = {}

-- ####################################################################################################################
-- ##### Default Settings #############################################################################################
-- ####################################################################################################################

module.defaults = {
	profile = {
		Buffs = {
			Anchor = "TOPLEFT",
			X = 30,
			Y = -35,
			Size = 35,
			AurasPerRow = 16,
			NumRows = 2,
			HorizontalSpacing = 12,
			VerticalSpacing = 22,
			SortMethod = "Time",
			ReverseSort = false,
		},
		Debuffs = {
			Anchor = "TOPLEFT",
			X = 30,
			Y = -160,
			Size = 35,
			AurasPerRow = 16,
			NumRows = 1,
			HorizontalSpacing = 12,
			VerticalSpacing = 22,
			SortMethod = "Time",
			ReverseSort = false,
		},
		Fonts = {
			BuffsDur =     { Name = "NotoSans-SCB", Size = 12, Flag = "OUTLINE", },
			DebuffsDur =   { Name = "NotoSans-SCB", Size = 12, Flag = "OUTLINE", },
			BuffsCount =   { Name = "NotoSans-SCB", Size = 12, Flag = "OUTLINE", },
			DebuffsCount = { Name = "NotoSans-SCB", Size = 12, Flag = "OUTLINE", },
		},
		Colors = {
			--Font Colors
			BuffsDur =     { r = 1,   g = 1,   b = 1, },
			DebuffsDur =   { r = 1,   g = 1,   b = 1, },
			BuffsCount =   { r = 1,   g = 1,   b = 1, },
			DebuffsCount = { r = 1,   g = 1,   b = 1, },
			--Debuff Types
			None =    { r = 0.8, g = 0,   b = 0, },
			Magic =   { r = 0.2, g = 0.6, b = 1, },
			Curse =   { r = 0.6, g = 0,   b = 1, },
			Disease = { r = 0.6, g = 0.4, b = 0, },
			Poison =  { r = 0,   g = 0.6, b = 0, },
		},
	},
}

-- ####################################################################################################################
-- ##### Module Functions #############################################################################################
-- ####################################################################################################################

--Note: These functions may be generic enough for inclusion in LUI api if they find usage elsewhere
local function GetTimeFactor(seconds)
	local minuteSecs = 60
	local hourSecs = 3600
	local daySecs = 86400
	if seconds < minuteSecs then
		return 1, "%d"
	elseif seconds < hourSecs then
		return minuteSecs, MINUTE_ONELETTER_ABBR
	elseif seconds < daySecs then
		return hourSecs, HOUR_ONELETTER_ABBR
	else
		return daySecs, DAY_ONELETTER_ABBR
	end
end

local function FormatTime(seconds)
	local factor, timeFormat = GetTimeFactor(seconds)
	return gsub(timeFormat, "%s", ""), ceil(seconds / factor)
end

function module:GetDebuffColor(debuffType)
	if db.Colors[debuffType] then
		return module:RGB(debuffType)
	else
		return module:RGB("None")
	end
end

function module:NewAuraHeader(auraType, helpful)
	if headerStorage[auraType] then
		headerStorage[auraType]:Configure()
		headerStorage[auraType]:Show()
		return
	end

	local header = CreateFrame("Frame", format("LUIAura_%s", auraType), UIParent, "SecureAuraHeaderTemplate")
	header.auraType = auraType
	header.helpful = helpful
	header.auraList = {}

	--Embed prototype
	for k, v in pairs(Header) do
		header[k] = v
	end

	header:SetClampedToScreen(true)
	header:SetSize(1,1) -- Anchoring can bug out if no size are set
	header:SetAttribute('filter', (helpful) and "HELPFUL" or "HARMFUL")

	if helpful then
		header:SetAttribute("template", "LUIAura_BuffTemplate")
	else
		header:SetAttribute("template", "LUIAura_DebuffTemplate")
	end

	header:RegisterEvent('PLAYER_ENTERING_WORLD')
	header:HookScript('OnEvent', header.Update)

	RegisterAttributeDriver(header, 'unit', "[vehicleui] vehicle; player")

	header:Configure()
	header:Show()
end

-- ####################################################################################################################
-- ##### Header Prototype #############################################################################################
-- ####################################################################################################################
-- Turn into HeaderMixin?

function Header:GetOption(name)
	return db[self.auraType][name]
end

function Header:Update(event, ...)
	local unit = self:GetAttribute("unit")
	if (unit ~= ... and event ~= "PLAYER_ENTERING_WORLD") or not self:IsShown() then return end

	local filter = self:GetAttribute("filter")

	for i=1, #self.auraList do
		self.auraList[i]:Update(unit, self.auraList[i]:GetID(), filter)
	end
end

function Header:ChildCreated(child)
	child.header = self
	child.helpful = self.helpful

	local template
	if child:GetAttribute("proxy") then
		LUI:Print("Proxy Child")
	elseif child:GetAttribute("weaponEnchant") then
		LUI:Print("WeaponEnchant")
		template = WeaponEnchant
	else
		self.auraList[#self.auraList + 1] = child
		template = Aura
	end

	--Mixin the prototype
	for k, v in pairs(template) do
		child[k] = v
	end
	-- technically this is the border. Probably could change that.
	-- the child.border texture is for the colored borders around debuffs and weapon enchants
	child.normalTexture:SetDrawLayer("BORDER")

	child:SetProperties(true)
end

function Header:Configure()
	self:SetAttribute("_ignore", true)

	local anchor = self:GetOption("Anchor")
	local auraSize = self:GetOption("Size")
	local spacing = self:GetOption("HorizontalSpacing") + auraSize
	local rowSpacing = self:GetOption("VerticalSpacing") + auraSize
	if strfind(anchor, "RIGHT") then
		spacing = -spacing
	end
	if strfind(anchor, "TOP") then
		rowSpacing = -rowSpacing
	end

	self:ClearAllPoints()
	self:SetPoint(anchor, self:GetOption("X"), self:GetOption("Y"))
	self:SetAttribute("minWidth", auraSize)
	self:SetAttribute("minHeight", auraSize)
	self:SetAttribute("point", anchor)
	self:SetAttribute("xOffset", spacing)
	self:SetAttribute("wrapAfter", self:GetOption("AurasPerRow"))
	self:SetAttribute("maxWraps", self:GetOption("NumRows"))
	self:SetAttribute("wrapYOffset", rowSpacing)
	self:SetAttribute("sortMethod", self:GetOption("SortMethod"))
	--self:SetAttribute("sortDirection")  -- Will uncomment when sort out trickery


	for i = 1, #self.auraList do
		self.auraList[i]:SetProperties()
	end

	self:SetAttribute("_ignore", nil)

	--This looks sketchy, try to make it look better.
	local initConfig = [=[
		local size = %d
		self:SetWidth(size)
		self:SetHeight(size)
	]=]
	self:SetAttribute("initialConfigFunction", format(initConfig, auraSize))
end

-- ####################################################################################################################
-- ##### Aura Prototype #############################################################################################
-- ####################################################################################################################

function Aura:GetNextUpdate(seconds)
	local factor = GetTimeFactor(seconds)
	return seconds - (seconds % factor)
end

function Aura:OnUpdate(elapsed)
	--Make sure it only updates once per
	if self.nextUpdate then
		self.remaining = self.remaining - elapsed
		if self.remaining > self.nextUpdate then return end
	end
	self.nextUpdate = self:GetNextUpdate(self.remaining)
	self.duration:SetFormattedText(FormatTime(self.remaining))
end

function Aura:Update(...)
	local name, icon, count, dispelType, duration, expires, caster = UnitAura(...)
	-- Blizzard has a bug with SecureAuraHeaders that causes extra aura buttons to sometimes be shown
	-- It occurs when the consolidation or tempEnchants are shown, an extra button gets added
	-- to the end of the list for each one shown
	if not name then
		return
	end

	--skipped duration block, not sure what it does.
	if duration and duration > 0 then
		self.remaining = expires - GetTime()
		self.nextUpdate = nil -- forces update
		self:SetScript("OnUpdate", self.OnUpdate)
	else
		self:SetScript("OnUpdate", nil)
		self.duration:SetText()
	end

	self.icon:SetTexture(icon)
	if not self.helpful then
		self.border:SetVertexColor(module:RGB(dispelType))
	end

	if count and count > 1 then
		self.count:SetText(count)
	else
		self.count:SetText()
	end

	self.caster = caster
end

function Aura:UpdateTooltip()
	GameTooltip:SetUnitAura(self.header:GetAttribute("unit"), self:GetID(), self.header:GetAttribute("filter"))

	if self.caster then
		GameTooltip:AddLine(self.caster)
		--force the tooltip to update
		GameTooltip:Show()
	end
end

function Aura:SetProperties(init)
	local auraSize = self.header:GetOption("Size")

	-- Size is handled by the initConfig func if we're initializing. (We could be in CombatLockdown)
	if not init then
		self:SetSize(auraSize, auraSize)
	end

	--Maybe not use magic numbers for thoes?
	self.gloss:SetSize(auraSize * 1.12, auraSize * 1.12)
	self.normalTexture:SetSize(auraSize * 1.2, auraSize * 1.2)
	if self.border then
		self.border:SetSize(auraSize * 1.2, auraSize * 1.2)
	end

	module:RefreshFontString(self.count, format("%sCount", self.header.auraType))
	module:RefreshFontString(self.duration, format("%sDur", self.header.auraType))
	self.TooltipAnchor = format("Anchor_%s",LUI.Opposites[self.header:GetOption("Anchor")])
end

-- ####################################################################################################################
-- ##### Framework Events #############################################################################################
-- ####################################################################################################################

module.enableButton = true

function module:OnInitialize()
	LUI:RegisterModule(module, true)
	db = module.db.profile
end

function module:OnEnable()
	BuffFrame:Hide()
	module:NewAuraHeader("Buffs", true)
	module:NewAuraHeader("Debuffs")
end

function module:OnDisable()
end
