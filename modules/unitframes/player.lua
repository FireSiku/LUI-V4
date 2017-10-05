------------------------------------------------------
-- / SETUP AND LOCALS / --
------------------------------------------------------
-- Unitframes elements need to be named exactly like Blizzard unit values (player, target, etc)
local addonname, LUI = ...
local module = LUI:GetModule("Unitframes")
local element = module:NewElement("player")
local db

element.defaults = {
	profile = {	
		Enable = true,
		Height = 45,
		Width = 220,
		X = -130,
		Y = -250,
		Point = "CENTER",
		Scale = 1,
		Border = {
			Aggro = false,
			EdgeSize = 5,
			Insets = {
				Left = 3,
				Right = 3,
				Top = 3,
				Bottom = 3,
			},
		},
		Backdrop = {
			Padding = {
				Left = -4,
				Right = 4,
				Top = 4,
				Bottom = -4,
			},
		},
		Bars = {
			Health = {
				Height = 28,
				Width = 220,
				X = 0,
				Y = 0,
				BGAlpha = 1,
				BGMultiplier = 0.4,
				BGInvert = false,
				Smooth = true,
				HealthPredict = false,
				Absorb = false,
			},
			Power = {
				Enable = true,
				Height = 14,
				Width = 220,
				X = 0,
				Y = 0,
				BGAlpha = 1,
				BGMultiplier = 0.4,
				BGInvert = false,
				Smooth = true,
			},
			AltPower = {
				Enable = false,
				OverPower = false,
				Height = 10,
				Width = 250,
				X = 0,
				Y = -44,
				BGAlpha = 1,
				BGMultiplier = 0.4,
				Smooth = true,
			},
			ClassPower = {
				Enable = true,
				X = 0,
				Y = 0,
				Height = 8,
				Width = 220,
				Padding = 1.1,
				Lock = true,
			},
		},
		Aura = {
			Buffs = {
				Enable = false,
				ColorByType = false,
				PlayerOnly = false,
				IncludePet = false,
				AuraTimer = false,
				DisableCooldown = false,
				CooldownReverse = true,
				X = -0.5,
				Y = -30,
				InitialAnchor = "BOTTOMRIGHT",
				GrowthY = "DOWN",
				GrowthX = "LEFT",
				Size = 26,
				Spacing = 2,
				Num = 8,
			},
			Debuffs = {
				Enable = false,
				ColorByType = false,
				PlayerOnly = false,
				IncludePet = false,
				FadeOthers = false,
				AuraTimer = false,
				DisableCooldown = false,
				CooldownReverse = true,
				X = -0.5,
				Y = -60,
				InitialAnchor = "BOTTOMLEFT",
				GrowthY = "DOWN",
				GrowthX = "RIGHT",
				Size = 26,
				Spacing = 2,
				Num = 36,
			},
		},
		Portrait = {
			Enable = false,
			Height = 43,
			Width = 110,
			X = 0,
			Y = 0,
			Alpha = 1,
		},
		Texts = {
			Name = {
				Enable = true,
				X = 0,
				Y = -18,
				Point = "TOPLEFT",
				RelativePoint = "BOTTOMLEFT",
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
				X = -3,
				Y = 8,
				ShowAlways = true,
				Point = "RIGHT",
				RelativePoint = "RIGHT",
				Format = "Standard Short",
				ShowDead = false,
			},
			Power = {
				Enable = true,
				X = -5,
				Y = 0,
				ShowFull = true,
				ShowEmpty = true,
				Point = "RIGHT",
				RelativePoint = "RIGHT",
				Format = "Standard",
			},
			HealthPercent = {
				Enable = true,
				X = 5,
				Y = 8,
				ShowAlways = false,
				Point = "LEFT",
				RelativePoint = "LEFT",
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
				X = -3,
				Y = 0,
				ShortValue = true,
				ShowAlways = false,
				Point = "BOTTOMRIGHT",
				RelativePoint = "BOTTOMRIGHT",
			},
			PowerMissing = {
				Enable = false,
				X = -3,
				Y = -15,
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
			PvP = {
				Enable = true,
				X = 20,
				Y = 5,
			},
			AltPower = {
				Enable = false,
				X = 0,
				Y = 0,
				Format = "Standard",
			},
		},
		Icons = {
			Lootmaster = { Enable = true, Size = 15, X = 16,  Y = 10,  Point = "TOPLEFT",    },
			Leader =     { Enable = true, Size = 17, X = 0,   Y = 10,  Point = "TOPLEFT",    },
			Role =       { Enable = true, Size = 22, X = 15,  Y = 10,  Point = "TOPRIGHT",   },
			Raid =       { Enable = true, Size = 55, X = 0,   Y = 10,  Point = "CENTER",     },
			Resting =    { Enable = true, Size = 27, X = -12, Y = 13,  Point = "TOPLEFT",    },
			Combat =     { Enable = true, Size = 27, X = -15, Y = -30, Point = "BOTTOMLEFT", },
			PvP =        { Enable = true, Size = 35, X = -12, Y = 10,  Point = "TOPLEFT",    },
		},
		Colors = {
			-- Note: Type is not currently supported by :Color() as it relates to unitframes only.
			Border =       { r = 0,    g = 0,    b = 0,    a = 1,    },
			Background =   { r = 0,    g = 0,    b = 0,    a = 1,    },
			HealPredict =  { r = 0,    g = 0.5,  b = 0,    a = 0.25, },
			Absorb =       { r = 0,    g = 1,    b = 0,    a = 0.5,  },
			PvPTime =      { r = 1,    g = 0.1,  b = 0.1,  a = 1,    },
			HealthBar =    { r = 0.6, g = 0.6, b = 0.6,    t = "Individual", },
			PowerBar =     { r = 0.8,  g = 0.8,  b = 0.8,  t = "Class",      },
			AltPower =     { r = 1,    g = 1,    b = 1,    t = "Type",       },
			NameText =     { r = 1,    g = 1,    b = 1,    t = "Class",      },
			HealthText =   { r = 1,    g = 1,    b = 1,    t = "Individual", },
			PowerText =    { r = 1,    g = 1,    b = 1,    t = "Class",      },
			HealthPerc =   { r = 1,    g = 1,    b = 1,    t = "Individual", },
			PowerPerc =    { r = 1,    g = 1,    b = 1,    t = "Individual", },
			HealthMiss =   { r = 1,    g = 1,    b = 1,    t = "Individual", },
			PowerMiss =    { r = 1,    g = 1,    b = 1,    t = "Individual", },
			AltPowerText = { r = 1,    g = 1,    b = 1,    t = "Individual", },
		}, 
		Fonts = {
			Master =     { Name = "Prototype", Flag = "NONE", },
			NameText =   { Name = "Prototype", Size = 18, Flag = "NONE",    },
			HealthText = { Name = "Prototype", Size = 16, Flag = "NONE",    },
			PowerText =  { Name = "Prototype", Size = 14, Flag = "NONE",    },
			HealthPerc = { Name = "Prototype", Size = 14, Flag = "NONE",    },
			PowerPerc =  { Name = "Prototype", Size = 12, Flag = "NONE",    },
			HealthMiss = { Name = "Prototype", Size = 15, Flag = "NONE",    },
			PowerMiss =  { Name = "Prototype", Size = 13, Flag = "NONE",    },
			Combat =     { Name = "vibrocen",  Size = 20, Flag = "OUTLINE", },
			PvPTime =    { Name = "vibroceb",  Size = 12, Flag = "NONE",    },
			AltPower =   { Name = "neuropol",  Size = 10, Flag = "NONE",    },
		},
		StatusBars = {
			Health ="LUI_Minimalist",
			Power = "LUI_Minimalist",
			AltPower = "LUI_Gradient",
			HealthBG = "LUI_Minimalist",
			PowerBG = "LUI_Minimalist",
			AltPowerBG = "LUI_Gradient",
			HealPredict = "LUI_Gradient",
			Absorb = "LUI_Gradient",
			ClassPower = "LUI_Gradient",
			
		},
		Backgrounds = {
			Frame = "Blizzard Tooltip",
		},
		Borders = {
			Frame = "glow",
		},
	},
}

function element.SetUnitStyle(self, unit, isSingle)
	-- Class Powers are only available to players, due to its size and to keep things clean
	-- The function has its own call in class.lua
	module.SetClassPower(self, element)
end


function element:OnInitialize()
end

function element:OnEnable()
	db = element:GetDB()
end

function element:OnDisable()
end