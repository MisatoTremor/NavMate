-----------------------------------------------------------------------------------------------
-- Client Lua Script for NavMate
-- Copyright (c) NCsoft. All rights reserved
-- @author daihenka
-----------------------------------------------------------------------------------------------
 
require "Apollo"
require "Window"
require "GameLib"
require "PlayerPathLib"
require "ICCommLib"
require "GroupLib"
require "Sound"
require "Unit"
require "HexGroups"
 
-----------------------------------------------------------------------------------------------
-- NavMate Module Definitions
-----------------------------------------------------------------------------------------------
local ADDON_NAME     = "NavMate"
local CONFIG_VERSION = 2

local NavMate        = Apollo.GetAddon("NavMate")
local L              = NavMate.L
local GUILib         = Apollo.GetPackage("Gemini:GUI-1.0").tPackage
local GLocale        = Apollo.GetPackage("Gemini:Locale-1.0").tPackage
local Waypoint       = NavMate.Waypoint
local waypoints      = NavMate.waypoints      -- waypoints collection

-----------------------------------------------------------------------------------------------
-- Constants and Local Variables
-----------------------------------------------------------------------------------------------
local _G = _G
local setmetatable, rawget, rawset = setmetatable, rawget, rawset
local pairs, ipairs, tostring, type = pairs, ipairs, tostring, type
local tonumber, pcall, select, Print = tonumber, pcall, select, Print
local PI2 = math.pi * 2

local nLastDistance, nSpeed, nSpeedCount                = 0, 0, 0
local lastTime, updateTime, refreshTime, throttleCount  = 0, 0, 0, 0      -- time since last update and refresh, number of throttled updates
local updateThrottle, refreshThrottle, maxThrottle      = 0.1, 0.016, 5 	-- max 10 updates and/or 60 refreshes per second, min update every 0.5 second
local timed, forced                                     = false, false 		-- set to force an immediate update, obviously you don't want to do this very often
local etaThrottle, etaTime                              = 0.5, 0					-- eta updates capped at approx. 0.5 seconds

local knWaypointArrivalSoundId  = Sound.PlayUIAlertPopUpTitleReceived

NavMate.CodeEnumMapType = {
  ["ZoneMap"] = 1,
  ["MiniMap"] = 2
}

-----------------------------------------------------------------------------------------------
-- MiniMap and ZoneMap data for resource nodes
-----------------------------------------------------------------------------------------------
local ktNodeResourceIcons = {
  ["Dot"] = "MiniMapObject",
  ["Default"] = "sprMM_EldanStone",
}
local kstrResourceDotIcon 		  = "MiniMapObject"
local kstrResourceDefaultIcon 	= "sprMM_EldanStone"
local kstrResourceMiningIcon    = "NavMate_sprMM_Mine"
local kstrResourceFarmingIcon   = "NavMate_sprMM_Farm"
local kstrResourceSurvivalIcon  = "NavMate_sprMM_Wood"
local kstrResourceRelicIcon     = "NavMate_sprMM_Relic"

local ktResourceNodes = {
  mining   = { "IronNode", "TitaniumNode", "ZephyriteNode", "PlatinumNode", "HydrogemNode", "XenociteNode", "ShadeslateNode", "GalactiumNode", "NovaciteNode" },
  relic    = { "StandardRelicNode", "AcceleratedRelicNode", "AdvancedRelicNode", "DynamicRelicNode", "KineticRelicNode" },
  farming  = { "SpirovineNode", "BladeleafNode", "YellowbellNode", "PummelgranateNode", "SerpentlilyNode", "GoldleafNode", "HoneywheatNode", "CrowncornNode", "CoralscaleNode", "LogicleafNode", "StoutrootNode", "GlowmelonNode", "FaerybloomNode", "WitherwoodNode", "FlamefrondNode", "GrimgourdNode", "MourningstarNode", "BloodbriarNode", "OctopodNode", "HeartichokeNode", "SmlGrowthshroomNode", "MedGrowthshroomNode", "LrgGrowthshroomNode", "SmlHarvestshroomNode", "MedHarvestshroomNode", "LrgHarvestshroomNode", "SmlRenewshroomNode", "MedRenewshroomNode", "LrgRenewshroomNode" },
  survival = { "AlgorocTreeNode", "CelestionTreeNode", "DeraduneTreeNode", "EllevarTreeNode", "GalerasTreeNode", "AuroriaTreeNode", "WhitevaleTreeNode", "DreadmoorTreeNode", "FarsideTreeNode", "CoralusTreeNode", "MurkmireTreeNode", "WilderrunTreeNode", "MalgraveTreeNode", "HalonRingTreeNode", "GrimvaultTreeNode" },
}


-- Function to rebuild the Minimap Markers info
-- Used when resource node settings have been changed, i.e. color or icon
function NavMate:GenerateMinimapMarkerInfo()
  local tMarkers = {
    PvpRedFlag				      = { strIcon = "sprMM_VendorGeneral", bAboveOverlay = true },
    PvpBlueFlag				      = { strIcon = "MiniMapSoonQuest" },
  	SchoolOfFishNode		    = { strToggle = "TradeskillNodes", strIcon = kstrResourceDefaultIcon, 	  crObject = CColor.new(0.2, 1.0, 1.0, 1.0), 	crEdge = CColor.new(0.2, 1.0, 1.0, 1.0) },
  }
  
  local tVis = {
    PvpRedFlag       = true,
    PvpBlueFlag			 = true,
  	SchoolOfFishNode = true,
  }
  
  for strNodeType, tNodes in pairs(ktResourceNodes) do
    if self.db.modules.map[strNodeType].show then
      for _, strNodeKey in ipairs(tNodes) do
        if not self.db.modules.map[strNodeType].usePerNode or (self.db.modules.map[strNodeType].usePerNode and self.db.modules.map[strNodeType].perNode[strNodeKey].show) then
          local strIcon = self.db.modules.map[strNodeType].usePerNode and self.db.modules.map[strNodeType].perNode[strNodeKey].sprIcon or self.db.modules.map[strNodeType].sprIcon
          local crIcon  = self.db.modules.map[strNodeType].usePerNode and self.db.modules.map[strNodeType].perNode[strNodeKey].color or self.db.modules.map[strNodeType].color
          
          tMarkers[strNodeKey] = {
            strToggle = "TradeskillNodes",
            strIcon   = strIcon,
            crObject  = crIcon,
            crEdge    = crIcon,
          }
          tVis[strNodeKey] = true
        else
          tVis[strNodeKey] = false
        end
      end
    else
      for _, strNodeKey in ipairs(tNodes) do
          tVis[strNodeKey] = false
      end
    end
  end
  
	self.tMinimapMarkerInfo = tMarkers
  self.tMinimapMarkerVisibility = tVis
end

-----------------------------------------------------------------------------------------------
-- Local Utility / Helper Functions
-----------------------------------------------------------------------------------------------
local function stringStartsWith(str,strStart)
   return string.sub(str, 1, string.len(strStart)) == strStart
end

local function SerializeColors(t)
  for k,v in pairs(t) do
    if type(v) == "table" then
      SerializeColors(v)
    else
      if type(v) == "userdata" and stringStartsWith(tostring(v), "CColor(") then
        t[k] = { __CColor = true, r = v.r, b = v.b, g = v.g, a = v.a }
      elseif type(v) == "userdata" and type(getmetatable(v).IsSameColorAs) == "function" then
        t[k] = v:ToTable()
        t[k].__ApolloColor = true
      end
    end
  end
end

local function DeserializeColors(t)
  for k,v in pairs(t) do
    if type(v) == "table" and v.__CColor then
      v = CColor.new(v.r, v.g, v.b, v.a)
    elseif type(v) == "table" and v.__ApolloColor then
      v = ApolloColor.new(v)
    elseif type(v) == "table" then
      DeserializeColors(v)
    end
  end
end


local function TableCopy(t)
  local t2 = {}
  if type(t) ~= "table" then
    return t
  end
  for k,v in pairs(t) do
    t2[k] = TableCopy(v)
  end
  return t2
end

local function TableMerge(t1, t2)
  for k,v in pairs(t2) do
    if type(v) == "table" then
      if type(t1[k] or false) == "table" then
        TableMerge(t1[k] or {}, t2[k] or {})
      else
        t1[k] = v
      end
    else
      t1[k] = v
    end
  end
  return t1
end

-----------------------------------------------------------------------------------------------
-- Distance Functions
-----------------------------------------------------------------------------------------------
local function CalculateDistance2D(tPos1, tPos2)
	if not tPos1 or not tPos2 then
		return
	end
	
	local nDeltaX = tPos2.x - tPos1.x
	local nDeltaZ = tPos2.z - tPos1.z
	
	local nDistance = math.sqrt(math.pow(nDeltaX, 2) + math.pow(nDeltaZ, 2))
	return nDistance, nDeltaX, nDeltaZ
end


-----------------------------------------------------------------------------------------------
-- NavMate Functions
-----------------------------------------------------------------------------------------------
function NavMate:OnInitialize()
  self.AssetFolder = Apollo.GetAssetFolder()
  
  -- setup the asset folder path
  self:GenerateMinimapMarkerInfo()

  -- update events
  Apollo.RegisterEventHandler("NextFrame", 							         "OnUpdate",						      self)

  -- navmate events
  Apollo.RegisterEventHandler("NavMate_ArrivedAtWaypoint",       "OnArrivedAtWaypoint",       self)
  Apollo.RegisterEventHandler("NavMate_WaypointAdded",				   "OnWaypointAdded", 				  self)
  Apollo.RegisterEventHandler("ToggleNavMateOptionsWindow",			 "ToggleOptionsWindow",		    self)

  -- slash commands
  Apollo.RegisterSlashCommand("navmate", "OnSlashCmd", self)
  Apollo.RegisterSlashCommand("way",  "OnWaypointCmd", self)
  self:LoadSprites()
end

function NavMate:OnEnable()
  self:LoadSprites()
  self:InitializeModules()
  self:UpdateResourceNodes()
end

function NavMate:InitializeModules()
  for strModuleName, oModule in self:IterateModules() do
    if type(oModule.Initialize) == "function" and not oModule.bInitialized then
      oModule:Initialize()
    end
  end
end

function NavMate:LoadSprites()
  if not Apollo.IsSpriteLoaded("NavMate_Square_MiniMapCompassOverlay") then
    Apollo.LoadSprites(self.AssetFolder .. "\\NavMate_Sprites.xml")
  end
	if not Apollo.IsSpriteLoaded("ColorPickerSprites:dgcpHueMap") then 
		Apollo.LoadSprites(self.AssetFolder .. "\\ColorPickerSprites.xml", "ColorPickerSprites")
	end
end

function NavMate:OnUnitCreated(unit)
  self.tUnits[unit:GetId()] = unit
end

function NavMate:OnUnitDestroyed(unit)
  self.tUnits[unit:GetId()] = nil
end


--- Add NavMate to the addon list in WildStar options
function NavMate:OnConfigure()
	self:ToggleOptionsWindow()
end

function NavMate:ForceUpdate() 
	forced = true 
end

function NavMate:OnUpdate()
	local now = GameLib.GetGameTime()
	local elapsedTime = now - lastTime
	
	lastTime = now
	updateTime = updateTime + elapsedTime
	
	if forced or (updateTime >= updateThrottle) then
	
		throttleCount = throttleCount + 1
		if throttleCount == maxThrottle then 
			throttleCount = 0
			timed = true
		end
		
		if timed or forced then
      self:UpdateCurrentWaypoint() -- must be called before arrow:update()
      
      for strModuleName, oModule in self:IterateModules() do
        if oModule.bInitialized and type(oModule.Update) == "function" then
          oModule:Update()
        end
      end
      
      if self.bRedrawWaypoints and g_wndTheMiniMap and g_wndTheZoneMap then
        self:UpdateMapWaypoints()
      end
      
			timed, forced = false, false
		else
			self:GetModule("Arrow"):Refresh()
		end
		
		updateTime = 0
	else
    self:GetModule("Arrow"):Tick(elapsedTime)
	end
end

function NavMate:UpdateResourceNodes(bFullRedraw)
  self:GenerateMinimapMarkerInfo()
  -- update zonemap markers
	for _, strModuleName in ipairs({"ZoneMapHooker", "MiniMapHooker"}) do
		local zmHook = self:GetModule(strModuleName)
		if zmHook and zmHook.addon and zmHook.addon.tMinimapMarkerInfo then
			for k,v in pairs(self.tMinimapMarkerInfo) do
				if zmHook.addon.tMinimapMarkerInfo[k] then
					zmHook.addon.tMinimapMarkerInfo[k].strIcon  = self.tMinimapMarkerInfo[k].strIcon
					zmHook.addon.tMinimapMarkerInfo[k].crObject = self.tMinimapMarkerInfo[k].crObject
					zmHook.addon.tMinimapMarkerInfo[k].crEdge   = self.tMinimapMarkerInfo[k].crEdge
				end
			end
		end
	end

  for strModuleName, oModule in self:IterateModules() do
    if type(oModule.RedrawResourceNodes) == "function" then
      oModule:RedrawResourceNodes()
    end
  end
end

function NavMate:UpdateCurrentWaypoint()
	if self:GetModule("Arrow").waypoint == nil and #waypoints > 0 then 
		-- find the closest waypoint since we do not have a current waypoint
		local tPosPlayer = GameLib.GetPlayerUnit():GetPosition()
		local bActive = false
		
		local function sortByDistance(a, b)
			local nDistA = CalculateDistance2D(tPosPlayer, a.tWorldLoc)
			local nDistB = CalculateDistance2D(tPosPlayer, b.tWorldLoc)
			return nDistA < nDistB
		end
		
		table.sort(waypoints, sortByDistance)
    self:GetModule("Arrow"):SetWaypoint(waypoints[1])
	end
end

--- Clears any waypoint objects from the maps and re-adds them
function NavMate:UpdateMapWaypoints()
	if not GameLib.IsCharacterLoaded() then
		return
	end
	self.bRedrawWaypoints = false
	
	-- clear existing waypoints from the maps
  self:GetModule("MiniMapHooker"):ClearWaypointMarkers()
  self:GetModule("ZoneMapHooker"):ClearWaypointMarkers()
  
	-- get the current zone info
	local tCurrentZoneInfo = GameLib.GetCurrentZoneMap()
	
	-- loop through the waypoints and re-add them
	for idx, waypoint in ipairs(waypoints) do
    waypoint.nMinimapObjectId = nil
		waypoint.nZoneMapObjectId = nil
		waypoint:AddToZoneMap()
    waypoint:AddToMiniMap()
	end
end


--- Add waypoint to the maps when a waypoint is added to the waypoints table
-- @param tWaypoint waypoint
function NavMate:OnWaypointAdded(tWaypoint)
	self:GetModule("Arrow"):SetWaypoint(tWaypoint)

	-- add to zone map
  tWaypoint:AddToZoneMap()

	-- we are on the same continent, add to minimap
  tWaypoint:AddToMiniMap()
end

--- ArrivedAtWaypoint event handler
function NavMate:OnArrivedAtWaypoint(tWaypoint)
  self:PlayArrivalSound()
  waypoints:Remove(tWaypoint) -- remove from the waypoint collection
  self:GetModule("Arrow"):SetWaypoint()	  -- clear the current waypoint
  self:ForceUpdate()				
end


--- Play the arrival sound
function NavMate:PlayArrivalSound()
	if self:GetModule("Arrow").config.waypointArrivalSound then
    --Sound.PlayFile(Apollo.GetAssetFolder() .. "\\media\\WaterDrop.mp3")
		Sound.Play(knWaypointArrivalSoundId)
	end
end


--- remove all waypoints
function NavMate:RemoveAllWaypoints()
  waypoints:Clear()
  self:GetModule("Arrow"):SetWaypoint()
	self:ForceUpdate()
end



local function GetCharacterKey()
  local tArc = GameLib.GetAccountRealmCharacter()
  return tArc.strCharacter .. "-" .. tArc.strRealm
end


-----------------------------------------------------------------------------------------------
-- NavMate Settings
-----------------------------------------------------------------------------------------------
--- Addon save configuration event handler
-- @param eLevel addon save level
-- @return table with configuration data to save
function NavMate:OnSaveSettings(eLevel)
  if eLevel ~= GameLib.CodeEnumAddonSaveLevel.Account then
    return
  end

  -- notify modules that save settings has been called
  for strModuleName, oModule in self:IterateModules() do
    if type(oModule.OnSaveSettings) == "function" then
      oModule:OnSaveSettings()
    end
  end
  
  -- save the waypoints for the character
  self.db.modules.waypoints = self.db.modules.waypoints or {}
  self.db.modules.waypoints[GetCharacterKey()] = {}
  for idx, waypoint in ipairs(self.waypoints) do
    table.insert(self.db.modules.waypoints[GetCharacterKey()], waypoint:ToTable())
  end
  
  local tData = TableCopy(self.db)
  tData.Version = CONFIG_VERSION
  
  SerializeColors(tData)
  
  return tData
end



--- Addon restore configuration event handler
-- @param eLevel addon save level
-- @param tData saved addon configuration data
function NavMate:OnRestoreSettings(eLevel, tData)
  if eLevel ~= GameLib.CodeEnumAddonSaveLevel.Account then
    return
  end
	NavMateRestoreProcess = {}
	NavMateRestoreData = TableCopy(tData)
  
  if (tData.Version or 0) < CONFIG_VERSION then
    -- discard old versions of the config as they are incompatible
    return
  end
  
  DeserializeColors(tData)
	table.insert(NavMateRestoreProcess, "DeserializeColors")

  -- merge the settings with the defaults
  TableMerge(self.db, tData)
	table.insert(NavMateRestoreProcess, "TableMerge")
  
  -- restore waypoints
  self.db.modules.waypoints = self.db.modules.waypoints or {}
  self.db.modules.waypoints[GetCharacterKey()] = self.db.modules.waypoints[GetCharacterKey()] or {}
	table.insert(NavMateRestoreProcess, "RestoreWaypoints-a")
  
  for idx, waypoint in ipairs(self.db.modules.waypoints[GetCharacterKey()]) do
    table.insert(self.waypoints, Waypoint.FromTable(waypoint))
  end
	table.insert(NavMateRestoreProcess, "RestoreWaypoints-b")
  self.bRedrawWaypoints = true
  
  -- notify modules that restore settings has been called
	table.insert(NavMateRestoreProcess, "StartModuleRestore")
  for strModuleName, oModule in self:IterateModules() do
    if type(oModule.OnRestoreSettings) == "function" then
			table.insert(NavMateRestoreProcess, "StartRestoreModule - " .. strModuleName)
      oModule:OnRestoreSettings()
			table.insert(NavMateRestoreProcess, "FinishRestoreModule - " .. strModuleName)
    end
  end
	table.insert(NavMateRestoreProcess, "FinishModuleRestore")
  self:UpdateResourceNodes()
	table.insert(NavMateRestoreProcess, "FinishRestore")
end

-----------------------------------------------------------------------------------------------
-- NavMate Slash Commands
-----------------------------------------------------------------------------------------------
--- Add waypoint slash command handler
-- @usage /way -2592, -3492
-- @usage /way -2592 -3492 Ravaging Super God Boss That Drops Sparklies!
-- @usage /way -2592,-3492 Same point
-- @param cmd
-- @param args
function NavMate:OnWaypointCmd(cmd, args)
  local x, z, strName = args:match("^%s*(-?%d+%.?%d*)[%s,]+(-?%d+%.?%d*)%s*(.*)%s*$")
  x = math.floor(tonumber(x))
  z = math.floor(tonumber(z))
  if x ~= nil and z ~= nil then
    if strName:len() == 0 then
      strName = nil
    end
    waypoints:AddNew({ x = x, z = z }, nil, strName)
  end
end

--- General slash command handler
-- @param cmd
-- @param args
function NavMate:OnSlashCmd(cmd, args)
	if string.lower(args) == "options" then
		self:ToggleOptionsWindow()
	elseif string.lower(args) == "lock" then
		self:GetModule("Arrow"):ToggleLock()
  else -- if string.lower(args) == "help" then
    self:WriteToChat(L["NavMate Slash Commands"], true)
    self:WriteToChat("/navmate options         " .. L["SlashCommand_Options"], true)
    self:WriteToChat("/navmate lock              " .. L["SlashCommand_ToggleArrowLock"], true)
	end
end



-----------------------------------------------------------------------------------------------
-- API for External Addon Consumption
-----------------------------------------------------------------------------------------------
_G["NavMate"] = {
  --- Sends a waypoint to NavMate
  -- @param strAppName Addon/App providing the waypoint
  -- @param tLocation Position in the world as a 3D vector table (i.e. x, y, z)
  -- @param strName Name of the waypoint
  -- @return a table containing the waypoint information
  -- @usage local wayDubRock = NavMate.AddWaypoint("MyAddon", { x = 4420, y = 800, z = -5675 }, "DubRock Island Resort")
  AddWaypoint = function(strAppName, tLocation, strName)
    return waypoints:AddNew(tLocation, nil, strName, { strAppName = strAppName })
  end,
  
  --- Removes a waypoint from NavMate
  -- @param tWaypoint the waypoint table that was provided by AddWaypoint
  -- @usage NavMate.RemoveWaypoint(wayDubRock)
  RemoveWaypoint = function(tWaypoint)
    waypoints:Remove(tWaypoint)
  end
}