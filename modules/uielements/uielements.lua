-- This module handle various UI Elements by LUI or Blizzard.
-- It's an umbrella module to consolidate the many, many little UI changes that LUI does
--	that do not need a full module for themselves.

-- ####################################################################################################################
-- ##### Setup and Locals #############################################################################################
-- ####################################################################################################################

local _, LUI = ...
local module = LUI:NewModule("UI Elements", "AceHook-3.0")
local db

--local NUM_OBJECTIVE_HEADERS = 3

-- luacheck: globals DurabilityFrame OrderHallCommandBar ObjectiveTrackerFrame
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
	if db.ObjectiveTracker.HeaderColor then
		module:SecureHook("ObjectiveTracker_Initialize", function()
			for i, v in pairs(ObjectiveTrackerFrame.MODULES) do
				module:ChangeHeaderColor(v.Header, module:RGB(LUI.playerClass))
			end
		end)
	end
	if db.ObjectiveTracker.ManagePosition then
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
-- ##### Framework Events #############################################################################################
-- ####################################################################################################################

function module:OnInitialize()
	LUI:RegisterModule(module)
	db = module.db.profile
end

function module:OnEnable()
	module:SetHiddenFrames()
	module:SetObjectiveFrame()
end

function module:OnDisable()
end
