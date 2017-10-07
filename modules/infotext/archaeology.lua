-- Archaeology Infotext

------------------------------------------------------
-- / SETUP AND LOCALS / --
------------------------------------------------------
local addonname, LUI = ...
local module = LUI:GetModule("Infotext")
local element = module:NewElement("Archaeology", "AceEvent-3.0")
local L = LUI.L
local db

local PROFESSIONS_ARCHAEOLOGY_MISSING = PROFESSIONS_ARCHAEOLOGY_MISSING

local ARCH_PROFESSION_ID = 10
local GAP = 10

-- Note: As of Legion, Blizzard reversed the order of all races so that the newer ones appear first in the Archaeology Pane
--       So we are reversing the order again, so we can easily add new data at the end, instead of the beginning.

-- Order of Arch races:
-- Dwarf, Draenei, Fossil, Night Elf, Nerubian, Orc, Tolvir, Troll, Vrykul
-- Mantid, Panderen, Mogu, Arakkoa, Clans, Ogre, Highborne, Highmountain, Demonic
--                    1, 2,  3,  4, 5, 6, 7,  8, 9, 0, 11, 12, 13, 14, 15, 16, 17, 18
local ARCH_COMMON = {27, 8, 12, 18, 7, 9, 7, 14, 5, 8, 10, 10, 11, 19, 10,  5,  5,  5}
local ARCH_RARE =   { 4, 2,  5,  7, 2, 1, 6,  3, 2, 2,  2,  2,  1,  2,  2,  5,  3,  5}

local ARCH_PRISTINE = {
	[10] = {32686, 32688, 32690, 32692, 32687, 32689, 32691, 32693},
	[11] = {31802, 31800, 31799, 31796, 31801, 31795, 31803, 31804, 31797, 31798},
	[12] = {31793, 31791, 31792, 31786, 31794, 31787, 31805, 31789, 31788, 31790},
	[13] = {36771, 36773, 36775, 36777, 36779, 36772, 36774, 36776, 36778, 36780},
	[14] = {36725, 36744, 36746, 36748, 36750, 36752, 36754, 36756, 36758, 36760, 36743, 36745, 36747, 36749, 36751, 36753, 36755, 36757, 36759},
	[15] = {36761, 36763, 36765, 36767, 36769, 36962, 36764, 36766, 36768, 36770},
	[16] = {40349, 40350, 40351, 40352, 40353},
	[17] = {40354, 40355, 40356, 40357, 40358},
	[18] = {40359, 40360, 40361, 40362, 40363},
}

local ARCH_ACHIEVEMENTS = {
	 [1] = {4859, 5193},
	 [4] = {5191},
	 [6] = {5192},
	 [7] = {5301},
	[10] = {8219, 8222, 8223, 8220, 8221, 8226, 8227, 8234, 8235, 8230, 8231, 8224, 8225, 8228, 8229, 8232, 8233},
	[11] = {7331, 7332, 7333, 7345, 7365, 7343, 7363, 7362, 7342, 7364, 7344, 7338, 7339, 7358, 7359, 7346, 7366, 7347, 7367, 7340, 7341, 7360, 7361},
	[12] = {7334, 7335, 7336, 7337, 7369, 7349, 7373, 7353, 7354, 7374, 7348, 7368, 7356, 7376, 7371, 7351, 7350, 7370, 7352, 7372, 7355, 7375, 7377, 7357},
	[13] = {9415, 9412},
	[14] = {9410, 9413},
	[15] = {9414, 9411},
}

local infotip
local onBlock

local cacheCommon = {}
local cacheRare = {}

-- Defaults
element.defaults = {
	profile = {
		X = 1100,
		Colors = {
			Header =      { r = 0.14, g = 0.76, b = 0.15, },
		},
	},
}
------------------------------------------------------
-- / ARCHY FUNCTIONS / --
------------------------------------------------------
-- Since they reversed all the race IDs, lets revert it to how it used to be
local ID_OFFSET = GetNumArchaeologyRaces() + 1

-- Any other functions that uses race ID needs to be added here if we're using them.
local function GetNumArtifactsByRaceReverse(id) return GetNumArtifactsByRace(ID_OFFSET - id) or 0 end
local function GetArtifactInfoByRaceReverse(id, i) return GetArtifactInfoByRace(ID_OFFSET - id, i) end
local function GetArchaeologyRaceInfoReverse(id) return GetArchaeologyRaceInfo(ID_OFFSET - id) end

------------------------------------------------------
-- / INFOTIP FUNCTIONS / --
------------------------------------------------------
function element:BuildTooltip()
	infotip = module:GetModule("Infotip"):NewInfotip(element)
	infotip.Races = {}
end

function element:CreateLearnArch()
	if infotip.learnArch then return infotip.learnArch end
	local learnArch = infotip:NewLine()
	learnArch.name = learnArch:AddFontString("LEFT")
	learnArch.name:SetPoint("TOPLEFT")
	learnArch.name:SetPoint("TOPRIGHT")
	learnArch:SetPoint("TOPLEFT", GAP, -GAP)
	infotip.learnArch = learnArch
	return learnArch
end

function element:CreateArchHeader()
	if infotip.header then return infotip.header end
	local header = infotip:NewLine()
	header:SetPoint("TOPLEFT", GAP, -GAP)
	header.name = header:AddFontString("CENTER", element:Color("Header"))
	header.name:SetPoint("LEFT", header, "LEFT")
	header.fragments = header:AddFontString("CENTER", header.name, nil, element:Color("Header"))
	header.missing = header:AddFontString("CENTER", header.fragments, nil, element:Color("Header"))
	header.progress = header:AddFontString("CENTER", header.missing, nil, element:Color("Header"))
	
	infotip.header = header
	return header
end

function element:CreateArchRace(id)
	if infotip.Races[id] then return infotip.Races[id] end
	local race = infotip:NewLine()

	race.name = race:AddFontString("LEFT")
	race.name:SetPoint("LEFT", race, "LEFT")
	race.fragments = race:AddFontString("CENTER", race.name)
	race.missing = race:AddFontString("LEFT", race.fragments)
	race.progress = race:AddFontString("CENTER", race.missing)
	
	--race:AddHighlight()

	infotip.Races[id] = race
	return race
end

function element:UpdateInfotip()
	if infotip and onBlock then
		infotip:UpdateTooltip()
	end
end

------------------------------------------------------
-- / MODULE FUNCTIONS / --
------------------------------------------------------

function element:UpdateArch()
	element.text = GetArchaeologyInfo()
	element:UpdateInfotip()
end

function element:GetArchRareProgress(id)
	if not ARCH_COMMON[id] then
		return 0
	end
	local maxCommon = ARCH_COMMON[id]
	local maxRare = ARCH_RARE[id]
	local maxPristine = (ARCH_PRISTINE[id]) and #ARCH_PRISTINE[id] or 0
	local maxCollection = (ARCH_ACHIEVEMENTS[id]) and #ARCH_ACHIEVEMENTS[id] or 0
	
	local maxProgress = maxCommon + maxRare * 3 + maxPristine + maxCollection
	
	local common, rare, pristine, collection = element:GetMissingArchForRace(id)
	
	local currProgress = (maxCommon - common) + (maxRare - rare) * 3 + (maxPristine - pristine) + (maxCollection - collection)
	
	return format("%.2f%%", currProgress / maxProgress * 100)
	
end

-- Checks for the missing parts of any archaeological race.
-- Returns missing number of commons, rares, pristine and collection achievements.
function element:GetMissingArchForRace(id)
	local missingCommon, missingRare, missingPristine, missingCollection
	local currCommon, maxCommon = 0, ARCH_COMMON[id]
	local currRare, maxRare = 0, ARCH_RARE[id]
	
	--We need cached data because it's also impossible to lose artifacts so it's a pretty safe bet.
	if cacheCommon[id] and cacheCommon[id] == maxCommon then
		missingCommon = 0
	else
		--NumArtifacts returns the total amount, this loop checks for uniques.
		for i=1, GetNumArtifactsByRaceReverse(id) do
			local name, _, quality, _, _, _, _, _, count = GetArtifactInfoByRaceReverse(id,i)
			if quality == 0 and count > 0 then 
				currCommon = currCommon + 1	
			end
		end

		--If higher than the currently recorded information, update it. 
		if not cacheCommon[id] or currCommon > cacheCommon[id] then 
			cacheCommon[id] = currCommon
		end
		missingCommon = maxCommon - currCommon
	end
	
	-- And now we do the same thing for rares!
	if cacheRare[id] and cacheRare[id] == maxRare then
		missingRare = 0
	else
		for i=1, GetNumArtifactsByRaceReverse(id) do
			local name, _, quality, _, _, _, _, _, count = GetArtifactInfoByRaceReverse(id,i)
			if quality == 1 and count > 0 then 
				currRare = currRare + 1
			end 
		end
		if not cacheRare[id] or currRare > cacheRare[id] then 
			cacheRare[id] = currRare
		end
		missingRare = maxRare - currRare
	end
	
	--Check for Pristines
	if ARCH_PRISTINE[id] then
		missingPristine = #ARCH_PRISTINE[id]
		for i = 1, #ARCH_PRISTINE[id] do
			if IsQuestFlaggedCompleted(ARCH_PRISTINE[id][i]) then 
				missingPristine = missingPristine - 1
			end
		end
	else
		missingPristine = 0
	end
	
	--Check for achievements
	if ARCH_ACHIEVEMENTS[id] then
		missingCollection = #ARCH_ACHIEVEMENTS[id]
		for i = 1, #ARCH_ACHIEVEMENTS[id] do
			local _, _, _, earned = GetAchievementInfo(ARCH_ACHIEVEMENTS[id][i])
			if earned then
				missingCollection = missingCollection - 1
			end
		end
	else
		missingCollection = 0
	end
	
	return missingCommon, missingRare, missingPristine, missingCollection
end

function element:CreateMissingArchString(id)
	local common, rare, pristine, collection = element:GetMissingArchForRace(id)
	
	if common > 0 or rare > 0 or pristine > 0 or collection > 0 then
		--A better way to do comma separations would be neat.
		local sepChar = ", "
		local commonString = (common > 0) and format("%d Commons", common) or ""
		local sep1 = (common > 0 and (rare > 0 or pristine > 0 or collection > 0)) and sepChar or ""
		local rareString = (rare > 0) and format("%d Rares", rare) or ""
		local sep2 = (rare > 0 and (pristine > 0 or collection > 0)) and sepChar or ""
		local pristineString = (pristine > 0) and format("%d Pristine", pristine) or ""
		local sep3 = (pristine > 0 and (collection > 0)) and sepChar or ""
		local collectionString = (collection > 0) and format("%d Achievements", collection) or ""
		
		return format("%s%s%s%s%s%s%s", commonString, sep1, rareString, sep2, pristineString, sep3, collectionString)
	else
		return "-"
	end
end

--[[Testing code for scaling problems.
function element.OnClick(frame, button)
	--DoNothing
	local win = {
		X = 1100,
		Y = -10,
		Scale = 1,
		Point = "TOP",
	}
	LUIInfo_Archaeology.text:SetParent(UIParent)
	LUI:RegisterConfig(LUIInfo_Archaeology.text, win)
	LUI:RestorePosition(LUIInfo_Archaeology.text)
end]]

function element.OnEnter(frame)
	if not infotip then element:BuildTooltip() end
	local maxWidth, maxHeight = 0, 0
	local _, _, skillLevel = GetProfessionInfo(ARCH_PROFESSION_ID)
	if skillLevel and skillLevel > 1 then
		if infotip.learnArch then infotip.learnArch:Hide() end
		
		--Header
		local header = element:CreateArchHeader()
		header.name:SetText("Race")
		header.fragments:SetText("Fragments")
		header.missing:SetText("Missing Parts")
		header.progress:SetText("Progress")
		maxHeight = maxHeight + header:GetHeight()
	
		local nameColumnWidth = header.name:GetStringWidth()
		local fragColumnWidth = header.fragments:GetStringWidth()
		local missingColumnWidth = header.missing:GetStringWidth()
		local progressColumnWidth = header.progress:GetStringWidth()
		
		-- If we don't request the history, we may receive false or dummy information.
		-- BUG: As of 7.2, one common returns wrong information unless a second request is made.
		-- Uncomment the If statement when that's fixed.
		--if not IsArtifactCompletionHistoryAvailable() then
			RequestArtifactCompletionHistory()
		--end

		for i = 1, GetNumArchaeologyRaces() do
			local race = element:CreateArchRace(i)
			
			local name, _, _, fragCollected, fragRequired = GetArchaeologyRaceInfoReverse(i)
			
			race.name:SetText(name)
			race.fragments:SetFormattedText("%d/%d", fragCollected, fragRequired)
			race.missing:SetText(element:CreateMissingArchString(i))
			race.progress:SetText(element:GetArchRareProgress(i))
			
			nameColumnWidth = max(nameColumnWidth, race.name:GetStringWidth())
			fragColumnWidth = max(fragColumnWidth, race.fragments:GetStringWidth())
			missingColumnWidth = max(missingColumnWidth, race.missing:GetStringWidth())
			progressColumnWidth = max(progressColumnWidth, race.progress:GetStringWidth())
		end
		
		header.name:SetWidth(nameColumnWidth)
		header.fragments:SetWidth(fragColumnWidth)
		header.missing:SetWidth(missingColumnWidth)
		header.progress:SetWidth(progressColumnWidth)
	
		for i = 1, #infotip.Races do
			local race = infotip.Races[i]
			race.name:SetWidth(nameColumnWidth)
			race.fragments:SetWidth(fragColumnWidth)
			race.missing:SetWidth(missingColumnWidth)
			race.progress:SetWidth(progressColumnWidth)
			
			if i == 1 then
				race:SetPoint("TOPLEFT", infotip.header, "BOTTOMLEFT")
			else
				race:SetPoint("TOPLEFT", infotip.Races[i-1], "BOTTOMLEFT")
			end
			race:Show()

			maxHeight = maxHeight + race:GetHeight()
		end
		maxHeight = maxHeight + GAP * 2
		
		maxWidth = nameColumnWidth + fragColumnWidth + missingColumnWidth + progressColumnWidth + GAP * 5
		
	else -- does not have Arch profession
		local learnArch = element:CreateLearnArch()
		learnArch.name:SetWordWrap(true)
		learnArch.name:SetText(PROFESSIONS_ARCHAEOLOGY_MISSING)
		-- Make the text appear over two lines.
		learnArch.name:SetWidth(learnArch.name:GetStringWidth()/2)
		maxWidth = learnArch.name:GetStringWidth()/2 + GAP * 2
		maxHeight = learnArch.name:GetStringHeight() + GAP * 2
	end

	infotip:SetWidth(maxWidth)
	infotip:SetHeight(maxHeight)
	
	infotip:Show()
	onBlock = true
end

function element.OnLeave(frame)
	if not infotip:IsMouseOver() then
		infotip:Hide()
		onBlock = false
	end
end

------------------------------------------------------
-- / FRAMEWORK FUNCTIONS / --
------------------------------------------------------
function element:OnCreate()
	db = element:GetDB()
end
