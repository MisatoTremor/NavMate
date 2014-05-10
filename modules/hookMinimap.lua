-----------------------------------------------------------------------------------------------
-- MiniMap Hooker
-----------------------------------------------------------------------------------------------
require "Apollo"
require "GameLib"
require "Unit"

local setmetatable, ipairs, pairs, type = setmetatable, ipairs, pairs, type

local N = Apollo.GetAddon("NavMate")
local L = N.L
local GUILib = Apollo.GetPackage("Gemini:GUI-1.0").tPackage

local ktModuleName = "MiniMapHooker"
local MiniMapHooker = N:NewModule(ktModuleName)

MiniMapHooker.EnumMaskType = {
	Default = 1,
	Square  = 2,
}

-----------------------------------------------------------------------------------------------
-- Constants / Lookup Tables
-----------------------------------------------------------------------------------------------
local knMiniMapPingType
local knMapMarkerType
local kcrMMRQuest               = "xkcdGreenishCyan"

local ktMiniMapPathSprites = {
	[PlayerPathLib.PlayerPathType_Explorer]		= "NavMate_sprMM_Explorer",
	[PlayerPathLib.PlayerPathType_Scientist]	= "NavMate_sprMM_Scientist",
	[PlayerPathLib.PlayerPathType_Settler]		= "NavMate_sprMM_Settler",
	[PlayerPathLib.PlayerPathType_Soldier]		= "NavMate_sprMM_Soldier",
}


-----------------------------------------------------------------------------------------------
-- Utility Functions
-----------------------------------------------------------------------------------------------
local function GetAddon(strAddonName)
	local info = Apollo.GetAddonInfo(strAddonName)

	if info and info.bRunning == 1 then 
		return Apollo.GetAddon(strAddonName)
	end
end

--- Get the first object at point (excluding waypoints & minimap pings)
-- @param wnd the map window
-- @param tPoint coords on the map window
-- @return map object
local function GetPoi(wnd, tPoint)
	local tMapObjects = g_wndTheMiniMap:GetObjectsAtPoint(tPoint.x, tPoint.y) -- all others
	if tMapObjects == nil then 
		return L["Unknown Waypoint"] 
	end
	
	-- grabbing first map object here... refine later to add mapobjecttype priority
	table.sort(tMapObjects, function(a,b) return a.eType < b.eType end)
	for idx, tMapObj in ipairs(tMapObjects) do
		if tMapObj.eType ~= knMiniMapPingType and tMapObj.eType ~= knMapMarkerType then
			return tMapObj.strName, tMapObj.loc
		end
	end
	
	return L["Unknown Waypoint"] 
end

local function IsQuestOrChallengeUnit(unit)
  if unit == nil then
    return
  end
  
  local tRewardInfo = unit:GetRewardInfo()
  if tRewardInfo == nil then
    return
  end
  
  for idx, tInfo in ipairs(tRewardInfo) do
    if tInfo.strType == "Quest" then -- or tInfo.type == "Challenge" then
      return true
    end
  end
end

-----------------------------------------------------------------------------------------------
-- MiniMap Hooker Definition
-----------------------------------------------------------------------------------------------
local mm_oldOnMapClick, mm_oldOnQuestStateChanged, mm_oldRedrawIconsOfType, mm_oldHandleUnitCreated
function MiniMapHooker:Initialize()
  self:InitConfig()
 
--	Apollo.RegisterEventHandler("Group_MemberConnect",  "OnGroupMemberConnect", self)
--	Apollo.RegisterEventHandler("Group_Updated", 				"OnGroupUpdated", self)				-- ()
--	Apollo.RegisterEventHandler("Group_UpdatePosition", "OnGroupUpdatePosition", self)
 
  self.config.mask = self.EnumMaskType.Default
	Apollo.RegisterTimerHandler("NMMMHookAsyncLoadTimer", "AsyncLoadCheck", self)
  self:AsyncLoadCheck()
	self.bInitialized = true
end

function MiniMapHooker:AsyncLoadCheck()
	if g_wndTheMiniMap == nil then
		Apollo.CreateTimer("NMMMHookAsyncLoadTimer", 1.0, false)
	else
		self:Hook()
	end
end

function MiniMapHooker:MarkerEnabledState(strMarker)
  if not self.addon then return end
  return self.addon.tToggledIcons[self.addon["eObjectType" .. strMarker]]
end


function MiniMapHooker:EnableMarker(strMarker, bEnable)
  if not self.addon then return end
	local eObjectType = self.addon["eObjectType" .. strMarker]
  self.addon.tToggledIcons[eObjectType] = bEnable
  if bEnable then
		self.addon.wndMiniMap:ShowObjectsByType(eObjectType)
  else
		self.addon.wndMiniMap:HideObjectsByType(eObjectType)
  end
end



-- Remove dead units from the minimap
function MiniMapHooker:RemoveDeadUnits()
  if self.addon == nil then
    return
  end
  
  for nUnitId, tInfo in pairs(self.addon.tUnitsShown) do
    if tInfo.unitObject:IsDead() then
      -- found a dead unit, removing it
      self.addon.tUnitsShown[nUnitId] = nil
      self.addon.tUnitsHidden[nUnitId] = nil
      self.addon.wndMiniMap:RemoveUnit(tInfo.unitObject)
    end
  end
end

function MiniMapHooker:GetMapMarkerType()
	if not self.eMapMarkerType and self.addon then
		self.eMapMarkerType = self.addon.wndMiniMap:CreateOverlayType()
	end
	return self.eMapMarkerType or 968
end

--- Remove the minimap ping at point
function MiniMapHooker:RemovePing(tPoint)
  if self.addon == nil then
    return
  end
  
  local tMapObjects = g_wndTheMiniMap:GetObjectsAtPoint(tPoint.x, tPoint.y) -- all others
  if tMapObjects == nil then 
    return 
  end
  
  knMiniMapPingType = knMiniMapPingType or self.addon:GetPingType()
    
  for idx, tMapObj in ipairs(tMapObjects) do
    if tMapObj.eType == knMiniMapPingType then
      self.addon.wndMiniMap:RemoveObject(tMapObj.id)
    end
  end
end


function MiniMapHooker:HookMapClick()
  -- Hook Minimap:OnMapClick
	if self.addon and mm_oldOnMapClick == nil then
    mm_oldOnMapClick = self.addon.OnMapClick
		local nMarkerType = self:GetMapMarkerType()
    local mmHooker = self
    self.addon.OnMapClick = function(self, wndHandler, wndControl, eButton, nX, nY, bDouble)
			local tPoint    = self.wndMiniMap:WindowPointToClientPoint(nX, nY)
			local tWorldLoc = self.wndMiniMap:ClientPointToWorldLoc(tPoint.x, tPoint.y)
			local nLocX     = math.floor(tWorldLoc.x + .5)
			local nLocZ     = math.floor(tWorldLoc.z + .5)
			if eButton == 1 and Apollo.IsControlKeyDown() then
				-- ctrl + right click - add a new waypoint
				-- check if there are any other map objects here that we can use to name this waypoint?
				local strName, tPoiLoc = GetPoi(self.wndMiniMap, tPoint)
        N.waypoints:AddNew(tPoiLoc or tWorldLoc, nil, strName)
				mmHooker:RemovePing(tPoint)
				
			elseif eButton == 1 then
				-- right click - context menu for waypoint if waypoint exists
				-- context menu the first waypoint object it finds
        N:OnShowWaypointContextMenu(self.wndMiniMap, tPoint, nMarkerType)
			end
			
			mm_oldOnMapClick(self, wndHandler, wndControl, eButton, nX, nY, bDouble)
		end
	end
end

function MiniMapHooker:ClearWaypointMarkers()
  if not self.addon then return end
  
	if self.addon.wndMiniMap ~= nil then
		self.addon.wndMiniMap:RemoveObjectsByType(self:GetMapMarkerType())
	end
end




function MiniMapHooker:HookQuestStateChanged()
  if self.addon and mm_oldOnQuestStateChanged == nil then
    mm_oldOnQuestStateChanged = self.addon.OnQuestStateChanged
    self.addon.OnQuestStateChanged = function(self)
      mm_oldOnQuestStateChanged(self)
      
      if not self.unitPlayerDisposition then
        self.unitPlayerDisposition = GameLib.GetPlayerUnit()
      end

      local tInfo = self:GetDefaultUnitInfo()
      local tPerTypeSettings = {bNeverShowOnEdge = true, bFixedSizeSmall = false}
      local bPerUnitInfo = false
      for idx, tCurr in pairs(self.tUnitsShown) do
        if tCurr.strType == "MMR_Quest" or tCurr.strType == "MMR_Hostile" or tCurr.strType == "MMR_Neutral" then
          if IsQuestOrChallengeUnit(tCurr.unitObject) then
            tCurr.strType = "MMR_Quest"
						self:OnUnitChanged(tCurr.unitObject)
          else
            local eDisposition = tCurr.unitObject:GetDispositionTo(self.unitPlayerDisposition)
            if eDisposition == Unit.CodeEnumDisposition.Hostile then
              tCurr.strType = "MMR_Hostile"
							self:OnUnitChanged(tCurr.unitObject)
            else
              tCurr.strType = "MMR_Neutral"
							self:OnUnitChanged(tCurr.unitObject)
            end
          end
        end
      end
    end
  end
end

-- Hook MiniMap:HandleUnitCreated
function MiniMapHooker:HookHandleUnitCreated()
  if self.addon and mm_oldHandleUnitCreated == nil then
    mm_oldHandleUnitCreated = self.addon.HandleUnitCreated
    local navmate = N
		local groupConfig = N.db.modules.map.group
    self.addon.HandleUnitCreated = function(self, unitNew)
			mm_oldHandleUnitCreated(self, unitNew)
			
      local tActivation = unitNew:GetActivationState()
      local tMarkers 	  = unitNew:GetMiniMapMarkers()
--      local bShowUnit 	= unitNew:IsVisibleOnCurrentZoneMinimap()
--      local strType 		= unitNew:GetType()


			if not self.unitPlayerDisposition then
        self.unitPlayerDisposition = GameLib.GetPlayerUnit()
      end
			
			local eDisposition = unitNew:GetDispositionTo(self.unitPlayerDisposition)
			local bShouldShowNameplate = unitNew:ShouldShowNamePlate() -- first pass at hiding units player shouldn't see
     	local bQuestUnit = IsQuestOrChallengeUnit(unitNew)
			
			if bQuestUnit and tMarkers and #tMarkers > 0 then
				for nIdx, strMarker in ipairs(tMarkers) do
					local bAddMarker = false
					
					if strMarker == "Hostile" or strMarker == "Neutral" then
						bAddMarker = true
					end
					
					if bAddMarker then
						self.wndMiniMap:RemoveUnit(unitNew)
						local tMarkerInfo = self.tMinimapMarkerInfo[strMarker]
						local tInfo = self:GetDefaultUnitInfo()
						if tMarkerInfo.strIcon  then
							tInfo.strIcon = tMarkerInfo.strIcon
						end
						tInfo.crObject = kcrMMRQuest
						tInfo.crEdge = kcrMMRQuest
						
						local objectType = tMarkerInfo.objectType or GameLib.CodeEnumMapOverlayType.Unit
						
						local tMarkerOptions = {bNeverShowOnEdge = true}
						if tMarkerInfo.bAboveOverlay then
							tMarkerOptions.bAboveOverlay = tMarkerInfo.bAboveOverlay
						end
						if tMarkerInfo.bShown then
							tMarkerOptions.bShown = tMarkerInfo.bShown
						end
						-- only one of these should be set
						if tMarkerInfo.bFixedSizeSmall then
							tMarkerOptions.bFixedSizeSmall = tMarkerInfo.bFixedSizeSmall
						elseif tMarkerInfo.bFixedSizeMedium then
							tMarkerOptions.bFixedSizeMedium = tMarkerInfo.bFixedSizeMedium
						end
						
						self.wndMiniMap:AddUnit(unitNew, objectType, tInfo, tMarkerOptions, self.tToggledIcons[objectType] ~= nil and not self.tToggledIcons[objectType])
						self.tUnitsShown[unitNew:GetId()] = { tInfo = tInfo, unitObject = unitNew, bQuestUnit = IsQuestOrChallengeUnit(unitNew)}
					end					
				end
			end
			

      -- Collectable Journals / Datacubes
      if tActivation.Datacube ~= nil then
				local tInfo = self:GetDefaultUnitInfo()
				tInfo.strIcon = "spr_HUD_MenuIcons_Lore" -- "NavMate_sprMM_Chat" -- 
				tInfo.crObject = "white"
        self.wndMiniMap:AddUnit(unitNew, self.eObjectTypeDatacube, tInfo, {bNeverShowOnEdge=true, bFixedSizeSmall=true, bAboveOverlay=true}, not self.tToggledIcons[self.eObjectTypeDatacube])
        self.tUnitsShown[unitNew:GetId()] = {unitObject = unitNew}
      end
			
      -- Path interactables
      if (tActivation.ScientistScannable ~= nil and self.playerPathType == PlayerPathLib.PlayerPathType_Scientist)
				or (tActivation.ExplorerInterest ~= nil and self.playerPathType == PlayerPathLib.PlayerPathType_Explorer)
				or (tActivation.SettlerActivate  ~= nil and self.playerPathType == PlayerPathLib.PlayerPathType_Settler)
				or (tActivation.SoldierActivate  ~= nil and self.playerPathType == PlayerPathLib.PlayerPathType_Soldier)
				or (tActivation.Collect ~= nil and tActivation.Collect.bUsePlayerPath and tActivation.Collect.bCanInteract and tActivation.Collect.bIsActive) then
				
				local tInfo = self:GetDefaultUnitInfo()
				tInfo.strIcon = ktMiniMapPathSprites[self.playerPathType]
				tInfo.crObject = "xkcdAcidGreen"
        self.wndMiniMap:AddUnit(unitNew, self.eObjectTypePath, tInfo, {bNeverShowOnEdge=true}, not self.tToggledIcons[self.eObjectTypePath])
        self.tUnitsShown[unitNew:GetId()] = {unitObject = unitNew}
			end
			
      -- Settler Minfrastructure - Available only
      if tActivation.SettlerMinfrastructure ~= nil and tActivation.Busy == nil and self.playerPathType == PlayerPathLib.PlayerPathType_Settler then
				local tInfo = self:GetDefaultUnitInfo()
				tInfo.strIcon = "ClientSprites:MiniMapMarkerTiny"
				tInfo.crObject = "xkcdGrey"
        self.wndMiniMap:AddUnit(unitNew, self.eObjectTypeSettlerMinfrastructure, tInfo, {bNeverShowOnEdge=true}, not self.tToggledIcons[self.eObjectTypeSettlerMinfrastructure])
        self.tUnitsShown[unitNew:GetId()] = {unitObject = unitNew}
			end
      --[[ NavMate Added Toggles -- END ]]--
    end
  end
end

function MiniMapHooker:IsValid()
  if self.addon and self.addon.wndMiniMap ~= nil and self.addon.wndMiniMap:IsValid() then
    return true
  end
  return false
end

function MiniMapHooker:AddOverlayType(overlayType)
  self.addon["eObjectType" .. overlayType] = self.addon.wndMiniMap:CreateOverlayType()
end

function MiniMapHooker:AddOverlayTypes()
	if self:IsValid() and not self.bOverlayTypesAdded then
		self.bOverlayTypesAdded = true
    
    -- add overlay types
    self:AddOverlayType("Datacube")
    self:AddOverlayType("Path")
    self:AddOverlayType("SettlerMinfrastructure")
    --self:AddOverlayType("NavMateWaypoint")
    self.addon.eObjectTypeNavMateWaypoint = self:GetMapMarkerType()
		
		-- set defaults for additional toggled icons
		self.addon.tToggledIcons[self.addon.eObjectTypeDatacube] 	= self.addon.tToggledIcons[self.addon.eObjectTypeDatacube] or true
		self.addon.tToggledIcons[self.addon.eObjectTypePath] 			= self.addon.tToggledIcons[self.addon.eObjectTypePath] or true
		self.addon.tToggledIcons[self.addon.eObjectTypeSettlerMinfrastructure] = self.addon.tToggledIcons[self.addon.eObjectTypeSettlerMinfrastructure] or false
	end
end




local mm_oldOnUnitCreated
function MiniMapHooker:HookOnUnitCreated()
	if self.addon and mm_oldOnUnitCreated == nil then
		mm_oldOnUnitCreated = self.addon.OnUnitCreated
		self.addon.OnUnitCreated = function(self, unitNew)
			if unitNew == nil or not unitNew:IsValid() or unitNew:IsThePlayer() then
				return
			end
			self.tQueuedUnits[unitNew:GetId()] = unitNew
		end
	end
end


--- hook the required minimap functions
function MiniMapHooker:Hook()
  -- Get the minimap addon
  self.addon = self.addon or GetAddon("MiniMap")
	if self.addon == nil or g_wndTheMiniMap == nil then
		return		-- MiniMap addon cannot be found, either replaced or disabled.
	end
	
	self:AddOverlayTypes()

  knMiniMapPingType = knMiniMapPingType or self.addon.eObjectTypePing
  knMapMarkerType   = knMapMarkerType or self:GetMapMarkerType()
  
	self:HookOnUnitCreated()
  self:HookMapClick()
  self:HookQuestStateChanged()
  self:HookHandleUnitCreated()
end

function MiniMapHooker:OnRestoreSettings()
  self.bConfigUpdatePending = true
end

function MiniMapHooker:OnSaveSettings()
  if self.addon == nil then return end
  
  self.config.rotate = self.addon and self.addon.wndMinimapOptions:FindChild("OptionsBtnRotate"):IsChecked() or false
  self.config.tToggledIcons = self.addon.tToggledIcons
end

--- Set the minimap rotation state
-- @param bRotate rotation mode enable state
function MiniMapHooker:SetRotationStatus(bRotate)
  if self.addon == nil then
    return
  end
  bRotate = bRotate or false
    
  self.addon.wndMinimapOptions:FindChild("OptionsBtnRotate"):SetCheck(bRotate)
  self.addon.wndMiniMap:SetMapOrientation(bRotate and 2 or 0)
end

function MiniMapHooker:Update()
  if self.addon == nil then return end
  self:UpdateConfig()
  self:RemoveDeadUnits()
end

--- Updates the minimap from the saved configuration
function MiniMapHooker:UpdateConfig(bForce)
  if (not self.bConfigUpdatePending and not bForce) or self.addon == nil then
    return
  end
  self.bConfigUpdatePending = false
  
  if self.config.mask ~= nil then
    self:SetMask(self.config.mask)
  end
  if self.config.rotate ~= nil then
    self:SetRotationStatus(self.config.rotate)
  end
  self:RedrawResourceNodes()
end

function MiniMapHooker:SetMask(eMask)
  N:LoadSprites()
  local tWndDef = {
    Class               = "MiniMapWindow",
    Name                = "MapContent",
    RelativeToClient    = true,
    IgnoreMouse         = true,
    IgnoreTooltipDelay  = true,
    MaintainAspectRatio = true,
    NewControlDepth     = 2,
    ItemRadius          = 0.7,
    MapOrientation      = 0,
    Events = {
      GenerateTooltip = "OnGenerateTooltip",
      MouseButtonDown = "OnMapClick",
    },
  }

  local fZoomLevel = self.addon.wndMiniMap:GetZoomLevel()

  if self.addon.wndMain:FindChild("SquareBackdrop") then
    self.addon.wndMain:FindChild("SquareBackdrop"):Destroy()
  end
  
  local wndResize = self.addon.wndMain:FindChild("MiniMapResizeArtForPixie")
  if eMask == self.EnumMaskType.Square then
    tWndDef.Mask = N.AssetFolder .. "\\images\\mask_square.tga"
    tWndDef.AnchorFill = 12
    
    -- add a backdrop
    GUILib:Create({ Name = "SquareBackdrop", AnchorFill = 12, Sprite = "ClientSprites:WhiteFill", BGColor = "88000000", NewControlDepth = 0, NeverBringToFront = true, IgnoreMouse = true }):GetInstance(self.addon, self.addon.wndMain)
    
    -- hide the ring bg
    self.addon.wndMain:FindChild("MapRingBackground"):Show(false)
    
    -- move the resize art
    wndResize:MoveToLocation(WindowLocation.new({ fPoints = {0, 0, 0, 0}, nOffsets = {-9,-9,9,9} }))
    wndResize:SetRotation(90)
    wndResize:SetStyle("NewWindowDepth", 1)
    wndResize:AddStyle("NoClip")
  
    self.addon.wndMain:FindChild("ButtonContainer"):SetStyle("NewWindowDepth", 1)
    for _, wndChild in ipairs(self.addon.wndMain:FindChild("ButtonContainer"):GetChildren()) do
      wndChild:SetStyle("IgnoreMouse", 1)
    end
  else
    tWndDef.Mask = [[ui\textures\UI_CRB_HUD_MiniMap_Mask.tex]]
    tWndDef.AnchorFill = true
    tWndDef.CircularItems = true
    
    -- show the ring bg
    self.addon.wndMain:FindChild("MapRingBackground"):Show(true)
    
    -- restore the resize art
    self.addon.wndMain:FindChild("ButtonContainer"):RemoveStyle("NewWindowDepth")
    wndResize:MoveToLocation(WindowLocation.new({ fPoints = {0.06863, 0.77451, 0.06863, 0.77451}, nOffsets = {0,0,18,18} }))
    wndResize:RemoveStyle("NewWindowDepth")
    wndResize:RemoveStyle("NoClip")
    wndResize:SetRotation(0)
    for _, wndChild in ipairs(self.addon.wndMain:FindChild("ButtonContainer"):GetChildren()) do
      wndChild:RemoveStyle("IgnoreMouse")
    end
  end
  
  local wndParent = self.addon.wndMiniMap:GetParent()
  self.addon.wndMiniMap:Destroy()
  GUILib:Create(tWndDef):GetInstance(self.addon, wndParent)
  self.addon.wndMiniMap = self.addon.wndMain:FindChild("MapContent")
  g_wndTheMiniMap = self.addon.wndMiniMap
	
	-- redraw all overlays on the minimap
 	self.addon:OnChangeZoneName()
  N:UpdateMapWaypoints()
 
	-- restore zoom level
	self.addon.wndMiniMap:SetZoomLevel(fZoomLevel)
end


function MiniMapHooker:RedrawResourceNodes()
  if not self.addon then return end
  for _, tUnitsShown in ipairs({self.addon.tUnitsShown, self.addon.tUnitsHidden}) do
    for unitIdx, tUnitData in pairs(tUnitsShown) do
			if tUnitData.unitObject:CanBeHarvestedBy(GameLib.GetPlayerUnit()) then
				self.addon:OnUnitChanged(tUnitData.unitObject)
			end
    end
  end
end