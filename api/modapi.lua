--- Modules api contains all the generic embeddable api that modules can use to easily acess or do stuff.
-- @classmod ModuleMixin

-- ####################################################################################################################
-- ##### Setup and Locals #############################################################################################
-- ####################################################################################################################

-- Addon building reference.
local addonname, LUI = ...
local Media = LibStub("LibSharedMedia-3.0")

--local copies
local pairs = pairs

--Local variables
local ModuleMixin = {}
local ModuleCreationMixin = {}

function LUI:EmbedModule(target)
	for k, v in pairs(ModuleMixin) do
		target[k] = v
	end
end


-- ####################################################################################################################
-- ##### Module Mixin #################################################################################################
-- ####################################################################################################################

--- Module API
-- @section moduleapi

--- Fetch a colo and return the r, g, b values
-- @string color Name of the color to fetch as named in the database.
-- This will check the specific module's database and then check the generic Color module.
-- This function will be really helpful later on when we add choice to use a class or theme color instead of individual.
-- @treturn number r Red
-- @treturn number g Green
-- @treturn number b Blue
function ModuleMixin:RGB(colorName)
	--TODO: Fix the issue with RGB colors as RGBA colors in the options
	local db = self:GetDB("Colors")
	if db and db[colorName] then
		-- TODO: Check for all planned types (.t)
		if db[colorName].t and db[colorName].t == "Class" then
			return LUI:GetClassColor(LUI.playerClass)
		else
			local color = db[colorName]
			return color.r, color.g, color.b
		end
	end
	return LUI:GetFallbackRGB(colorName)
end

function ModuleMixin:RGBA(colorName)
	local db = self:GetDB("Colors")

	if db and db[colorName] then
		-- TODO: Check for all planned types (.t)
		if db[colorName].t and db[colorName].t == "Class" then
			local r, g, b = LUI:GetClassColor(LUI.playerClass)
			return r, g, b, db[colorName].a or 1
		else
			local color = db[colorName]
			return color.r, color.g, color.b, color.a or 1
		end
	end

	local r, g, b = LUI:GetFallbackRGB(colorName)
	if r and g and b then
		return r, g, b, 1
	end
end

--- Fetch a color from LUI database and creates a Blizzard Color with it.
-- @string color Name of the color to fetch as named in the database.
-- @treturn ColorMixin color
-- TODO: Cache this information?
function ModuleMixin:Color(colorName)
	local r, g, b, a = self:RGBA(colorName)
	if r and g and b then
		return CreateColor(r, g, b, a)
	end
end

function ModuleMixin:ColorText(text, colorName)
	local color = self:Color(colorName)
	if color then
		return color:WrapTextInColorCode(text)
	end
	return text
end

-- Wrapper around SharedMedia fetch features.
function ModuleMixin:FetchStatusBar(name)
	local db = self:GetDB("StatusBars")
	if db and db[name] then
		return Media:Fetch("statusbar", db[name])
	end
end

function ModuleMixin:FetchBorder(name)
	local db = self:GetDB("Borders")
	if db and db[name] then
		return Media:Fetch("border", db[name])
	end
end

function ModuleMixin:FetchBackground(name)
	local db = self:GetDB("Backgrounds")
	if db and db[name] then
		return Media:Fetch("background", db[name])
	end
end

-- Function that creates a backdrop table for use with SetBackdrop and keeps a copy around based on name.
-- When function is called on an existing backdrop, update it and return it.
-- If Tile or Insets options aren't found in the DB, they can be optionally be set through parameters.
-- Requires a DB.Backdrop entry based on name.
function ModuleMixin:FetchBackdrop(name, tile, tileSize, l, r, t, b)
	local db = self:GetDB("Backdrop")
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
	frame:SetBackdropColor(self:RGB(name.."BG"))
	frame:SetBackDropBorderColor(self:RGB(name.."Border"))
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
	local db = self:GetDB("Fonts")
	local font = db[mFont]
	fs:SetFont(Media:Fetch("font", font.Name), font.Size, font.Flag)
	if hJustify then fs:SetJustifyH(hJustify) end
	if vJustify then fs:SetJustifyV(vJustify) end
	return fs
end

function ModuleMixin:RefreshFontString(fs, mFont)
	local db = self:GetDB("Fonts")
	local font = db[mFont]
	fs:SetFont(Media:Fetch("font", font.Name), font.Size, font.Flag)
	fs:SetTextColor(self:RGB(mFont))
end

--- Returns the profile database table.
-- @tparam[opt] ?string tbl The name of a table in the database to return.
function ModuleMixin:GetDB(subTable)
	local db
	if self.db then
		db = self.db.profile
	end
	if db and subTable and type(db[subTable] == "table") then
		return db[subTable]
	end
	return db
end

--- Returns a database scope table.
-- @tparam[opt] ?string scope The scope to look up. Can be one of the nine database types as specified by AceDB.
function ModuleMixin:GetDBScope(scope)
	scope = scope or "profile"
	if self.db then
		return self.db[scope]
	end
end


--- Print exclusively for Module Messages.
-- Those prints will not appear if ModuleMessages is disabled
-- @string msg Message to print. Note that this print automatically adds the module name at the start.
function ModuleMixin:ModPrint(...)
	local db = LUI:GetDB("General")
	if db.ModuleMessages then
		LUI:Print(self:GetName()..":", ...)
	end
end

-- ####################################################################################################################
-- ##### Module Creation Mixin ########################################################################################
-- ####################################################################################################################

--- Toggle a module's enabled state.
function ModuleCreationMixin:Toggle()
	local name = self:GetName()
	local state = not self:IsEnabled()
	if state then
		LUI:EnableModule(name)
	else
		LUI:DisableModule(name)
	end
	LUI.db.profile.modules[name] = state
end

--- Merge given table into module.defaults if it exists. Support all AceDB types
---@param source table
---@param name string
function ModuleCreationMixin:MergeDefaults(source, name)
	if not self.defaults then self.defaults = {} end
	for i, scope in ipairs(LUI.DB_TYPES) do
		if source[scope] then
			if not self.defaults[scope] then self.defaults[scope] = {} end
			if name then
				self.defaults[scope][name] = LUI:CopyTable(source[scope], self.defaults[scope][name])
			else
				self.defaults[scope] = LUI:CopyTable(source[scope], self.defaults[scope])
			end
		end
	end
end

--- Since we arent doing any closure shenanigans using OnModuleCreated, this accomplish the same in a much better way.
LUI:SetDefaultModulePrototype(ModuleCreationMixin)

--- Will be executed automatically after Ace :NewModule is called, before OnInitialize
---@param newModule Module
-- function LUI:OnModuleCreated(newModule)
-- 	for k, v in pairs(ModuleCreationMixin) do
-- 		newModule[k] = v
-- 	end
-- end