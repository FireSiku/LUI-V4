-- API file that handles the backend of all addon-support files.
-- ####################################################################################################################
-- ##### Setup and Locals #############################################################################################
-- ####################################################################################################################

local _, LUI = ...
local L = LUI.L

-- Needs to be updated every patch.

local LIVE_BUILD = "42010" -- Jan 20 2022
local LIVE_TOC = 90105
local BETA_TOC = 100000

-- ####################################################################################################################
-- ##### LUI.IsPTR ####################################################################################################
-- ####################################################################################################################
-- Check the TOC number and then compare builds. Live version can end up with a build higher than Beta.

local _, patchBuild, _, patchTOC = GetBuildInfo()
local printedMessage = false
local isPTR = false
local isBeta = false

if patchTOC > BETA_TOC then
    isBeta = true
elseif patchTOC > LIVE_TOC then
    isPTR = true
elseif patchBuild > LIVE_BUILD then
    isPTR = true
end

--- Check if playing on the PTR.
---@return boolean isPTR
function LUI:IsPTR()
    if isPTR and not printedMessage then
        LUI:Print("New patch version detected. Enabled compatibility code.")
        printedMessage = true
    end
    return isPTR
end

--- Check if playing on the Beta
---@return boolean isBeta
function LUI:IsBeta()
    if isBeta and not printedMessage then
        LUI:Print("WoW Beta detected. Enabled Beta Branch code.")
        printedMessage = true
    end
    return isBeta
end