-- This module handle V-Nameplates shown in the game world.

------------------------------------------------------
-- / SETUP AND LOCALS / --
------------------------------------------------------
local addonname, LUI = ...
local module = LUI:NewModule("Nameplates")
local Media = LibStub("LibSharedMedia-3.0")
local L = LUI.L
local db

local _G = _G
local select = select

local NAMEPLATE_SCAN_TIME = 0.05
local ELITE_ICON_TEXTURE = [[Interface\Tooltips\EliteNameplateIcon]]
local ELITE_ICON_OFFSET_X = -8

local oldDefault = {}

module.defaults = {
	profile = {
		ShowElite = true,
		HealthBar = {
			Height = 7,
			Width = 110,
			Texture = "LUI_Minimalist",
		},
		CastBar = {
			Enable = true,
			Height = 5,
			Width = 110,
			XOffset = 0,
			YOffset = -4,
		},
		Name = {
			Enable = true,
			OffsetX = 0,
			OffsetY = 3,
			Truncate = true,
			TruncateAmount = 20,
		},
		Fonts = {
			Nameplate = { Name = "vibroceb", Size = 10, Flag = "OUTLINE", },
		},
		Colors = {
			Nameplate = { r = 0.84, g = 0.75, b = 0.65 },
		},
	},
}

------------------------------------------------------
-- / MAPPING OUT NAMEPLATE FRAMES / --
------------------------------------------------------
--[[

	NamePlate [Frame]
	
	-- NameContainer [Frame]
		-- NameText [FontString]
	
	-- ArtContainer [Frame]
		-- CastBarSpellIcon [Texture]
		-- CastBar [StatusBar]
		-- Highlight [Texture]
		-- CastBarTextBG [Texture]
		-- RaidTargetIcon [Texture]
		-- HealthBar [StatusBar]
			-- OverAbsorb [Texture]
		-- Border [Texture]
		-- AggroWarningTexture [Texture]
		-- AbsorbBar [StatusBar]
			-- Overlay [Texture]
		-- EliteIcon [Texture]
		-- HighLevelIcon [Texture]
		-- LevelText [FontString]
		-- CastBarBorder [Texture]
		-- CastBarText [FontString]
		-- CastBarFrameShield [Texture]

function LUI:NamePlateMapping(frame)
	local function nprint(name, frame, prefix)
		if name == 0 or type(frame) == "userdata" then return end
		LUI:Printf("%s %s [%s]", prefix or "", name or "nil", frame:GetObjectType() or "nil")
	end
	
	nprint(frame:GetName(), frame)
	for name, obj in pairs(frame) do
		nprint(name, obj, "--")
		if type(frame[name]) ~= "userdata" then
			for k, v in pairs(frame[name]) do
				nprint(k, v, "-- --")
			end
		end
	end
end
--]]		

------------------------------------------------------
-- / MODULE FUNCTIONS / --
------------------------------------------------------

function module:IsNamePlate(frame)
	--return boolean
	return (frame.ArtContainer and frame.ArtContainer.HealthBar and frame.ArtContainer.AbsorbBar)
end

function module:CreateNewNameplate(frame)
	--Comments are the names used in V3. 
	local nameText = frame.NameContainer.NameText
	local levelText = frame.ArtContainer.LevelText
	local border = frame.ArtContainer.Border  -- OverlayRegion
	local highlight = frame.ArtContainer.Highlight
	local eliteIcon = frame.ArtContainer.EliteIcon -- StateRegionIcon
	local skullIcon = frame.ArtContainer.HighLevelIcon -- BossIcon
	local raidTargetIcon = frame.ArtContainer.RaidTargetIcon 
	local aggroWarningTexture = frame.ArtContainer.AggroWarningTexture -- Called GlowRegion
	
	local castBar = frame.ArtContainer.CastBar
	local castBarText = frame.ArtContainer.CastBarText
	local castBarTextBG = frame.ArtContainer.CastBarTextBG
	local castBarBorder = frame.ArtContainer.CastBarBorder -- CastOverlay
	local castBarSpellIcon = frame.ArtContainer.CastBarSpellIcon
	local castBarFrameShield = frame.ArtContainer.CastBarFrameShield -- ShieldedRegion
	
	local healthBar = frame.ArtContainer.HealthBar
	local absorbBar = frame.ArtContainer.AbsorbBar
	local overAbsorb = frame.ArtContainer.HealthBar.OverAbsorb
	local absorbOverlay = frame.ArtContainer.AbsorbBar.Overlay
	
	local barTexture = Media:Fetch("statusbar", db.HealthBar.Texture)
	local glowBackdrop = {
		edgeFile = Media:Fetch("border", "glow"), edgeSize = 3,
		insets = {left = 3, right = 3, top = 3, bottom = 3}
	}
		
	-- Name Text
	frame.oldName = nameText
	nameText:Hide()
	
	-- Need to make a new name string so we can alter it without losing the original information
	local newNameText = frame:CreateFontString(nil, "OVERLAY")
	module:RefreshFontString(newNameText, "Nameplate")
	newNameText:SetPoint("BOTTOM", healthBar, "TOP", db.Name.OffsetX, db.Name.OffsetY)
	newNameText:SetShadowOffset(1, -1)
	frame.name = newNameText
	
	-- Level Text
	frame.oldLevel = levelText
	levelText:Hide()
	
	local newLevelText = frame:CreateFontString(nil, "OVERLAY")
	module:RefreshFontString(newLevelText, "Nameplate")
	newLevelText:SetPoint("RIGHT", healthBar, "LEFT", -2, 0)
	newLevelText:SetShadowOffset(1, -1)
	frame.level = newLevelText
	
	--Keep the text color
	frame.level:SetTextColor(frame.oldLevel:GetTextColor())
	
	-- Horizontally flip the elite icon texture.
	local ulX, ulY, llX, llY, urX, urY, lrX, lrY = eliteIcon:GetTexCoord()
	eliteIcon:SetTexCoord(urX, ulY, lrX, llY, ulX, urY, llX, lrY)
	
	-- Health Bar
	--TODO: Understand Absorbs
	healthBar:SetStatusBarTexture(barTexture)
	
	healthBar.glow = CreateFrame("Frame", nil, healthBar)
	healthBar.glow:SetPoint("TOPLEFT", healthBar, "TOPLEFT", -3, 3)
	healthBar.glow:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", 3, -3)
	healthBar.glow:SetBackdrop(glowBackdrop)
	healthBar.glow:SetBackdropColor(0,0,0)
	healthBar.glow:SetBackdropBorderColor(0,0,0)
	
	highlight:SetTexture(barTexture)
	highlight:SetVertexColor(0.25, 0.25, 0.25)
	
	--CastBar
	
	--Remove uneeded textures
	border:SetTexture(nil)
	skullIcon:SetTexture(nil)
	castBarBorder:SetTexture(nil)
	castBarFrameShield:SetTexture(nil)
	aggroWarningTexture:SetTexture(nil)
	
	module.UpdateNamePlate(frame)
	frame:HookScript("OnShow", module.UpdateNamePlate)
	--frame:HookScript("OnHide")
	--frame:HookScript("OnUpdate")
end

function module.UpdateNamePlate(frame)
	local healthBar = frame.ArtContainer.HealthBar
	local eliteIcon = frame.ArtContainer.EliteIcon
	local skullIcon = frame.ArtContainer.HighLevelIcon
	local healthBar = frame.ArtContainer.HealthBar
	
	local r, g, b = healthBar:GetStatusBarColor()
	
	if g + b == 0 then
		-- Hostile Unit
		healthBar:SetStatusBarColor(module:Color("Hostile"))
	elseif r + b == 0 then
		-- Friendly Unit
		healthBar:SetStatusBarColor(module:Color("Friendly"))
	elseif r + g == 0 then
		-- Friend player
		healthBar:SetStatusBarColor(module:Color("Friendly"))
	elseif 2 - (r + g) < 0.01 and b == 0 then
		-- Neutral Unit
		healthBar:SetStatusBarColor(module:Color("Neutral"))
	else
		-- Hostile Player, Class Colored
		-- Do Nothing
	end
	
	healthBar:ClearAllPoints()
	healthBar:SetPoint("CENTER", healthBar:GetParent())
	healthBar:SetSize(db.HealthBar.Width, db.HealthBar.Height)
	
	--Update name
	local nameString = frame.oldName:GetText()
	-- If the name is only two characters longer than truncation, it would be longer to actually truncate it.
	if strlen(nameString) < db.Name.TruncateAmount + 3 then
		frame.name:SetText(nameString)
	else
		frame.name:SetFormattedText("%s...", strsub(nameString, 0, db.Name.TruncateAmount))
	end
	
	
	if db.Name.Enable then
		frame.name:Show()
	else
		frame.name:Hide()
	end
	frame.name:SetPoint("BOTTOM", healthBar, "TOP", db.Name.OffsetX, db.Name.OffsetY)
	
	-- Move level to the left
	--levelText:ClearAllPoints()
	--levelText:SetPoint("RIGHT", healthBar, "LEFT", -2, 0)
	
	--Update the level text color since we're using a new fontstring
	frame.level:SetTextColor(frame.oldLevel:GetTextColor())
	
	local plateLevel = frame.oldLevel:GetText()
	frame.oldLevel:Hide()
	if skullIcon:IsShown() then
		frame.level:SetText(BOSS)
		frame.level:SetTextColor(module:Color("Hostile"))
		frame.level:Show()
	elseif not eliteIcon:IsShown() and plateLevel == UnitLevel("player") then
		frame.level:Hide()
	else
		frame.level:SetFormattedText("%d%s", plateLevel, (eliteIcon:IsShown()) and "+" or "")
	end
	
	-- Elite icon needs to be offset to fit new level position.
	local point, parent, relativePoint, offsetX, offsetY = eliteIcon:GetPoint()
	eliteIcon:ClearAllPoints()
	eliteIcon:SetPoint(point, frame.level, relativePoint, ELITE_ICON_OFFSET_X, offsetY)
	--Make sure eliteIcon is under the level text.
	--eliteIcon:SetFrameLevel(frame.level:GetFrameLevel()-1)
	if db.ShowElite then 
		eliteIcon:SetTexture(ELITE_ICON_TEXTURE)
	else
		eliteIcon:SetTexture(nil)
	end
	
	-- Update Health Bar
	local barTexture = Media:Fetch("statusbar", db.HealthBar.Texture)
	healthBar:SetStatusBarTexture(barTexture)
	
	--LUI:Print("Updating", frame:GetName())
end

------------------------------------------------------
-- / MODULE SETUP / --
------------------------------------------------------

function module:SetNameplates()
	
	-- Stop resizing nameplate according to threat level.
	--Todo: Add this to revert function
	SetCVar("bloatthreat", 0) 
	
	local nameplates = CreateFrame("Frame", "LUINameplates", UIParent)
	--Make sure any event goes to its respective function, similar to AceEvent
	nameplates:HookScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
	
	local numKids = 0
	local function ScanForNameplates()
		-- Nameplates are created as children of the world frame, check for new ones.
		local newNumKids = WorldFrame:GetNumChildren()
		if newNumKids ~= numKids then
			for i = numKids + 1, newNumKids do
				local frame = select(i, WorldFrame:GetChildren())
				--Make sure the new frame found is actually a nameplate before skinning it.
				if module:IsNamePlate(frame) then
					module:CreateNewNameplate(frame)
				end
			end
			numKids = newNumKids
		end
	end
	
	module.nameplateScan = C_Timer.NewTicker(NAMEPLATE_SCAN_TIME, ScanForNameplates)
end

------------------------------------------------------
-- / FRAMEWORK FUNCTIONS / --
------------------------------------------------------

module.enableButton = true

function module:Refresh()
	
	--Force update on all current nameplates
	for i = 1, WorldFrame:GetNumChildren() do
		local frame = select(i, WorldFrame:GetChildren())
		if module:IsNamePlate(frame) then
			module.UpdateNamePlate(frame)
		end
	end
end

function module:LoadOptions()
	local options = {
		Header = module:NewHeader(L["Nameplates_Name"], 1),
		General = module:NewRootGroup(L["Settings"], 2, nil, nil, {
			ShowElite = module:NewToggle(L["Nameplates_ShowElite_Name"], L["Nameplates_ShowElite_Desc"], 1, "Refresh"),
		}),
		Name = module:NewGroup(NAME, 3, nil, nil, {
			Enable = module:NewToggle(L["Nameplates_Enable_Name"], L["Nameplates_Enable_Desc"], 1, "Refresh"),
			Truncate = module:NewToggle(L["Nameplates_Truncate_Name"], L["Nameplates_Truncate_Desc"], 2, "Refresh", "normal"),
			TruncateAmount = module:NewSlider(L["Nameplates_TruncateAmount_Name"], L["Nameplates_TruncateAmount_Desc"], 3, 8, 32, 1, nil, "Refresh"),
			OffsetHeader = module:NewHeader(L["Nameplates_OffsetHeader"], 4),
			Offset = module:NewPosition("offset", 5, nil, "Refresh")
		}),
		HealthBar = module:NewGroup(L["Health Bar"], 4, nil, nil, {
			Texture = module:NewTexStatusBar(L["Nameplates_HealthBar_Name"], L["Nameplates_HealthBar_Desc"], 2, "Refresh", "double"),
		}),
	}
	
	return options
end

function module:OnInitialize()
	--LUI:RegisterModule(module)
end

function module:OnEnable()
	module:Disable()
	--db = module:GetDB()
	--module:SetNameplates()
end

function module:OnDisable()
end
