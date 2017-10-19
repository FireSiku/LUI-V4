------------------------------------------------------
-- / SETUP AND LOCALS / --
------------------------------------------------------
local addonname, LUI = ...
local module = LUI:GetModule("Unitframes", "AceHook-3.0")
local L = LUI.L
local db

-- Note: As opposed to regular coding style for defaults tables, the tables for every unit must be in lowercase similar to the unitID token

module.defaults = {
	profile = {

------------------------------------------------------
-- / GENERAL SETTINGS / --
------------------------------------------------------
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

------------------------------------------------------
-- / CASTBAR SETTINGS / --
------------------------------------------------------
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

            -- Player 
            player = {
                General = {
                    Enable = true,
                    Height = 33,
                    Width = 360,
                    X = 13,
                    Y = 155,
                    Point = "BOTTOM",
                    Texture = "LUI_Gradient",
                    TextureBG = "LUI_Minimalist",
                    Latency = true,
                    Icon = true,
                    Shield = true,
                },
                Text = {
                    Name = {
                        Enable = true,
                        Font = "neuropol",
                        Size = 15,
                        OffsetX = 5,
                        OffsetY = 1,
                    },
                    Time = {
                        Enable = true,
                        ShowMax = true,
                        Font = "neuropol",
                        Size = 13,
                        OffsetX = -5,
                        OffsetY = 1,
                    },
                },
                Border = {
                    Texture = "glow",
                    Thickness = 4,
                    Inset = {    left = 3,    right = 3,    top = 3,    bottom = 3,},
                },
    
                Shield = {
                    Enable = true,
                    Text = true,
                    Border = false,
                    Texture = "glow",
                    Thickness = 4,
                    Inset = {    left = 3,    right = 3,    top = 3,    bottom = 3,},
                },
            },

            -- Target
            target = {
                General = {
                    Enable = true,
                    Height = 33,
                    Width = 360,
                    X = 13,
                    Y = 205,
                    Point = "BOTTOM",
                    Texture = "LUI_Gradient",
                    TextureBG = "LUI_Minimalist",
                    Icon = true,
                    Shield = true,
                },
                Text = {
                    Name = {
                        Enable = true,
                        Font = "neuropol",
                        Size = 15,
                        OffsetX = 5,
                        OffsetY = 1,
                    },
                    Time = {
                        Enable = true,
                        ShowMax = true,
                        Font = "neuropol",
                        Size = 13,
                        OffsetX = -5,
                        OffsetY = 1,
                    },
                },
                Border = {
                    Texture = "glow",
                    Thickness = 4,
                    Inset = {    left = 3,    right = 3,    top = 3,    bottom = 3,},
                },
                Shield = {
                    Enable = true,
                    Text = true,
                    Border = false,
                    Texture = "glow",
                    Thickness = 4,
                    Inset = {    left = 3,    right = 3,    top = 3,    bottom = 3,},
                },
            },

            -- Focus
            focus = {
                General = {
                    Enable = true,
                    Height = 26,
                    Width = 200,
                    X = 0,
                    Y = 70,
                    Texture = "LUI_Gradient",
                    TextureBG = "LUI_Minimalist",
                    Icon = false,
                    Shield = true,
                },
                Text = {
                    Name = {
                        Enable = true,
                        Font = "neuropol",
                        Size = 13,
                        OffsetX = 5,
                        OffsetY = 1,
                    },
                    Time = {
                        Enable = true,
                        ShowMax = false,
                        Font = "neuropol",
                        Size = 13,
                        OffsetX = -5,
                        OffsetY = 1,
                    },
                },
                Border = {
                    Texture = "glow",
                    Thickness = 4,
                    Inset = {    left = 3,    right = 3,    top = 3,    bottom = 3,},
                },
                Shield = {
                    Enable = true,
                    Text = true,
                    Border = false,
                    Texture = "glow",
                    Thickness = 4,
                    Inset = {    left = 3,    right = 3,    top = 3,    bottom = 3,},
                },
            },

            --Pet
            pet = {
                General = {
                    Enable = false,
                    UseBlizzard = true,
                    Height = 26,
                    Width = 130,
                    X = 0,
                    Y = 80,
                    Texture = "LUI_Gradient",
                    TextureBG = "LUI_Minimalist",
                    Icon = false,
                    Shield = true,
                },
                Text = {
                    Name = {
                        Enable = true,
                        Font = "neuropol",
                        Size = 13,
                        OffsetX = 5,
                        OffsetY = 1,
                    },
                    Time = {
                        Enable = true,
                        ShowMax = false,
                        Font = "neuropol",
                        Size = 13,
                        OffsetX = -5,
                        OffsetY = 1,
                    },
                },
                Border = {
                    Texture = "glow",
                    Thickness = 4,
                    Inset = {    left = 3,    right = 3,    top = 3,    bottom = 3,},
                },
                Shield = {
                    Enable = true,
                    Text = true,
                    Border = false,
                    Texture = "glow",
                    Thickness = 4,
                    Inset = {    left = 3,    right = 3,    top = 3,    bottom = 3,},
                },
            },

            --Party
            party = {
                General = {
                    Enable = true,
                    Height = 20,
                    Width = 100,
                    X = 10,
                    Y = 0,
                    Texture = "LUI_Gradient",
                    TextureBG = "LUI_Minimalist",
                    Icon = false,
                    Shield = true,
                },
                Text = {
                    Name = {
                        Enable = true,
                        Font = "neuropol",
                        Size = 13,
                        OffsetX = 5,
                        OffsetY = 1,
                    },
                    Time = {
                        Enable = false,
                        ShowMax = true,
                        Font = "neuropol",
                        Size = 13,
                        OffsetX = -5,
                        OffsetY = 1,
                    },
                },
                Border = {
                    Texture = "glow",
                    Thickness = 4,
                    Inset = {    left = 3,    right = 3,    top = 3,    bottom = 3,},
                },
                Shield = {
                    Enable = true,
                    Text = true,
                    Border = false,
                    Texture = "glow",
                    Thickness = 4,
                    Inset = {    left = 3,    right = 3,    top = 3,    bottom = 3,},
                },
            },

            -- Boss
            boss = {
                General = {
                    Enable = false,
                    Height = 20,
                    Width = 140,
                    X = -140,
                    Y = -35,
                    Texture = "LUI_Gradient",
                    TextureBG = "LUI_Minimalist",
                    Icon = false,
                    Shield = true,
                },
                Text = {
                    Name = {
                        Enable = true,
                        Font = "neuropol",
                        Size = 13,
                        OffsetX = 5,
                        OffsetY = 1,
                    },
                    Time = {
                        Enable = false,
                        ShowMax = true,
                        Font = "neuropol",
                        Size = 13,
                        OffsetX = -5,
                        OffsetY = 1,
                    },
                },
                Border = {
                    Texture = "glow",
                    Thickness = 4,
                    Inset = {    left = 3,    right = 3,    top = 3,    bottom = 3,},
                },
                Shield = {
                    Enable = true,
                    Text = true,
                    Border = false,
                    Texture = "glow",
                    Thickness = 4,
                    Inset = {    left = 3,    right = 3,    top = 3,    bottom = 3,},
                },
            },

            -- Arena
            arena = {
                General = {
                    Enable = true,
                    Height = 20,
                    Width = 100,
                    X = -10,
                    Y = 0,
                    Texture = "LUI_Gradient",
                    TextureBG = "LUI_Minimalist",
                    Icon = false,
                    Shield = true,
                },
                Text = {
                    Name = {
                        Enable = true,
                        Font = "neuropol",
                        Size = 13,
                        OffsetX = 5,
                        OffsetY = 1,
                    },
                    Time = {
                        Enable = false,
                        ShowMax = true,
                        Font = "neuropol",
                        Size = 13,
                        OffsetX = -5,
                        OffsetY = 1,
                    },
                },
                Border = {
                    Texture = "glow",
                    Thickness = 4,
                    Inset = {    left = 3,    right = 3,    top = 3,    bottom = 3,},
                },
                Shield = {
                    Enable = true,
                    Text = true,
                    Border = false,
                    Texture = "glow",
                    Thickness = 4,
                    Inset = {    left = 3,    right = 3,    top = 3,    bottom = 3,},
                },
            },
        },

    ------------------------------------------------------
    -- / TEMPLATE SETTINGS / --
    ------------------------------------------------------
        Units = {
            ["**"] = {
                Enable = true,
                Height = 24,
                Width = 130,
                X = 0,
                Y = 0,
                Point = "CENTER",
                Scale = 1,
                Colors = {
                    Border        = {  r = 0,     g = 0,     b = 0,      a = 1,            },
                    Background    = {  r = 0,     g = 0,     b = 0,      a = 1,            },
                    HealthBar     = {  r = 0.25,  g = 0.25,  b = 0.25,   t = "Individual", },
                    PowerBar      = {  r = 0.8,   g = 0.8,   b = 0.8,    t = "Class",      },
                    NameText      = {  r = 1,     g = 1,     b = 1,      t = "Class",      },
                    HealthText    = {  r = 1,     g = 1,     b = 1,      t = "Individual", },
                    PowerText     = {  r = 1,     g = 1,     b = 1,      t = "Class",      },
                    HealthPercent = {  r = 1,     g = 1,     b = 1,      t = "Individual", },
                    PowerPercent  = {  r = 1,     g = 1,     b = 1,      t = "Individual", },
                    HealthMiss    = {  r = 1,     g = 1,     b = 1,      t = "Individual", },
                    PowerMiss     = {  r = 1,     g = 1,     b = 1,      t = "Individual", },
                },
                Fonts = {
                    NameText      = { Name = "Prototype", Size = 18, Flag = "NONE", }, 
                    HealthText    = { Name = "Prototype", Size = 16, Flag = "NONE", }, 
                    PowerText     = { Name = "Prototype", Size = 14, Flag = "NONE", }, 
                    HealthPercent = { Name = "Prototype", Size = 14, Flag = "NONE", }, 
                    PowerPercent  = { Name = "Prototype", Size = 12, Flag = "NONE", }, 
                    HealthMiss    = { Name = "Prototype", Size = 16, Flag = "NONE", }, 
                    PowerMiss     = { Name = "Prototype", Size = 14, Flag = "NONE", }, 
                    Combat        = { Name = "Prototype", Size = 20, Flag = "NONE", }, 
                },
                Border = {
                    Aggro = false,
                    EdgeFile = "glow",
                    EdgeSize = 5,
                    Insets = { Left = 3, Right = 3, Top = 3, Bottom = 3, }, 
                },
                Backdrop = {
                    Texture = "Blizzard Tooltip",
                    Padding = { Left = -4, Right = 4, Top = 4, Bottom = -4, }, 
                },
                Bars = {
                    Health = {
                        Height = 30,
                        Width = 250,
                        X = 0,
                        Y = 0,
                        Texture = "LUI_Gradient",
                        TextureBG = "LUI_Gradient",
                        BGAlpha = 1,
                        BGInvert = false,
                        Smooth = true,
                        Tapping = true,
                    },
                    Power = {
                        Enable = true,
                        Height = 10,
                        Width = 250,
                        X = 0,
                        Y = -32,
                        Texture = "LUI_Minimalist",
                        TextureBG = "LUI_Minimalist",
                        BGAlpha = 1,
                        BGInvert = false,
                        Smooth = true,
                    },
                },
                Aura = {
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
                },
                
                Portrait = {
                    Enable = false,
                    Height = 43,
                    Width = 90,
                    X = 0,
                    Y = 0,
                    Alpha = 1,
                },
                Icons = {
                    Lootmaster = { Enable = false, Size = 15, X = 16 , Y = 0, Point = "TOPLEFT" , }, 
                    Leader     = { Enable = false, Size = 17, X = 0  , Y = 0, Point = "TOPLEFT" , }, 
                    Role       = { Enable = false, Size = 22, X = 15 , Y = 0, Point = "TOPRIGHT", }, 
                    Raid       = { Enable = false, Size = 55, X = 0  , Y = 0, Point = "CENTER"  , }, 
                    PvP        = { Enable = false, Size = 35, X = -12, Y = 0, Point = "TOPLEFT" , }, 
                },
                Texts = {
                    Name = {
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
                    Health = {
                        Enable = false,
                        X = 0,
                        Y = -43,
                        ShowAlways = false,
                        Point = "BOTTOMLEFT",
                        RelativePoint = "BOTTOMRIGHT",
                        Format = "Absolut Short",
                        ShowDead = false,
                    },
                    Power = {
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
                    Combat = {
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
            },
    ------------------------------------------------------
    -- / PLAYER SETTINGS / --
    ------------------------------------------------------
            player = {
                Enable = true,
                Height = 43,
                Width = 250,
                X = -200,
                Y = -200,
                Point = "CENTER",
                Colors = {
                    PvPTime       = { r = 1   , g = 0.1 , b = 0.1 , a = 1           , }, 
                    AltMana       = { r = 0.8 , g = 0.8 , b = 0.8 , t = "Type"      , },
                    ClassPower    = { r = 1   , g = 1   , b = 1   , t = "Type"      , },
                },
                Fonts = {
                    PvPTime =       { Name = "vibroceb",  Size = 12, Flag = "NONE",    },
                },
                Bars = {
                    AltMana = {
                        Enable = true,
                        OverPower = true,
                        Height = 10,
                        Width = 250,
                        X = 0,
                        Y = -44,
                        Texture = "LUI_Minimalist",
                        TextureBG = "LUI_Minimalist",
                        BGAlpha = 1,
                        Smooth = true,
                    },
                    Runes = {
                        Enable = true,
                        X = 0,
                        Y = 0.5,
                        Height = 8,
                        Width = 249,
                        Texture = "LUI_Gradient",
                        Padding = 1,
                        Lock = true,
                    },
                    ClassPower = {
                        Enable = true,
                        X = 0,
                        Y = 0.5,
                        Height = 8,
                        Width = 250,
                        Texture = "LUI_Gradient",
                        Padding = 1,
                        Lock = true,
                    },
                },
                Aura = {
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
                },
                Icons = {
                    Combat     = { Enable = false,    Size = 27,    X = -15,    Y = -30,    Point = "BOTTOMLEFT",  },
                    Resting    = { Enable = false,    Size = 27,    X = -12,    Y = 13,     Point = "TOPLEFT",     },
                },
                Texts = {
                    Name = {
                        Enable = false,
                        X = 0,
                    },
                    Power = {
                        Point = "BOTTOMRIGHT",
                        RelativePoint = "BOTTOMRIGHT",
                    },
                    PvP = {
                        Enable = true,
                        X = 20,
                        Y = 5,
                    },
                },
            },

    ------------------------------------------------------
    -- / TARGET SETTINGS / --
    ------------------------------------------------------
            target = {
                Height = 43,
                Width = 250,
                X = 200,
                Y = -200,
                Portrait = {
                    Height = 43,
                    Width = 110,
                },
                Icons = {
                    Lootmaster = {    Enable = true,     Size = 15,    X = 16,     Y = 10,    Point = "TOPLEFT",},
                    Leader     = {    Enable = true,     Size = 17,    X = 0,      Y = 10,    Point = "TOPLEFT",},
                    Role       = {    Enable = true,     Size = 22,    X = 15,     Y = 10,    Point = "TOPRIGHT",},
                    Raid       = {    Enable = true,     Size = 55,    X = 0,      Y = 10,    Point = "CENTER",},
                    PvP        = {    Enable = false,    Size = 35,    X = -12,    Y = 10,    Point = "TOPLEFT",},
                },
                Texts = {
                    Name = {
                        Enable = true,
                        X = 5,
                        Y = 0,
                        Point = "BOTTOMLEFT",
                        RelativePoint = "BOTTOMRIGHT",
                        Format = "Level + Name",
                        Length = "Medium",
                        ColorNameByClass = true,
                        ColorClassByClass = true,
                        ColorLevelByDifficulty = true,
                        ShowClassification = true,
                        ShortClassification = false,
                    },
                    Health = {
                        Enable = true,
                        X = 0,
                        Y = -31,
                        ShowAlways = true,
                        Point = "BOTTOMLEFT",
                        RelativePoint = "BOTTOMLEFT",
                        Format = "Standard",
                        ShowDead = false,
                    },
                    Power = {
                        Enable = true,
                        X = 0,
                        Y = -51,
                        ShowFull = true,
                        ShowEmpty = true,
                        Point = "BOTTOMLEFT",
                        RelativePoint = "BOTTOMLEFT",
                        Format = "Standard",
                    },
                    HealthPercent = {
                        Enable = true,
                        X = 0,
                        Y = 6,
                        ShowAlways = false,
                        Point = "CENTER",
                        RelativePoint = "CENTER",
                        ShowDead = true,
                    },
                },
            },

    ------------------------------------------------------
    -- / FOCUS SETTINGS / --
    ------------------------------------------------------
            focus = {
                Enable = true,
                Height = 24,
                Width = 200,
                X = -435,
                Y = -250,
            },

    ------------------------------------------------------
    -- / FOCUS TARGET SETTINGS / --
    ------------------------------------------------------
            focustarget = {
                Enable = false,
                Height = 24,
                Width = 200,
                X = -465,
                Y = -285,
            },

    ------------------------------------------------------ 
    -- / TARGET OF TARGET SETTINGS / --
    ------------------------------------------------------
            targettarget = {
                Enable = true,
                Height = 24,
                Width = 200,
                X = 435,
                Y = -250,
            },

    ------------------------------------------------------
    -- / TARGET OF TARGET OF TARGET SETTINGS / --
    ------------------------------------------------------
            targettargettarget = {
                Enable = false,
                Height = 24,
                Width = 200,
                X = 465,
                Y = -285,
            },

    ------------------------------------------------------
    -- / PET SETTINGS / --
    ------------------------------------------------------
            pet = {
                Enable = true,
                Height = 43,
                Width = 130,
                X = 0,
                Y = -200,
            },

    ------------------------------------------------------
    -- / PET TARGET SETTINGS / --
    ------------------------------------------------------
            pettarget = {
                Enable = true,
                Height = 24,
                Width = 130,
                X = 0,
                Y = -160,
            },

    ------------------------------------------------------
    -- / RAID SETTINGS / --
    ------------------------------------------------------
            raid = {
                Enable = true,
                UseBlizzard = false,
                Height = 33,
                Width = 77.5,
                X = -28.5,
                Y = 40.5,
                Point = "BOTTOMRIGHT",
                Padding = 4,
                GroupPadding = 4,
            },

    ------------------------------------------------------
    -- / PARTY SETTINGS / --
    ------------------------------------------------------
            party = {
                Enable = true,
                UseBlizzard = false,
                Height = 43,
                Width = 170,
                X = 150,
                Y = 100,
                Scale = 1,
                Point = "LEFT",
                GrowDirection = "BOTTOM",
                Padding = 50,
                ShowPlayer = false,
                ShowInRaid = false,
                ShowInRealParty = false,
                RangeFade = true,
            },

    ------------------------------------------------------
    -- / PARTY PET SETTINGS / --
    ------------------------------------------------------
            partypet = {
                Enable = true,
                Height = 24,
                Width = 130,
                X = -15,
                Y = -10,
            },

    ------------------------------------------------------
    -- / PARTY TARGET SETTINGS / --
    ------------------------------------------------------
            partytarget = {
                Enable = true,
                Height = 24,
                Width = 130,
                X = 8,
                Y = -8,
            },

    ------------------------------------------------------
    -- / MAIN TANK SETTINGS / --
    ------------------------------------------------------
            maintank = {
                Enable = false,
                Height = 24,
                Width = 130,
                X = -10,
                Y = 350,
                Scale = 1,
                Point = "BOTTOMRIGHT",
                GrowDirection = "BOTTOM",
                Padding = 6,
            },

    ------------------------------------------------------
    -- / MAIN TANK TARGET SETTINGS / --
    ------------------------------------------------------
            maintanktarget = {
                Enable = true,
                Height = 24,
                Width = 130,
                X = -8,
                Y = 0,
            },

    ------------------------------------------------------
    -- / MAIN TANK TARGET OF TARGET SETTINGS / --
    ------------------------------------------------------
            maintanktargettarget = {
                Enable = false,
                Height = 24,
                Width = 130,
                X = -146,
                Y = 0,
            },

    ------------------------------------------------------
    -- / BOSS SETTINGS / --
    ------------------------------------------------------
            boss = {
                Enable = true,
                UseBlizzard = false,
                Height = 24,
                Width = 130,
                X = -25,
                Y = -250,
                Point = "TOPRIGHT",
                GrowDirection = "BOTTOM",
                Padding = 6,
            },

    ------------------------------------------------------
    -- / BOSS TARGET SETTINGS / --
    ------------------------------------------------------
            bosstarget = {
                Enable = false,
                Height = 24,
                Width = 130,
                X = -8,
                Y = -8,
            },

    ------------------------------------------------------
    -- / ARENA SETTINGS / --
    ------------------------------------------------------
            arena = {
                Enable = true,
                UseBlizzard = false,
                Height = 43,
                Width = 170,
                X = -150,
                Y = 100,
                GrowDirection = "BOTTOM",
                Padding = 50,
            },

    ------------------------------------------------------
    -- / ARENA PET SETTINGS / --
    ------------------------------------------------------
            arenapet = {
                Enable = true,
                Height = 24,
                Width = 130,
                X = 15,
                Y = -10,
            },

    ------------------------------------------------------
    -- / ARENA TARGET SETTINGS / --
    ------------------------------------------------------
            arenatarget = {
                Enable = true,
                Height = 24,
                Width = 130,
                X = -8,
                Y = -8,
            },
        },
    ------------------------------------------------------
    -- / END OF UNIT SETTINGS / --
    ------------------------------------------------------
    },
}
