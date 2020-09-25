-- ####################################################################################################################
-- ##### Setup and Locals #############################################################################################
-- ####################################################################################################################
---@type Opt
local optName, Opt = ...
local LUI = LibStub("AceAddon-3.0"):GetAddon("LUI4")
local module = LUI:GetModule("Unitframes")
local db = module.db.profile
local L = LUI.L

-- ####################################################################################################################
-- ##### Utility Functions ############################################################################################
-- ####################################################################################################################
local sizeValues = {softMin = 8, softMax = 64, min = 4, max = 255, step = 1}
local spacingValues = {softMin = -10, softMax = 10, step = 1}
local auraCountValues = {min = 1, max = 64, softMax = 36, step = 1}


-- ####################################################################################################################
-- ##### Options Tables ###############################################################################################
-- ####################################################################################################################
Opt.options.args.Unitframes = Opt:Group("Unitframes", nil, nil, "tab")
Opt.options.args.Unitframes.handler = module

Opt.options.args.Unitframes.args.Header = Opt:Header("Unitframes", 1)

local function GenerateIconGroup(name, order, get, set)
    local group = Opt:Group(name, nil, order, nil, nil, nil, get, set)
    group.args = {
        Enabled = Opt:Toggle("Enabled", nil, 1),
        X = Opt:Input("X Value", nil, 2),
        Y = Opt:Input("Y Value", nil, 3),
        Size = Opt:Slider("Size", nil, 4, sizeValues),
        Point = Opt:Select(L["Anchor"], nil, 5, LUI.Points),
    }

    return group
end

local function NewUnitOptionGroup(unit, order)
    local isPlayer = (unit == "player")

    local unitOptions = Opt:Group(unit, nil, order, "tree")
    unitOptions.args.General = Opt:Group("General", nil, 1, nil, nil, nil, Opt.GetSet(db.Units[unit]))
    unitOptions.args.General.args = {
        Position = Opt:Header("Position", 1),
        X = Opt:Input("X Value", nil, 2),
        Y = Opt:Input("Y Value", nil, 3),
        Point = Opt:Select(L["Anchor"], nil, 4, LUI.Points),
        Scale = Opt:Slider("Scale", nil, 5, Opt.ScaleValues),
    }

    unitOptions.args.HealthBar = Opt:Group("Health Bar", nil, 2, nil, nil, nil, Opt.GetSet(db.Units[unit].HealthBar))
    unitOptions.args.HealthBar.args = {
        Width = Opt:Input("Width", nil, 2),
        Height = Opt:Input("Height", nil, 3),
        Texture = Opt:MediaStatusbar("Bar Texture", nil, 5),
        TextureBG = Opt:MediaStatusbar("Background Texture", nil, 6),
    }

    unitOptions.args.PowerBar = Opt:Group("Power Bar", nil, 2, nil, nil, nil, Opt.GetSet(db.Units[unit].PowerBar))
    unitOptions.args.PowerBar.args = {
        Width = Opt:Input("Width", nil, 2),
        Height = Opt:Input("Height", nil, 3),
        X = Opt:Input("X Value", nil, 4),
        Y = Opt:Input("Y Value", nil, 5),
        --Point = Opt:Select(L["Anchor"], nil, 6, LUI.Points),
        Texture = Opt:MediaStatusbar("Bar Texture", nil, 7),
        TextureBG = Opt:MediaStatusbar("Background Texture", nil, 8),
    }

    unitOptions.args.AbsorbBar = Opt:Group("Absorb Bar", nil, 3, nil, nil, nil, Opt.GetSet(db.Units[unit].AbsorbBar))
    unitOptions.args.AbsorbBar.args.sillyDesc = Opt:Desc("Settings will go here", 1)

    unitOptions.args.ClassPowerBar = Opt:Group("Class Power Bar", nil, 4, nil, nil, nil, Opt.GetSet(db.Units[unit].ClassPowerBar))
    unitOptions.args.ClassPowerBar.args = {
        Width = Opt:Input("Width", nil, 2),
        Height = Opt:Input("Height", nil, 3),
        X = Opt:Input("X Value", nil, 4),
        Y = Opt:Input("Y Value", nil, 5),
        --Point = Opt:Select(L["Anchor"], nil, 6, LUI.Points),
        Texture = Opt:MediaStatusbar("Bar Texture", nil, 7),
        TextureBG = Opt:MediaStatusbar("Background Texture", nil, 8),
    }

    unitOptions.args.NameText = Opt:Group("Name Text", nil, 5, nil, nil, nil, Opt.GetSet(db.Units[unit].NameText))
    unitOptions.args.NameText.args.sillyDesc = Opt:Desc("Settings will go here", 1)

    -- Use a single entry to handle Value, Percent and Missing?
    unitOptions.args.HealthText = Opt:Group("Health Text", nil, 6, nil, nil, nil, Opt.GetSet(db.Units[unit].HealthText))
    unitOptions.args.HealthText.args.sillyDesc = Opt:Desc("Settings will go here", 1)

    unitOptions.args.PowerText = Opt:Group("Power Text", nil, 7, nil, nil, nil, Opt.GetSet(db.Units[unit].PowerText))
    unitOptions.args.PowerText.args.sillyDesc = Opt:Desc("Settings will go here", 1)

    unitOptions.args.CombatText = Opt:Group("Combat Text", nil, 8, nil, nil, nil, Opt.GetSet(db.Units[unit].CombatText))
    unitOptions.args.CombatText.args.sillyDesc = Opt:Desc("Settings will go here", 1)

    unitOptions.args.Portrait = Opt:Group("Portrait", nil, 9, nil, nil, nil, Opt.GetSet(db.Units[unit].Portait))
    unitOptions.args.ClassPowerBar.args = {
        Width = Opt:Input("Width", nil, 2),
        Height = Opt:Input("Height", nil, 3),
        X = Opt:Input("X Value", nil, 4),
        Y = Opt:Input("Y Value", nil, 5),
        --Point = Opt:Select(L["Anchor"], nil, 6, LUI.Points),
        Alpha = Opt:Slider("Alpha", nil, 7, Opt.PercentValues),
    }

    unitOptions.args.Buffs = Opt:Group("Buffs", nil, 10, nil, nil, nil, Opt.GetSet(db.Units[unit].Buffs))
    unitOptions.args.Buffs.args = {
        NYI = Opt:Desc("Auras Not Yet Implemented", 0.5),
        ColorByType = Opt:Toggle("Color By Type", nil, 1),
        PlayerOnly = Opt:Toggle("Player Only", nil, 2),
        IncludePet = Opt:Toggle("Include Pet", nil, 3),
        AuraTimer = Opt:Toggle("Aura Timer", nil, 4),
        DisableCooldown = Opt:Toggle("Disable Cooldown", nil, 5),
        CooldownReverse = Opt:Toggle("Cooldown Reverse", nil, 6),
        X = Opt:Input("X Value", nil, 7),
        Y = Opt:Input("Y Value", nil, 8),
        InitialAnchor = Opt:Select(L["Anchor"], nil, 9, LUI.Points),
        GrowthX = Opt:Select("Horizontal Growth", nil, 10, LUI.Directions),
        GrowthY = Opt:Select("Vertical Growth", nil, 10, LUI.Directions),
        Size = Opt:Slider("Size", nil, 11, sizeValues),
        Spacing = Opt:Slider("Spacing", nil, 12, spacingValues),
        Num = Opt:Slider("Amount of Buffs", nil, 13, auraCountValues),
    }
    unitOptions.args.Debuffs = Opt:Group("Debuffs", nil, 10, nil, nil, nil, Opt.GetSet(db.Units[unit].Debuffs))
    unitOptions.args.Debuffs.args = {
        NYI = Opt:Desc("Auras Not Yet Implemented", 0.5),
        ColorByType = Opt:Toggle("Color By Type", nil, 1),
        PlayerOnly = Opt:Toggle("Player Only", nil, 2),
        IncludePet = Opt:Toggle("Include Pet", nil, 3),
        AuraTimer = Opt:Toggle("Aura Timer", nil, 4),
        DisableCooldown = Opt:Toggle("Disable Cooldown", nil, 5),
        CooldownReverse = Opt:Toggle("Cooldown Reverse", nil, 6),
        X = Opt:Input("X Value", nil, 7),
        Y = Opt:Input("Y Value", nil, 8),
        InitialAnchor = Opt:Select(L["Anchor"], nil, 9, LUI.Points),
        GrowthX = Opt:Select("Horizontal Growth", nil, 10, LUI.Directions),
        GrowthY = Opt:Select("Vertical Growth", nil, 10, LUI.Directions),
        Size = Opt:Slider("Size", nil, 11, sizeValues),
        Spacing = Opt:Slider("Spacing", nil, 12, spacingValues),
        Num = Opt:Slider("Amount of Debuffs", nil, 13, auraCountValues),
    }

    unitOptions.args.LeaderIcon = GenerateIconGroup("Leader Icon", 50, Opt.GetSet(db.Units[unit].LeaderIcon))
    unitOptions.args.RoleIcon = GenerateIconGroup("Role Icon", 50, Opt.GetSet(db.Units[unit].RoleIcon))
    unitOptions.args.RaidIcon = GenerateIconGroup("Raid Icon", 50, Opt.GetSet(db.Units[unit].RaidIcon))
    unitOptions.args.PvPIcon = GenerateIconGroup("PvP Icon", 50, Opt.GetSet(db.Units[unit].PvPIcon))
    --unitOptions.args.RestedIcon = GenerateIconGroup("Leader Icon", 50, Opt.GetSet(db.Units[unit].LeaderIcon))

    return unitOptions
end

for i = 1, #module.unitSpawns do
    local unit = module.unitSpawns[i]
    Opt.options.args.Unitframes.args[unit] = NewUnitOptionGroup(unit, i+10)
end

--[[

	Portrait = opt:NewGroup("Portrait", 4, "tab", nil, {
			Size = opt:NewUnitframeSize(nil, 1, true),
			Position = opt:NewPosition("Position", 2, true),
			Point = opt:NewSelect(L["Anchor"], nil, 3, LUI.Points),
			Alpha = opt:NewSlider("Alpha", nil, 4, 0, 1, 0.05, true),
        }),
]]
