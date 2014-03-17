-----------------------------------------------------------------------------------------------
-- Waypoint
-----------------------------------------------------------------------------------------------

require "Apollo"
require "GameLib"

local N = Apollo.GetAddon("NavMate")
local L = N.L
local Waypoint = {}
N.Waypoint = Waypoint
local waypoints = N.waypoints


--- Creates a new waypoint
-- @param tWorldLoc world location for the waypoint
-- @param tZoneInfo zone information if not in current zone
-- @param strName name of the waypoint
-- @param tOpt optional settings table
-- @return waypoint
function Waypoint:new(tWorldLoc, tZoneInfo, strName, tOpt)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  self.__eq = function(a, b)
    return a.tWorldLoc.x == b.tWorldLoc.x and
       a.tWorldLoc.z == b.tWorldLoc.z and
       a.nContinentId == b.nContinentId
  end
  
  
  -- if tZoneInfo wasn't supplied, use the current zone
  tZoneInfo = tZoneInfo or GameLib.GetCurrentZoneMap()

  o.strIcon         = "sprMM_TargetObjective"
  o.crObject        = CColor.new(0,1,0,1)
  o.nMiniMapObjectType = N:GetModule("MiniMapHooker"):GetMapMarkerType()
  o.nZoneMapObjectType = N:GetModule("ZoneMapHooker"):GetMapMarkerType()
	o.nContinentId    = tZoneInfo.continentId
  o.tWorldLoc       = tWorldLoc
  o.tZoneInfo       = tZoneInfo
  o.strName         = strName or L["Unknown Waypoint"]
  o.tOpt            = tOpt
 
  return o
end

-- Create waypoint from a raw table
function Waypoint.FromTable(tData)
  return Waypoint:new(tData.tWorldLoc, tData.tZoneInfo, tData.strName, tData.tOpt)
end

-- Serialize waypoint to a raw table
function Waypoint:ToTable()
  return {
    strName = self.strName,
    tWorldLoc = self.tWorldLoc,
    tZoneInfo = self.tZoneInfo,
    tOpt = self.tOpt
  }
end

--- Add waypoint to the zone map
function Waypoint:AddToZoneMap()
	if _G["ZoneMapLibrary"] == nil then 
    return  -- ZoneMapLibrary doesn't exist! 
  end
	local strName = self.strName and string.format("Waypoint: %s", self.strName) or L["Unknown Waypoint"]
	self.nZoneMapObjectId = _G["ZoneMapLibrary"].wndZoneMap:AddObject(self.nZoneMapObjectType, self.tWorldLoc, strName, {
		strIcon           = self.strIcon,
		strIconEdge       = self.strIcon,
		crObject          = self.crObject,
		crEdge            = self.crObject,
	}, { 
    bNeverShowOnEdge  = false 
  })
end


--- Add waypoint to the minimap
function Waypoint:AddToMiniMap()
	if g_wndTheMiniMap == nil then 
    return  -- g_wndTheMiniMap doesn't exist!
  end
  
	local tCurrentZoneInfo = GameLib.GetCurrentZoneMap()
	if tCurrentZoneInfo.continentId == self.nContinentId then
		local strName = self.strName and string.format("Waypoint: %s", self.strName) or L["Unknown Waypoint"]
		self.nMinimapObjectId = g_wndTheMiniMap:AddObject(self.nMiniMapObjectType, self.tWorldLoc, strName, {
      strIcon       = self.strIcon,
      crObject      = self.crObject,
      crEdge        = self.crObject,
			strIconEdge   = "MiniMapObjectEdge",
			bAboveOverlay = true,
		})
	end
end



-----------------------------------------------------------------------------------------------
-- Waypoint collection helper functions
-----------------------------------------------------------------------------------------------
-- find a waypoint by the minimap object id
-- @param nObjectId minimap object id
function waypoints:FindByMiniMapId(nObjectId)
	for idx, tWaypoint in ipairs(self) do
		if tWaypoint.nMinimapObjectId == nObjectId then
			return tWaypoint
		end
	end
end

-- find a waypoint by the zonemap object id
-- @param nObjectId zonemap object id
function waypoints:FindByZoneMapId(nObjectId)
	for idx, tWaypoint in ipairs(self) do
		if tWaypoint.nZoneMapObjectId == nObjectId then
			return tWaypoint
		end
	end
end

-- find a waypoint by the map object id
-- @param eMapType map type
-- @param nObjectId map object id
function waypoints:FindByMapId(eMapType, nId)
  if eMapType == N.CodeEnumMapType.ZoneMap then
    return self:FindByZoneMapId(nId)
  elseif eMapType == N.CodeEnumMapType.MiniMap then
    return self:FindByMiniMapId(nId)
  end
end

-- remove a waypoint
-- @param tWaypoint
function waypoints:Remove(tWaypoint)
	if tWaypoint == nil then 
		return
	end
	for idx, tEntry in ipairs(self) do
		if tEntry == tWaypoint then
			table.remove(self, idx)
			break
		end
	end

	-- remove from zone map and minimap	
  if _G["ZoneMapLibrary"] ~= nil then
		_G["ZoneMapLibrary"].wndZoneMap:RemoveObject(tWaypoint.nZoneMapObjectId)
	end
	if g_wndTheMiniMap ~= nil and tWaypoint.nMinimapObjectId ~= nil then
		g_wndTheMiniMap:RemoveObject(tWaypoint.nMinimapObjectId)
	end
	
	-- notify subscribers that a waypoint was removed
	Event_FireGenericEvent("NavMate_WaypointRemoved", tWaypoint)
end

--- Add waypoint to collection
-- @param tWaypoint
function waypoints:Add(tWaypoint)
  for idx, t in ipairs(self) do
    if t == tWaypoint then
      -- found an existing one... ignore it
      t.strName = tWaypoint.strName
      return
    end
  end
  
	table.insert(self, tWaypoint)
	-- notify subscribers that a waypoint was added
	Event_FireGenericEvent("NavMate_WaypointAdded", tWaypoint)
end


--- Creates a new waypoint and adds it to the collection
-- @see Waypoint:new()
-- @returns tWaypoint
function waypoints:AddNew(...)
  local tWaypoint = Waypoint:new(...)
  self:Add(tWaypoint)
  return tWaypoint
end

function waypoints:Clear()
	repeat
    self:Remove(self[1])
	until #self == 0
end