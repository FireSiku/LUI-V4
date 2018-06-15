-- This module handle various UI Elements by LUI or Blizzard.
-- It's an umbrella module to consolidate the many, many little UI changes that LUI does
--	that do not need a full module for themselves.

-- ####################################################################################################################
-- ##### Setup and Locals #############################################################################################
-- ####################################################################################################################

local _, LUI = ...
local module = LUI:NewModule("UI Elements", "AceHook-3.0")

--local NUM_OBJECTIVE_HEADERS = 3

--local origInfo = {}

-- ####################################################################################################################
-- ##### Default Settings #############################################################################################
-- ####################################################################################################################

module.defaults = {
	profile = {
		ObjectiveTracker = {
			OffsetX = -90,
			OffsetY = -30,
			HeaderColor = true,
			ManagePosition = true,
		},
		DurabilityFrame = {
			X = -90,
			Y = 0,
			ManagePosition = false,
			HideFrame = true,
		},
		OrderHallCommandBar = {
			HideFrame = true,
		},
	},
}

-- ####################################################################################################################
-- ##### Module Functions #############################################################################################
-- ####################################################################################################################

local function ForceHide(frame)
	frame.OldShow = frame.Show
	frame.Show = frame.Hide
	frame:Hide()
end

local function RestoreFrame(frame)
	frame.Show = frame.OldShow
end

local orderUI = false
function module:SetHiddenFrames()
	local db = module:GetDB()
	-- Durability Frame
	if db.DurabilityFrame.HideFrame then
		ForceHide(DurabilityFrame)
	else
		RestoreFrame(DurabilityFrame)
		DurabilityFrame_SetAlerts()
		if db.DurabilityFrame.ManagePosition then
			DurabilityFrame:ClearAllPoints()
			-- Not Working. Figure out why.
			DurabilityFrame:SetPoint("RIGHT", Minimap, "LEFT", db.DurabilityFrame.X, db.DurabilityFrame.Y)
		else
			DurabilityFrame_SetAlerts()
		end
	end

	if db.OrderHallCommandBar.HideFrame and not orderUI then
		module:SecureHook("OrderHall_LoadUI", function()
			ForceHide(OrderHallCommandBar)
		end)
		orderUI = true
	end
end

-- ####################################################################################################################
-- ##### UIElement: ObjectiveTracker ##################################################################################
-- ####################################################################################################################

function module:ChangeHeaderColor(header, r, g, b)
	header.Background:SetDesaturated(true)
	header.Background:SetVertexColor(r, g, b)
end

function module:SetObjectiveFrame()
	local db = module:GetDB("ObjectiveTracker")
	if db.HeaderColor then
		module:SecureHook("ObjectiveTracker_Initialize", function()
			for i, v in pairs(ObjectiveTrackerFrame.MODULES) do
				module:ChangeHeaderColor(v.Header, module:RGB(LUI.playerClass))
			end
		end)
	end
	if db.ManagePosition then
		module:SecureHook("ObjectiveTracker_Update", function()
			ObjectiveTrackerFrame:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", db.OffsetX, db.OffsetY)
		end)
	end
end

-- ####################################################################################################################
-- ##### Module Refresh ###############################################################################################
-- ####################################################################################################################

function module:Refresh()
	module:SetHiddenFrames()
end


-- ####################################################################################################################
-- ##### Options Menu #################################################################################################
-- ####################################################################################################################

module.childGroups = "select"
function module:LoadOptions()
	local db = module:GetDB()
	local function DisablePosition(info)
		local parent = info[#info-1]
		return not db[parent].ManagePosition
	end
	local options = {
		Header = module:NewHeader("UI Elements", 1),
		--Note: Displaying a tree group inside of a tree group just results in collapsable entries
		--      instead of displaying two tree lists.
		--The only way around that is to make a tab group and then have its childs be a tree list.
		Elements = module:NewGroup("UI Elements", 2, "tree", nil, {
			ObjectiveTracker = module:NewGroup("ObjectiveTracker", 1, nil, nil, {
				Desc = module:NewDesc("As of currently, these options requires a Reload UI.",1),
				HeaderColor = module:NewToggle("Color Headers by Class", nil, 2),
				ManagePosition = module:NewToggle("Manage Position", nil, 3, "Refresh"),
				Offset = module:NewPosition("ObjectiveTracker", 4, nil, "Refresh", nil, DisablePosition),
			}),
			DurabilityFrame = module:NewGroup("DurabilityFrame", 2, nil, nil, {
				Desc = module:NewDesc("This frame shows a little armored guy when equipment breaks.", 1),
				HideFrame = module:NewToggle("Hide This Frame", nil, 2, "Refresh"),
				ManagePosition = module:NewToggle("Manage Position", nil, 3, "Refresh"),
				Position = module:NewPosition("DurabilityFrame", 4, true, "Refresh", nil, DisablePosition),
			}),
			OrderHallCommandBar = module:NewGroup("OrderHallCommandBar", 2, nil, nil, {
				Desc = module:NewDesc("This frame shows a bar at the top when you are in your class halls.", 1),
				HideFrame = module:NewToggle("Hide This Frame", nil, 2),
			}),
		}),
	}
	return options
end

-- ####################################################################################################################
-- ##### Framework Events #############################################################################################
-- ####################################################################################################################

function module:OnInitialize()
	LUI:RegisterModule(module)
end

function module:OnEnable()
	module:SetHiddenFrames()
	module:SetObjectiveFrame()
end

function module:OnDisable()
end
