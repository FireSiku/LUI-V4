-- ####################################################################################################################
-- ##### Setup and Locals #############################################################################################
-- ####################################################################################################################

local _, LUI = ...
local module = LUI:GetModule("Unitframes", "AceHook-3.0")
local L = LUI.L

-- Note: As opposed to regular coding style for defaults tables
-- the tables for every unit must be in lowercase similar to the unitID token

-- ####################################################################################################################
-- ##### Default Settings #############################################################################################
-- ####################################################################################################################

module.defaults = {
	profile = {

-- ####################################################################################################################
-- ##### Settings: General ############################################################################################
-- ####################################################################################################################
        Settings = {
        },
		Colors = {
			Border =       { r = 0,    g = 0,    b = 0,    a = 1,    },
			Background =   { r = 0,    g = 0,    b = 0,    a = 1,    },
			HealPredict =  { r = 0,    g = 0.5,  b = 0,    a = 0.25, },
			Absorb =       { r = 0,    g = 1,    b = 0,    a = 0.5,  },
			HealthBar =    { r = 0.25, g = 0.25, b = 0.25, },
			PowerBar =     { r = 0.8,  g = 0.8,  b = 0.8,  },
		},

-- ####################################################################################################################
-- ##### Settings: Castbar ############################################################################################
-- ####################################################################################################################
        CastBar = {

            Colors = {
                Name         = { r = 0.9 , g = 0.9 , b = 0.9 , },
                Time         = { r = 0.9 , g = 0.9 , b = 0.9 , },
                DefaultBar   = { r = 0.13, g = 0.59, b = 1   , a = 0.68, },
                DefaultBG    = { r = 0.15, g = 0.15, b = 0.15, a = 0.67, },
                Latency      = { r = 0.11, g = 0.11, b = 0.11, a = 0.74, },
                Border       = { r = 0   , g = 0   , b = 0   , a = 0.7 , },
                ShieldBar    = { r = 0.13, g = 0.59, b = 1   , a = 0.68, },
                ShieldBorder = { r = 0.13, g = 0.59, b = 1   , a = 0.68, },
                player       = { r = 0.13, g = 0.59, b = 1   , a = 0.68, t = "Individual", },
                target       = { r = 0.13, g = 0.59, b = 1   , a = 0.68, t = "Individual", },
                focus        = { r = 0.13, g = 0.59, b = 1   , a = 0.68, t = "Individual", },
                pet          = { r = 0.13, g = 0.59, b = 1   , a = 0.68, t = "Individual", },
                party        = { r = 0.13, g = 0.59, b = 1   , a = 0.68, t = "Individual", },
                boss         = { r = 0.13, g = 0.59, b = 1   , a = 0.68, t = "Individual", },
                arena        = { r = 0.13, g = 0.59, b = 1   , a = 0.68, t = "Individual", },
            },

            ["**"] = {
                Fonts = {
                    SpellText = { Name = "NotoSans-SCB", Size = 12, Flag = "OUTLINE", },
                    TimeText =  { Name = "NotoSans-SCB", Size = 12, Flag = "OUTLINE", },
                },
                General = {
                    Enable = true,
                    Height = 20,
                    Width = 100,
                    X = 0,
                    Y = 0,
                    Point = "BOTTOM",
                    Texture = "Gradient",
                    TextureBG = "Minimalist",
                    Icon = false,
                    Shield = true,
                },
                Text = {
                    Name = {
                        Enable = true,
                        OffsetX = 5,
                        OffsetY = 1,
                    },
                    Time = {
                        Enable = true,
                        ShowMax = true,
                        OffsetX = -5,
                        OffsetY = 1,
                    },
                },
                Border = {
                    Texture = "glow",
                    Thickness = 4,
                    Inset = { left = 3, right = 3, top = 3, bottom = 3,},
                },

                Shield = {
                    Enable = true,
                    Text = true,
                    Border = false,
                    Texture = "glow",
                    Thickness = 4,
                    Inset = { left = 3, right = 3, top = 3, bottom = 3,},
                },
            },
            player = {
                General = {
                    Height = 33,
                    Width = 360,
                    X = 13,
                    Y = 155,
                    Latency = true,
                    Icon = true,
                },
                Text = {
                    Name = {
                        Size = 15,
                    },
                },
            },
            target = {
                General = {
                    Height = 33,
                    Width = 360,
                    X = 13,
                    Y = 205,
                    Icon = true,
                },
                Text = {
                    Name = {
                        Size = 15,
                    },
                },
            },
            focus = {
                General = {  X = 0, Y = 70, },
            },
            pet = {
                General = { X = 0, Y = 80, Enable = false, },
            },
            party = {
                General = { X = 10, Y = 0, },
            },
            boss = {
                General = { X = -140, Y = -35, Enable = false, },
            },
            arena = {
                General = { X = -10, Y = 0, },
            },
        },

-- ####################################################################################################################
-- ##### Settings: Template ############################################################################################
-- ####################################################################################################################
        Units = {
            ["**"] = {
                Enable = true,
                X = 0,
                Y = 0,
                Point = "CENTER",
                Scale = 1,
                Colors = {
                    Border        = {  r = 0   , g = 0   , b = 0   , a = 1           , },
                    Background    = {  r = 0   , g = 0   , b = 0   , a = 1           , },
                    HealthBar     = {  r = 0.25, g = 0.25, b = 0.25, t = "Individual", },
                    PowerBar      = {  r = 0.8 , g = 0.8 , b = 0.8 , t = "Class"     , },
                    NameText      = {  r = 1   , g = 1   , b = 1   , t = "Class"     , },
                    HealthText    = {  r = 1   , g = 1   , b = 1   , t = "Individual", },
                    PowerText     = {  r = 1   , g = 1   , b = 1   , t = "Class"     , },
                    HealthPercent = {  r = 1   , g = 1   , b = 1   , t = "Individual", },
                    PowerPercent  = {  r = 1   , g = 1   , b = 1   , t = "Individual", },
                    HealthMissing = {  r = 1   , g = 1   , b = 1   , t = "Individual", },
                    PowerMissing  = {  r = 1   , g = 1   , b = 1   , t = "Individual", },
                },
                Fonts = {
                    NameText      = { Name = "NotoSans-SCB", Size = 18, Flag = "OUTLINE", },
                    HealthText    = { Name = "NotoSans-SCB", Size = 16, Flag = "OUTLINE", },
                    PowerText     = { Name = "NotoSans-SCB", Size = 14, Flag = "OUTLINE", },
                    HealthPercent = { Name = "NotoSans-SCB", Size = 14, Flag = "OUTLINE", },
                    PowerPercent  = { Name = "NotoSans-SCB", Size = 12, Flag = "OUTLINE", },
                    HealthMissing = { Name = "NotoSans-SCB", Size = 16, Flag = "OUTLINE", },
                    PowerMissing  = { Name = "NotoSans-SCB", Size = 14, Flag = "OUTLINE", },
                    CombatText    = { Name = "NotoSans-SCB", Size = 20, Flag = "OUTLINE", },
                },
                LootmasterIcon = { Enable = false, Size = 15, X = 16 , Y = 0, Point = "TOPLEFT" , },
                LeaderIcon     = { Enable = false, Size = 17, X = 0  , Y = 0, Point = "TOPLEFT" , },
                RoleIcon       = { Enable = false, Size = 22, X = 15 , Y = 0, Point = "TOPRIGHT", },
                RaidIcon       = { Enable = false, Size = 55, X = 0  , Y = 0, Point = "CENTER"  , },
                PvPIcon        = { Enable = false, Size = 35, X = -12, Y = 0, Point = "TOPLEFT" , },
                Backdrop = {
                    Texture = "Solid",
                    EdgeFile = "glow",
                    EdgeSize = 5,
                },
                Portrait = {
                    Enable = false,
                    Height = 43,
                    Width = 90,
                    X = 0,
                    Y = 0,
                    Alpha = 1,
                },
                HealthBar = {
                    Height = 24,
                    Width = 130,
                    Texture = "Gradient",
                    TextureBG = "Gradient",
                    BGAlpha = 1,
                    BGInvert = false,
                    Smooth = true,
                    Tapping = true,
                },
                PowerBar = {
                    Enable = true,
                    Height = 10,
                    Width = 250,
                    IsWidthRelative = false,
                    IsHeightRelative = false,
                    RelativeWidth = 1,
                    RelativeHeight = 0.33,
                    X = 0,
                    Y = -2,
                    Texture = "Minimalist",
                    TextureBG = "Minimalist",
                    BGAlpha = 1,
                    BGInvert = false,
                    Smooth = true,
                },
                AbsorbBar = {
                    Enable = true,
                    Height = 10,
                    Width = 250,
                    X = 0,
                    Y = -2,
                    Texture = "Minimalist",
                    TextureBG = "Minimalist",
                    BGAlpha = 1,
                    BGInvert = false,
                    Smooth = true,
                },
                Buffs = {
                    Enable = true,
                    ColorByType = false,
                    PlayerOnly = false,
                    IncludePet = false,
                    AuraTimer = false,
                    DisableCooldown = false,
                    CooldownReverse = true,
                    X = -0.5,
                    Y = 30,
                    InitialAnchor = "TOPLEFT",
                    GrowthY = "UP",
                    GrowthX = "RIGHT",
                    Size = 26,
                    Spacing = 2,
                    Num = 36,
                },
                Debuffs = {
                    Enable = true,
                    ColorByType = false,
                    PlayerOnly = false,
                    IncludePet = false,
                    FadeOthers = true,
                    AuraTimer = false,
                    DisableCooldown = false,
                    CooldownReverse = true,
                    X = -0.5,
                    Y = 60,
                    InitialAnchor = "TOPRIGHT",
                    GrowthY = "UP",
                    GrowthX = "LEFT",
                    Size = 26,
                    Spacing = 2,
                    Num = 36,
                },
                NameText = {
                    Enable = true,
                    X = 0,
                    Y = 0,
                    Point = "CENTER",
                    RelativePoint = "CENTER",
                    Format = "Name",
                    Length = "Medium",
                    ColorNameByClass = false,
                    ColorClassByClass = false,
                    ColorLevelByDifficulty = false,
                    ShowClassification = false,
                    ShortClassification = false,
                },
                HealthText = {
                    Enable = false,
                    X = 0,
                    Y = -43,
                    ShowAlways = false,
                    Point = "BOTTOMLEFT",
                    RelativePoint = "BOTTOMRIGHT",
                    Format = "Absolut Short",
                    ShowDead = false,
                },
                PowerText = {
                    Enable = false,
                    X = 0,
                    Y = -66,
                    ShowFull = true,
                    ShowEmpty = true,
                    Point = "BOTTOMLEFT",
                    RelativePoint = "BOTTOMRIGHT",
                    Format = "Absolut Short",
                },
                HealthPercent = {
                    Enable = false,
                    X = 0,
                    Y = 0,
                    ShowAlways = false,
                    Point = "CENTER",
                    RelativePoint = "CENTER",
                    ShowDead = true,
                },
                PowerPercent = {
                    Enable = false,
                    X = 0,
                    Y = 0,
                    ShowFull = false,
                    ShowEmpty = false,
                    Point = "CENTER",
                    RelativePoint = "CENTER",
                },
                HealthMissing = {
                    Enable = false,
                    X = 0,
                    Y = 0,
                    ShortValue = true,
                    ShowAlways = false,
                    Point = "RIGHT",
                    RelativePoint = "RIGHT",
                },
                PowerMissing = {
                    Enable = false,
                    X = 0,
                    Y = 0,
                    ShortValue = true,
                    ShowFull = false,
                    ShowEmpty = false,
                    Point = "RIGHT",
                    RelativePoint = "RIGHT",
                },
                CombatText = {
                    Enable = false,
                    Point = "CENTER",
                    RelativePoint = "BOTTOM",
                    X = 0,
                    Y = 0,
                    ShowDamage = true,
                    ShowHeal = true,
                    ShowImmune = true,
                    ShowEnergize = true,
                    ShowOther = true,
                    MaxAlpha = 0.6,
                },
            },
-- ####################################################################################################################
-- ##### Settings: Player #############################################################################################
-- ####################################################################################################################
            player = {
                Enable = true,
                X = -200,
                Y = -200,
                Point = "CENTER",
                Colors = {
                    PvPTimeText   = { r = 1  , g = 0.1, b = 0.1, a = 1     , },
                    AltManaBar    = { r = 0.8, g = 0.8, b = 0.8, t = "Type", },
                    ClassPowerBar = { r = 1  , g = 1  , b = 1  , t = "Type", },
                },
                Fonts = {
                    PvPTime = { Name = "NotoSans-SCB", Size = 12, Flag = "OUTLINE", },
                },
                CombatIcon  = { Enable = false, Size = 27, X = -15, Y = -30, Point = "BOTTOMLEFT", },
                RestingIcon = { Enable = false, Size = 27, X = -12, Y = 13,  Point = "TOPLEFT",    },
                HealthBar = {
                    Height = 30,
                    Width = 250,
                },
                AltManaBar = {
                    Enable = true,
                    OverPower = true,
                    Height = 10,
                    Width = 250,
                    IsWidthRelative = false,
                    IsHeightRelative = false,
                    RelativeWidth = 1,
                    RelativeHeight = 0.33,
                    X = 0,
                    Y = -44,
                    Texture = "Minimalist",
                    TextureBG = "Minimalist",
                    BGAlpha = 1,
                    Smooth = true,
                },
                RunesBar = {
                    Enable = true,
                    X = 0,
                    Y = 0.5,
                    Height = 8,
                    Width = 249,
                    Texture = "Minimalist",
                    Padding = 2,
                    Lock = true,
                },
                ClassPowerBar = {
                    Enable = true,
                    X = 0,
                    Y = 2,
                    Height = 8,
                    Width = 250,
                    IsWidthRelative = false,
                    IsHeightRelative = false,
                    RelativeWidth = 1,
                    RelativeHeight = 0.33,
                    Texture = "Minimalist",
                    TextureBG = "Minimalist",
                    Padding = 2,
                    Lock = true,
                },
                Buffs = {
                    Enable = false,
                    InitialAnchor = "BOTTOMRIGHT",
                    GrowthY = "DOWN",
                    GrowthX = "LEFT",
                    Num = 8,
                },
                Debuffs = {
                    Enable = false,
                    FadeOthers = false,
                    InitialAnchor = "BOTTOMLEFT",
                    GrowthY = "DOWN",
                    GrowthX = "RIGHT",
                },
                NameText = {
                    Enable = false,
                    X = 0,
                },
                PowerText = {
                    Point = "BOTTOMRIGHT",
                    RelativePoint = "BOTTOMRIGHT",
                },
                PvPTimeText = {
                    Enable = true,
                    X = 20,
                    Y = 5,
                },
            },

-- ####################################################################################################################
-- ##### Settings: Target #############################################################################################
-- ####################################################################################################################
            target = {
                X = 200,
                Y = -200,
                HealthBar = {
                    Height = 30,
                    Width = 250,
                },
                NameText = {
                    X = 5,
                    Point = "BOTTOMLEFT",
                    RelativePoint = "BOTTOMRIGHT",
                    Format = "Level + Name",
                    ColorNameByClass = true,
                    ColorClassByClass = true,
                    ColorLevelByDifficulty = true,
                    ShowClassification = true,
                },
                HealthText = {
                    Enable = true,
                    Y = -31,
                    ShowAlways = true,
                    RelativePoint = "BOTTOMLEFT",
                    Format = "Standard",
                },
                PowerText = {
                    Enable = true,
                    Y = -51,
                    RelativePoint = "BOTTOMLEFT",
                    Format = "Standard",
                },
                HealthPercent = {
                    Enable = true,
                    Y = 6,
                },
            },

            targettarget = {
                Enable = true,
                X = 435,
                Y = -250,
                HealthBar = {
                    Width = 200,
                },
            },
            
            targettargettarget = {
                Enable = false,
                X = 465,
                Y = -285,
                HealthBar = {
                    Width = 200,
                },
            },

-- ####################################################################################################################
-- ##### Settings: Focus ##############################################################################################
-- ####################################################################################################################
            
            focus = {
                Enable = true,
                X = -435,
                Y = -250,
                HealthBar = {
                    Width = 200,
                },
            },

            focustarget = {
                Enable = false,
                X = -465,
                Y = -285,
                HealthBar = {
                    Width = 200,
                },
            },

-- ####################################################################################################################
-- ##### Settings: Pets ###############################################################################################
-- ####################################################################################################################

            pet = {
                Enable = true,
                X = 0,
                Y = -200,
            },

            pettarget = {
                Enable = true,
                X = 0,
                Y = -160,
            },
            
-- ####################################################################################################################
-- ##### Settings: Party/Raid #########################################################################################
-- ####################################################################################################################

            raid = {
                Enable = true,
                UseBlizzard = false,
                X = -28,
                Y = 41,
                Point = "BOTTOMRIGHT",
                Padding = 4,
                GroupPadding = 4,
                HealthBar = {
                    Height = 33,
                    Width = 78,
                },
            },

            party = {
                Enable = true,
                UseBlizzard = false,
                X = 150,
                Y = 100,
                Point = "LEFT",
                GrowDirection = "BOTTOM",
                Padding = 50,
                ShowPlayer = false,
                ShowInRaid = false,
                ShowInRealParty = false,
                RangeFade = true,
                HealthBar = {
                    Height = 30,
                    Width = 200,
                },
            },

            partypet = {
                Enable = true,
                X = -15,
                Y = -10,
            },

            partytarget = {
                Enable = true,
                X = 8,
                Y = -8,
            },

-- ####################################################################################################################
-- ##### Settings: Tanks ##############################################################################################
-- ####################################################################################################################
            maintank = {
                Enable = false,
                X = -10,
                Y = 350,
                Point = "BOTTOMRIGHT",
                GrowDirection = "BOTTOM",
                Padding = 6,
            },

            maintanktarget = {
                Enable = true,
                X = -8,
                Y = 0,
            },

            maintanktargettarget = {
                Enable = false,
                X = -146,
                Y = 0,
            },

-- ####################################################################################################################
-- ##### Settings: Boss ###############################################################################################
-- ####################################################################################################################

            boss = {
                Enable = true,
                UseBlizzard = false,
                X = -25,
                Y = -250,
                Point = "TOPRIGHT",
                GrowDirection = "BOTTOM",
                Padding = 6,
            },

            bosstarget = {
                Enable = false,
                X = -8,
                Y = -8,
            },

-- ####################################################################################################################
-- ##### Settings: Arena ##############################################################################################
-- ####################################################################################################################
            arena = {
                Enable = true,
                UseBlizzard = false,
                X = -150,
                Y = 100,
                GrowDirection = "BOTTOM",
                Padding = 50,
            },

            arenapet = {
                Enable = true,
                X = 15,
                Y = -10,
            },

            arenatarget = {
                Enable = true,
                X = -8,
                Y = -8,
            },
-- ####################################################################################################################
-- ##### Settings: End of User functions. #############################################################################
-- ####################################################################################################################
        },
    },
}
