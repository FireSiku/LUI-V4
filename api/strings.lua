--- Strings API mostly contains LUI methods, but moved to their own file for clarity.
-- This api module deal mostly in storing huge string table and functions that convert a string (or to a string)
-- @classmod strings

-- @type LUI

------------------------------------------------------
-- / SETUP AND LOCALS / --
------------------------------------------------------
local addonname, LUI = ...
local module = LUI:GetModule("API")
local element = module:NewModule("Strings")
local L = LUI.L

--local copies
local strsub, format, tonumber = strsub, format, tonumber

--constants
local LOCALIZED_CLASS_NAMES_FEMALE = LOCALIZED_CLASS_NAMES_FEMALE
local LOCALIZED_CLASS_NAMES_MALE = LOCALIZED_CLASS_NAMES_MALE

-- Default fonts used for specialized character sets. Currently here for documentation purposes.
-- TODO: Whenever a FontString may potentially get those characters, use an api call to detect those.
--           We could then detect those and replace the font with the correct font to keep support.
local UNIT_NAME_FONT_KOREAN = UNIT_NAME_FONT_KOREAN      -- Korean font
local UNIT_NAME_FONT_CHINESE = UNIT_NAME_FONT_CHINESE    -- Chinese/Japanese Font
local UNIT_NAME_FONT_CYRILLIC = UNIT_NAME_FONT_CYRILLIC  -- Russian Font

------------------------------------------------------
-- / MODULE FUNCTIONS / --
------------------------------------------------------

--- String Functions
-- @section stringfunc

-- Take RGBA values and turn them into hexstrings, usable for color codes and other uses.
function LUI:ColorToHex(r, g, b, a)
	if a then
		return format("%02x%02x%02x%02x", r*255, g*255, b*255, a*255)
	else
		return format("%02x%02x%02x", r*255, g*255, b*255)
	end
end

function LUI:HexToColor(str)
	local rhex, ghex, bhex, ahex = strsub(str, 1, 2), strsub(str, 3, 4), strsub(str, 5, 6)
	if strlen(str) > 6 then ahex = strsub(str, 7, 8) end
	local r = format("%.2f",tonumber(rhex, 16)/255)
	local g = format("%.2f",tonumber(ghex, 16)/255)
	local b = format("%.2f",tonumber(bhex, 16)/255)
	local a = format("%.2f",tonumber(ahex or 0, 16)/255)
	return r, g, b, (ahex) and a
end

-- Takes RGB values along with text to be colored.
function LUI:ColorToString(text, r, g, b)
	if not text then return "" end
	local colorString = LUI:ColorToHex(r, g, b)
	return format("|cff%s%s|r", colorString, text)
end

-- Takes a LUI Color Table and return a hex string, and vice versa.
local TypeStrings = { Individual = "I", Class = "C", Spec = "S", Theme1 = "A", Theme2 = "B" }
local ReverseTypes = { I = "Individual", C = "Class", S = "Spec", A = "Theme1", B = "Theme2" }
function LUI:LUIColorToString(color)
	-- TODO: Add Asserts to more API functions, possibly have custom assert function.
	assert(type(color) == "table", format("LUIColorToString, bad argument #1. expected table, got %s", type(color)))
	local hext = TypeStrings[color.t] or "X"
	if color.a then
		return format("%s%02x%02x%02x%02x", hext, color.r*255, color.g*255, color.b*255, color.a*255)
	else
		return format("%s%02x%02x%02x", hext, color.r*255, color.g*255, color.b*255)
	end
end

function LUI:StringToLUIColor(s)
	local ihex, rhex, ghex, bhex, ahex = strsub(s, 1, 1), strsub(s, 2, 3), strsub(s, 4, 5), strsub(s, 6, 7), strsub(s, 8, 9)
	local color = {}
	color.r = format("%.2f",tonumber(rhex, 16)/255)
	color.g = format("%.2f",tonumber(ghex, 16)/255)
	color.b = format("%.2f",tonumber(bhex, 16)/255)
	if ahex and tonumber(ahex, 16) then color.a = format("%.2f",tonumber(ahex, 16)/255) end
	color.t = ReverseTypes[ihex]
	return color
end

local localClassNames
--- Return a class token given a localized class name
-- @string className The localized name of one of the player classes.
-- @treturn string A locale-independant class token. (ie: "DEATHKNIGHT")
function LUI:GetTokenFromClassName(className)
	if not localClassNames then
		localClassNames = {}
		for class, localized in pairs(LOCALIZED_CLASS_NAMES_MALE) do
			localClassNames[localized] = class
		end
		for class, localized in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
			localClassNames[localized] = class
		end
	end
	return localClassNames[className]
end

------------------------------------------------------
-- / STRING TABLES / --
------------------------------------------------------
--@local here

LUI.DB_TYPES = {
	"profile",
	"global",
	"char",
	"realm",
	"class",
	"race",
	"faction",
	"factionrealm",
}

LUI.REACTION_NAMES = {
	"Hated",      -- 1
	"Hostile",    -- 2
	"Unfriendly", -- 3
	"Neutral",    -- 4
	"Friendly",   -- 5
	"Honored",    -- 6
	"Revered",    -- 7
	"Exalted",    -- 8
}

LUI.GENDERS = {
	UNKNOWN,	-- 1
	MALE,		-- 2
	FEMALE,		-- 3
}

LUI.FontFlags = {
	NONE = L["Flag_None"],
	OUTLINE = L["Flag_Outline"],
	THICKOUTLINE = L["Flag_ThickOutline"],
	MONOCHROME = L["Flag_Monochrome"],
}

LUI.Points = {
	CENTER = L["Point_Center"],
	TOP = L["Point_Top"],
	BOTTOM = L["Point_Bottom"],
	LEFT = L["Point_Left"],
	RIGHT = L["Point_Right"],
	TOPLEFT = L["Point_TopLeft"],
	TOPRIGHT = L["Point_TopRight"],
	BOTTOMLEFT = L["Point_BottomLeft"],
	BOTTOMRIGHT = L["Point_BottomRight"],
}

LUI.Corners = {
	TOPLEFT = L["Point_TopLeft"],
	TOPRIGHT = L["Point_TopRight"],
	BOTTOMLEFT = L["Point_BottomLeft"],
	BOTTOMRIGHT = L["Point_BottomRight"],
}
LUI.Sides = {
	TOP = L["Point_Top"],
	BOTTOM = L["Point_Bottom"],
	LEFT = L["Point_Left"],
	RIGHT = L["Point_Right"],
}

LUI.Opposites = {
	-- Sides
	TOP = "BOTTOM",
	BOTTOM = "TOP",
	LEFT = "RIGHT",
	RIGHT = "LEFT",
	-- Corners
	TOPLEFT = "BOTTOMRIGHT",
	TOPRIGHT = "BOTTOMLEFT",
	BOTTOMLEFT = "TOPRIGHT",
	BOTTOMRIGHT = "TOPLEFT",
}

LUI.ColorTypes = {
	Individual = L["Color_Individual"],
	Theme = L["Color_Theme"],
	Class = L["Color_Class"],
}

-- As found in the Colors module.
LUI.PowerTypes = {
	"MANA",
	"RAGE",
	"FOCUS",
	"ENERGY",
	"RUNIC_POWER",
	"RUNES",
	"FUEL",
	"COMBO_POINTS",
	"ARCANE_CHARGES",
	"HOLY_POWER",
	"SOUL_SHARDS",
	"CHI",
	"SHADOW_ORB",
	"BURNING_EMBERS",
	"DEMONIC_FURY",
	"BLOOD_RUNES",
	"UNHOLY_RUNES",
	"FROST_RUNES",
	"DEATH_RUNES",
	"LUNAR_ECLIPSE",
	"SOLAR_ECLIPSE",
}

--CommonStrings should go lower-lower, lower-upper, upper-lower, upper-upper case in order.
--Try not to have different cases on the same group as to avoid headaches later on.
--It should go without saying that none of the strings in this table should be localized.
--Only flip the table when that information is needed.
function LUI:GenerateCommonStrings()
	LUI.CommonStrings = {
		--1                        2                          3                          4
		Au = "author",
		aS = "alwaysShow",         aT = "alwaysShowText",
		Al = "Alliance", 
		bt = "Bottom",
		Ba = "Bags",               Bc = "Broadcast",          Bd = "Bad",                Bk = "Bank",
		bS = "BugSack",            bT = "backgroundTex",      brS = "borderSize",        brT = "borderTex",
		BD = "Border",             BG = "Background",         BL = "BOTTOMLEFT",         BR = "BOTTOMRIGHT",
		BT = "BOTTOM",             BZ = "Blizzard Tooltip",
		cP = "coordPrecision",
		Cl = "Class",              Cu = "Currency",
		cS = "coloredSymbols",
		CL = "Color",              CP = "Control Panel",      CR = "Cursor",             CS = "Colors",
		ds = "desc",
		De = "DiffEasy",           Dh = "DiffHard",           Dk = "Death Knight",       Dl = "DiffLow",
		Dq = "DiffEqual",          Dr = "Druid",              Ds = "Dualspec",           Du = "Durability",
		DK = "DEATHKNIGHT",        DR = "DRUID",              DS = "DiffSkull",
		Ex = "Exalted", 
		EN = "Enable",
		Fn = "Fonts",              Fr = "Friends",
		Gn = "General",            Go = "Good",               Gt = "GameText",           Gu = "Guild",
		hA = "hideApp",            hC = "hideMissingCoord",   hN = "hideNotes",          hP = "hidePVP",
		hU = "hideCombatUnit",
		Ha = "Hatred",             Hi = "Hint",               Hn = "Honored",            Ho = "Hostile",
		Hc = "hideCombat",         Hu = "Hunter",
		HO = "Horde",              HP = "Health",             HU = "HUNTER",
		iD = "instanceDifficulty", 
		It = "Infotext",
		iT = "Infotip",
		IS = "Insets",             IQ = "ItemQuality",
		lt = "Left",
		lS = "lootSpec",
		Lo = "Locked",
		LG = "LUI_Gradient",       LM = "LUI_Minimalist",     LT = "LEFT",
		mt = "meta",
		Ma = "Mage",               Md = "Medium",             Me = "Memory",             Mn = "Minimap",
		Mo = "Monk",
		MA = "MAGE",               MC = "MONOCHROME",         MG = "MyGuild",            MO = "MONK",
		na = "name",
		Ne = "Neutral",            No = "Note",
		NA = "Name",               NO = "NONE",
		OF = "OfficerNote",        OL = "OUTLINE",
		pr = "prototype",
		Pa = "Paladin",            Pr = "Priest",             Ps = "Position",
		PA = "PALADIN",            PR = "PRIEST",             PT = "Point",
		rt = "Right",
		Re = "Revered",            Ro = "Rogue",
		RO = "ROGUE",              RP = "RelativePoint",      RT = "RIGHT",
		sC = "showCombat",         sH = "Shaman",             sO = "showCoord",          
		sR = "showRealm",          sS = "showSavedRaids",     sT = "showTextures",       sU = "showUF",
		sW = "showWorldBosses", 
		Sa = "Sanctuary",          Sc = "Scale",
		SH = "SHAMAN",             SM = "Stripped_medium",    SZ = "Size",               SC = "showCopper",
		ST = "showTotal",          SW = "showWorldPVP",
		tp = "Top",
		Ti = "Title",
		TA = "Tapped",             TL = "TOPLEFT",            TP = "TOP",
		TR = "TOPRIGHT",           TO = "THICKOUTLINE",       TT = "Tooltip",            TX = "Texture",
		uB = "useBlizzard",
		Un = "Unfriendly", 
		UI = "UI Elements",
		vb = "vibroceb",           vn = "vibrocen",
		Wa = "Warrior",            Wl = "Warlock",
		WA = "WARRIOR",            WL = "WARLOCK",
		Zo = "Zone",
		
		--Need to redo CommonString to use 3 letter for most options otherwise will run out of letters.
		aa = "hideRealm", ab = "Rank", ac = "Flag", ad = "Panels", ae = "Clock",
		af = "Friendly", ag = "Hated", ah = "Auras", ai = "Debuffs", aj = "HorizontalSpacing",
		ak = "ReverseSort", al = "NumRows", am = "SortMethod", an = "Time", ao = "Anchor", 
		ap = "VerticalSpacing", aq = "AurasPerRow", ar = "BuffsCount", as = "BuffsDur", at = "DebuffsDur",
		au = "DebuffsCount", av = "Disease", aw = "Curse", ax = "Poison", ay = "Magic", az = "None",
		aA = "BackgroundTexture", aB = "Spacing", aC = "ShowNew", aD = "Textures", aE = "BackgroundMenu",
		aF = "Gold", aG = "MOTD", aH = "FPS", aI = "Scale", aJ = "BorderSize",
		aK = "BorderTexture", aL = "Professions", aM  = "RowSize", aN = "Search", aO = "Lock",
		aP = "BagBar", aQ = "BagNewline", aR = "AvantGarge_LT_Medium", 
		aU = "Buffs", aV = "alwaysShowText", aW = "showSex", aX = "Blizzard Dialog Background Dark", aY = "healthBar", aZ = "hideUF",
		Aa = "hideCombatSkills",  Ab = "ShowQuest", Ac = "Micromenu",
		
	}
	
	LUI.ReverseStrings = {}
	for k, v in pairs(LUI.CommonStrings) do
		LUI.ReverseStrings[v] = k
	end
	
end