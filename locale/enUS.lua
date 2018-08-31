-- WHEN UPDATING THIS FILE, REMEMBER TO ALSO ADD ANY LINES INTO THE CURSE LOCALIZATION
-- Otherwise, issues will rise with missing values in translated versions.

local addonname, LUI = ...

local L = LibStub("AceLocale-3.0"):NewLocale(addonname, "enUS", true)

-- Generic
L["Settings"] = true
L["Position"] = true
L["Texture"] = true
L["Textures"] = true
L["Color"] = true
L["Colors"] = true
L["Background"] = true
L["Border"] = true
L["Tapped"] = true
L["Padding"] = true
L["Spacing"] = true
L["Scale"] = true
L["Precision"] = true
L["Options"] = true
L["Anchor"] = true
L["Width"] = true
L["Height"] = true
L["Parent"] = true
L["Relative Anchor"] = true
L["Health Bar"] = true
L["BackgroundDesc"] = "Choose the background texture."
L["BorderDesc"] = "Choose the border texture."

-- Flags
L["Flag_None"] = "None"
L["Flag_Outline"] = "Outline"
L["Flag_ThickOutline"] = "Thick Outline"
L["Flag_Monochrome"] = "Monochrome"
L["Point_Up"] = "Up"
L["Point_Down"] = "Down"
L["Point_Center"] = "Center"
L["Point_Top"] = "Top"
L["Point_Bottom"] = "Bottom"
L["Point_Left"] = "Left"
L["Point_Right"] = "Right"
L["Point_TopLeft"] = "Top Left"
L["Point_TopRight"] = "Top Right"
L["Point_BottomLeft"] = "Bottom Left"
L["Point_BottomRight"] = "Bottom Right"

-- Core
L["Core_InstallSucess"] = "LUI has been installed."
L["Core_ModuleInstallFail_Format"] = "Error installing %s module: %s"
L["Core_Welcome"] = "Welcome"
L["Core_IntroText"] = "Welcome to LUI v4, a complete default UI replacement.\n\n For any question regarding the UI, please go to our forums at http://wowlui.com \n\n\n"
L["Core_Revision_Format"] = "Revision: %s"
L["Core_ModuleMenu"] = "|cffffffffModules:|r"
L["Core_OpenOptionsFail"] = "|cffFF0000Unable to open the options for the first time while in combat."
L["Core_Dev_RevertState_Format"] = "Reverted %s's installed state"
L["Core_LoadProfileSucess_Format"] = "Loading Profile: %s"
L["Core_LoadProfileFail_Format"] = "No Profile Found: %s"
L["Core_ModuleClickHint"] = "Left Click: Toggle between Enabled and Disabled.\nShift Click: Reset module's settings."
L["Core_ModuleReset"] = "Settings have been reset."

-- API
L["API_InputNumber"] = "Please input a number."
L["API_BtnEnabled"] = "|cff00FF00Enabled|r"
L["API_BtnDisabled"] = "|cffFF0000Disabled|r"
L["API_XValue_Name"] = "X Value"
L["API_XValue_Desc"] = "Horizontal value of the %s"
L["API_XValue_Note"] = "\n\nNote:\nPositive Values = Right\nNegative Values = Left"
L["API_YValue_Name"] = "Y Value"
L["API_YValue_Desc"] = "Vertical value for the %s"
L["API_YValue_Note"] = "\n\nNote:\nPositive Values = Up\nNegative Values = Down"
L["API_Advanced"] = "Advanced"
L["API_BGMultiplier"] = "Background Multiplier"
L["API_BGMultiplier_Desc"] = "How much of a darker shade should the background of the bar be."

-- CPanel
L["CPanel_Modules"] = "Modules"
L["CPanel_Infotext"] = "Infotext"
L["CPanel_Addons"] = "Addons"
L["CPanel_AddonReset"] = "Reset %s"
L["CPanel_AddonDesc"] = "These buttons will not automatically reset your settings. It will simply causes LUI to ask if you want to install pre-set settings again. If you select No, none of your settings will be affected."

-- Colors
L["Colors_Classes"] = "Classes"
L["Colors_Factions"] = "Factions"
L["Color_Resources"] = "Resources"
L["Color_Primary"] = "Primary"
L["Color_Secondary"] = "Secondary"
L["Colors_Gradients"] = "Gradients"
L["Colors_Good"] = "Good"
L["Colors_Medium"] = "Medium"
L["Colors_Bad"] = "Bad"
L["Color_Levels"] = "Level Differences"
L["Color_DiffSkull"] = "Skull. Level >= 5"
L["Color_DiffHard"] = "Hard. Level >= 3"
L["Color_DiffEqual"] = "Normal. Target Within 2 Levels"
L["Color_DiffEasy"] = "Easy. Green Quest Range."
L["Color_DiffLow"] = "Trivial. Low Level Target."
L["Color_Individual"] = "Individual"
L["Color_Theme"] = "Theme Color"
L["Color_Class"] = "Class Color"

-- Layout
L["Layout_Name"] = "Layout"
L["Layout_TextLength"] = "Layout Text (%d Characters Long)"
L["Layout_SaveLayout_Name"] = "Save Layout"
L["Layout_SaveLayout_Desc"] = "Save the current settings as a layout."
L["Layout_LoadLayout_Name"] = "Load Layout"
L["Layout_LoadLayout_Desc"] = "Load the selected layout."

-- Minimap
L["Minimap_AlwaysShowText_Name"] = "Always Show Minimap Text"
L["Minimap_AlwaysShowText_Desc"] = "If this is checked, Location and Coordinates text will always be shown."
L["Minimap_ShowTextures_Name"] = "Show Minimap Textures"
L["Minimap_ShowTextures_Desc"] = "If this is unchecked, the textures surrounding the minimap will be gone."
L["Minimap_CoordPrecision_Name"] = "Coord Precision"
L["Minimap_CoordPrecision_Desc"] = "Determines the floating point precision of the coordinates."
L["Minimap_Scale_Name"] = "Minimap Scale"
L["Minimap_Scale_Desc"] = "Determines the scale of your Minimap."
L["Minimap_BorderColor_Name"] = "Border Color"
L["Minimap_BorderColor_Desc"] = "Choose a color for your Minimap's Border"

-- Tooltip
L["Tooltip_Name"] = "Tooltip"
L["Tooltip_Rare"] = "Rare"
L["Tooltip_Ghost"] = "Ghost"
L["Tooltip_MyGuild"] = "MyGuild"
L["Tooltip_Positions"] = "tooltip"
L["Tooltip_HideCombat_Name"] = "Hide All Tooltips In Combat"
L["Tooltip_HideCombat_Desc"] = "Determines if any tooltips will be shown in combat"
L["Tooltip_HideCombatSkills_Name"] = "Only Hide Abilities In Combat"
L["Tooltip_HideCombatSkills_Desc"] = "Determines if ability tooltips will be shown in combat"
L["Tooltip_HideCombatUnit_Name"] = "Only Hide Unit Tooltips In Combat"
L["Tooltip_HideCombatUnit_Desc"] = "Determines if unit tooltips will be shown in combat"
L["Tooltip_HideUF_Name"] = "Hide Unitframes Tooltips"
L["Tooltip_HideUF_Desc"] = "If Checked, unitframes will not display a tooltip."
L["Tooltip_HidePVP_Name"] = "Hide PvP Flag"
L["Tooltip_HidePVP_Desc"] = "If Checked, the PvP flag line will not be displayed inside tooltips."
L["Tooltip_ShowSex_Name"] = "Show Unit Sex"
L["Tooltip_ShowSex_Desc"] = "If Checked, the unit's sex will be displayed if available."
L["Tooltip_Scale_Name"] = "Tooltip Scale"
L["Tooltip_Scale_Desc"] = "Changes the size of the tooltip"
L["Tooltip_Cursor_Name"] = "Anchor to Cursor"
L["Tooltip_Cursor_Desc"] = "Determines if the tooltips will show at the cursor's position."
L["Tooltip_PosDesc"] = "Those values are relative to the right side of the screen."
L["Tooltip_BackgroundTex_Name"] = "Tooltip Background Texture"
L["Tooltip_BorderTex_Name"] = "Tooltip Border Texture"
L["Tooltip_HealthBar_Name"] = "Health Bar Texture"
L["Tooltip_HealthBar_Desc"] = "Choose the tooltip's health bar texture."
L["Tooltip_BorderTex_Name"] = "Tooltip Border Texture"
L["Tooltip_BorderSize_Name"] = "Border Size"
L["Tooltip_BorderSize_Desc"] = "Value for the tooltip's border size."

-- Nameplates
L["Nameplates_Name"] = "Nameplates"
L["Nameplates_ShowElite_Name"] = "Show Elite"
L["Nameplates_ShowElite_Desc"] = "Whether or not to show the elite dragon texture around the nameplates."
L["Nameplates_Enable_Name"] = "Show Name Text"
L["Nameplates_Enable_Desc"] = "If checked, name will be displayed above the health bar."
L["Nameplates_Truncate_Name"] = "Truncate Names"
L["Nameplates_Truncate_Desc"] = "If checked, names that are longer than a given length will be truncated."
L["Nameplates_TruncateAmount_Name"] = "Truncate Length"
L["Nameplates_TruncateAmount_Desc"] = "Select the length that names needs to be before getting truncated."
L["Nameplates_OffsetHeader"] = "Positioning Offset"
L["Nameplates_HealthBar_Name"] = "Health Bar Texture"
L["Nameplates_HealthBar_Desc"] = "Choose the nameplates' health bar texture."

-- Experience Bar
L["ExpBar_Name"] = "Experience Bar"
L["ExpBar_Mode_Artifact"] = "Artifact"
L["ExpBar_Mode_Experience"] = "Experience"
L["ExpBar_Mode_Reputation"] = "Reputation"
L["ExpBar_Mode_Honor"] = "Honor"
L["ExpBar_Mode_Auto"] = "Auto"
L["ExpBar_Mode_None"] = "None"
L["ExpBar_Format_XP"] = "XP"
L["ExpBar_Format_AP"] = "AP"
L["ExpBar_Format_AP_Level"] = "AP +%d"
L["ExpBar_Format_Honor"] = "Honor (%d)"
L["ExpBar_Options_ShowText"] = "Show Text"
L["ExpBar_Options_TextPosition"] = "Text Position"
L["ExpBar_Options_Text"] = "Bar Text"
L["ExpBar_Options_BarMode_Format"] = "Bar %d Mode"
L["ExpBar_Options_BarMode_Desc"] = "Use this to force the bar to display a specific type of experience. Auto to use its normal behavior. None to disable the bar."
L["ExpBar_Options_Spacing_Desc"] = "If two bars are shown, this is the amount of space between them."
L["ExpBar_ShortName_Hatred"] = "Ha"
L["ExpBar_ShortName_Hostile"] = "Ho"
L["ExpBar_ShortName_Unfriendly"] = "Un"
L["ExpBar_ShortName_Neutral"] = "Ne"
L["ExpBar_ShortName_Friendly"] = "Fr"
L["ExpBar_ShortName_Honored"] = "Hon"
L["ExpBar_ShortName_Revered"] = "Rev"
L["ExpBar_ShortName_Exalted"] = "Ex"
L["ExpBar_ShortName_Paragon"] = "Pa"
L["ExpBar_ShortName_Reward"] = "Pa+1" -- Placeholder, +1 is used due to similarity with Artifact bar.

-- Bags
L["Bags_Name"] = "Bags"
L["Bags_SearchHint"] = "Right-click to search."
L["Bags_ItemsPerRow_Name"] = "Items Per Row"
L["Bags_ItemsPerRow_Desc"] = "Select how many items will be displayed per rows in your bags."
L["Bags_Lock_Name"] = "Lock Frames"
L["Bags_Lock_Desc"] = "Lock the bags frames in place."
L["Bags_Padding_Desc"] = "This sets the space between the background border and the adjacent items."
L["Bags_Spacing_Desc"] = "This sets the distance between items."
L["Bags_Scale_Desc"] = "Determines the scale of your bags frame."
-- TODO: Review writing of the following "Whether or not" toggles.
L["Bags_ShowBagBar_Name"] = "Show Bag Bar"
L["Bags_ShowBagBar_Desc"] = "Whether or not to show bag bar."
L["Bags_ShowItemQuality_Name"] = "Show Item Quality"
L["Bags_ShowItemQuality_Desc"] = "Whether or not to show item quality."
L["Bags_ShowNewItemAnim_Name"] = "Show New Item Animation"
L["Bags_ShowNewItemAnim_Desc"] = "Whether or not to show new item animations."
L["Bags_ShowQuestHighlights_Name"] = "Show Quest Highlights"
L["Bags_ShowQuestHighlights_Desc"] = "Whether or not to show quest highlights."
L["Bags_BackgroundTex_Name"] = "Bags' Background Texture"
L["Bags_BorderTex_Name"] = "Bags' Border Texture"
L["Bags_ItemBackground_Name"] = "ItemSlot Background"

--Bag Types
L["BagType_Unknown"] = "Unknown"
L["BagType_Normal"] = "Normal"
L["BagType_Quiver"] = "Quiver"
L["BagType_AmmoPouch"] = "Ammo Pouch"
L["BagType_SoulBag"] = "Soul Bag"
L["BagType_LeatherworkingBag"] = "Leatherworking Bag"
L["BagType_InscriptionBag"] = "Inscription Bag"
L["BagType_HerbBag"] = "Herb Bag"
L["BagType_EnchantingBag"] = "Enchanting Bag"
L["BagType_EngineeringBag"] = "Engineering Bag"
L["BagType_Keyring"] = "Keyring"
L["BagType_GemBag"] = "Gem Bag"
L["BagType_MiningBag"] = "Mining Bag"
L["BagType_VanityPets"] = "Vanity Pets"
L["BagType_TackleBox"] = "Tackle Box"
L["BagType_CookingBag"] = "Cooking Bag"

-- Panels
L["Panels_Name"] = "Panels"
L["Panels_TexMode_LUI"] = "LUI Texture"
L["Panels_TexMode_CustomLUI"] = "Custom LUI Texture"
L["Panels_TexMode_Custom"] = "Custom Texture Path"
L["Panels_Tex_Border_Screen"] = "Screen Border"
L["Panels_Tex_Border_ScreenBack"] = "Screen Border Back"
L["Panels_Tex_Panel_Solid"] = "Solid Panel"
L["Panels_Tex_Panel_Corner"] = "Corner Panel"
L["Panels_Tex_Panel_Center"] = "Center Panel"
L["Panels_Tex_Border_Corner"] = "Corner Panel Border"
L["Panels_Tex_Border_Center"] = "Center Panel Border"
L["Panels_Tex_Bar_Top"] = "Bar Top"
L["Panels_Options_InputName"] = "Enter New Name"
L["Panels_Options_NewPanel"] = "New Panel"
L["Panels_Options_DeletePanel"] = "Delete Panel"
L["Panels_Options_PanelSelect"] = "Current Panels"
L["Panels_Options_PanelSelect_Desc"] = "Choose from this menu any panel you wish to delete."
L["Panels_Options_Category"] = "Category"
L["Panels_Options_Texture_Desc"] = "Name of the texture to be used"
L["Panels_Options_TextureSelect"] = "Texture Select"
L["Panels_Options_TextureSelect_Desc"] = "Select the texture to be used"
L["Panels_Options_Anchored"] = "Anchored"
L["Panels_Options_Anchored_Desc"] = "Whether the texture is anchored to another frame or attached to UIParent"
L["Panels_Options_Parent_Desc"] = "Name of the frame to attach to"
L["Panels_Options_HorizontalFlip"] = "Horizontal Flip"
L["Panels_Options_HorizontalFlip_Desc"] = "Whether the texture should be horizontally flipped or not"
L["Panels_Options_VerticalFlip"] = "Vertical Flip"
L["Panels_Options_VerticalFlip_Desc"] = "Whether the texture should be vertically flipped or not"
L["Panels_Options_CustomTexCoords"] = "Use Custom TexCoords"
L["Panels_Options_CustomTexCoords_Desc"] = "Let you speciwfy custom texture coordinates. Only change them if you know what you are doing."

-- Infotext
L["Info_Hint"] = "Hint:"
L["InfoArmor_Display_Format"] = "Armor: %d%%"
L["InfoArmor_Hint_Any"] = "Click to open Character Frame."
L["InfoMemory_Header"] = "Memory:"
L["InfoMemory_TotalMemory"] = "Total Memory Usage:"
L["InfoMemory_Hint_Any"] = "Click to Collect Garbage."
L["InfoFps_Header"] = "FPS / Latency:"
L["InfoFps_Latency"] = "Latency:"
L["InfoFps_Home"] = "Home:"
L["InfoFps_World"] = "World:"
L["InfoFps_Bandwidth"] = "Bandwidth usage:"
L["InfoFps_Current"] = "Current:"
L["InfoFps_CurrentDown"] = "Current Down:"
L["InfoFps_CurrentUp"] = "Current Up:"
L["InfoFps_MB_Format"] = "%.2f MB/s"
L["InfoFps_KB_Format"] = "%.2f KB/s"
L["InfoBags_Header"] = "Bags:"
L["InfoBags_Text_Format"] = "Bags: %d/%d"
L["InfoBags_Hint_Any"] = "Click to open Bags."
L["InfoClock_Instance_Normal"] = "N"
L["InfoClock_Instance_Heroic"] = "H"
L["InfoClock_Instance_LFR"] = "L"
L["InfoClock_Instance_Challenge"] = "C"
L["InfoClock_Instance_Mythic"] = "M"
L["InfoClock_Instance_Event"] = "E"
L["InfoClock_Instance_Timewalk"] = "T"
L["InfoClock_InvitePending"] = "(Inv. Pending!)"
L["InfoClock_TimeUntil_Format"] = "Time until %s:"
L["InfoClock_SavedRaids"] = "Saved Raid(s) :"
L["InfoClock_LockoutTimeLeft_Format"] = " %dd %dh %dm"
L["InfoClock_LockoutTimeLeftGsub_Format"] = " 0[dhm]"
L["InfoClock_Hint_Right"] = "Right-Click to open Time Manager Frame."
L["InfoClock_InstanceDifficulty_Name"] = "Show Instance Difficulty"
L["InfoClock_InstanceDifficulty_Desc"] = "Display a little indicator about the instance you're in next to the time."
L["InfoClock_ShowSavedRaids_Name"] = "Show Saved Raids"
L["InfoClock_ShowSavedRaids_Desc"] = "Show information about your raid lockouts for this week inside the tooltip."
L["InfoClock_ShowWorldBosses_Name"] = "Show World Bosses"
L["InfoClock_ShowWorldBosses_Desc"] = "Show information about your world bosses loot lockouts for this week inside the tooltip."
L["InfoDualspec_NoSpec"] = "No Specialization"
L["InfoDualspec_Hint_Any"] = "Click to switch talent group."
L["InfoDualspec_Hint_Right"] = "Right-Click to open Talent Frame."
L["InfoDualspec_Hint_Shift"] = "Shift-Click to open Glyph Frame."
-- Dualspec hints added by inSpired, open-ended to append spec names
L["InfoDualspec_Hint_Left-2"] = "Left-Click to switch to "
L["InfoDualspec_Hint_Right-2"] = "Right-Click to switch to "
L["InfoDualspec_Hint_Middle-2"] = "Middle-Click to switch to "
L["InfoDualspec_Hint_Shift-2"] = "Shift-Click to toggle Talent Frame"
----------------
L["InfoDualspec_LootSpec_Name"] = "Show Loot Specialization"
L["InfoDualspec_LootSpec_Desc"] = "Display your current loot specialization in the infotext if you are using a specific one.\n\nNote: Your loot specialization will be displayed in the tooltip regardless of this option."
L["InfoCurrency_Hint_Any"] = "Click to open Currency frame."
L["InfoGuild_NoGuild"] = "No Guild"
L["InfoFriends_NoFriends"] = "No friends online."
L["InfoGold_Session"] = "Session:"
L["InfoGold_Earned"] = "Earned"
L["InfoGold_Spent"] = "Spent"
L["InfoGold_Profit"] = "Profit:"
L["InfoGold_Deficit"] = "Deficit:"
L["InfoGold_Characters"] = "Characters:"
L["InfoGold_Realms"] = "Realms:"
L["InfoGold_Hint_Any"] = "Click to toggle realm/character gold."
L["InfoGold_Hint_Right"] = "Right-Click to reset current Session."

-- Micromenu
L["Micro_Name"] = "Micromenu"
L["Micro_PlayerReq"] = "Available at level %d"
L["MicroSettings_Right"] = "Right Click: LUI Option Panel"
L["MicroSettings_Left"] = "Left Click: WoW Option Panel"
L["MicroBags_Any"] = "Show/Hide your bags"
L["MicroStore_Name"] = "Blizzard Store"
L["MicroStore_Any"] = "Show/Hide the Blizzard Store Frame"
L["MicroCollect_Name"] = "Collections"
L["MicroCollect_Any"] = "Show/Hide the Collections UI"
L["MicroLFG_Name"] = "Dungeon Finder"
L["MicroLFG_Left"] = "Left Click: Dungeon Finder"
L["MicroLFG_Right"] = "Right Click: Raid Browser"
L["MicroEJ_Name"] = "Encounter Journal"
L["MicroEJ_Any"] = "Show/Hide Dungeon & Encounter Journal"
L["MicroPVP_Name"] = "PvP"
L["MicroPVP_Any"] = "Show/Hide Arena & Battlegrounds Panel"
L["MicroGuild_Name"] = "Guild/Friends"
L["MicroGuild_Left"] = "Left Click: Guild Frame"
L["MicroGuild_Right"] = "Right Click: Friends Frame"
L["MicroQuest_Name"] = "Quest Log"
L["MicroQuest_Any"] = "Show/Hide your Quest Log"
L["MicroAch_Name"] = "Achievements"
L["MicroAch_Any"] = "Show/Hide your Achievements"
L["MicroTalents_Name"] = "Talents"
L["MicroTalents_Any"] = "Show/Hide your Talent Frame"
L["MicroSpell_Name"] = "Spellbook & Abilities"
L["MicroSpell_Any"] = "Show/Hide your Spellbook"
L["MicroPlayer_Name"] = "Character Info"
L["MicroPlayer_Any"] = "Show/Hide your Character Pane"
L["MicroOptions_Spacing_Desc"] = "The amount of space between buttons"
L["MicroOptions_Direction_Name"] = "Direction"
L["MicroOptions_ColorMatch_Name"] = "Match Colors"
L["MicroOptions_ColorMatch_Desc"] = "Make sure the background color matches the Micromenu buttons."
L["MicroOptions_Direction_Desc"] = "The side where every button is anchored to. \nRIGHT means Bags is the rightmost button. \nLEFT means Bags is the leftmost button."
