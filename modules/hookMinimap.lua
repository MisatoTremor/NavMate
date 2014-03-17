-----------------------------------------------------------------------------------------------
-- MiniMap Hooker
-----------------------------------------------------------------------------------------------
require "Apollo"
require "GameLib"
require "Unit"

local setmetatable, ipairs, pairs, type = setmetatable, ipairs, pairs, type

local N = Apollo.GetAddon("NavMate")
local L = N.L
local DaiGUI = Apollo.GetPackage("DaiGUI-1.0").tPackage

local ktModuleName = "MiniMapHooker"
local MiniMapHooker = N:NewModule(ktModuleName)

MiniMapHooker.EnumMaskType = {
	Default = 1,
	Square  = 2,
}

-----------------------------------------------------------------------------------------------
-- UI Form Definition
-----------------------------------------------------------------------------------------------
local function CreateMiniMapMenuButton(o, p)
	local wnd = DaiGUI:Create({
		Class         = "Button",
		Name          = "NavMateMiniMapMenuButton",
		NoClip        = true,
		TestAlpha     = true,
		AnchorPoints  = "BOTTOMRIGHT",
		AnchorOffsets = {-29,-25,-1,3},
		Scale 				= 0.9,
		DT_CENTER     = true,
		DT_VCENTER    = true,
		Base          = "CRB_Basekit:kitBtn_Metal_Options",
		Tooltip       = L["NavMate Options"],
		ButtonType    = "PushButton",
		SwallowMouseClicks = true,
		WindowSoundTemplate = "PushbuttonDigi01",
		TransitionShowHide = true,
		Events = {
			ButtonSignal   = function() N:ToggleOptionsWindow() end,
		},
	}):GetInstance(o, p)
	wnd:Show(false, true)
	return wnd
end

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
  self:Hook()
  self.bInitialized = true
end


function MiniMapHooker:SetupMenu()
  if self.addon == nil or self.wndMenuBtn ~= nil then
    return
  end
  
  self.wndMenuBtn = CreateMiniMapMenuButton(self, self.addon.wndMain:FindChild("ButtonContainer"))
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
      if self.tUnitsHidden and self.tUnitsHidden[unitNew:GetId()] then
        self.tUnitsHidden[unitNew:GetId()] = nil
        self.wndMiniMap:RemoveUnit(unitNew)
      end
      
      if self.tUnitsShown and self.tUnitsShown[unitNew:GetId()] then
        self.tUnitsShown[unitNew:GetId()] = nil
        self.wndMiniMap:RemoveUnit(unitNew)
      end

      local tActivation = unitNew:GetActivationState()
      local strMarker 	= unitNew:GetMiniMapMarker()
      local bShowUnit 	= unitNew:IsVisibleOnCurrentZoneMinimap()
      local strType 		= unitNew:GetType()
      
      if bShowUnit == false and not unitNew:IsInYourGroup() then
        self.tUnitsHidden[unitNew:GetId()] = {unitObject = unitNew} -- valid, but different subzone. Add it to the list
        return
      end

      local tMarkerOverride 
      if strMarker and N.tMinimapMarkerVisibility[strMarker] ~= nil then
        if N.tMinimapMarkerInfo[strMarker]then
          tMarkerOverride = self.tMinimapMarkerInfo[strMarker]
        elseif N.tMinimapMarkerVisibility[strMarker] == false then
          self.tUnitsHidden[unitNew:GetId()] = {strType = "TradeskillNodes", unitObject = unitNew}
          return
        end
			elseif strType == "Harvest" then
				self.arResourceNodes[unitNew:GetId()] = unitNew
      end

      if not self.unitPlayerDisposition then
        self.unitPlayerDisposition = GameLib.GetPlayerUnit()
      end
      
      -- NM: Check if we need to set the player path type 
      if not self.playerPathType then
        self.playerPathType = GameLib.GetPlayerUnit():GetPlayerPathType()
      end
      
        
      local eDisposition = unitNew:GetDispositionTo(self.unitPlayerDisposition)
      local bShouldShowNameplate = unitNew:ShouldShowNamePlate() -- first pass at hiding units player shouldn't see
      
      -- NM: Check if unit is required for a quest 
      local bQuestUnit = IsQuestOrChallengeUnit(unitNew)

			-- Duplicates are handled in code; only one of each type per unit ID is kept (most recently added used).
			-- This list represents the priority in which a unit's types will be drawn, with entries at the top having higher priority.
			if unitNew:IsInYourGroup() then
				for idx = 1, GroupLib.GetMemberCount() do
					local tMemberInfo = GroupLib.GetGroupMember(idx)
					if tMemberInfo.bIsOnline and GroupLib.GetUnitForGroupMember(idx) == unitNew then
						local tInfo = self:GetDefaultUnitInfo()
						tInfo.bAboveOverlay = true
						tInfo.strIcon = groupConfig.sprIcon -- "sprMM_Group"
						if tInfo.bInCombatPvp then
              tInfo.crObject		= groupConfig.pvpColor -- CColor.new(0, 1, 0, 1)
              tInfo.strIconEdge	= groupConfig.sprIcon
              tInfo.crEdge 		  = groupConfig.pvpColor -- CColor.new(0, 1, 0, 1)
						else
              tInfo.crObject		= groupConfig.normalColor -- CColor.new(0, 1, 0, 1)
              tInfo.strIconEdge	= groupConfig.sprIcon
              tInfo.crEdge 		  = groupConfig.normalColor -- CColor.new(0, 1, 0, 1)
						end
						self.wndMiniMap:AddUnit(unitNew, self.eObjectTypeGroupMember, tInfo, {bFixedSizeLarge = true}, false) -- not self.tToggledIcons[self.eObjectTypeGroupMember])
						self.tUnitsShown[unitNew:GetId()] = {unitObject = unitNew}
					end
				end
			end

			if unitNew:IsFriend() then
				local tInfo = self:GetDefaultUnitInfo()
				tInfo.strIcon = "ClientSprites:Icon_Windows_UI_CRB_Friend"
				self.wndMiniMap:AddUnit(unitNew, self.eObjectTypeFriend, tInfo, {bNeverShowOnEdge = true, bShown = true, bFixedSizeSmall = true}, false)
				self.tUnitsShown[unitNew:GetId()] = {unitObject = unitNew}
			end

			if unitNew:IsRival() then
				local tInfo = self:GetDefaultUnitInfo()
				tInfo.strIcon = "ClientSprites:Icon_Windows_UI_CRB_Rival"
				self.wndMiniMap:AddUnit(unitNew, self.eObjectTypeRival, tInfo, {bNeverShowOnEdge = true, bShown = true, bFixedSizeSmall = true}, false)
				self.tUnitsShown[unitNew:GetId()] = {unitObject = unitNew}
			end

			if tActivation.Trainer ~= nil then
				local tInfo = self:GetDefaultUnitInfo()
				tInfo.strIcon = "Icon_Windows_UI_VendorIcon"
				self.wndMiniMap:AddUnit(unitNew, self.eObjectTypeTrainer, tInfo, {bNeverShowOnEdge = true, bFixedSizeMedium = true}, not self.tToggledIcons[self.eObjectTypeTrainer])
				self.tUnitsShown[unitNew:GetId()] = {unitObject = unitNew}
			end

			if tActivation.QuestKill ~= nil then
				local tInfo = self:GetDefaultUnitInfo()
				tInfo.strIcon = "sprMM_TargetCreature"
				self.wndMiniMap:AddUnit(unitNew, self.eObjectTypeQuestKill, tInfo, {bNeverShowOnEdge = true, bFixedSizeMedium = true}, not self.tToggledIcons[self.eObjectTypeQuestReward])
				self.tUnitsShown[unitNew:GetId()] = {unitObject = unitNew}
			end
			if tActivation.QuestTarget ~= nil then
				local tInfo = self:GetDefaultUnitInfo()
				tInfo.strIcon = "sprMM_TargetObjective"
				self.wndMiniMap:AddUnit(unitNew, self.eObjectTypeQuestTarget, tInfo, {bNeverShowOnEdge = true, bFixedSizeMedium = true}, not self.tToggledIcons[self.eObjectTypeQuestReward])
				self.tUnitsShown[unitNew:GetId()] = {unitObject = unitNew}
			end
			if tActivation.PublicEventKill ~= nil then
				local tInfo = self:GetDefaultUnitInfo()
				tInfo.strIcon = "sprMM_TargetCreature"
				self.wndMiniMap:AddUnit(unitNew, self.eObjectTypePublicEventKill, tInfo, {bNeverShowOnEdge = true, bFixedSizeMedium = true}, not self.tToggledIcons[self.eObjectTypePublicEvent])
				self.tUnitsShown[unitNew:GetId()] = {unitObject = unitNew}
			end
			if tActivation.PublicEventTarget ~= nil then
				local tInfo = self:GetDefaultUnitInfo()
				tInfo.strIcon = "sprMM_TargetObjective"
				self.wndMiniMap:AddUnit(unitNew, self.eObjectTypePublicEventTarget, tInfo, {bNeverShowOnEdge = true, bFixedSizeMedium = true}, not self.tToggledIcons[self.eObjectTypePublicEvent])
				self.tUnitsShown[unitNew:GetId()] = {unitObject = unitNew}
			end
			if tActivation.QuestReward ~= nil then
				local tInfo = self:GetDefaultUnitInfo()
				tInfo.strIcon = "sprMM_QuestCompleteUntracked"
				self.wndMiniMap:AddUnit(unitNew, self.eObjectTypeQuestReward, tInfo, {bNeverShowOnEdge = true,}, not self.tToggledIcons[self.eObjectTypeQuestReward])
				self.tUnitsShown[unitNew:GetId()] = {unitObject = unitNew}
			end
			if tActivation.QuestNew ~= nil or tActivation.QuestNewMain ~= nil or tActivation.QuestNewRepeatable ~= nil then
				local tInfo = self:GetDefaultUnitInfo()
				tInfo.strIcon = "sprMM_QuestGiver"
				self.wndMiniMap:AddUnit(unitNew, self.eObjectTypeQuestNew, tInfo, {bNeverShowOnEdge = true}, not self.tToggledIcons[self.eObjectTypeQuestReward])
				self.tUnitsShown[unitNew:GetId()] = {unitObject = unitNew}
			end
			if tActivation.QuestReceiving ~= nil then
				local tInfo = self:GetDefaultUnitInfo()
				tInfo.strIcon = "sprMM_QuestCompleteOngoing"
				tInfo.crObject = CColor.new(1.0, 1.0, 1.0, 1.0)
				self.wndMiniMap:AddUnit(unitNew, self.eObjectTypeQuestReceiving, tInfo, {bNeverShowOnEdge = true,}, not self.tToggledIcons[self.eObjectTypeQuestReward])
				self.tUnitsShown[unitNew:GetId()] = {unitObject = unitNew}
			end
			if tActivation.QuestNewSoon ~= nil or tActivation.QuestNewMainSoon ~= nil then
				local tInfo = self:GetDefaultUnitInfo()
				tInfo.strIcon = "sprMM_QuestGiverOngoing"
				self.wndMiniMap:AddUnit(unitNew, self.eObjectTypeQuestNewSoon, tInfo, {bNeverShowOnEdge = true}, not self.tToggledIcons[self.eObjectTypeQuestReward])
				self.tUnitsShown[unitNew:GetId()] = {unitObject = unitNew}
			end
			if tActivation.ConvertItem ~= nil then
				local tInfo = self:GetDefaultUnitInfo()
				tInfo.strIcon = "sprMM_VendorGeneral"
				self.wndMiniMap:AddUnit(unitNew, self.eObjectTypeVendor, tInfo, {bNeverShowOnEdge = true, bFixedSizeMedium = true}, not self.tToggledIcons[self.eObjectTypeVendor])
				self.tUnitsShown[unitNew:GetId()] = {unitObject = unitNew}
			end
			if tActivation.ConvertRep ~= nil then
				local tInfo = self:GetDefaultUnitInfo()
				tInfo.strIcon = "sprMM_VendorGeneral"
				self.wndMiniMap:AddUnit(unitNew, self.eObjectTypeVendor, tInfo, {bNeverShowOnEdge = true, bFixedSizeMedium = true}, not self.tToggledIcons[self.eObjectTypeVendor])
				self.tUnitsShown[unitNew:GetId()] = {unitObject = unitNew}
			end
			if tActivation.Vendor ~= nil then
				local tInfo = self:GetDefaultUnitInfo()
				tInfo.strIcon = "sprMM_VendorGeneral"
				self.wndMiniMap:AddUnit(unitNew, self.eObjectTypeVendor, tInfo, {bNeverShowOnEdge = true, bFixedSizeMedium = true}, not self.tToggledIcons[self.eObjectTypeVendor])
				self.tUnitsShown[unitNew:GetId()] = {unitObject = unitNew}
			end
			-- show mini map marker
			if tMarkerOverride then
				local tInfo = self:GetDefaultUnitInfo()
				if tMarkerOverride.strIcon  then
					tInfo.strIcon = tMarkerOverride.strIcon
				end
				if tMarkerOverride.crObject then
					tInfo.crObject = tMarkerOverride.crObject
				end
				if tMarkerOverride.crEdge   then
					tInfo.crEdge = tMarkerOverride.crEdge
				end

				local tMarkerOptions = {bNeverShowOnEdge = true}
				if tMarkerOverride.bAboveOverlay then
					tMarkerOptions.bAboveOverlay = tMarkerOverride.bAboveOverlay
				end

				local objectType = GameLib.CodeEnumMapOverlayType.Unit
				if tMarkerOverride.objectType then
					objectType = tMarkerOverride.objectType
				end

				self.wndMiniMap:AddUnit(unitNew, objectType, tInfo, tMarkerOptions, self.tToggledIcons[objectType] ~= nil and not self.tToggledIcons[objectType])
				self.tUnitsShown[unitNew:GetId()] = { tInfo = tInfo, unitObject = unitNew }
			end
			-- instance portals
			if unitNew:IsVisibleInstancePortal() then
				local tInfo = self:GetDefaultUnitInfo()
				tInfo.strIcon = "sprMM_InstancePortal"
				self.wndMiniMap:AddUnit(unitNew, self.eObjectTypeInstancePortal, tInfo, {bNeverShowOnEdge = true}, not self.tToggledIcons[self.eObjectTypeInstancePortal])
				self.tUnitsShown[unitNew:GetId()] = {unitObject = unitNew}
			end
			-- bind points
				if unitNew:GetType() == "BindPoint" then
				local tInfo = self:GetDefaultUnitInfo()
				if unitNew:IsCurrentBindPoint() then
					tInfo.strIcon = "sprMM_EldanGateActive"
					self.wndMiniMap:AddUnit(unitNew, self.eObjectTypeBindPointActive, tInfo, {bNeverShowOnEdge = true}, not self.tToggledIcons[self.eObjectTypeBindPointActive])
					self.tUnitsShown[unitNew:GetId()] = {unitObject = unitNew}
				else
					tInfo.strIcon = "sprMM_EldanGateInactive"
					self.wndMiniMap:AddUnit(unitNew, self.eObjectTypeBindPointInactive, tInfo, {bNeverShowOnEdge = true}, not self.tToggledIcons[self.eObjectTypeBindPointActive])
					self.tUnitsShown[unitNew:GetId()] = {unitObject = unitNew}
				end
			end
			-- flight paths
			if tActivation.FlightPathSettler ~= nil then
				local tInfo = self:GetDefaultUnitInfo()
				tInfo.strIcon = "sprMM_VendorFlight"
				self.wndMiniMap:AddUnit(unitNew, tInfo, self.eObjectTypeVendorFlight, {bNeverShowOnEdge = true, bFixedSizeMedium = true}, false)
				self.tUnitsShown[unitNew:GetId()] = {unitObject = unitNew}
			end
			if tActivation.FlightPathNew ~= nil then
				local tInfo = self:GetDefaultUnitInfo()
				tInfo.strIcon = "sprMMIndicator"
				self.wndMiniMap:AddUnit(unitNew, tInfo, self.eObjectTypeFlightPathNew, {bNeverShowOnEdge = true, bFixedSizeMedium = true}, false)
				self.tUnitsShown[unitNew:GetId()] = {unitObject = unitNew}
			end
			if tActivation.FlightPath ~= nil then
				local tInfo = self:GetDefaultUnitInfo()
				tInfo.strIcon = "sprMM_VendorFlight"
				self.wndMiniMap:AddUnit(unitNew, tInfo, self.eObjectTypeVendorFlight, {bNeverShowOnEdge = true}, false)
				self.tUnitsShown[unitNew:GetId()] = {unitObject = unitNew}
			end
			-- tradeskill, auction and marketplace NPC's
			if tActivation.TradeskillTrainer ~= nil or tActivation.CraftingStation ~= nil then
				local tInfo = self:GetDefaultUnitInfo()
				tInfo.strIcon = "sprMM_Tradeskill"
				self.wndMiniMap:AddUnit(unitNew, self.eObjectTypeTradeskills, tInfo, {bNeverShowOnEdge = true, bFixedSizeMedium = true}, not self.tToggledIcons[self.eObjectTypeTradeskills])
				self.tUnitsShown[unitNew:GetId()] = {unitObject = unitNew}
			end
			if tActivation.CommodityMarketplace ~= nil then
				local tInfo = self:GetDefaultUnitInfo()
				tInfo.strIcon = "CRB_MinimapSprites:sprMM_AuctionHouse"
				self.wndMiniMap:AddUnit(unitNew, self.eObjectTypeAuctioneer, tInfo, {bNeverShowOnEdge = true}, not self.tToggledIcons[self.eObjectTypeVendor])
				self.tUnitsShown[unitNew:GetId()] = {unitObject = unitNew}
			end
			if tActivation.ItemAuctionhouse then
				local tInfo = self:GetDefaultUnitInfo()
				tInfo.strIcon = "CRB_MinimapSprites:sprMM_Bank"
				self.wndMiniMap:AddUnit(unitNew, self.eObjectTypeCommodity, tInfo, {bNeverShowOnEdge = true}, not self.tToggledIcons[self.eObjectTypeVendor])
				self.tUnitsShown[unitNew:GetId()] = {unitObject = unitNew}
			end
			if tActivation.SettlerImprovement ~= nil then
				local tInfo = self:GetDefaultUnitInfo()
				tInfo.strIcon = "sprMM_SmallIconSettler"
				self.wndMiniMap:AddUnit(unitNew, GameLib.CodeEnumMapOverlayType.PathObjective, tInfo, {bNeverShowOnEdge = true}, not self.tToggledIcons[GameLib.CodeEnumMapOverlayType.PathObjective])
				self.tUnitsShown[unitNew:GetId()] = {unitObject = unitNew}
			end

      --[[ NavMate Added Toggles -- START ]]--
			if eDisposition == Unit.CodeEnumDisposition.Neutral and bShouldShowNameplate and (strType == "NonPlayer" or strType == "Turret") then
				local tInfo = self:GetDefaultUnitInfo()
				tInfo.strIcon = "ClientSprites:MiniMapMarkerTiny"
				-- NM: Check if unit is required for a quest 
				tInfo.crObject = bQuestUnit and kcrMMRQuest or "xkcdBrightYellow"
				self.wndMiniMap:AddUnit(unitNew, self.eObjectTypeNeutral, tInfo, {bNeverShowOnEdge = true, bShown = false}, not self.tToggledIcons[self.eObjectTypeNeutral])
        self.tUnitsShown[unitNew:GetId()] = {strType = bQuestUnit and "MMR_Quest" or "MMR_Neutral", unitObject = unitNew, bQuestUnit = IsQuestOrChallengeUnit(unitNew)}
      end
      
			if eDisposition == Unit.CodeEnumDisposition.Hostile and bShouldShowNameplate  and (strType == "NonPlayer" or strType == "Turret") then
				local tInfo = self:GetDefaultUnitInfo()
				tInfo.strIcon = "ClientSprites:MiniMapMarkerTiny"
				-- NM: Check if unit is required for a quest 
				tInfo.crObject = bQuestUnit and kcrMMRQuest or "xkcdBrightRed"
				self.wndMiniMap:AddUnit(unitNew, self.eObjectTypeHostile, tInfo, {bNeverShowOnEdge = true, bShown = false}, not self.tToggledIcons[self.eObjectTypeHostile])
        self.tUnitsShown[unitNew:GetId()] = {strType = bQuestUnit and "MMR_Quest" or "MMR_Hostile", unitObject = unitNew, bQuestUnit = IsQuestOrChallengeUnit(unitNew)}
      end
      
      -- Bank Support
      if tActivation.Bank ~= nil then
				local tInfo = self:GetDefaultUnitInfo()
				tInfo.strIcon = "sprMM_Bank"
        self.wndMiniMap:AddUnit(unitNew, self.eObjectTypeBank, tInfo, {bNeverShowOnEdge=true}, not self.tToggledIcons[self.eObjectTypeBank])
        self.tUnitsShown[unitNew:GetId()] = {unitObject = unitNew}
			end
        
      -- Mailbox Support
      if tActivation.Mail ~= nil then
				local tInfo = self:GetDefaultUnitInfo()
        tInfo.strIcon = "sprMM_Mailbox"
        self.wndMiniMap:AddUnit(unitNew, self.eObjectTypeMailbox, tInfo, {bNeverShowOnEdge=true}, not self.tToggledIcons[self.eObjectTypeMailbox])
        self.tUnitsShown[unitNew:GetId()] = {unitObject = unitNew}
			end
			
      -- Collectable Journals / Datacubes
      if tActivation.Datacube ~= nil then
				local tInfo = self:GetDefaultUnitInfo()
				tInfo.strIcon = "NavMate_sprMM_Chat"
				tInfo.crObject = "xkcdCandyPink"
        self.wndMiniMap:AddUnit(unitNew, self.eObjectTypeDatacube, tInfo, {bNeverShowOnEdge=true}, not self.tToggledIcons[self.eObjectTypeDatacube])
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

local mm_oldOnMiniMapMouseEnter,mm_oldOnMiniMapMouseExit
function MiniMapHooker:HookOnMiniMapMouseEnterExit()
  if self.addon and mm_oldOnMiniMapMouseEnter == nil then
    mm_oldOnMiniMapMouseEnter = self.addon.OnMiniMapMouseEnter
    self.addon.OnMiniMapMouseEnter = function(self, wndHandler, wndControl)
      self.wndMain:FindChild("NavMateMiniMapMenuButton"):Show(true)
      mm_oldOnMiniMapMouseEnter(self, wndHandler, wndControl)
    end
  end
  if self.addon and mm_oldOnMiniMapMouseExit == nil then
    mm_oldOnMiniMapMouseExit = self.addon.OnMiniMapMouseExit 
    self.addon.OnMiniMapMouseExit = function(self, wndHandler, wndControl)
      self.wndMain:FindChild("NavMateMiniMapMenuButton"):Show(false)
      mm_oldOnMiniMapMouseExit(self, wndHandler, wndControl)
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
    
    -- add mailbox and bank overlay types
    self:AddOverlayType("Mailbox")
    self:AddOverlayType("Bank")
    self:AddOverlayType("Datacube")
    self:AddOverlayType("Path")
    self:AddOverlayType("SettlerMinfrastructure")
    --self:AddOverlayType("NavMateWaypoint")
    self.addon.eObjectTypeNavMateWaypoint = self:GetMapMarkerType()
		
		-- set defaults for additional toggled icons
		self.addon.tToggledIcons[self.addon.eObjectTypeMailbox] 	= self.addon.tToggledIcons[self.addon.eObjectTypeMailbox] or true
		self.addon.tToggledIcons[self.addon.eObjectTypeBank] 			= self.addon.tToggledIcons[self.addon.eObjectTypeBank] or true
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
  self.addon = self.addon or _G["MiniMapLibrary"] or GetAddon("MiniMap")
	if self.addon == nil then
		return		-- MiniMap addon cannot be found, either replaced or disabled.
	end
  
	self:AddOverlayTypes()

  knMiniMapPingType = knMiniMapPingType or self.addon.eObjectTypePing
  knMapMarkerType   = knMapMarkerType or self:GetMapMarkerType()
  
	self:HookOnUnitCreated()
  self:HookMapClick()
  self:HookQuestStateChanged()
  self:HookHandleUnitCreated()
  self:HookOnMiniMapMouseEnterExit()
  self:SetupMenu()
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
    DaiGUI:Create({ Name = "SquareBackdrop", AnchorFill = 12, Sprite = "ClientSprites:WhiteFill", BGColor = "88000000", NewControlDepth = 0, NeverBringToFront = true, IgnoreMouse = true }):GetInstance(self.addon, self.addon.wndMain)
    
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
  DaiGUI:Create(tWndDef):GetInstance(self.addon, wndParent)
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
      if tUnitData.unitObject:GetType() == "Harvest" then
        local strMarker = tUnitData.unitObject:GetMiniMapMarker()
        if strMarker then
          self.addon:OnUnitChanged(tUnitData.unitObject)
        end
      end
    end
  end
end