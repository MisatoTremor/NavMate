--- GeminiAddon-1.0
-- Formerly DaiAddon
-- Inspired by AceAddon
-- Modules and packages embeds are based heavily on AceAddon's functionally, so credit goes their authors.
--
-- Allows the addon to have modules
-- Allows for packages to be embedded (if supported) into the addon and it's modules
--
-- The core callbacks have been "renamed" for consumption that are used when creating an addon:
-- OnLoad    -> OnInitialize
-- OnSave    -> OnSaveSettings
-- OnRestore -> OnRestoreSettings (delayed until the character has been loaded into the world before it is called)
-- 
-- New callback:
-- OnEnable   - Called when the character has been loaded and is in the world. Called after OnInitialize but before OnRestoreSettings
--
-- General flow should be:
-- OnInitialize -> OnEnable -> OnRestoreSettings
-- OnSaveSettings is called upon reloadui and character log out.

local MAJOR, MINOR = "Gemini:Addon-1.0", 2
local APkg = Apollo.GetPackage("Gemini:Addon-1.0")
local GeminiAddon = APkg and Apollo.GetPackage("Gemini:Addon-1.0").tPackage or {}
if GeminiAddon and (GeminiAddon._VERSION or 0) >= MINOR then
	return -- no upgrade is needed
end


local error, type, tostring, select, pairs = error, type, tostring, select, pairs
local setmetatable, getmetatable, xpcall = setmetatable, getmetatable, xpcall
local assert, loadstring, rawset, next, unpack = assert, loadstring, rawset, next, unpack
local tinsert, tremove, ostime = table.insert, table.remove, os.time

GeminiAddon._VERSION     = MINOR
GeminiAddon.Addons       = GeminiAddon.Addons or {}        -- addon collection
GeminiAddon.EnableQueue  = GeminiAddon.EnableQueue or {}   -- addons awaiting to be enabled
GeminiAddon.RestoreQueue = GeminiAddon.RestoreQueue or {}  -- addons awaiting to be restored
GeminiAddon.AddonStatus  = GeminiAddon.AddonStatus or {}   -- status of addons

 -- per addon embedded packages list
GeminiAddon.Embeds       = GeminiAddon.Embeds or setmetatable({}, {__index = function(tbl, key) tbl[key] = {} return tbl[key] end })

-- Check if the player unit is available
local function IsPlayerInWorld()
  return GameLib.GetPlayerUnit() ~= nil
end

-- xpcall safecall implementation
local function CreateDispatcher(argCount)
  local code = [[
		local xpcall, eh = ...
		local method, ARGS
		local function call() return method(ARGS) end
	
		local function dispatch(func, ...)
			 method = func
			 if not method then return end
			 ARGS = ...
			 return xpcall(call, eh)
		end
	
		return dispatch
	]]
  
  local ARGS = {}
  for i = 1, argCount do ARGS[i] = "arg"..i end
  code = code:gsub("ARGS", table.concat(ARGS, ", "))
  return assert(loadstring(code, "safecall Dispatcher[" .. argCount .. "]"))(xpcall, error)
end

local Dispatchers = setmetatable({}, {__index=function(self, argCount)
  local dispatcher = CreateDispatcher(argCount)
  rawset(self, argCount, dispatcher)
  return dispatcher
end})
Dispatchers[0] = function(func)
  return xpcall(func, error)
end

local function safecall(func, ...)
  if type(func) == "function" then
    return Dispatchers[select('#', ...)](func, ...)
  end
end


-- delay the firing the OnEnable callback until after OnLoad is called
-- this is required if we are reloading the ui
-- otherwise wait until CharacterCreated is fired
Apollo.RegisterEventHandler("CharacterCreated", "OnCharacterCreated", GeminiAddon)

--- Processes the enable and restore queues when the player enters the world
-- **Note:** do not call this manually
function GeminiAddon:OnCharacterCreated()
  -- process enable queue for each addon
  while #self.EnableQueue > 0 do
    local oAddon = tremove(self.EnableQueue, 1)
    GeminiAddon:EnableAddon(oAddon)
  end
  while #self.RestoreQueue > 0 do
    local tAddonRestore = tremove(self.RestoreQueue, 1)
    GeminiAddon:RestoreAddon(tAddonRestore.oAddon, tAddonRestore.eLevel, tAddonRestore.tSavedData)
  end
end

local function AddonToString(self)
  return self.Name
end

local Enable, Disable, EmbedAddon, GetName, SetEnabledState
local EmbedModule, EnableModule, DisableModule, NewModule, GetModule, SetDefaultModulePrototype, SetDefaultModuleState, SetDefaultModulePackages

-- Create a new addon using GeminiAddon
-- The final addon object will be returned.
-- @paramsig [object, ] strAddonName, bOnConfigure[, tDependencies][, strPkgName, ...]
-- @param object Table to use as the base for the addon (optional)
-- @param strAddonName Name of the addon object to create
-- @param bOnConfigure Add a button to the options list and fire OnConfigure when clicked.  Instead of issuing true, you can pass custom text for the button.
-- @param tDependencies List of dependencies for the addon
-- @param strPkgName List of packages to embed into the addon - requires the packages to be registered with Apollo.RegisterPackage and for the packages to support embedding
-- @usage
-- -- Create a simple addon
-- local MyAddon = Apollo.GetPackage("Gemini:Addon-1.0").tPackage:NewAddon("MyAddon", false)
-- 
-- -- Create a simple addon with a configure button with custom text
-- local MyAddon = Apollo.GetPackage("Gemini:Addon-1.0").tPackage:NewAddon("MyAddon", "Addon Options Button")
-- 
-- -- Create a simple addon with a configure button and a dependency on ChatLog / ChatLogEx
-- local MyAddon = Apollo.GetPackage("Gemini:Addon-1.0").tPackage:NewAddon("MyAddon", true, { "ChatLog", "ChatLogEx" })
-- 
-- -- Create an addon with a base object
-- local tAddonBase = { config = { ... some default settings ... }, ... }
-- local MyAddon = Apollo.GetPackage("Gemini:Addon-1.0").tPackage:NewAddon(tAddonBase, "MyAddon", false)
-- 
-- -- Create an addon with a base object with a dependency on ChatLog / ChatLogEx
-- local tAddonBase = { config = { ... some default settings ... }, ... }
-- local MyAddon = Apollo.GetPackage("Gemini:Addon-1.0").tPackage:NewAddon(tAddonBase, "MyAddon", false, { "ChatLog", "ChatLogEx" })
function GeminiAddon:NewAddon(oAddonOrName, ...)
  local oAddon, strAddonName
  local i = 1
	-- get addon name
  if type(oAddonOrName) == "table" then
    oAddon = oAddonOrName
    strAddonName = select(i, ...)
    i = 2
  else
    strAddonName = oAddonOrName
  end
  
	-- get configure state
  local strConfigBtnName = select(i, ...); i = i + 1
  local bConfigure = (strConfigBtnName == true or type(strConfigBtnName) == "string")
  if bConfigure then
    strConfigBtnName = type(strConfigBtnName) == "boolean" and strAddonName or strConfigBtnName
  else
    strConfigBtnName = ""
  end
  
	-- get dependencies
  local tDependencies
  if type(select(i, ...)) == "table" then
    tDependencies = select(i, ...)
    i = i + 1
  else
    tDependencies = {}
  end
  
  if type(strAddonName) ~= "string" then
    error(("Usage: NewAddon([object, ] strAddonName, bOnConfigure[, tDependencies][, strPkgName, ...]): 'strAddonName' - string expected got '%s'."):format(type(strAddonName)), 2)
  end
  if self.Addons[strAddonName] then
    error(("Usage: NewAddon([object, ] strAddonName, bOnConfigure[, tDependencies][, strPkgName, ...]): 'strAddonName' - Addon '%s' already registered in GeminiAddon."):format(strAddonName), 2)
  end
  
  oAddon = oAddon or {}
  oAddon.Name = strAddonName
  
  -- use existing metatable if exists
  local addonmeta = {}
  local oldmeta = getmetatable(oAddon)
  if oldmeta then
    for k,v in pairs(oldmeta) do addonmeta[k] = v end
  end
  addonmeta.__tostring = AddonToString
  setmetatable(oAddon, addonmeta)
  
  -- setup addon skeleton
  self.Addons[strAddonName] = oAddon
  oAddon.Modules = {}
  oAddon.OrderedModules = {}
  oAddon.DefaultModulePackages = {}

  
  -- Embed any packages that are needed
  EmbedAddon( oAddon )
  self:EmbedPackages(oAddon, select(i, ...))
  
  -- Setup callbacks for the addon
	-- Setup the OnLoad callback handler to initialize the addon
	-- and either enable or delay enable the addon
  oAddon.OnLoad = function(self)
    GeminiAddon:InitializeAddon(self)
    
    if IsPlayerInWorld() then
      GeminiAddon:EnableAddon(self)
    else
      tinsert(GeminiAddon.EnableQueue, self)
    end
  end
  
	-- Setup the OnRestore callback handler to either call OnRestoreSettings or
	-- delay until the character is loaded
  oAddon.OnRestore = function(self, eLevel, tSavedData)
    if IsPlayerInWorld() then
      safecall(self.OnRestoreSettings, self, eLevel, tSavedData)
    else
      tinsert(GeminiAddon.RestoreQueue, { oAddon = self, eLevel = eLevel, tSavedData = tSavedData })
    end
  end
  
	-- Setup the OnSave callback handler to call OnSaveSettings
  oAddon.OnSave = function(self, eLevel)
    if type(self.OnSaveSettings) == "function" then
      return self:OnSaveSettings(eLevel)
    end
  end
    
		
	-- register the addon with Apollo
  Apollo.RegisterAddon(oAddon, bConfigure, strConfigBtnName, tDependencies)
  
  return oAddon  
end

-- Get the addon object by its name from the internal GeminiAddon addon registry
-- Throws an error if the addon object cannot be found (except if silent is set)
-- @param strAddonName the addon name registered with GeminiAddon
-- @param bSilent return nil if addon is not found instead of throwing an error
-- @usage
-- local MyAddon = Apollo.GetPackage("Gemini:Addon-1.0").tPackage:GetAddon("MyAddon")
function GeminiAddon:GetAddon(strAddonName, bSilent)
  if not bSilent and not self.Addons[strAddonName] then
    error(("Usage: GetAddon(strAddonName): 'strAddonName' - Cannot find an GeminiAddon called '%s'."):format(tostring(strAddonName)), 2)
  end
  return self.Addons[strAddonName]
end


-- Used internally when OnRestore is delayed
function GeminiAddon:RestoreAddon(oAddon, eLevel, tSavedData)
  safecall(oAddon.OnRestoreSettings, oAddon, eLevel, tSavedData)
end

--- Enable the addon
-- Used internally when the player has entered the world
-- 
-- **Note:** do not call this manually
-- @param oAddon addon object to enable
function GeminiAddon:EnableAddon(oAddon)
  if type(oAddon) == "string" then 
    oAddon = self:GetAddon(oAddon) 
  end
  
  local strAddonName = oAddon:GetName()
  
  if self.AddonStatus[strAddonName] or not oAddon.EnabledState then
    return false
  end
  
  self.AddonStatus[strAddonName] = true
  
  safecall(oAddon.OnEnable, oAddon)
  
  if self.AddonStatus[strAddonName] then
    -- embed packages
    local tEmbeds = self.Embeds[oAddon]
    for i = 1, #tEmbeds do
      local oPkg = Apollo.GetPackage(tEmbeds[i]).tPackage
      if oPkg then
        safecall(oPkg.OnEmbedEnable, oPkg, oAddon)
      end
    end
    
    -- enable modules
    local tModules = oAddon.OrderedModules
    for i = 1, #tModules do
      oAddon:EnableModule(tModules[i].ModuleName)
    end
  end
  return self.AddonStatus[strAddonName]
end

--function GeminiAddon:DisableAddon(oAddon)
--  if type(oAddon) == "string" then
--    oAddon = self:GetAddon(oAddon)
--  end
--
--  local strAddonName = oAddon:GetName()
--
--  if not self.AddonStatus[strAddonName] then
--    return false
--  end
--
--  if self.AddonStatus[strAddonName] then
--    local tEmbeds = self.Embeds[oAddon]
--    for i = 1, #tEmbeds do
--      local oPkg = Apollo.GetPackage(tEmbeds[i]).tPackage
--      if oPkg then
--        safecall(oPkg.OnEmbedDisable, oPkg, oAddon)
--      end
--    end
--
--    local tModules = oAddon.OrderedModules
--    for i = 1, #tModules do
--      oAddon:DisableModule(tModules[i])
--    end
--  end
--
--  return not self.AddonStatus[strAddonName]
--end



--- Initialize the addon after creation
-- Used internally when OnLoad is called for the addon
--
-- **Note:** do not call this manually
-- @param oAddon addon object to initialize
function GeminiAddon:InitializeAddon(oAddon)
  safecall(oAddon.OnInitialize, oAddon)
  
  local tEmbeds = self.Embeds[oAddon]
  for i = 1, #tEmbeds do
    local oPkg = Apollo.GetPackage(tEmbeds[i]).tPackage
    if oPkg then 
      safecall(oPkg.OnEmbedInitialize, oPkg, oAddon) 
    end
  end
end

--- Embed packages into the specified addon
-- @paramsig oAddon[, strPkgName, ...]
-- @param oAddon The addon object to embed packages in
-- @param strPkgName List of packages to embed into the addon
function GeminiAddon:EmbedPackages(oAddon, ...)
  for i = 1, select('#', ...) do
    local strPkgName = select(i, ...)
    self:EmbedPackage(oAddon, strPkgName, false, 4)
  end
end

--- Embed a package into the specified addon
--
-- **Note:** This function is for internal use by :EmbedPackages
-- @paramsig strAddonName, strPkgName[, silent[, offset]]
-- @param strAddonName addon object to embed the package in
-- @param strPkgName name of the package to embed
-- @param bSilent marks an embed to fail silently if the package doesn't exist (optional)
-- @param nOffset will push the error messages back to said offset, defaults to 2 (optional)
function GeminiAddon:EmbedPackage(oAddon, strPkgName, bSilent, nOffset)
  local oPkg = Apollo.GetPackage(strPkgName).tPackage
  if not oPkg and not bSilent then
    error(("Usage: EmbedPackage(oAddon, strPkgName, bSilent, nOffset): 'strPkgName' - Cannot find a package instance of '%s'."):format(tostring(strPkgName)), nOffset or 2)
  elseif oPkg and type(oPkg.Embed) == "function" then
    oPkg:Embed(oAddon)
    tinsert(self.Embeds[oAddon], strPkgName)
    return true
  elseif oPkg then
    error(("Usage: EmbedPackage(oAddon, strPkgName, bSilent, nOffset): Package '%s' is not Embed capable."):format(tostring(strPkgName)), nOffset or 2)
  end
end

--- Return the specified module from an addon object.
-- Throws an error if the addon object cannot be found (except if silent is set)
-- @name //addon//:GetModule
-- @paramsig strModuleName[, bSilent]
-- @param strModuleName unique name of the module
-- @param bSilent if true, the module is optional, silently return nil if its not found (optional)
-- @usage 
-- local MyModule = MyAddon:GetModule("MyModule")
function GetModule(self, strModuleName, bSilent)
  if not self.Modules[strModuleName] and not bSilent then
    error(("Usage: GetModule(strModuleName, bSilent): 'strModuleName' - Cannot find module '%s'."):format(tostring(strModuleName)), 2)
  end
  return self.Modules[strModuleName]
end



--- Creates an empty module prototype
-- Used internally
-- **Note:** do not call this manually
-- @param strName unique name of the module
-- @return oModule the module object
function GeminiAddon:NewModule(strName)
  local oModule = {}
  oModule.Name = strName
  
  -- use existing metatable if exists
  local addonmeta = {}
  addonmeta.__tostring = GetName
  setmetatable(oModule, addonmeta)
  
  return oModule
end

--- Create a new module for the addon.
-- The new module can have its own embedded packages and/or use a module prototype to be mixed into the module.
-- @name //addon//:NewModule
-- @paramsig strName[, oPrototype|strPkgName[, strPkgName, ...]]
-- @param strName unique name of the module
-- @param oPrototype object to derive this module from, methods and values from this table will be mixed into the module (optional)
-- @param strPkgName List of packages to embed into the module
-- @usage 
-- -- Create a module with some embeded packages
-- local MyModule = MyAddon:NewModule("MyModule", "PkgWithEmbed-1.0", "PkgWithEmbed2-1.0")
-- 
-- -- Create a module with a prototype
-- local oPrototype = { OnEnable = function(self) print("OnEnable called!") end }
-- local MyModule = MyAddon:NewModule("MyModule", oPrototype, "PkgWithEmbed-1.0", "PkgWithEmbed2-1.0")
function NewModule(self, strName, oPrototype, ...)
	if type(strName) ~= "string" then error(("Usage: NewModule(strName, [oPrototype, [strPkgName, strPkgName, strPkgName, ...]): 'strName' - string expected got '%s'."):format(type(strName)), 2) end
	if type(oPrototype) ~= "string" and type(oPrototype) ~= "table" and type(oPrototype) ~= "nil" then error(("Usage: NewModule(strName, [oPrototype, [strPkgName, strPkgName, strPkgName, ...]): 'oPrototype' - table (oPrototype), string (strPkgName) or nil expected got '%s'."):format(type(oPrototype)), 2) end
	if self.Modules[strName] then error(("Usage: NewModule(strName, [oPrototype, [strPkgName, strPkgName, strPkgName, ...]): 'strName' - Module '%s' already exists."):format(strName), 2) end
  
  local oModule = GeminiAddon:NewModule(string.format("%s_%s", self:GetName() or tostring(self), strName))
  oModule.ModuleName = strName
  
  EmbedModule(oModule)
  
  if type(oPrototype) == "string" then
    GeminiAddon:EmbedPackages(oModule, oPrototype, ...)
	else
    GeminiAddon:EmbedPackages(oModule, ...)
	end
	GeminiAddon:EmbedPackages(oModule, unpack(self.DefaultModulePackages))

	if not oPrototype or type(oPrototype) == "string" then
		oPrototype = self.DefaultModulePrototype or nil
    --self:_Log("Using Prototype type: " .. tostring(oPrototype))
	end
	
	if type(oPrototype) == "table" then
		local mt = getmetatable(oModule)
		mt.__index = oPrototype
		setmetatable(oModule, mt)
	end
	
	safecall(self.OnModuleCreated, self, oModule)
	self.Modules[strName] = oModule
	tinsert(self.OrderedModules, oModule)
	
	return oModule  
end


--- returns the name of the addon or module without any prefix
-- @name //addon|module//:GetName
-- @paramsig
-- @usage
-- Print(MyAddon:GetName())
-- Print(MyAddon:GetModule("MyModule"):GetName())
function GetName(self)
  return self.ModuleName or self.Name
end

-- Check if the addon is queued to be enabled
local function QueuedForEnable(oAddon)
  for i = 1, #GeminiAddon.EnableQueue do
    if GeminiAddon.EnableQueue[i] == oAddon then
      return true
    end
  end
  return false
end

--- Enables the addon, if possible, returns true on success.
-- This internally calls GeminiAddon:EnableAddon(), thus dispatching the OnEnable callback
-- and enabling all modules on the addon
-- :Enable() also sets the internal `enableState` variable to true.
-- @name //addon//:Enable
-- @paramsig
-- @usage
function Enable(self)
  self:SetEnabledState(true)
  
  if not QueuedForEnable(self) then
    if IsPlayerInWorld() then
      -- attempt to enable it
      return GeminiAddon:EnableAddon(self)
    else
      -- add to enable queue
      tinsert(GeminiAddon.EnableQueue, self)
    end
  end
end

--function Disable(self)
--  self:SetEnabledState(false)
--  return GeminiAddon:DisableAddon(self)
--end


--- Enables the Module, if possible, return true or false depending on success.
-- Short-hand function that retrieves the module via `:GetModule` and calls `:Enable` on the module object.
-- @name //addon//:EnableModule
-- @paramsig name
-- @usage 
-- -- Enable MyModule using :GetModule
-- local MyModule = MyAddon:GetModule("MyModule")
-- MyModule:Enable()
--
-- -- Enable MyModule using the short-hand
-- MyAddon:EnableModule("MyModule")
function EnableModule(self, strModuleName)
  local oModule = self:GetModule(strModuleName)
  return oModule:Enable()
end

--- Disables the Module, if possible, return true or false depending on success.
-- Short-hand function that retrieves the module via `:GetModule` and calls `:Disable` on the module object.
-- @name //addon//:DisableModule
-- @paramsig name
-- @usage 
-- -- Disable MyModule using :GetModule
-- local MyModule = MyAddon:GetModule("MyModule")
-- MyModule:Disable()
--
-- -- Disable MyModule using the short-hand
-- local MyAddon:DisableModule("MyModule")
function DisableModule(self, strModuleName)
  local oModule = self:GetModule(strModuleName)
  return oModule:Disable()
end

--- Set the default packages to be mixed into all modules created by this object.
-- Note that you can only change the default module packages before any module is created.
-- @name //addon//:SetDefaultModulePackages
-- @paramsig strPkgName[, strPkgName, ...]
-- @param strPkgName List of Packages to embed into the addon
-- @usage 
-- -- Create the addon object
-- local MyAddon = Apollo.GetPackage("Gemini:Addon-1.0").tPackage:NewAddon("MyAddon")
-- -- Configure default packages for modules
-- MyAddon:SetDefaultModulePackages("MyEmbeddablePkg-1.0")
-- -- Create a module
-- local MyModule = MyAddon:NewModule("MyModule")
function SetDefaultModulePackages(self, ...)
  if next(self.Modules) then
    error("Usage: SetDefaultModulePackages(...): cannot change the module defaults after a module has been registered.", 2)
  end
  self.DefaultModulePackages = {...}
end

--- Set the default state in which new modules are being created.
-- Note that you can only change the default state before any module is created.
-- @name //addon//:SetDefaultModuleState
-- @paramsig state
-- @param state Default state for new modules, true for enabled, false for disabled
-- @usage 
-- -- Create the addon object
-- local MyAddon = Apollo.GetPackage("Gemini:Addon-1.0").tPackage:NewAddon("MyAddon")
-- -- Set the default state to "disabled"
-- MyAddon:SetDefaultModuleState(false)
-- -- Create a module and explicilty enable it
-- local MyModule = MyAddon:NewModule("MyModule")
-- MyModule:Enable()
function SetDefaultModuleState(self, bState)
  if next(self.Modules) then
    error("Usage: SetDefaultModuleState(bState): cannot change the module defaults after a module has been registered.", 2)
  end
  self.DefaultModuleState = bState
end

--- Set the default prototype to use for new modules on creation.
-- Note that you can only change the default prototype before any module is created.
-- @name //addon//:SetDefaultModulePrototype
-- @paramsig prototype
-- @param prototype Default prototype for the new modules (table)
-- @usage 
-- -- Define a prototype
-- local prototype = { OnEnable = function(self) print("OnEnable called!") end }
-- -- Set the default prototype
-- MyAddon:SetDefaultModulePrototype(prototype)
-- -- Create a module and explicitly Enable it
-- local MyModule = MyAddon:NewModule("MyModule")
-- MyModule:Enable()
-- -- should print "OnEnable called!" now
-- @see NewModule
function SetDefaultModulePrototype(self, tPrototype)
	if next(self.Modules) then
		error("Usage: SetDefaultModulePrototype(tPrototype): cannot change the module defaults after a module has been registered.", 2)
	end
	if type(tPrototype) ~= "table" then
		error(("Usage: SetDefaultModulePrototype(tPrototype): 'tPrototype' - table expected got '%s'."):format(type(tPrototype)), 2)
	end
	self.DefaultModulePrototype = tPrototype
end

--- Set the state of an addon or module
-- This should only be called before any enabling actually happened, e.g. in/before OnInitialize.
-- @name //addon|module//:SetEnabledState
-- @paramsig state
-- @param state the state of an addon or module  (enabled = true, disabled = false)
function SetEnabledState(self, bState)
  self.EnabledState = bState
end

--- Return an iterator of all modules associated to the addon.
-- @name //addon//:IterateModules
-- @paramsig 
-- @usage 
-- -- Enable all modules
-- for strModuleName, oModule in MyAddon:IterateModules() do
--    oModule:Enable()
-- end
local function IterateModules(self) return pairs(self.Modules) end

-- Returns an iterator of all embeds in the addon
-- @name //addon//:IterateEmbeds
-- @paramsig 
local function IterateEmbeds(self) return pairs(GeminiAddon.Embeds[self]) end

--- Query the enabledState of an addon.
-- @name //addon//:IsEnabled
-- @paramsig 
-- @usage 
-- if MyAddon:IsEnabled() then
--     MyAddon:Disable()
-- end
local function IsEnabled(self) return self.EnabledState end


local function AddonLog(self, t)
  self._DebugLog = self._DebugLog or {}
  tinsert(self._DebugLog, { what = t, when = ostime() })
end

local tAddonMixins = {
	NewModule = NewModule,
	GetModule = GetModule,
	Enable = Enable,
	Disable = Disable,
	EnableModule = EnableModule,
	DisableModule = DisableModule,
	IsEnabled = IsEnabled,
	SetDefaultModulePackages = SetDefaultModulePackages,
	SetDefaultModuleState = SetDefaultModuleState,
	SetDefaultModulePrototype = SetDefaultModulePrototype,
	SetEnabledState = SetEnabledState,
	IterateModules = IterateModules,
	IterateEmbeds = IterateEmbeds,
	GetName = GetName,
--  _Log = AddonLog,
  DefaultModuleState = true,
  EnabledState = true,
}

local tModuleMixins = {
  GetName = GetName,
--  _Log = AddonLog,
	IsEnabled = IsEnabled,
	SetEnabledState = SetEnabledState,
  Enable = function(self)
    safecall(self.OnEnable, self)
    if self.EnabledState then
      -- embed packages
      local tEmbeds = GeminiAddon.Embeds[self]
      for i = 1, #tEmbeds do
        local oPkg = Apollo.GetPackage(tEmbeds[i]).tPackage
        if oPkg then
          safecall(oPkg.OnEmbedEnable, oPkg, self)
        end
      end
    end
  end,
  Disable = function(self)
    local tEmbeds = GeminiAddon.Embeds[self]
    for i = 1, #tEmbeds do
      local oPkg = Apollo.GetPackage(tEmbeds[i]).tPackage
      if oPkg then
        safecall(oPkg.OnEmbedDisable, oPkg, self)
      end
    end
  end,
}

-- Embed( target )
-- target (object) - target GeminiAddon object to embed in
--
-- **Note:** This is for internal use only.  Do not call manually
local function Embed(target, mixins)
	for k, v in pairs(mixins) do
		target[k] = v
	end
end

function EmbedAddon(target)
  Embed(target, tAddonMixins)
end

function EmbedModule(target)
  Embed(target, tModuleMixins)
end



--- Get an iterator over all registered addons.
-- @usage 
-- -- Print a list of all registered GeminiAddons
-- for name, addon in GeminiAddon:IterateAddons() do
--   print("Addon: " .. name)
-- end
function GeminiAddon:IterateAddons() return pairs(self.Addons) end

--- Get an iterator over the internal status registry.
-- @usage 
-- -- Print a list of all enabled addons
-- for name, status in GeminiAddon:IterateAddonStatus() do
--   if status then
--     print("EnabledAddon: " .. name)
--   end
-- end
function GeminiAddon:IterateAddonStatus() return pairs(self.AddonStatus) end


function GeminiAddon:OnLoad() end
function GeminiAddon:OnDependencyError(strDep, strError) return false end

Apollo.RegisterPackage(GeminiAddon, MAJOR, MINOR, {})
