-- API file that handles the backend of all addon-support files.
-- ####################################################################################################################
-- ##### Setup and Locals #############################################################################################
-- ####################################################################################################################

local _, LUI = ...
local L = LUI.L

-- To update every patch

local LIVE_BUILD = "41488" -- Dec 14 2021
local LIVE_TOC = 90105
local BETA_TOC = 90105

-- ####################################################################################################################
-- ##### LUI.IsPTR ####################################################################################################
-- ####################################################################################################################

-- Check the TOC number and then compare builds. Live version can end up with a build higher than Beta.

local _, patchBuild, _, patchTOC = GetBuildInfo()
local isPTR = false
local isBeta = false
if patchTOC > BETA_TOC then
    isBeta = true
elseif patchTOC > LIVE_TOC then
    isPTR = true
elseif patchBuild > LIVE_BUILD then
    isPTR = true
end

local printedMessage = false

--- Check if playing on the PTR.
---@return boolean
function LUI:IsPTR()
    if isPTR and not printedMessage then
        LUI:Print("New patch version detected, using compatibility code.")
        printedMessage = true
    end

    return isPTR
end

--- Check if playing on the Beta.
---@return boolean
function LUI:IsBeta()
    if isBeta and not printedMessage then
        LUI:Print("Shadowlands Beta detected, using beta branch code")
        printedMessage = true
    end
    
    return isBeta
end
