------------------------------------------------------
-- / SETUP AND LOCALS / --
------------------------------------------------------
local addonname, LUI = ...
local module = LUI:NewModule("Unitframes", "AceHook-3.0")
local L = LUI.L
local db

local unitSpawns = { "player", "target", }

-- Defaults have been moved to their own file under unitframes/defaults.lua

------------------------------------------------------
-- / MODULE FUNCTIONS / --
------------------------------------------------------

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
-- / META FUNCTIONS / --
------------------------------------------------------
-- oUF Meta Functions are functions available under every spawned unit object, similar to Tag.

local function FormatName(self)
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

oUF_LUI:RegisterMetaFunction("FormatName", FormatName)

------------------------------------------------------
-- / STYLE FUNCTIONS / --
------------------------------------------------------
local function SpawnUnit(self, unit, ...)
	self:SetActiveStyle("LUI")
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
	oUF_LUI:RegisterStyle("LUI", module.SetStyle)
end

function module:OnEnable()
	db = module:GetDB()
	module:SetOUFColors()
	for i = 1, #unitSpawns do
		local unit = unitSpawns[i]
		local db = module:GetModule(unit):GetDB()
		local spawn = SpawnUnit(oUF_LUI, unit, db.Point, db.X, db.Y)
	end
end

function module:OnDisable()
end