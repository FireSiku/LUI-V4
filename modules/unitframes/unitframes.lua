-- ####################################################################################################################
-- ##### Setup and Locals #############################################################################################
-- ####################################################################################################################

local _, LUI = ...
local module = LUI:NewModule("Unitframes", "AceHook-3.0")
local L = LUI.L
local oUF = LUI.oUF
local db

module.unitSpawns = { "player", "target", }
-- luacheck: globals UnitFrame_OnEnter UnitFrame_OnLeave

-- Defaults have been moved to their own file under unitframes/defaults.lua

-- ####################################################################################################################
-- ##### Module Functions #############################################################################################
-- ####################################################################################################################

function module:GetUnitDB(unit)
	return db.Units[unit]
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
-- ##### Framework Events #############################################################################################
-- ####################################################################################################################

local function SpawnUnit(unit, ...)
	oUF:SetActiveStyle("LUI4")
	local spawn = oUF:Spawn(unit)
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
	db = module.db.profile

	for k, v in pairs(SpawnMixin) do
		oUF:RegisterMetaFunction(k, v)
	end
end

function module:OnEnable()
	module:SetOUFColors()
	for i = 1, #module.unitSpawns do
		local unit = module.unitSpawns[i]
		local db = db.Units[unit]
		local spawn_ = SpawnUnit(unit, db.Point, db.X, db.Y)
	end
end

function module:OnDisable()
end
