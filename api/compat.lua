-- API file that handles the backend of all addon-support files.
-- ####################################################################################################################
-- ##### Setup and Locals #############################################################################################
-- ####################################################################################################################

local _, LUI = ...
local L = LUI.L

-- To update every patch
local LIVE_BUILD = "27009" -- Jul 3 2018
local LIVE_TOC = 80000

-- ####################################################################################################################
-- ##### LUI.IsPTR ####################################################################################################
-- ####################################################################################################################

-- Check the TOC number and then compare builds. Live version can end up with a build higher than Beta.
local _, patchBuild, _, patchTOC = GetBuildInfo()
local isPTR = false
if patchTOC > LIVE_TOC then
    isPTR = true
elseif patchBuild > LIVE_BUILD then
	isPTR = true
end

local printedMessage = false
function LUI:IsPTR()
    if isPTR and not printedMessage then
        LUI:Print("New patch version detected, using compatibility code.")
        printedMessage = true
    end
    return isPTR
end