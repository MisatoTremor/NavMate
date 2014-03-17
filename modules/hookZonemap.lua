-----------------------------------------------------------------------------------------------
-- ZoneMap Hooker
-----------------------------------------------------------------------------------------------
require "Apollo"
require "GameLib"
require "Unit"

local setmetatable, ipairs, pairs, type, pcall = setmetatable, ipairs, pairs, type, pcall

local N = Apollo.GetAddon("NavMate")
local L = N.L
local DaiGUI = Apollo.GetPackage("DaiGUI-1.0").tPackage

local ktModuleName = "ZoneMapHooker"
local ZoneMapHooker = N:NewModule(ktModuleName)

local knMapMarkerType

local ktTaxiNodes = {
  Neutral = {
    { nTextId = 351586, nX =   3467, nY =  -940, nZ =   -418, nContinentId = 6,  },
    { nTextId = 351587, nX =   3145, nY = -1041, nZ =    865, nContinentId = 6,  },
    { nTextId = 331373, nX =   1690, nY =  -820, nZ =   2827, nContinentId = 33, },
    { nTextId = 331369, nX =   1591, nY =  -969, nZ =   4142, nContinentId = 33, },
  },
  [Unit.CodeEnumFaction.ExilesPlayer] = {
    { nTextId = 442011, nX =   2069, nY =  -844, nZ =  -1616, nContinentId = 8,  },
    { nTextId = 442097, nX =   2718, nY =  -786, nZ =  -3893, nContinentId = 8,  },
    { nTextId = 197905, nX =   4203, nY = -1044, nZ =  -4006, nContinentId = 6,  },
    { nTextId = 307926, nX =   3801, nY =  -998, nZ =  -4550, nContinentId = 6,  },
    { nTextId = 310145, nX =   2618, nY =  -927, nZ =  -2395, nContinentId = 6,  }, 
    { nTextId = 313222, nX =   5377, nY =  -979, nZ =  -2829, nContinentId = 6,  },
    { nTextId = 313223, nX =   5740, nY =  -848, nZ =  -2611, nContinentId = 6,  },
    { nTextId = 313221, nX =   5107, nY =  -875, nZ =  -2871, nContinentId = 6,  },
    { nTextId = 351524, nX =   4494, nY =  -936, nZ =   -572, nContinentId = 6,  },
    { nTextId = 197956, nX =   5169, nY =  -883, nZ =  -2279, nContinentId = 6,  },
    { nTextId = 310144, nX =   1105, nY =  -943, nZ =  -2496, nContinentId = 6,  }, 
    { nTextId = 310146, nX =   3073, nY =  -920, nZ =  -2980, nContinentId = 6,  },
--    { nTextId = 306975, nX =   3095, nY =  -880, nZ =  -1496, nContinentId = 6,  }, -- camp viridian
    { nTextId = 197911, nX =   3896, nY =  -770, nZ =  -2391, nContinentId = 6,  },
    { nTextId = 563951, nX =    223, nY =  -890, nZ =  -4159, nContinentId = 33, },
    { nTextId = 568692, nX =   3142, nY =  -763, nZ =   2937, nContinentId = 33, },
    { nTextId = 561004, nX =    949, nY =  -924, nZ =     14, nContinentId = 33, },
    { nTextId = 561647, nX =    984, nY =  -970, nZ =  -1744, nContinentId = 33, },
    { nTextId = 519297, nX =   4449, nY =  -712, nZ =  -5673, nContinentId = 19, },
    { nTextId = 519296, nX =   5832, nY =  -495, nZ =  -4907, nContinentId = 19, },
  }, 
  [Unit.CodeEnumFaction.DominionPlayer] = {
    { nTextId = 283647, nX =  -2476, nY = -873, nZ = -1969, nContinentId = 8,  },
    { nTextId = 283651, nX =  -1266, nY = -888, nZ = -1026, nContinentId = 8,  },
    { nTextId = 283649, nX =  -1932, nY = -879, nZ = -2012, nContinentId = 8,  },
    { nTextId = 293816, nX =  -2601, nY = -790, nZ = -3586, nContinentId = 8,  },
    { nTextId = 291768, nX =  -5126, nY = -943, nZ = -1526, nContinentId = 8,  },
    { nTextId = 284862, nX =  -4898, nY = -931, nZ =   -79, nContinentId = 8,  },
    { nTextId = 291769, nX =  -5750, nY = -971, nZ =  -616, nContinentId = 8,  },
    { nTextId = 283650, nX =  -2202, nY = -904, nZ =  -836, nContinentId = 8,  },
    { nTextId = 442557, nX =   1130, nY = -712, nZ = -2009, nContinentId = 8,  },
    { nTextId = 442607, nX =   2713, nY = -787, nZ = -3913, nContinentId = 8,  },
    { nTextId = 293412, nX =  -3385, nY = -882, nZ =  -649, nContinentId = 8,  },
    { nTextId = 351584, nX =   1774, nY = -993, nZ =  -628, nContinentId = 6,  },
    { nTextId = 559601, nX =   2740, nY = -100, nZ =   419, nContinentId = 33, },
    { nTextId = 563950, nX =    223, nY = -890, nZ = -4032, nContinentId = 33, },
    { nTextId = 568600, nX =    372, nY = -954, nZ =  3150, nContinentId = 33, },
    { nTextId = 561645, nX =   1291, nY = -984, nZ = -1751, nContinentId = 33, },
    { nTextId = 519278, nX =   4072, nY = -721, nZ = -5170, nContinentId = 19, },
    { nTextId = 519247, nX =   5296, nY = -495, nZ = -4501, nContinentId = 19, },
  },
}



-----------------------------------------------------------------------------------------------
-- UI Form Definition
-----------------------------------------------------------------------------------------------
local function CreateWaypointButton(o, p)
  return DaiGUI:Create({
    Class = "Button",
    ButtonType = "PushButton",
    Base = "CRB_Basekit:kitBtn_Holo",
    Name = "NavMateClearWaypointsBtn",
    AnchorOffsets = {10,10,250,50},
    Font = "CRB_InterfaceMedium",
    Text = L["Remove All Waypoints"],
    NormalTextColor = "ff7fffb9",
    FlybyTextColor = "ff7fffb9",
    DisabledTextColor = "ff808080",
    DT_CENTER = true,
    DT_VCENTER = true,
    
    Events = {
      ButtonSignal = function() N:RemoveAllWaypoints() end,
    },
    
  }):GetInstance(o, p)
end

-----------------------------------------------------------------------------------------------
-- Utility / Helper functions
-----------------------------------------------------------------------------------------------

--- Get the first object at point (excluding waypoints & minimap pings)
-- @param wnd the map window
-- @param tPoint coords on the map window
-- @return map object
local function GetPoi(wnd, tPoint)
	local tMapObjects = _G["ZoneMapLibrary"].wndZoneMap:GetObjectsAt(tPoint.x, tPoint.y)
	if tMapObjects == nil then 
		return L["Unknown Waypoint"] 
	end
	
	-- grabbing first map object here... refine later to add mapobjecttype priority
	table.sort(tMapObjects, function(a,b) return a.eType < b.eType end)
	for idx, tMapObj in ipairs(tMapObjects) do
		if tMapObj.eType ~= knMapMarkerType then
			return tMapObj.strName, tMapObj.loc
		end
	end
	
	return L["Unknown Waypoint"] 
end

-----------------------------------------------------------------------------------------------
-- ZoneMap Hooker Definition
-----------------------------------------------------------------------------------------------
-- locals to store hooked functions
local zm_oldOnResizeOptionsPane
local zm_oldOnZoneMapButtonDown
local zm_oldOnUnitCreated

function ZoneMapHooker:Initialize()
  self:InitConfig()
  self.config.bZoneMapGhostMode = false
  self.config.showTaxiNodes = true
  self.tToggledTypes = {}
  
  Apollo.RegisterEventHandler("MapGhostMode",  "OnMapGhostMode",          self)
	Apollo.RegisterEventHandler("ToggleZoneMap", "Hook",                    self)
  Apollo.RegisterEventHandler("ZoneMapWindowModeChange", "SaveZoomLevel", self)
  Apollo.RegisterEventHandler("MapGhostMode",  "RestoreZoomLevel",        self)
  
  self.nFactionId = GameLib.GetPlayerUnit():GetFaction()

  self:Hook()
  self.bInitialized = true
end

function ZoneMapHooker:GetTaxiMapObjectType()
  if not self.eObjectTypeTaxi and self.addon then
    self.eObjectTypeTaxi = self.addon.wndZoneMap:CreateOverlayType()
  end
  return self.eObjectTypeTaxi or 969
end

function ZoneMapHooker:UpdateTaxiMarkers()
  if self.addon == nil then return end
  
  local eObjectType = self:GetTaxiMapObjectType()
  if self.config.showTaxiNodes == false then
    self.addon.wndZoneMap:RemoveObjectsByType(eObjectType)
    self.addon:SetTypeVisibility(eObjectType, self.config.showTaxiNodes)
  else
    local idCurrentZone = self.addon.wndMain:FindChild("ZoneComplexToggle"):GetData()
    local tCurrentInfo = self.addon.wndZoneMap:GetZoneInfo(idCurrentZone) or GameLib.GetCurrentZoneMap(idCurrentZone)
    if tCurrentInfo == nil then return end
    local tCurrentContinent = self.addon.wndZoneMap:GetContinentInfo(tCurrentInfo.continentId)
    
    -- if we have a continent change
    self.addon.wndZoneMap:RemoveObjectsByType(eObjectType)
    -- figure out what continent the zonemap is in
    local tInfo = {
      strIcon           = "sprMM_VendorFlight",
      strIconEdge       = "sprMM_VendorFlight",
      crObject          = "white",
      crEdge            = "white",
    }
    
    for _, tTaxiNode in ipairs(ktTaxiNodes.Neutral) do
      if tTaxiNode.nContinentId == tCurrentInfo.continentId then
        self.addon.wndZoneMap:AddObject(eObjectType, { x = tTaxiNode.nX, y = tTaxiNode.nY, z = tTaxiNode.nZ }, Apollo.GetString(tTaxiNode.nTextId), tInfo, { bNeverShowOnEdge  = true, bFixedSizeLarge = true })
      end
    end
    for _, tTaxiNode in ipairs(ktTaxiNodes[self.nFactionId]) do
      if tTaxiNode.nContinentId == tCurrentInfo.continentId then
        self.addon.wndZoneMap:AddObject(eObjectType, { x = tTaxiNode.nX, y = tTaxiNode.nY, z = tTaxiNode.nZ }, Apollo.GetString(tTaxiNode.nTextId), tInfo, { bNeverShowOnEdge  = true, bFixedSizeLarge = true })
      end
    end
    self.addon:SetTypeVisibility(eObjectType, self.config.showTaxiNodes)
  end
end

function ZoneMapHooker:AddTaxiToVisibilityLevels()
  if not self.addon or self.bAddedTaxiVisibility then return end
  self.bAddedTaxiVisibility = true
  
  local eObjectType = self:GetTaxiMapObjectType()
  table.insert(self.addon.arAllowedTypesSuperPanning, eObjectType)
  table.insert(self.addon.arAllowedTypesPanning,      eObjectType)
  table.insert(self.addon.arAllowedTypesScaled,       eObjectType)
  table.insert(self.addon.arAllowedTypesContinent,    eObjectType)
end



function ZoneMapHooker:GetMapMarkerType()
	if not self.eMapMarkerType and self.addon then
		self.eMapMarkerType = self.addon.wndZoneMap:CreateOverlayType()
	end
	return self.eMapMarkerType or 968
end


function ZoneMapHooker:ClearWaypointMarkers()
  if not self.addon then return end
  
	if self.addon.wndZoneMap ~= nil then
		self.addon.wndZoneMap:RemoveObjectsByType(self:GetMapMarkerType())
	end
end

function ZoneMapHooker:SaveZoomLevel(nDisplayMode)
  self.eLastMapDisplayMode = nDisplayMode    -- store the last known display mode
  self:UpdateTaxiMarkers()
end

function ZoneMapHooker:ResetClearWaypointsBtn()
  self.oClearWaypointsBtn:SetAnchorPoints(0,1,1,1)
  self.oClearWaypointsBtn:SetAnchorOffsets(10,-45,-10,-10)
  self.oClearWaypointsBtn:Show(true)
end

-- ZoneMap Zoom Level Fix
function ZoneMapHooker:RestoreZoomLevel(bGhostMode)
  if self.addon.wndZoneMap ~= nil and not bGhostMode and self.eLastMapDisplayMode ~= nil then
    self.addon.wndZoneMap:SetDisplayMode(self.eLastMapDisplayMode)     -- restore the last known display mode
    local bSuccess, oErrors = pcall(self.addon.SetControls, self.addon)
  end
end

-- Create Clear Waypoints button for placement on ZoneMap Options Pane
function ZoneMapHooker:CreateClearWaypointsButton()
  if not self:IsValid() then return end
	if self.oClearWaypointsBtn == nil then
    
    self.oClearWaypointsBtn = CreateWaypointButton(self, self.addon.wndMapControlPanel)
		
		local nLeft, nTop, nRight, nBottom = self.addon.wndMain:FindChild("ZoneMapControlPanel"):GetAnchorOffsets()
		self.addon.wndMain:FindChild("ZoneMapControlPanel"):SetAnchorOffsets(nLeft, nTop, nRight, nBottom + 20)
		nLeft, nTop, nRight, nBottom = self.addon.wndMapControlPanel:GetAnchorOffsets()
		self.addon.wndMapControlPanel:SetAnchorOffsets(nLeft, nTop, nRight, nBottom + 20)
		
		self.oClearWaypointsBtn:SetAnchorPoints(0,1,1,1)
		self.oClearWaypointsBtn:SetAnchorOffsets(10,-45,-10,-10)
		self.oClearWaypointsBtn:SetText(L["Remove All Waypoints"])
		self.oClearWaypointsBtn:Show(true)
	end
end


-- Hook ZoneMap:OnResizeOptionsPane
function ZoneMapHooker:HookResizeOptionsPane()
  if self.addon and self.wndMapControlPanel and zm_oldOnResizeOptionsPane == nil then
    local addon = self.addon
    local zmHook = self
    zm_oldOnResizeOptionsPane = addon.OnResizeOptionsPane
    
    addon.OnResizeOptionsPane = function(self)
      -- call original function
      zm_oldOnResizeOptionsPane(self)
     
			local nLeft, nTop, nRight, nBottom = self.wndMapControlPanel:GetAnchorOffsets()
			self.wndMapControlPanel:SetAnchorOffsets(nLeft, nTop, nRight, nBottom + 40)
			
      zmHook:ResetClearWaypointsBtn()
    end
  end
end

function ZoneMapHooker:IsValid()
  if self.addon and self.addon.wndZoneMap ~= nil and self.addon.wndZoneMap:IsValid() then
    return true
  end
  return false
end

-- AddExtraOverlayTypes
function ZoneMapHooker:AddExtraOverlayTypes()
	if self:IsValid() and not self.bExtraOverlayTypesAdded then
		self.bExtraOverlayTypesAdded = true
    
    -- add mailbox and bank overlay types
    self:AddOverlayType("Mailbox")
    self:AddOverlayType("Bank")
--    self:AddOverlayType("NavMateWaypoint")
    self.addon.eObjectTypeNavMateWaypoint = self:GetMapMarkerType()
    table.insert(self.addon.arAllowedTypesSuperPanning, self.addon.eObjectTypeNavMateWaypoint)
    table.insert(self.addon.arAllowedTypesPanning, self.addon.eObjectTypeNavMateWaypoint)
    table.insert(self.addon.arAllowedTypesScaled, self.addon.eObjectTypeNavMateWaypoint)
    table.insert(self.addon.arAllowedTypesContinent, self.addon.eObjectTypeNavMateWaypoint)
    self.addon:SetTypeVisibility(self.addon.eObjectTypeNavMateWaypoint, true)
  end
end

function ZoneMapHooker:AddOverlayType(overlayType)
  self.addon["eObjectType" .. overlayType] = self.addon.wndZoneMap:CreateOverlayType()
  table.insert(self.addon.arAllowedTypesSuperPanning, self.addon["eObjectType" .. overlayType])
  table.insert(self.addon.arAllowedTypesPanning, self.addon["eObjectType" .. overlayType])
  table.insert(self.addon.arAllowedTypesScaled, self.addon["eObjectType" .. overlayType])
  self.addon:SetTypeVisibility(self.addon["eObjectType" .. overlayType], true)
end


local zm_oldOnContinentNormalBtn, zm_oldOnContinentCustomBtn
function ZoneMapHooker:HookContinentButtons()
  if self.addon and zm_oldOnContinentNormalBtn == nil then
    zm_oldOnContinentNormalBtn = self.addon.OnContinentNormalBtn
    local zmhook = self
    self.addon.OnContinentNormalBtn = function(self, wndHandler, wndControl)
      zm_oldOnContinentNormalBtn(self, wndHandler, wndControl)
      zmhook:UpdateTaxiMarkers()
    end
  end
  if self.addon and zm_oldOnContinentCustomBtn == nil then
    zm_oldOnContinentCustomBtn = self.addon.OnContinentCustomBtn
    local zmhook = self
    self.addon.OnContinentCustomBtn = function(self, wndHandler, wndControl)
      zm_oldOnContinentCustomBtn(self, wndHandler, wndControl)
      zmhook:UpdateTaxiMarkers()
    end
  end
end

-- Hook ZoneMap:OnUnitCreated
function ZoneMapHooker:HookUnitCreated()
	if self.addon and zm_oldOnUnitCreated == nil then
		zm_oldOnUnitCreated = self.addon.OnUnitCreated
    local zmHook = self
		self.addon.OnUnitCreated = function(self, unitMade)
      -- units still "loading"? store them for later and then pass them back in
      if not GameLib.IsCharacterLoaded() then
        zmHook.tUnits = zmHook.tUnits or {}
        table.insert(zmHook.tUnits, unitMade)
        return
      end
      
			local tInfo =
			{
				strIcon       = "",
				strIconEdge   = "",
				crObject      = CColor.new(1, 1, 1, 1),
				crEdge        = CColor.new(1, 1, 1, 1),
				bAboveOverlay = false,
			}
			
			local eActivation = unitMade:GetActivationState()
			local bShowUnit   = unitMade:IsVisibleOnCurrentZoneMinimap()
    
      local strMarker = unitMade:GetMiniMapMarker()
      local tMarkerOverride
      if strMarker and N.tMinimapMarkerVisibility[strMarker] ~= nil then
        if N.tMinimapMarkerInfo[strMarker] and not N.tMinimapMarkerInfo[strMarker].bNotYetImplemented then
          tMarkerOverride = self.tMinimapMarkerInfo[strMarker]
        elseif N.tMinimapMarkerVisibility[strMarker] == false then
          self.tUnitsHidden[unitMade:GetId()] = {strType = "TradeskillNodes", unitValue = unitMade}
          return
        end
      end
      
      if bShowUnit then
        if eActivation.Bank ~= nil then
          tInfo.strIcon = "sprMM_Bank"
          self.wndZoneMap:AddUnit(unitMade, self.eObjectTypeBank, tInfo, {bNeverShowOnEdge = true}, self:IsTypeCurrentlyHidden(self.eObjectTypeBank))
          self.tUnitsShown[unitMade:GetId()] = {unitValue = unitMade}
          return
        elseif eActivation.Mail ~= nil then
          tInfo.strIcon = "sprMM_Mailbox"
          self.wndZoneMap:AddUnit(unitMade, self.eObjectTypeMailbox, tInfo, {bNeverShowOnEdge = true}, self:IsTypeCurrentlyHidden(self.eObjectTypeMailbox))
          self.tUnitsShown[unitMade:GetId()] = {unitValue = unitMade}
          return
        end
      end
      zm_oldOnUnitCreated(self, unitMade)
		end
  elseif self.tUnits and self.addon and GameLib.IsCharacterLoaded() then
    -- process units that were sent to the zonemap when the game was still "loading"
    local nCount = #self.tUnits
    for idx = nCount, 1, -1 do
      local unit = self.tUnits[idx]
      if unit:IsValid() == true then
        self.addon:OnUnitChanged(unit)
      end
      self.tUnits[idx] = nil
    end
    if #self.tUnits == 0 then
      self.tUnits = nil
    end
	end
end



-- Hook ZoneMap:OnZoneMapButtonDown
function ZoneMapHooker:HookZoneMapButtonDown()
  -- Hook ZoneMap:OnZoneMapButtonDown
	if self.addon and zm_oldOnZoneMapButtonDown == nil then
    local addon = self.addon
		zm_oldOnZoneMapButtonDown = addon.OnZoneMapButtonDown

    -- function to get the hex data names at a point on the zone map
    local function GetHexGroupData(self, tPoint)
			local tMap = self.wndZoneMap:GetRegionsAt(tPoint.x, tPoint.y)
			if tMap == nil then 
				return
			end
			
      local strFormat = "%s (%s)"
			local tHexData = {}
			for k, tHexes in pairs(tMap) do
				local strName = tHexes.strDescription
        -- Mission
				if tHexes.eType == self.eObjectTypeMission then
					strName = string.format(strFormat, tHexes.userData:GetName(), L["Mission"])
          
        -- Public Event
				elseif tHexes.eType == self.eObjectTypePublicEvent then
					if PublicEvent.is(tHexes.userData) then
						strName = string.format(strFormat, tHexes.userData:GetName(), L["Public Event"])
					elseif PublicEventObjective.is(tHexes.userData) then
						strName = string.format(strFormat, tHexes.userData:GetDescription(), L["Public Event"])
					end
          
        -- Challenge
				elseif tHexes.eType == self.eObjectTypeChallenge then
					if Challenges.is(tHexes.userData) then
						strName = string.format(strFormat, tHexes.userData:GetName(), L["Challenge"])
					end
          
        -- HexGroup
				elseif tHexes.eType == self.eObjectTypeHexGroup then
					if HexGroups.is(tHexes.userData) then
						strName = string.format(strFormat, tHexes.userData:GetTooltip(), L["HexGroup"])
					end
          
        -- Nemesis
				elseif tHexes.eType == self.eObjectTypeNemesisRegion then
					local tRegion = self.wndZoneMap:GetNemesisRegionInfo(tHexes.userData)
					if tRegion ~= nil then
						strName = string.format(strFormat, tRegion.strDescription, L["Nemesis"])
					end
				end
				table.insert(tHexData, { eType = tHexes.eType, strName = strName })
			end
			
			table.sort(tHexData, function(a, b) return a.eType < b.eType end)
			
			return tHexData
		end
		local nMarkerType = self:GetMapMarkerType()
		
    addon.OnZoneMapButtonDown = function(self, wndHandler, wndControl, eButton, nX, nY, bDoubleClick)
			local tPoint    = self.wndZoneMap:WindowPointToClientPoint(nX, nY)
			local tWorldLoc = self.wndZoneMap:GetWorldLocAtPoint(tPoint.x, tPoint.y)
			local nLocX     = math.floor(tWorldLoc.x + .5)
			local nLocZ     = math.floor(tWorldLoc.z + .5)
			
			if eButton == 1 and Apollo.IsControlKeyDown() then
				-- ctrl + right click - add a new waypoint
				local strName, tPoiLoc = GetPoi(self.wndZoneMap, tPoint)
				if tPoiLoc == nil then
					local tHexData = GetHexGroupData(self, tPoint)
					if tHexData and #tHexData > 0 then
						strName = tHexData[1].strName
					end
				end
        local tZoneInfo = self.wndZoneMap:GetZoneInfo(self.wndMain:FindChild("ZoneComplexToggle"):GetData())
        N.waypoints:AddNew(tPoiLoc or tWorldLoc, tZoneInfo, strName)
				
			elseif eButton == 1 then
				-- right click - context menu for waypoint if waypoint exists
				-- context menu the first waypoint object it finds
        N:OnShowWaypointContextMenu(self.wndZoneMap, tPoint, nMarkerType)
			end
			
      zm_oldOnZoneMapButtonDown(self, wndHandler, wndControl, eButton, nX, nY, bDoubleClick)
		end
	end
end

local zm_oldDrawGroupMembers
function ZoneMapHooker:HookDrawGroupMembers()
  if self.addon and zm_oldDrawGroupMembers == nil then
    zm_oldDrawGroupMembers = self.addon.DrawGroupMembers
    local config = N.db.modules.map.group
    self.addon.DrawGroupMembers = function(self)
      
      self:DestroyGroupMarkers()
      for idx, tMember in pairs(self.tGroupMembers) do
        local tInfo = GroupLib.GetGroupMember(idx)
        tInfo.strIcon = config.sprIcon
        if tInfo.bIsOnline then
          local bNeverShowOnEdge = true
          if tMember.InCombatPvp then
            tInfo.strIconEdge	= config.sprIcon
            tInfo.crObject		= config.pvpColor -- CColor.new(0, 1, 0, 1)
            tInfo.crEdge 		  = config.pvpColor -- CColor.new(0, 1, 0, 1)
            bNeverShowOnEdge  = false
          else
            tInfo.strIconEdge	= config.sprIcon
            tInfo.crObject 		= config.normalColor -- CColor.new(1, 1, 1, 1)
            tInfo.crEdge 		  = config.normalColor -- CColor.new(1, 1, 1, 1)
            bNeverShowOnEdge  = false
          end

          local strNameFormatted = string.format("<T Font=\"CRB_InterfaceMedium_B\" TextColor=\"ff31fcf6\">%s</T>", tMember.strName)
          strNameFormatted = String_GetWeaselString(Apollo.GetString("ZoneMap_AppendGroupMemberLabel"), strNameFormatted)
          self.tGroupMemberObjects[idx] = self.wndZoneMap:AddObject(1, tMember.tWorldLoc, strNameFormatted, tInfo, {bNeverShowOnEdge = bNeverShowOnEdge})
        end
      end
    end
  end
end

--- hook the zonemap required functions
function ZoneMapHooker:Hook()
  self.addon = self.addon or _G["ZoneMapLibrary"]
	if not self.addon then
		return -- ZoneMapLibrary global addon cannot be found
	end
  self:AddExtraOverlayTypes()
  
  knMapMarkerType = knMapMarkerType or self:GetMapMarkerType()

  self:AddTaxiToVisibilityLevels()

  self:HookUpdateMissionList()
  self:HookUpdateChallengeList()
  self:HookOnCityDirectionsList()
  self:HookFactoryProduce()
  self:HookUpdateQuestList()
  self:HookUpdatePublicEventList()
  
  self:HookUnitCreated()
  self:HookContinentButtons()
  self:HookZoneMapButtonDown()
  
  self:CreateClearWaypointsButton()
  
  self:HookDrawGroupMembers()
  self:HookResizeOptionsPane()
	
	self:UpdateTaxiMarkers()
  
  if self.oClearWaypointsBtn then
    self.oClearWaypointsBtn:Show(true)
  end
end

function ZoneMapHooker:OnRestoreSettings()
  self.bRequireConfigRestore = true
end


function ZoneMapHooker:OnSaveSettings()
  if not self.addon then return end
  
  self.config.ghostMode = self.config.bZoneMapGhostMode or false
  self.config.tToggledTypes = self:GetToggledTypes()
  self.config.bShowLabels = self.addon.wndZoneMap:IsShowLabelsOn()
end


function ZoneMapHooker:DrawGroupMembers()
  if self.addon == nil then
    return
  end
  
  self.addon:DrawGroupMembers()
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
function ZoneMapHooker:RedrawResourceNodes()
  if not self.addon then return end
  for _, tUnitsShown in ipairs({self.addon.tUnitsShown, self.addon.tUnitsHidden}) do
    for unitIdx, tUnitData in pairs(tUnitsShown) do
      if tUnitData.unitValue:GetType() == "Harvest" then
        local strMarker = tUnitData.unitValue:GetMiniMapMarker()
        if strMarker then
          self.addon:OnUnitChanged(tUnitData.unitValue)
        end
      end
    end
  end
end

function ZoneMapHooker:GetToggledTypes()
  local tToggledTypes = {}
  if self.addon then
    for idx, wndBtn in ipairs(self.addon.wndMain:FindChild("MarkersList:MarkerPaneButtonList"):GetChildren()) do
      local eType = wndBtn:GetData()
      local bVisible = wndBtn:IsChecked()
      if eType ~= nil then
        tToggledTypes[eType] = bVisible
      end
    end
  end
  return tToggledTypes
end


--- ZoneMap Ghost Mode Event Handler
-- @param bMode bool for ghost mode state
function ZoneMapHooker:OnMapGhostMode(bMode)
  self.config.bZoneMapGhostMode = bMode
end

--- Updates the zone map from the saved configuration
-- including ghost mode, position and markers
function ZoneMapHooker:Update()
  if not self.bRequireConfigRestore or self.addon == nil then
    return
  end
  
  self.bRequireConfigRestore = false
  self.addon.bIgnoreQuestStateChanged = true
  if self.config.ghostMode ~= nil then
    self:SetGhostMode(self.config.ghostMode)
  end
  -- restore the map marker preferences
  if self.config.tToggledTypes ~= nil then
    for idx, wndBtn in ipairs(self.addon.wndMain:FindChild("MarkersList:MarkerPaneButtonList"):GetChildren()) do
      local eType = wndBtn:GetData()
      if self.config.tToggledTypes[eType] ~= nil then
        if self.config.tToggledTypes[eType] then
          self.addon:OnMarkerBtnCheck(wndBtn, wndBtn)
        else
          self.addon:OnMarkerBtnUncheck(wndBtn, wndBtn)
        end
        wndBtn:SetCheck(self.config.tToggledTypes[eType])
      end
    end
  end
  if self.config.bShowLabels ~= nil then
    local wndLabelsBtn = self.addon.wndMain:FindChild("MarkersList:MarkerPaneButtonList:OptionsBtnLabels")
    wndLabelsBtn:SetCheck(self.config.bShowLabels)
    self.addon:OnToggleLabels(wndLabelsBtn, wndLabelsBtn)
  end
  self.addon.bIgnoreQuestStateChanged = false
  self:RedrawResourceNodes()
end

--- Set the Zone Map Ghost Mode state
-- @param bGhostMode ghost mode enable state
function ZoneMapHooker:SetGhostMode(bGhostMode)
  if self.addon == nil then
    return
  end
  
  if bGhostMode then
    Event_FireGenericEvent("ToggleZoneMap")
    self.addon:ToggleGhostModeOn()
  else
    self.addon.wndZoneMap:SetGhostWindow(false)
		Event_FireGenericEvent("MapGhostMode", false)
  end
end



-----------------------------------------------------------------------------------------------
-- Temp Fix for ZoneMap LoadForms! -- WTB AssetFolder bug being fixed... this shouldn't be needed. Sigh!
-----------------------------------------------------------------------------------------------
local zoneMapFormFile = [[ui\ZoneMap\ZoneMapForms.xml]]

local knPOIColorHidden 					= 0
local knPOIColorShown 					= 4294967295
local kcrButtonColorNormal 				= CColor.new(0.0, 191/255, 1.0, 1.0)
local kcrButtonColorPressed 			= CColor.new(1.0, 1.0, 1.0, 1.0)
local kcrButtonColorDisabled 			= CColor.new(0.0, 121/255, 121/255, 1.0)
local kcrQuestNumberColor 				= CColor.new(198/255, 255/255, 255/255, 1.0)
local knQuestItemHeight 				= 20
local kstrQuestFont 					= "CRB_InterfaceMedium_B"
local kstrQuestNameColor 				= "ffffffff"
local kstrQuestNameColorComplete 		= "ff2fdc02"
local kstrQuestNameColorTimed 			= "fffffc00"
local kcrEpisodeColor 					= "ff31fcf6"
local kcrEpisodeColorMinimized 			= "cc21a5a1"


local zm_oldUpdateChallengeList
function  ZoneMapHooker:HookUpdateChallengeList()
  if self.addon and zm_oldUpdateChallengeList == nil then
    zm_oldUpdateChallengeList = self.addon.UpdateChallengeList
    self.addon.UpdateChallengeList = function(self)
      if self.wndMain == nil then
        -- yes, it is possible for this to be nil here because we might not have gotten the OnLoad event yet
        return
      end

      self.wndMapControlPanel:FindChild("ChallengePaneContentList"):DestroyChildren()
      
      local tChallengeList = ChallengesLib:GetActiveChallengeList()

      local nCount = 0
      for id, chalCurrent in pairs(tChallengeList) do
        if chalCurrent:IsActivated() then
          local wndLine = Apollo.LoadForm(zoneMapFormFile, "ChallengeEntry", self.wndMapControlPanel:FindChild("ChallengePaneContentList"), self)
          local wndNumber = wndLine:FindChild("TextNumber")

          -- number the queCurr
          nCount = nCount + 1
          wndNumber:SetText(String_GetWeaselString(Apollo.GetString("ZoneMap_TextNumber"), nCount))
          wndNumber:SetTextColor(kcrQuestNumberColor)

          wndLine:FindChild("TextNoItem"):Enable(false)
          
          local strTitle = string.format("<P Font=\"%s\" TextColor=\"%s\">%s</P>", kstrQuestFont, kstrQuestNameColor, chalCurrent:GetName())
          
          wndLine:FindChild("TextNoItem"):SetAML(strTitle)
          wndLine:FindChild("ChallengeBacker"):SetBGColor(CColor.new(1,1,1,0.5))
          wndLine:SetData(chalCurrent)

          local nTextWidth, nTextHeight = wndLine:FindChild("TextNoItem"):SetHeightToContentHeight()
          local nLeft, nTop, nRight, nBottom = wndLine:GetAnchorOffsets()
          wndLine:SetAnchorOffsets(nLeft, nTop, nRight, 10 + math.max(knQuestItemHeight, nTextHeight))
        end
      end

      self.wndMapControlPanel:FindChild("ChallengePaneContentList"):ArrangeChildrenVert(0)    
    end
  end
end

local zm_oldUpdateMissionList
function ZoneMapHooker:HookUpdateMissionList()
  if self.addon and zm_oldUpdateMissionList == nil then
    zm_oldUpdateMissionList = self.addon.UpdateMissionList
    self.addon.UpdateMissionList = function(self)
      if self.wndMain == nil then
        -- yes, it is possible for this to be nil here because we might not have gotten the OnLoad event yet
        return
      end

      self.wndMapControlPanel:FindChild("MissionPaneContentList"):DestroyChildren()
      local epiPathEpisode = PlayerPathLib.GetCurrentEpisode()
      if epiPathEpisode == nil then
        return
      end
      
      local tMissionList = epiPathEpisode:GetMissions()

      local nCount = 0
      for idx, pmCurrent in ipairs(tMissionList) do
        local state = pmCurrent:GetMissionState()
        if state == PathMission.PathMissionState_Unlocked or state == PathMission.PathMissionState_Started then
          local wndMissionLine = Apollo.LoadForm(zoneMapFormFile, "MissionEntry", self.wndMapControlPanel:FindChild("MissionPaneContentList"), self)
          local wndNumber = wndMissionLine:FindChild("TextNumber")

        
          -- number the queCurr
          nCount = nCount + 1
          wndNumber:SetText(String_GetWeaselString(Apollo.GetString("ZoneMap_TextNumber"), nCount))
          wndNumber:SetTextColor(kcrQuestNumberColor)

          wndMissionLine:FindChild("TextNoItem"):Enable(false)
          
          local strMissionTitle = string.format("<P Font=\"%s\" TextColor=\"%s\">%s</P>", kstrQuestFont, kstrQuestNameColor, pmCurrent:GetName())
          
          wndMissionLine:FindChild("TextNoItem"):SetAML(strMissionTitle)
          wndMissionLine:FindChild("MissionBacker"):SetBGColor(CColor.new(1,1,1,0.5))
          wndMissionLine:SetData(pmCurrent)

          local nQuestTextWidth, nQuestTextHeight = wndMissionLine:FindChild("TextNoItem"):SetHeightToContentHeight()
          local nLeft, nTop, nRight, nBottom = wndMissionLine:GetAnchorOffsets()
          wndMissionLine:SetAnchorOffsets(nLeft, nTop, nRight, 10 + math.max(knQuestItemHeight, nQuestTextHeight))
        end
      end

      self.wndMapControlPanel:FindChild("MissionPaneContentList"):ArrangeChildrenVert(0)
    end
  end
end

  

local zm_oldUpdatePublicEventList
function ZoneMapHooker:HookUpdatePublicEventList()
  if self.addon and zm_oldUpdatePublicEventList == nil then
    zm_oldUpdatePublicEventList = self.addon.UpdatePublicEventList
    self.addon.UpdatePublicEventList = function(self)
      if self.wndMain == nil then
        -- yes, it is possible for this to be nil here because we might not have gotten the OnLoad event yet
        return
      end

      self.wndMapControlPanel:FindChild("PublicEventPaneContentList"):DestroyChildren()
      
      local tEventList = PublicEventsLib.GetActivePublicEventList()

      local nCount = 0
      for id, peCurrent in pairs(tEventList) do
        if peCurrent:IsActive() then
          local wndLine = Apollo.LoadForm(zoneMapFormFile, "PublicEventEntry", self.wndMapControlPanel:FindChild("PublicEventPaneContentList"), self)
          local wndNumber = wndLine:FindChild("TextNumber")

          -- number the queCurr
          nCount = nCount + 1
          wndNumber:SetText(String_GetWeaselString(Apollo.GetString("ZoneMap_TextNumber"), nCount))
          wndNumber:SetTextColor(kcrQuestNumberColor)

          wndLine:FindChild("TextNoItem"):Enable(false)
          
          local strTitle = string.format("<P Font=\"%s\" TextColor=\"%s\">%s</P>", kstrQuestFont, kstrQuestNameColor, peCurrent:GetName())
          
          wndLine:FindChild("TextNoItem"):SetAML(strTitle)
          wndLine:FindChild("PublicEventBacker"):SetBGColor(CColor.new(1,1,1,0.5))
          wndLine:SetData(peCurrent)

          local nTextWidth, nTextHeight = wndLine:FindChild("TextNoItem"):SetHeightToContentHeight()
          local nLeft, nTop, nRight, nBottom = wndLine:GetAnchorOffsets()
          wndLine:SetAnchorOffsets(nLeft, nTop, nRight, 10 + math.max(knQuestItemHeight, nTextHeight))
        end
      end

      self.wndMapControlPanel:FindChild("PublicEventPaneContentList"):ArrangeChildrenVert(0)
    end
  end
end



local zm_oldUpdateQuestList
function ZoneMapHooker:HookUpdateQuestList()
  if self.addon and zm_oldUpdateQuestList == nil then
    zm_oldUpdateQuestList = self.addon.UpdateQuestList
    self.addon.UpdateQuestList = function(self)
    
    
    	if self.wndMain == nil then
        -- yes, it is possible for this to be nil here because we might not have gotten the OnLoad event yet
        return
      end

      if self.bIgnoreQuestStateChanged then
        -- used to prevent errors when setting the active queCurr (auto-toggled)
        return
      end

      self.tEpisodeList = QuestLib.GetTrackedEpisodes(self.bQuestTrackerByDistance)
      self.wndMapControlPanel:FindChild("QuestPaneContentList"):DestroyChildren()

      local nCount = 0
      for idx, epiCurr in ipairs(self.tEpisodeList) do
        for idx2, queCurr in ipairs(epiCurr:GetTrackedQuests(0, self.bQuestTrackerByDistance)) do
          local wndQuestLine = Apollo.LoadForm(zoneMapFormFile, "QuestEntry", self.wndMapControlPanel:FindChild("QuestPaneContentList"), self)
          local wndNumber = wndQuestLine:FindChild("TextNumber")

          -- number the queCurr
          nCount = nCount + 1
          wndNumber:SetText(String_GetWeaselString(Apollo.GetString("ZoneMap_TextNumber"), nCount))
          wndNumber:SetTextColor(kcrQuestNumberColor)

          local eQuestState = queCurr:GetState() -- don't show completed or unknown quests
          if eQuestState == Quest.QuestState_Achieved or eQuestState == Quest.QuestState_Botched then
            wndQuestLine:FindChild("DifficultyMark"):SetBGColor(CColor.new(1.0, 1.0, 1.0, 1.0))
            wndQuestLine:FindChild("DifficultyMark"):SetSprite("")
            wndNumber:SetTextColor(CColor.new(47/255, 220/255, 2/255, 1.0))

            --Fail state settings
            if eQuestState == Quest.QuestState_Botched then
              wndQuestLine:FindChild("DifficultyMark"):SetSprite("")
              wndNumber:SetTextColor(CColor.new(1.0, 0, 0, 1.0))
              wndNumber:SetText(Apollo.GetString("ZoneMap_FailMarker"))
            end

          else
            wndQuestLine:FindChild("DifficultyMark"):SetSprite("ClientSprites:WhiteFill")

            local eConLevel = queCurr:GetColoredDifficulty()
            if eConLevel == Unit.CodeEnumLevelDifferentialAttribute.Grey then
              wndQuestLine:FindChild("DifficultyMark"):SetBGColor(CColor.new(130/255, 130/255, 130/255, 1.0))
            elseif eConLevel == Unit.CodeEnumLevelDifferentialAttribute.Green then
              wndQuestLine:FindChild("DifficultyMark"):SetBGColor(CColor.new(130/255, 130/255, 130/255, 1.0))
            elseif eConLevel == Unit.CodeEnumLevelDifferentialAttribute.Cyan then
              wndQuestLine:FindChild("DifficultyMark"):SetBGColor(CColor.new(162/255, 255/255, 0/255, 1.0))
            elseif eConLevel == Unit.CodeEnumLevelDifferentialAttribute.Blue then
              wndQuestLine:FindChild("DifficultyMark"):SetBGColor(CColor.new(0/255, 150/255, 255/255, 1.0))
            elseif eConLevel == Unit.CodeEnumLevelDifferentialAttribute.White then
              wndQuestLine:FindChild("DifficultyMark"):SetBGColor(CColor.new(255/255, 255/255, 255/255, 1.0))
            elseif eConLevel == Unit.CodeEnumLevelDifferentialAttribute.Yellow then
              wndQuestLine:FindChild("DifficultyMark"):SetBGColor(CColor.new(255/255, 240/255, 0/255, 1.0))
            elseif eConLevel == Unit.CodeEnumLevelDifferentialAttribute.Orange then
              wndQuestLine:FindChild("DifficultyMark"):SetBGColor(CColor.new(255/255, 155/255, 0/255, 1.0))
            elseif eConLevel == Unit.CodeEnumLevelDifferentialAttribute.Red then
              wndQuestLine:FindChild("DifficultyMark"):SetBGColor(CColor.new(232/255, 5/255, 0/255, 1.0))
            elseif eConLevel == Unit.CodeEnumLevelDifferentialAttribute.Magenta then
              wndQuestLine:FindChild("DifficultyMark"):SetBGColor(CColor.new(175/255, 0/255, 232/255, 1.0))
            else
              --wndQuestLine:FindChild("DifficultyMark"):SetSprite("")
            end
          end

          wndQuestLine:FindChild("TextNoItem"):Enable(false)
          wndQuestLine:FindChild("TextNoItem"):SetAML(self:BuildQuestTitleString(queCurr))
          wndQuestLine:FindChild("QuestBacker"):SetBGColor(CColor.new(1,1,1,0.5))
          wndQuestLine:SetData(queCurr)

          local nQuestTextWidth, nQuestTextHeight = wndQuestLine:FindChild("TextNoItem"):SetHeightToContentHeight()
          local nLeft, nTop, nRight, nBottom = wndQuestLine:GetAnchorOffsets()
          wndQuestLine:SetAnchorOffsets(nLeft, nTop, nRight, 10 + math.max(knQuestItemHeight, nQuestTextHeight))
        end
      end

      self.wndMapControlPanel:FindChild("QuestPaneContentList"):ArrangeChildrenVert(0)

    
    
    end
  end
end

    
local zm_oldFactoryProduce
function ZoneMapHooker:HookFactoryProduce()
  if self.addon and zm_oldFactoryProduce == nil then
    zm_oldFactoryProduce = self.addon.FactoryProduce
    self.addon.FactoryProduce = function(self, wndParent, strFormName, tObject)
      local wndNew = wndParent:FindChildByUserData(tObject)
      if not wndNew then
        wndNew = Apollo.LoadForm(zoneMapFormFile, strFormName, wndParent, self)
        wndNew:SetData(tObject)
      end
      return wndNew
    end
  end
end

local karCityDirectionsTypeToIcon =
{
	[GameLib.CityDirectionType.Mailbox] 		= "ClientSprites:Icon_Windows_UI_ReadMail",
	[GameLib.CityDirectionType.Bank] 			= "ClientSprites:Icon_BuffDebuff_Money_Loot_Drop_Increase_Buff",
	[GameLib.CityDirectionType.AuctionHouse] 	= "ClientSprites:Icon_Windows_UI_CRB_LevelUp_NewCapitalCity",
	[GameLib.CityDirectionType.CommodityMarket] = "ClientSprites:Icon_Windows_UI_CRB_LevelUp_NewCapitalCity",
	[GameLib.CityDirectionType.AbilityVendor] 	= "ClientSprites:Icon_Windows_UI_CRB_LevelUp_NewAbility",
	[GameLib.CityDirectionType.Tradeskill] 		= "ClientSprites:Icon_Windows_UI_CRB_LevelUp_NewGearSlot",
	[GameLib.CityDirectionType.General] 		= "ClientSprites:Icon_Windows_UI_CRB_LevelUp_NewGeneralFeature",
	[GameLib.CityDirectionType.HousingNpc] 		= "ClientSprites:Icon_Windows_UI_CRB_LevelUp_NewCapitalCity",
	[GameLib.CityDirectionType.Transport] 		= "ClientSprites:Icon_Windows_UI_CRB_LevelUp_NewZone",
}
local zm_oldOnCityDirectionsList
function ZoneMapHooker:HookOnCityDirectionsList()
  if self.addon and zm_oldOnCityDirectionsList == nil then
    zm_oldOnCityDirectionsList = self.addon.OnCityDirectionsList
    self.addon.OnCityDirectionsList = function(self, tDirections)
    
    	if self.wndCityDirections ~= nil and self.wndCityDirections:IsValid() then
        self.wndCityDirections:Destroy()
      end

      self.wndCityDirections = Apollo.LoadForm(zoneMapFormFile, "CityDirections", nil, self)
			self.wndCityDirections:ToFront()

			local wndCityDirectionsList = self.wndCityDirections:FindChild("CityDirectionsList")
			table.sort(tDirections, function(a, b) return a.strName < b.strName end)
			for idx, tCurrDirection in pairs(tDirections) do
				local wndCurr = Apollo.LoadForm("ZoneMapForms.xml", "CityDirectionsBtn", wndCityDirectionsList, self)
				wndCurr:FindChild("CityDirectionsBtnIcon"):SetSprite(karCityDirectionsTypeToIcon[tCurrDirection.eType] or "Icon_ArchetypeUI_CRB_DefensiveHealer")
				wndCurr:FindChild("CityDirectionsBtnText"):SetText(tCurrDirection.strName)
				wndCurr:SetData(tCurrDirection.idDestination)
			end
			self.wndCityDirections:FindChild("CityDirectionsList"):ArrangeChildrenVert(0)
    
    
    end
  end
end