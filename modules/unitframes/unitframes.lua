------------------------------------------------------
-- / SETUP AND LOCALS / --
------------------------------------------------------
local addonname, LUI = ...
local module = LUI:NewModule("Unitframes", "AceHook-3.0")
local L = LUI.L

local unitSpawns = { "player", "target", }

-- Defaults have been moved to their own file under unitframes/defaults.lua

------------------------------------------------------
-- / MODULE FUNCTIONS / --
------------------------------------------------------

function module:GetUnitDB(unit)
	return module:GetDB().Units[unit]
end

--TODO: Fix color system so we don't have to create new tables every call.
function module:SetOUFColors()
	local colors = oUF_LUI.colors
	colors.reaction = {}
	for i = 1, #LUI.REACTION_NAMES do
		colors.reaction[i] = {module:Color(LUI.REACTION_NAMES[i])}
	end
	for class in pairs(RAID_CLASS_COLORS) do
		colors.class[class] = {module:Color(class)}
	end
	for _, powerType in pairs(LUI.PowerTypes) do
		colors.power[powerType] = {module:Color(powerType)}
	end
	colors.health = {module:Color("HealthBar")}
	
	colors.runes = {
		{module:Color("BLOOD_RUNES")},
		{module:Color("UNHOLY_RUNES")},
		{module:Color("FROST_RUNES")},
		{module:Color("DEATH_RUNES")},
	}
end


local siValue = function(val)
	if(val >= 1e6) then
		return format("%.1fm", val / 1e6)
	elseif(val >= 1e4) then
		return format("%.1fk", val / 1e3)
	else
		return val
	end
end

------------------------------------------------------
-- / OUF TAGS METHODS / --
------------------------------------------------------

oUF_LUI.Tags.Methods['LUI:health'] = function(unit)
	if(not UnitIsConnected(unit) or UnitIsDead(unit) or UnitIsGhost(unit)) then return end
	--return siValue(UnitHealth(unit)) .. '/' .. siValue(UnitHealthMax(unit))
	return siValue(UnitHealth(unit))
end
oUF_LUI.Tags.Methods['LUI:Absorb'] = function(unit)
	if(not UnitIsConnected(unit) or UnitIsDead(unit) or UnitIsGhost(unit)) then return end
	local totalAbsorb = UnitGetTotalAbsorbs(unit)
	if totalAbsorb < 1 then return end
	return format("(+%s)",siValue(totalAbsorb))
end
oUF_LUI.Tags.Methods['ClassColor'] = function(unit)
	local _, class = UnitClass(unit)
	local r, g, b = module:Color(class)
	if not r then r, g, b = LUI:GetReactionColor(unit) end
	
	return format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
end

------------------------------------------------------
-- / MIXIN FUNCTIONS / --
------------------------------------------------------
-- Every function under SpawnMixin will become available to all spawned unitframes. 
local SpawnMixin = {}

-- Version of module:Color tailored for unitframes, with support for additional types (ie: Color Based On Type)
function SpawnMixin:Color(colorName)
	local color
	if self.db and self.db[colorName] then
		if self.db[colorName].t and self.db[colorName].t == "Class" then
			return LUI:Color(LUI.playerClass)
		else
			color = db[colorName]
		end
	else
		local colorDB = LUI:GetModule("Colors"):GetDB()
		color = colorDB.Colors[colorName]
	end
	if color then
		return color.r, color.g, color.b
	end
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

------------------------------------------------------
-- / STYLE FUNCTIONS / --
------------------------------------------------------
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

------------------------------------------------------
-- / FRAMEWORK FUNCTIONS / --
------------------------------------------------------

module.enableButton = true

function module:OnInitialize()
	LUI:RegisterModule(module)
	oUF_LUI:RegisterStyle("LUI4", module.SetStyle)

	for k, v in pairs(SpawnMixin) do
		oUF_LUI:RegisterMetaFunction(k, v)
	end
end

function module:OnEnable()
	module:SetOUFColors()
	for i = 1, #unitSpawns do
		local unit = unitSpawns[i]
		local db = module:GetUnitDB(unit)
		local spawn = SpawnUnit(oUF_LUI, unit, db.Point, db.X, db.Y)
	end
end

function module:OnDisable()
end
