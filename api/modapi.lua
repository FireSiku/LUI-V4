--- Modules api conta ins all the generic embeddable api that modules can use to easily acess or do stuff.
-- @classmod ModuleMixin

------------------------------------------------------
-- / SETUP AND LOCALS / --
------------------------------------------------------

-- Addon building reference.
local addonname, LUI = ...
local module = LUI:GetModule("API")
local element = module:NewModule("Modules")
local Media = LibStub("LibSharedMedia-3.0")
local db

--local copies
local pairs = pairs

--Local variables
local ModuleMixin = {}
local ModuleCreationMixin = {}
local modColor  -- Will hold color module.

function LUI:EmbedModule(target)
	for k, v in pairs(ModuleMixin) do
		target[k] = v
	end
end

------------------------------------------------------
-- / MODULE API  / --
------------------------------------------------------

--- Module API
-- @section moduleapi

--- Fetch a color.
-- @string color Name of the color to fetch as named in the database.
-- This will check the specific module's database and then check the generic Color module.
-- This function will be really helpful later on when we add choice to use a class or theme color instead of individual.
-- @treturn number r Red
-- @treturn number g Green
-- @treturn number b Blue
-- @treturn ?number a Alpha
function ModuleMixin:Color(colorName)
	--TODO: Fix the issue with RGB colors as RGBA colors in the options
	--TODO: Add Better Element/Module support, order to check should be the element,then parent module, then Colors.
	local color
	local db = self:GetDB("profile", "Colors")
	if db and db[colorName] then
		-- TODO: Check for all planned types (.t)
		if db[colorName].t and db[colorName].t == "Class" then
			return LUI:Color(LUI.playerClass)	
		else
			color = db[colorName]
		end
	else
		color = modColor.db.profile.Colors[colorName]
	end
	if color then return color.r, color.g, color.b end
end

-- altAlpha: If the color.a is not found, altAlpha will be used.
function ModuleMixin:AlphaColor(colorName, altAlpha)
	if not altAlpha then altAlpha = 1 end
	
	local color
	local db = self:GetDB("profile", "Colors")
	if db and db[colorName] then
		-- TODO: Check for all planned types (.t)
		if db[colorName].t and db[colorName].t == "Class" then
			return LUI:AlphaColor(LUI.playerClass, db[colorName].a)
		else
			color = db[colorName]
		end
	else
		color = modColor.db.profile.Colors[colorName]
	end
	if color then return color.r, color.g, color.b, color.a or altAlpha end
end

-- Wrapper around SharedMedia fetch features.
function ModuleMixin:FetchStatusBar(name)
	local db = self:GetDB("profile", "StatusBars")
	if db and db[name] then
		return Media:Fetch("statusbar", db[name])
	end
end

function ModuleMixin:FetchBorder(name)
	local db = self:GetDB("profile", "Borders")
	if db and db[name] then
		return Media:Fetch("border", db[name])
	end
end

function ModuleMixin:FetchBackground(name)
	local db = self:GetDB("profile", "Backgrounds")
	if db and db[name] then
		return Media:Fetch("background", db[name])
	end
end

-- Function that creates a backdrop table for use with SetBackdrop and keeps a copy around based on name. 
-- When function is called on an existing backdrop, update it and return it.
-- If Tile or Insets options aren't found in the DB, they can be optionally be set through parameters.
-- Requires a DB.Backdrop entry based on name. 
function ModuleMixin:FetchBackdrop(name, tile, tileSize, l, r, t, b)
	local db = self:GetDB("profile", "Backdrop")
	if db and db[name] then
		local backdrop
		-- Check if backdrop exists, if not create it.
		if not self.__backdrops[name] then
			backdrop = {}
			backdrop.insets = {}
			self.__backdrops[name] = backdrop
		else
			backdrop = self.__backdrops[name]
		end
		--Make sure the values are up to date.
		backdrop.bgFile = Media:Fetch("background", db[name].Background)
		backdrop.edgeFile = Media:Fetch("border", db[name].Border)
		backdrop.edgeSize = db[name].Size
		if db[name].Tile or tile then backdrop.tile = db[name].Tile or tile end
		if db[name].TileSize or tileSize then backdrop.tileSize = db[name].TileSize or tileSize end
		if db[name].Left or l then
			backdrop.insets.left = db[name].Left or l
			backdrop.insets.right = db[name].Right or r
			backdrop.insets.top = db[name].Top or t
			backdrop.insets.bottom = db[name].Bottom or b
		end
		
		return backdrop
	end
end

-- Function that fetch and set Backdrop, along with setting color and border color.
function ModuleMixin:UpdateFrameBackdrop(name, frame, ...)
	local backdrop = self:FetchBackdrop(name, ...)
	
	frame:SetBackdrop(backdrop)
	frame:SetBackdropColor(self:Color(name.."BG"))
	frame:SetBackDropBorderColor(self:Color(name.."Border"))
end

--- Quickly Setup a FontString widget
-- @tparam table frame Frame to attach the font string to.
-- @string gName Global name for the new font stirng
-- @string mFont Name of the font to fetch as named in the database.
-- @tparam[opt] ?string layer Layer on which to create the font string, default to ARTWORK.
-- @tparam[opt] ?string hJustify Set the font horizontal alignment.
-- @tparam[opt] ?string vJustify Set the font vertical alignment.
function ModuleMixin:SetFontString(frame, gName, mFont, layer, hJustify, vJustify)
	local fs = frame:CreateFontString(gName, layer)
	local db = self:GetDB("profile", "Fonts")
	local font = db[mFont]
	fs:SetFont(Media:Fetch("font", font.Name), font.Size, font.Flag)
	if hJustify then fs:SetJustifyH(hJustify) end
	if vJustify then fs:SetJustifyV(vJustify) end
	return fs
end

function ModuleMixin:RefreshFontString(fs, mFont)
	local db = self:GetDB()
	local font = db.Fonts[mFont]
	fs:SetFont(Media:Fetch("font", font.Name), font.Size, font.Flag)
	fs:SetTextColor(self:Color(mFont))
end

--- Returns a database table. It will return the profile scope by defaults.
-- @tparam[opt] ?string scope The scope to look up. Can be one of the nine database types as specified by AceDB.
-- @tparam[opt] ?string extra The name of a table in the database to return.
function ModuleMixin:GetDB(scope, extra)
	local scope = scope or "profile"
	if self:IsElement() then
		local _, parent = self:GetParent()
		db = parent.db[scope][self:GetName()]
	else
		db = self.db[scope]
	end
	return (extra) and db[extra] or db
end

--- Check if the module is an element.
-- @treturn bool Returns true if it's an element, false if it's a module (or the LUI object)
function ModuleMixin:IsElement()
	if not self.GetParent then return false end
	return (self:GetParent() ~= "LUI") and true or false
end

--- Print exclusively for Module Messages.
-- Those prints will not appear if ModuleMessages is disabled
-- @string msg Message to print. Note that this print automatically adds the module name at the start.
function ModuleMixin:ModPrint(...)
	local db = LUI:GetDB()
	if db.General.ModuleMessages then
		LUI:Print(self:GetName()..":", ...)
	end
end

------------------------------------------------------
-- / MODULE CREATION-EMBEDDED API / --
------------------------------------------------------
-- @local here
function ModuleCreationMixin:NewElement(name, ...)
	local element = self:NewModule(name, ...)
	LUI:EmbedModule(element)
	return element
end

--Make sure every element also has a :GetParent()
function ModuleCreationMixin:OnModuleCreated(element)
	element.GetParent = function()
		return self:GetName(), self
	end
end

--- Get the module's parent.
-- This function returns nil if called by LUI.
-- @function ModuleMixin:GetParent
-- @treturn string The parent's name.
-- @treturn table The parent's table

--- Toggle a module's enabled state.
-- This function is not avaible to elements or LUI.
-- @function Toggle

function LUI:OnModuleCreated(module)
	module.GetParent = function()
		return self:GetName(), self
	end
	
	--Only modules with an enableButton should be toggle-able.
	module.Toggle = function()
		local name = module:GetName()
		local state = not module:IsEnabled()
		if state then
			LUI:EnableModule(name)
		else
			LUI:DisableModule(name)
		end
		local db = LUI:GetDB()
		db.modules[name] = state
	end
	
	for k, v in pairs(ModuleCreationMixin) do
		module[k] = v
	end
end

------------------------------------------------------
-- / FRAMEWORK FUNCTIONS / --
------------------------------------------------------
-- @local here
function element:OnInitialize()
	modColor = LUI:GetModule("Colors")
end