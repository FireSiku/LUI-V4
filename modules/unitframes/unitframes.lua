-- ####################################################################################################################
-- ##### Setup and Locals #############################################################################################
-- ####################################################################################################################

local _, LUI = ...
local module = LUI:NewModule("Unitframes", "AceHook-3.0")
local L = LUI.L
local oUF = LUI.oUF

local unitSpawns = { "player", "target", }

-- Defaults have been moved to their own file under unitframes/defaults.lua

-- ####################################################################################################################
-- ##### Module Functions #############################################################################################
-- ####################################################################################################################

function module:GetUnitDB(unit)
	return module:GetDB("Units")[unit]
end

--TODO: Fix color system so we don't have to create new tables every call.
function module:SetOUFColors()
	local colors = oUF.colors
	colors.reaction = {}
	for i = 1, #LUI.REACTION_NAMES do
		colors.reaction[i] = {module:RGB(LUI.REACTION_NAMES[i])}
	end
	for class in pairs(RAID_CLASS_COLORS) do
		colors.class[class] = {module:RGB(class)}
	end
	for _, powerType in pairs(LUI.PowerTypes) do
		colors.power[powerType] = {module:RGB(powerType)}
	end
	colors.health = {module:RGB("HealthBar")}

	colors.runes = {
		{module:RGB("BLOOD_RUNES")},
		{module:RGB("UNHOLY_RUNES")},
		{module:RGB("FROST_RUNES")},
		{module:RGB("DEATH_RUNES")},
	}
end


local function ShortValue(value)
	if(value >= 1e9) then
		return format("%.1fb", value / 1e9)
	elseif(value >= 1e6) then
		return format("%.1fm", value / 1e6)
	elseif(value >= 1e4) then
		return format("%.1fk", value / 1e3)
	else
		return value
	end
end

-- ####################################################################################################################
-- ##### Unitframes: Tags Methods #####################################################################################
-- ####################################################################################################################

oUF.Tags.Methods['LUI:health'] = function(unit)
	if(not UnitIsConnected(unit) or UnitIsDead(unit) or UnitIsGhost(unit)) then return end
	--return siValue(UnitHealth(unit)) .. '/' .. siValue(UnitHealthMax(unit))
	return ShortValue(UnitHealth(unit))
end
oUF.Tags.Methods['LUI:Absorb'] = function(unit)
	if(not UnitIsConnected(unit) or UnitIsDead(unit) or UnitIsGhost(unit)) then return end
	local totalAbsorb = UnitGetTotalAbsorbs(unit)
	if totalAbsorb < 1 then return end
	return format("(+%s)",ShortValue(totalAbsorb))
end
oUF.Tags.Methods['ClassColor'] = function(unit)
	local _, class = UnitClass(unit)
	local r, g, b = module:RGB(class)
	if not r then r, g, b = LUI:GetReactionColor(unit) end

	return format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
end

-- ####################################################################################################################
-- ##### SpawnMixin ###################################################################################################
-- ####################################################################################################################
-- Every function under SpawnMixin will become available to all spawned unitframes.
local SpawnMixin = {}

-- Version of module:RGB tailored for unitframes, with support for additional types (ie: Color Based On Type)
function SpawnMixin:RGB(colorName)
	local colorDB = self.db.Colors[colorName]
	if colorDB and colorDB.t == "Type" then
		-- Use module coloring logic here
	elseif colorDB and colorDB.t == "Class" then
		return LUI:RGB(LUI.playerClass)
	end
	return module:RGB(colorName)
end

function SpawnMixin:FormatName()
	if not self or not self.Name then return end

	local name = (self.Name.ColorNameByClass) and "[ClassColor][name]|r" or "[name]"
	--TODO/HACK: Disabled the level conditional because I havent added DiffColor tag.
	local level = (self.Name.ColorLevelByDifficulty and false) and "[DiffColor][level]|r" or "[level]"
	local class = (self.Name.ColorClassByClass) and "[ClassColor][smartclass]|r" or "[smartclass]"
	local race = "[race]"

	if self.Name.ShowClassification then
		level = (self.Name.ShortClassification) and level.."[shortclassification]" or level.."[classification]"
	end

	local tagStr = gsub(self.Name.Format, ' %+ ', ' ')
	tagStr = gsub(tagStr, "Level", level)
	tagStr = gsub(tagStr, "Class", class)
	tagStr = gsub(tagStr, "Name", name)
	tagStr = gsub(tagStr, "Race", race)
	self:Tag(self.Name, tagStr)
	--self:UpdateAllElements()
end

-- ####################################################################################################################
-- ##### Options Menu #################################################################################################
-- ####################################################################################################################

module.childGroups = "tree"

-- Function to create an option menu for a given unit.
-- Takes: unit id and option order
function module:NewUnitOptionGroup(unit, order)
	-- Create an object to represent the unit, GetDB is the only function we need to recreate for the Options API.
	local opt = {}
	function opt:GetDB(subTable)
		local db = module:GetDB()
		return (subTable and db.Units[unit][subTable]) or db.Units[unit]
	end
	LUI:EmbedOptions(opt)

	-- Boolean shortcut, since many options are player-specific.
	local isPlayer = (unit == "player") or nil

	local unitOptions = opt:NewGroup(unit, order, "tab", nil, {
		-- General = opt:NewGroup("General", 1, "tab", nil, {
		-- 	sillyDesc = opt:NewDesc("General Settings will go here", 1),
		-- }),

		Bars = opt:NewGroup("Bars", 2, "tab", nil, {
			HealthBar = opt:NewGroup("Health", 1, "tab", nil, {
				Size = opt:NewUnitframeSize(nil, 1),
				Position = opt:NewPosition("Position", 2, true),
				Point = opt:NewSelect(L["Anchor"], nil, 3, LUI.Points),
				Scale = opt:NewScale("Scale", nil, 4),
				Texture = opt:NewTexStatusBar("Texture", nil, 5),
				TextureBG = opt:NewTexStatusBar("Background Texture", nil, 6),
				-- Options unsure about currently:
				-- BGAlpha = 1,
				-- BGInvert Toggle,
				-- Smooth toggle,
				-- Tapping toggle,
			}),
			PowerBar = opt:NewGroup("Power", 2, "tab", nil, {
				Size = opt:NewUnitframeSize(nil, 1, true),
				Position = opt:NewPosition("Position", 2, true),
				Point = opt:NewSelect(L["Anchor"], nil, 3, LUI.Points),
				Scale = opt:NewScale("Scale", nil, 4),
				Texture = opt:NewTexStatusBar("Texture", nil, 5),
				TextureBG = opt:NewTexStatusBar("Background Texture", nil, 6),
				-- Options unsure about currently:
				-- BGAlpha = 1,
				-- BGInvert Toggle,
				-- Smooth toggle,
			}),
			AbsorbBar = opt:NewGroup("Absorb", 2, "tab", nil, {
				sillyDesc = opt:NewDesc("Absorb Bar Settings will go here. Coming Soon.", 1),
			}),
			ClassPowerBar = isPlayer and opt:NewGroup("Class Powers", 3, "tab", nil, {
				Size = opt:NewUnitframeSize(nil, 1, true),
				Position = opt:NewPosition("Position", 2, true),
				Point = opt:NewSelect(L["Anchor"], nil, 3, LUI.Points),
				Scale = opt:NewScale("Scale", nil, 4),
				Texture = opt:NewTexStatusBar("Texture", nil, 5),
				TextureBG = opt:NewTexStatusBar("Background Texture", nil, 6),
				-- Pending
				-- AlwaysShow / Only show when used (ie: ComboPoints)
				-- Options unsure about currently:
				-- BGAlpha = 1,
				-- BGInvert Toggle,
				-- Smooth toggle,
			}),
		}),

		Texts = opt:NewGroup("Texts", 3, "tab", nil, {
			Nametext = opt:NewGroup("Name", 1, "tab", nil, {
				sillyDesc = opt:NewDesc("Nametext Settings will go here", 1),
			}),
			HealthText = opt:NewGroup("Health Value", 2, "tab", nil, {
				sillyDesc = opt:NewDesc("HealthText Settings will go here", 1),
			}),
			PowerText = opt:NewGroup("Power Value", 3, "tab", nil, {
				sillyDesc = opt:NewDesc("PowerText Settings will go here", 1),
			}),
			HealthPercent = opt:NewGroup("Health Percent", 4, "tab", nil, {
				sillyDesc = opt:NewDesc("HealthPercent Settings will go here", 1),
			}),
			PowerPercent = opt:NewGroup("Power Percent", 5, "tab", nil, {
				sillyDesc = opt:NewDesc("PowerPercent Settings will go here", 1),
			}),
			HealthMissing = opt:NewGroup("Health Missing", 6, "tab", nil, {
				sillyDesc = opt:NewDesc("HealthMissing Settings will go here", 1),
			}),
			PowerMissing = opt:NewGroup("Power Missing", 7, "tab", nil, {
				sillyDesc = opt:NewDesc("PowerMissing Settings will go here", 1),
			}),
			CombatText = opt:NewGroup("Combat", 8, "tab", nil, {
				sillyDesc = opt:NewDesc("Combat Settings will go here", 1),
			}),
		}),

		Portrait = opt:NewGroup("Portrait", 4, "tab", nil, {
			Size = opt:NewUnitframeSize(nil, 1, true),
			Position = opt:NewPosition("Position", 2, true),
			Point = opt:NewSelect(L["Anchor"], nil, 3, LUI.Points),
			Alpha = opt:NewSlider("Alpha", nil, 4, 0, 1, 0.05, true),
		}),

		Buffs = opt:NewGroup("Buffs", 5, "tab", nil, {
			NYI = opt:NewDesc("Auras Not Yet Implemented", 0.9),
			ColorByType = opt:NewToggle("Color By Type", nil, 1),
			PlayerOnly = opt:NewToggle("Player Only", nil, 2),
			IncludePet = opt:NewToggle("Include Pet", nil, 3),
			AuraTimer = opt:NewToggle("Aura Timer", nil, 4),
			DisableCooldown = opt:NewToggle("Disable Cooldown", nil, 5),
			CooldownReverse = opt:NewToggle("Cooldown Reverse", nil, 6),
			Position = opt:NewPosition("Position", 7, true),
			InitialAnchor = opt:NewSelect(L["Anchor"], nil, 8, LUI.Points),
			GrowthX = opt:NewSelect("Horizontal Growth", nil, 9, LUI.Directions),
			GrowthY = opt:NewSelect("Vertical Growth", nil, 10, LUI.Directions),
			Size = opt:NewSlider("Size", nil, 11, 8, 64, 1),
			Spacing = opt:NewSlider("Spacing", nil, 12, -10, 10, 1),
			Num = opt:NewSlider("Amount of Buffs", nil, 13, 1, 48, 1),
		}),

		Debuffs = opt:NewGroup("Debuffs", 6, "tab", nil, {
			NYI = opt:NewDesc("Auras Not Yet Implemented", 0.9),
			ColorByType = opt:NewToggle("Color By Type", nil, 1),
			PlayerOnly = opt:NewToggle("Player Only", nil, 2),
			IncludePet = opt:NewToggle("Include Pet", nil, 3),
			AuraTimer = opt:NewToggle("Aura Timer", nil, 4),
			DisableCooldown = opt:NewToggle("Disable Cooldown", nil, 5),
			CooldownReverse = opt:NewToggle("Cooldown Reverse", nil, 6),
			Position = opt:NewPosition("Position", 7, true),
			InitialAnchor = opt:NewSelect(L["Anchor"], nil, 8, LUI.Points),
			GrowthX = opt:NewSelect("Horizontal Growth", nil, 9, LUI.Directions),
			GrowthY = opt:NewSelect("Vertical Growth", nil, 10, LUI.Directions),
			Size = opt:NewSlider("Size", nil, 11, 8, 64, 1),
			Spacing = opt:NewSlider("Spacing", nil, 12, -10, 10, 1),
			Num = opt:NewSlider("Amount of Buffs", nil, 13, 1, 48, 1),
		}),

		Icons = opt:NewGroup("Icons", 7, "tab", nil, {
			LootmasterIcon = opt:NewGroup("LootmasterIcon", 1, "tab", nil, {
				Position = opt:NewPosition("Position", 1, true),
				Size = opt:NewSlider("Size", nil, 2, 8, 64, 1),
				Point = opt:NewSelect(L["Anchor"], nil, 3, LUI.Points),
			}),
			LeaderIcon = opt:NewGroup("LeaderIcon", 2, "tab", nil, {
				Position = opt:NewPosition("Position", 1, true),
				Size = opt:NewSlider("Size", nil, 2, 8, 64, 1),
				Point = opt:NewSelect(L["Anchor"], nil, 3, LUI.Points),
			}),
			RoleIcon = opt:NewGroup("RoleIcon", 3, "tab", nil, {
				Position = opt:NewPosition("Position", 1, true),
				Size = opt:NewSlider("Size", nil, 2, 8, 64, 1),
				Point = opt:NewSelect(L["Anchor"], nil, 3, LUI.Points),
			}),
			RaidIcon = opt:NewGroup("RaidIcon", 4, "tab", nil, {
				Position = opt:NewPosition("Position", 1, true),
				Size = opt:NewSlider("Size", nil, 2, 8, 64, 1),
				Point = opt:NewSelect(L["Anchor"], nil, 3, LUI.Points),
			}),
			PvPIcon = opt:NewGroup("PvPIcon", 5, "tab", nil, {
				Position = opt:NewPosition("Position", 1, true),
				Size = opt:NewSlider("Size", nil, 2, 8, 64, 1),
				Point = opt:NewSelect(L["Anchor"], nil, 3, LUI.Points),
			}),
		}),
	})

	
	unitOptions.handler = opt
	return unitOptions
end

module.childGroups = "tab" -- Placeholder

function module:LoadOptions()
	local options = {
		Header = module:NewHeader("Unitframes", 1),
	}

	for i = 1, #unitSpawns do
		local unit = unitSpawns[i]
		options[unit] = module:NewUnitOptionGroup(unit, i+10)
		--module:NewGroup(unit, i+10, "tab", nil, )
	end

	return options
end


-- ####################################################################################################################
-- ##### Framework Events #############################################################################################
-- ####################################################################################################################

local function SpawnUnit(self, unit, ...)
	self:SetActiveStyle("LUI4")
	local spawn = self:Spawn(unit)
	spawn:SetPoint(...)
	spawn:RegisterForClicks("AnyUp")
    spawn:SetAttribute("*type2", "menu")
    spawn:SetScript("OnEnter", UnitFrame_OnEnter)
    spawn:SetScript("OnLeave", UnitFrame_OnLeave)

	return spawn
end

module.enableButton = true

function module:OnInitialize()
	LUI:RegisterModule(module)
	oUF:RegisterStyle("LUI4", module.SetStyle)

	for k, v in pairs(SpawnMixin) do
		oUF:RegisterMetaFunction(k, v)
	end
end

function module:OnEnable()
	module:SetOUFColors()
	for i = 1, #unitSpawns do
		local unit = unitSpawns[i]
		local db = module:GetUnitDB(unit)
		local spawn_ = SpawnUnit(oUF, unit, db.Point, db.X, db.Y)
	end
end

function module:OnDisable()
end
