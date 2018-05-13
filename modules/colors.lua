-- This module handles the colors section and themes
-- This module hosts most of the Color-related API.
-- Also, possibly the CUSTOM_CLASS_COLOR implementation

-- Addon building reference.
local _, LUI = ...
local module = LUI:NewModule("Colors")
local L = LUI.L
local db

-- constants
local SANCTUARY = SANCTUARY_TERRITORY:sub(2, -2)  -- Remove parenthesis.
local FACTION_ALLIANCE = FACTION_ALLIANCE
local FACTION_HORDE = FACTION_HORDE
local MISCELLANEOUS = MISCELLANEOUS
local COLORS = COLORS

local STANDING_HATED      = FACTION_STANDING_LABEL1
local STANDING_HOSTILE    = FACTION_STANDING_LABEL2
local STANDING_UNFRIENDLY = FACTION_STANDING_LABEL3
local STANDING_NEUTRAL    = FACTION_STANDING_LABEL4
local STANDING_FRIENDLY   = FACTION_STANDING_LABEL5
local STANDING_HONORED    = FACTION_STANDING_LABEL6
local STANDING_REVERED    = FACTION_STANDING_LABEL7
local STANDING_EXALTED    = FACTION_STANDING_LABEL8

--Defaults
module.defaults = {
	profile = {
		Advanced = {
			BGMult = 0.4,
		},
		Colors = {
			-- Class Colors
			DEATHKNIGHT = { r = 0.8,  g = 0.1,  b = 0.1,  },
			DRUID =       { r = 1,    g = 0.44, b = 0.15, },
			HUNTER =      { r = 0.22, g = 0.91, b = 0.18, },
			MAGE =        { r = 0.12, g = 0.58, b = 0.89, },
			MONK =        { r = 0.00, g = 1.00, b = 0.59, },
			PALADIN =     { r = 0.96, g = 0.21, b = 0.73, },
			PRIEST =      { r = 0.9,  g = 0.9,  b = 0.9,  },
			ROGUE =       { r = 0.95, g = 0.86, b = 0.16, },
			SHAMAN =      { r = 0.04, g = 0.39, b = 0.98, },
			WARLOCK =     { r = 0.57, g = 0.22, b = 1,    },
			WARRIOR =     { r = 1,    g = 0.78, b = 0.55, },
			DEMONHUNTER = { r = 0.65, g = 0.2,  b = 0.8   },

			-- Faction Colors
			Alliance =  { r = 0, g = 0.6, b = 1,   },
			Horde =     { r = 1, g = 0.3, b = 0.3, },
			Sanctuary = { r = 0, g = 1,   b = 1,   },

			-- Reaction Colors
			Hated =      { r = 1,   g = 0.3, b = 0.3, },
			Hostile =    { r = 1,   g = 0.3, b = 0.3, },
			Unfriendly = { r = 0.9, g = 0.2, b = 0,   },
			Neutral =    { r = 0.9, g = 0.7, b = 0,   },
			Friendly =   { r = 0,   g = 0.6, b = 0.1, },
			Honored =    { r = 0,   g = 0.6, b = 0.1, },
			Revered =    { r = 0,   g = 0.6, b = 0.1, },
			Exalted =    { r = 0,   g = 0.6, b = 0.1, },

			-- Resources
			MANA           = { r = 0.12, g = 0.58, b = 0.89, },
			RAGE           = { r = 0.69, g = 0.31, b = 0.31, },
			FOCUS          = { r = 0.65, g = 0.63, b = 0.35, },
			ENERGY         = { r = 0.95, g = 0.86, b = 0.16, },
			RUNIC_POWER    = { r = 0   , g = 0.82, b = 1   , },
			RUNES          = { r = 0.55, g = 0.57, b = 0.61, },
			FUEL           = { r = 0   , g = 0.55, b = 0.5 , },
			COMBO_POINTS   = { r = 0.95, g = 0.86, b = 0.16, },
			ARCANE_CHARGES = { r = 0.12, g = 0.58, b = 0.89, },
			HOLY_POWER     = { r = 0.9 , g = 0.88, b = 0.06, },
			SOUL_SHARDS    = { r = 0.57, g = 0.22, b = 1   , },
			CHI            = { r = 0   , g = 1   , b = 0.59, },
			STAGGER_LOW    = { r = 052 , g = 1   , b = 0.52, },
			STAGGER_MED    = { r = 1   , g = 0.97, b = 0.72, },
			STAGGER_HIGH   = { r = 1   , g = 0.42, b = 0.42, },
			LUNAR_POWER    = { r = 0.3 , g = 0.52, b = 0.9 , },
			MAELSTROM      = { r = 0.04, g = 0.39, b = 0.98, },
			PAIN           = { r = 1   , g = 0.61, b = 0   , },
			INSANITY       = { r = 0.4 , g = 0   , b = 0.8 , },
			FURY           = { r = 0.79, g = 0.26, b = 0.99, },

			--Gradient
			Good =   { r = 0,   g = 1,   b = 0,   },
			Medium = { r = 1,   g = 1,   b = 0,   },
			Bad =    { r = 0.8, g = 0.3, b = 0.2, },

			--Level Differences
			DiffSkull = { r = 0.69, g = 0.31, b = 0.31, }, -- Target Level >= 5
			DiffHard =  { r = 0.71, g = 0.43, b = 0.27, }, -- Target Level >= 3
			DiffEqual = { r = 0.84, g = 0.75, b = 0.65, }, -- Target Level <> 2
			DiffEasy =  { r = 0.33, g = 0.59, b = 0.33, }, -- Target Level GreenQuestRange
			DiffLow =   { r = 0.55, g = 0.57, b = 0.61, }, -- Low Level Target
		},
	},
}
--[[
	Class Colors	LUI V3					Blizzard
	DEATHKNIGHT = 	{0.8,  0.1,  0.1 },		{0.8,  0.1,  0.1 },
	DRUID = 		{1,    0.44, 0.15},		{1,    0.44, 0.15},
	HUNTER = 		{0.22, 0.91, 0.18},		{0.22, 0.91, 0.18},
	MAGE = 			{0.12, 0.58, 0.89},		{0.12, 0.58, 0.89},
	MONK = 			{0.00, 1.00, 0.59},		{0.00, 1.00, 0.59},
	PRIEST = 		{0.9,  0.9,  0.9 },		{0.9,  0.9,  0.9 },
	PALADIN = 		{0.96, 0.21, 0.73},		{0.96, 0.21, 0.73},
	SHAMAN = 		{0.04, 0.39, 0.98},		{0.04, 0.39, 0.98},
	WARLOCK = 		{0.57, 0.22, 1   },		{0.57, 0.22, 1   },
	WARRIOR = 		{1,   0.78,  0.55},		{1,    0.78, 0.55},
	DEMONHUNTER =   N\A						TBA

	-- LEVEL DIFFS FUNCTIONS
	oUF:
	function(unit)
		local r, g, b
		local level = UnitLevel(unit)
		if level < 1 then
			r, g, b = unpack(module.colors.leveldiff[1])
		else
			local difference = level - UnitLevel("player")
			if difference >= 5 then
				r, g, b = unpack(module.colors.leveldiff[1])
			elseif difference >= 3 then
				r, g, b = unpack(module.colors.leveldiff[2])
			elseif difference >= -2 then
				r, g, b = unpack(module.colors.leveldiff[3])
			elseif -difference <= GetQuestGreenRange() then
				r, g, b = unpack(module.colors.leveldiff[4])
			else
				r, g, b = unpack(module.colors.leveldiff[5])
			end
		end
		return string.format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
	end

	Blizzard:
	function GetRelativeDifficultyColor(unitLevel, challengeLevel)
		local levelDiff = challengeLevel - unitLevel;
		local color;
		if ( levelDiff >= 5 ) then
			return QuestDifficultyColors["impossible"];
		elseif ( levelDiff >= 3 ) then
			return QuestDifficultyColors["verydifficult"];
		elseif ( levelDiff >= -2 ) then
			return QuestDifficultyColors["difficult"];
		elseif ( -levelDiff <= GetQuestGreenRange() ) then
			return QuestDifficultyColors["standard"];
		else
			return QuestDifficultyColors["trivial"];
		end
	end
--]]

------------------------------------------------------
-- / VARIOUS COLOR API / --
------------------------------------------------------

-- Return r, g, b for selected faction, otherwise return white.
function LUI:GetFactionColor(faction)
	if LUI:Color(faction) then
		return LUI:Color(faction)
	else
		return 1, 1, 1
	end
end

-- Return r, g, b based on reaction of unit towards another unit.
-- If a second unit isnt given, assume player.
function LUI:GetReactionColor(unit, otherUnit)
	local reaction = UnitReaction(unit, otherUnit or "player")
	if LUI:Color(LUI.REACTION_NAMES[reaction]) then
		return LUI:Color(LUI.REACTION_NAMES[reaction])
	else
		return 1, 1, 1
	end
end

-- Return r, g, b based on level difference.
function LUI:GetDifficultyColor(level)
	local color = GetQuestDifficultyColor(level)
	return color.r, color.g, color.b
end

--Function wrappers for Good/Bad colors convenience.
function LUI:PositiveColor()
	return LUI:Color("Good")
end
function LUI:NegativeColor()
	return LUI:Color("Bad")
end

-- Based on Wowpedia's ColorGradient. Use our three gradient colors to make a color based on a percentage
-- TODO: Possibly rename some variables inside to better names. (such as relperc.)
function LUI:ColorGradient(perc)
	if perc >= 1 then
		return LUI:PositiveColor()
	elseif perc <= 0 then
		return LUI:NegativeColor()
	end

	local segment, relperc = math.modf(perc * 2)
	local r1, r2, g1, g2, b1, b2
	if segment == 0 then
		r1, g1, b1 = LUI:Color("Bad")
		r2, g2, b2 = LUI:Color("Medium")
	elseif segment == 1 then
		r1, g1, b1 = LUI:Color("Medium")
		r2, g2, b2 = LUI:Color("Good")
	end

	local r = r1 + (r2 - r1) * relperc
	local g = g1 + (g2 - g1) * relperc
	local b = b1 + (b2 - b1) * relperc
	return r, g, b
end

--Wrapper for ColorGradient's that inverse the percent given.
function LUI:InverseGradient(perc)
	return LUI:ColorGradient(1 - perc)
end

function LUI:GetBGMultiplier()
	return db.Advanced.BGMult
end

local multiplierCallback = {}
function LUI:AddBGMultiplierCallback(id, func)
	if multiplierCallback[id] then return end
	multiplierCallback[id] = func
end

--This is used by option API to callback a function call when someone change class/theme colors.
local colorCallback = {}
function LUI:AddColorCallback(id, func)
	if colorCallback[id] then return end
	colorCallback[id] = func
end
------------------------------------------------------
-- / FRAMEWORK FUNCTIONS / --
------------------------------------------------------

module.order = 3 -- Makes Colors parts of the "core" options at the top.

function module:RefreshClassColors()
	--Nothing happens currently, as we don't alter class colors.

	--Callback functions that needs to know
	for id_, func in pairs(colorCallback) do
		func()
	end
end

function module:LoadOptions()

	--May be moved to the API if we need to.
	--List of localizedclass by englishClass
	local classL = {}
	for i = 1, GetNumClasses() do
		local localizedClass, englishClass = GetClassInfo(i)
		classL[englishClass] = localizedClass
	end

	local options = {
			Header = module:NewHeader(COLORS, 1),
			Class = module:NewGroup(L["Colors_Classes"], 3, nil, nil, {
				ClassHeader = module:NewHeader(L["Colors_Classes"], 2),
				DEATHKNIGHT = module:NewColor(classL["DEATHKNIGHT"], nil, 2, nil, "RefreshClassColors"),
				DEMONHUNTER = module:NewColor(classL["DEMONHUNTER"], nil, 3, nil, "RefreshClassColors"),
				DRUID = module:NewColor(classL["DRUID"], nil, 4, nil, "RefreshClassColors"),
				HUNTER = module:NewColor(classL["HUNTER"], nil, 5, nil, "RefreshClassColors"),
				MAGE = module:NewColor(classL["MAGE"], nil, 6, nil, "RefreshClassColors"),
				MONK = module:NewColor(classL["MONK"], nil, 7, nil, "RefreshClassColors"),
				PALADIN = module:NewColor(classL["PALADIN"], nil, 8, nil, "RefreshClassColors"),
				PRIEST = module:NewColor(classL["PRIEST"], nil, 9, nil, "RefreshClassColors"),
				ROGUE = module:NewColor(classL["ROGUE"], nil, 10, nil, "RefreshClassColors"),
				SHAMAN = module:NewColor(classL["SHAMAN"], nil, 11, nil, "RefreshClassColors"),
				WARLOCK = module:NewColor(classL["WARLOCK"], nil, 12, nil, "RefreshClassColors"),
				WARRIOR = module:NewColor(classL["WARRIOR"], nil, 13, nil, "RefreshClassColors"),
				--Note: Blizzard seems to be shifting toward using POWER_TYPE_NAME for the strings,
				--      but havent converted all of them to it yet.
				PrimaryHeader = module:NewHeader(L["Color_Primary"], 21),
				MANA = module:NewColor(POWER_TYPE_MANA, nil, 22),
				RAGE = module:NewColor(RAGE, nil, 23),
				FOCUS = module:NewColor(POWER_TYPE_FOCUS, nil, 24),
				ENERGY = module:NewColor(POWER_TYPE_ENERGY, nil, 25),
				RUNIC_POWER = module:NewColor(RUNIC_POWER, nil, 26),
				FURY = module:NewColor(POWER_TYPE_FURY, nil, 27),
				INSANITY = module:NewColor(POWER_TYPE_INSANITY, nil, 28),
				MAELSTROM = module:NewColor(POWER_TYPE_MAELSTROM, nil, 29),
				PAIN = module:NewColor(POWER_TYPE_PAIN, nil, 30),
				LUNAR_POWER = module:NewColor(POWER_TYPE_LUNAR_POWER, nil, 31),
				SecondaryHeader = module:NewHeader(L["Color_Secondary"], 40),
				COMBO_POINTS = module:NewColor(TUTORIAL_TITLE61_ROGUE, nil, 41),
				ARCANE_CHARGES = module:NewColor(POWER_TYPE_ARCANE_CHARGES, nil, 42),
				HOLY_POWER = module:NewColor(HOLY_POWER, nil, 43),
				SOUL_SHARDS = module:NewColor(SOUL_SHARDS_POWER, nil, 44),
				CHI = module:NewColor(CHI_POWER, nil, 45),
				RUNES = module:NewColor(RUNES, nil, 46),
			}),
			Factions = module:NewGroup(L["Colors_Factions"], 4, nil, nil, {
				Alliance = module:NewColor(FACTION_ALLIANCE, nil, 1),
				Horde = module:NewColor(FACTION_HORDE, nil, 2),
				Sanctuary = module:NewColor(SANCTUARY, nil, 3),
				Break = module:NewLineBreak(4),
				Hated = module:NewColor(STANDING_HATED, nil, 5),
				Hostile = module:NewColor(STANDING_HOSTILE, nil, 6),
				Unfriendly = module:NewColor(STANDING_UNFRIENDLY, nil, 7),
				Neutral = module:NewColor(STANDING_NEUTRAL, nil, 8),
				Friendly = module:NewColor(STANDING_FRIENDLY, nil, 9),
				Honored = module:NewColor(STANDING_HONORED, nil, 10),
				Revered = module:NewColor(STANDING_REVERED, nil, 11),
				Exalted = module:NewColor(STANDING_EXALTED, nil, 12),
			}),
			Misc = module:NewGroup(MISCELLANEOUS, 6, nil, nil, {
				GradientHeader = module:NewHeader(L["Colors_Gradients"], 1),
				Good = module:NewColor(L["Colors_Good"], nil, 2),
				Medium = module:NewColor(L["Colors_Medium"], nil, 3),
				Bad = module:NewColor(L["Colors_Bad"], nil, 4),
				-- Need much better names for these.
				LevelHeader = module:NewHeader(L["Color_Levels"], 5),
				DiffSkull = module:NewColor(L["Color_DiffSkull"], nil, 6, nil, nil, "full"),
				DiffHard = module:NewColor(L["Color_DiffHard"], nil, 7, nil, nil, "full"),
				DiffEqual = module:NewColor(L["Color_DiffEqual"], nil, 8, nil, nil, "full"),
				DiffEasy = module:NewColor(L["Color_DiffEasy"], nil, 9, nil, nil, "full"),
				DiffLow = module:NewColor(L["Color_DiffLow"], nil, 10, nil, nil, "full"),
			}),
			Advanced = module:NewAdvancedGroup({
				BGMult = module:NewSlider("Background Color Multiplier", nil, 4, 0.05, 1, 0.05, true, "Refresh"),
				ResetColors = module:NewExecute("Reset Colors", nil, 1, function() module.db:ResetProfile() end)
			}),
		}
	return options
end

------------------------------------------------------
-- / FRAMEWORK FUNCTIONS / --
------------------------------------------------------

function module:OnInitialize()
	LUI:RegisterModule(module)
end

function module:OnEnable()
	db = module:GetDB()
end
