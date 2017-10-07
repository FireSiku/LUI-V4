--- Core API only contains generic API methods found in LUI object.
-- @classmod coreapi

-- @type LUI

------------------------------------------------------
-- / SETUP AND LOCALS / --
------------------------------------------------------
local addonname, LUI = ...
local module = LUI:NewModule("API")

local type, pairs = type, pairs
local strmatch, tostring = strmatch, tostring
local tinsert, tremove = tinsert, tremove
local min, max, math = min, max, math
local GetFunctionCPUUsage = GetFunctionCPUUsage

local LibWin = LibStub("LibWindow-1.1")

-- Constants
local MAX_AVG_ENTRIES = 10000
local MS_PER_SECOND = 1000

-- local variables
local cpuProfile = {}
local cpuAvgProfile = {}

--Dummy module db for API module.
module.defaults = {
	profile = {
		Enable = true,
	},
}

------------------------------------------------------
-- / TEXCOORD ATLAS API / --
------------------------------------------------------

-- Instead of having TexCoords Constants peppered amongst various files, keep them all centralized in here.
-- TexCoords are calculated such as 2/64 means 2 pixels to the left of a 64px file.
local gTexCoordAtlas = {
	MicroBtn_Default = { 15/64, 48/64, 2/32, 30/32 },
	MicroBtn_Right =   {  1/64, 47/64, 2/32, 30/32 },
	MicroBtn_Left =    {  1/64, 49/64, 2/32, 30/32 },
	CleanUp =          {  4/28, 24/28, 3/26, 22/26 },
}

--Returns TexCoords based on the given string that matches the table above
function LUI:GetCoordAtlas(atlas)
	local t = gTexCoordAtlas[atlas]
	return t[1], t[2], t[3], t[4]
end

------------------------------------------------------
-- / LIBWINDOW API / --
------------------------------------------------------
-- Wrapper around LibWindow for sake of implementation

-- This call initializes a frame for use with LibWindow, and tells it where configuration data lives. 
-- Note: Since LUI supports profiles, it is needed to do a new .RegisterConfig and .RestorePosition to every frame
--       that is being affected in the :Refresh call.
-- TODO: Implement a way to remember what frames have been affected, and automatically handle this.
function LUI:RegisterConfig(frame, storage, names)
	if not names then
		--By default, the names need to be lower case, but all of LUI's db options are using PascalCase.
		names = {
			x = "X", y = "Y", 
			point = "Point", 
			scale = "Scale",
		}
	end
	LibWin.RegisterConfig(frame, storage, names)
end

-- This computes which quadrant the frame lives in, and saves its position relative to the right corner.
-- Usage: frame:SetScript("OnDragStop", LUI.SavePosition)
-- No need to call this yourself if you used :MakeDraggable on the frame.
function LUI:SavePosition(frame)
	LibWin.SavePosition(frame)
end

-- Restore frame and scale from config data 
function LUI:RestorePosition(frame)
	LibWin.RestorePosition(frame)
end

-- Sets the scale of the frame without causing it to move and saves it. 
function LUI:SetScale(frame, scale)
	LibWin.SetScale(frame, scale)
end

-- Adds drag handlers to the frame and makes it movable. 
-- Positioning information is automatically stored according to :RegisterConfig().
function LUI:MakeDraggable(frame)
	LibWin.MakeDraggable(frame)
end

--Other functions LibWindow has that arent implemented because I dont believe will be used:
--LibWin.EnableMouseOnAlt
--LibWin.EnableMouseWheelScaling

------------------------------------------------------
-- / GENERAL API / --
------------------------------------------------------

--Count the number of entries in a table. This is done because #Table only returns array.
function LUI:Count(t,isPrint)
	local count = 0
	if type(t) == "table" then
		for _ in pairs(t) do count = count + 1 end
	end
	if isPrint then
		LUI:Print(count)
	else
		return count
	end
end

--Give us a sorted table to work with, fill the array with the keys, then sort based on the values in original table
--then we can just use a for loop to get a sorted result and call original[ sorted[i] ] for the value
--Went with a return-less approach that you need to provide the sort table because otherwise,
--I would need to create a new table every single call, and that would create needless garbage.
function LUI:SortTable(sortT, origT, sortFunc)
	wipe(sortT)
	for k in pairs(origT) do sortT[#sortT+1] = k end
	sort(sortT, sortFunc)
end

--Copy a table recursively.
function LUI:CopyTable(source, target)
	if type(target) ~= "table" then target = {} end
	for k, v in pairs(source) do
		if type(v) == "table" then
			target[k] = LUI:CopyTable(v, target[k])
		elseif not target[k] then
			target[k] = v
		end
	end
	return target
end

--- Print a table to the chat frame
function LUI:PrintTable(tbl)
	if type(tbl) ~= "table" then return LUI:Print("Tried to Print a nil table.") end
	LUI:Print("-------------------------")
	for k, v in pairs(tbl) do
		LUI:Print(k,v)
	end
	LUI:Print("-------------------------")
end

--takes table, second arg for recursion. Prints an entire table to default chat.
function LUI:PrintFullTable(tbl,msg, recurse)
	if type(tbl) ~= "table" then return LUI:Print("Tried to Print a nil table.") end
	if not recurse then LUI:Print("-------------------------") end
	msg = msg or ""
	for k,v in pairs(tbl) do
		if type(v) == "table" then
			LUI:Print(msg,k,v)
			LUI:PrintFullTable(v,msg.."-- ", true)
		else LUI:Print(msg,k,v) end
	end
	if not recurse then LUI:Print("-------------------------") end
end

------------------------------------------------------
-- / DEV FUNCTIONS / --
------------------------------------------------------

--Function to find a wildcard inside the _G global table.
function GFind(arg, keyOnly)
	for k, v in pairs(_G) do
		if strmatch(k, arg) then
			LUI:Print(k,not keyOnly and v or nil)
		end
	end
end

function GFindValue(arg, keyOnly)
	for k, v in pairs(_G) do
		if v == arg then
			LUI:Print(k)
		end
	end
end

function GFindCTables()
	for k, v in pairs(_G) do
		if strmatch(k, "C_") and type(v) == "table" then
			LUI:Print(k,v)
		end
	end
end

function LUI:CPUProfile(func, include)
	-- Prepare a table entry for our func
	local name = tostring(func)
	if not cpuProfile[name] then
		cpuProfile[name] = 0
		cpuAvgProfile[name] = {}
	end

	--locals
	local cpuUsage = GetFunctionCPUUsage(func, include)
	local msExecTime = (cpuUsage - cpuProfile[name]) * MS_PER_SECOND
	cpuProfile[name] = cpuUsage
	tinsert(cpuAvgProfile[name], msExecTime)
	if #cpuAvgProfile[name] > MAX_AVG_ENTRIES then
		tremove(cpuAvgProfile[name], 1)
	end

	--Calculate statistics
	local sum = 0
	local vmin, vmax = math.huge, -math.huge
	for i = 1, #cpuAvgProfile[name] do
		local result = cpuAvgProfile[name][i]
		sum = sum + result
		vmin = min(vmin, result)
		vmax = max(vmax, result)
	end
	local avg = (sum / #cpuAvgProfile[name])

	LUI:Printf("%.2fms (min: %.2fms, max: %.2fms, avg: %.2fms)", msExecTime, vmin, vmax, avg)
end

--Function to add a bright border around a given frame to help seeing it and its size.
function LUI:HighlightBorder(frame)
	local glowBackdrop = {
		bgFile="Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile="Interface\\AddOns\\LUI\\media\\statusbar\\glowTex.tga",
		--tile=0, tileSize=0,
		edgeSize=5,
		insets={left=3, right=3, top=3, bottom=3}
	}
	frame:SetBackdrop(glowBackdrop)
	frame:SetBackdropColor(0,0,0,0)
	frame:SetBackdropBorderColor(1,1,0,1)
end

--Keeping the basic structure of the function for the next time something is needed to profile.
function LUI:SpeedTest()
	--We're using debugprofilestop instead of the original GetTime due to being more precise for profiling.
	local GetTime = debugprofilestop
	local start, finish, mark
	local iter = 1000000
	
	-- Use Player micro button for Coord testing
	local player = LUIMicromenu_Player.tex
	local atlas = "MicroBtn_Left"
	
	local function Bench(name, start, finish, mark)
		LUI:Print(name, finish - start, format("(%.f%%)", ((finish-start)/mark)*100))
	end
	
	--[[ We'll use this one as the baseline to compare the others to.
	start = GetTime()
	for i = 1, iter do
		player:SetTexCoord(1/64, 49/64, 2/32, 30/32)
	end
	finish = GetTime()
	
	Bench("player:SetTexCoord(1/64, 49/64, 2/32, 30/32)", start, finish, mark)--]]

	start = GetTime()
	for i = 1, iter do
		player:SetTexCoord(LUI:GetCoordAtlas(atlas))
	end
	finish = GetTime()
	mark = finish - start
	Bench("player:SetTexCoord(LUI:GetCoordAtlas(atlas))", start, finish, mark)
	
	start = GetTime()
	for i = 1, iter do
		LUI:SetCoordAtlas(player, atlas)
	end
	finish = GetTime()
	Bench("LUI:SetCoordAtlas(player, atlas)", start, finish, mark)
end
