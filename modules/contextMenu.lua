local NavMate        = Apollo.GetAddon("NavMate")
local L              = NavMate.L
local GUILib         = Apollo.GetPackage("Gemini:GUI-1.0").tPackage
local GLocale        = Apollo.GetPackage("Gemini:Locale-1.0").tPackage
local waypoints      = NavMate.waypoints

local function CreateWaypointContextMenuForm(o, p)
  return GUILib:Create({
    Name                 = "WaypointContextMenuForm",
    AnchorOffsets        = {0,0,250,58},
    Sprite               = "CRB_Basekit:kitInnerFrame_MetalGrey_InlayStretch",
    CloseOnExternalClick = true,
    IgnoreMouse          = true,
    Overlapped           = true,
    Escapable            = true,
    NoClip               = true,
    NewWindowDepth       = true,
    SwallowMouseClicks   = true,
    Font                 = "CRB_InterfaceSmall_O",
    Events = {
      WindowClosed      = "OnWaypointContextMenuClosed",
    },
    
    Pixies = {
      { Text = L["WaypointContextMenuTitle"], TextColor = "xkcdYellow", Font = "CRB_InterfaceSmall_O", AnchorPoints = "HFILL", AnchorOffsets = {10,4,-10,20}, DT_VCENTER = true, DT_CENTER = true },
    },
    
    
    Children = {
      { -- ButtonList
        Name = "ButtonList",
        AnchorPoints  = "FILL",
        AnchorOffsets = {4,26,-4,-4},
        IgnoreMouse = true,
      },
    },
    
  }):GetInstance(o, p)
end

local function CreateWaypointContextMenuButton(o, p)
  return GUILib:Create({
    Class               = "Button",
    Name                = "WaypointContextMenuButton",
    AnchorPoints        = "HFILL",
    AnchorOffsets       = {0,0,0,25},
    DT_VCENTER          = true,
    ButtonType          = "PushButton",
    Base                = "CRB_Basekit:kitBtn_List_Holo",
    TextTheme           = "UI_BtnTextGrayList",
    SwallowMouseClicks  = true,
    WindowSoundTemplate = "PushbuttonDigi01",
    Font                = "CRB_InterfaceSmall_O",
    Events = {
      ButtonSignal   = "OnContextMenuBtn",
    },
    
    Children = {
      { -- BtnText
        Name = "BtnText",
        AnchorPoints  = "FILL",
        AnchorOffsets = {8,0,0,0},
        IgnoreMouse = true,
        TextColor = "UI_BtnTextGrayListNormal",
        Font = "CRB_InterfaceSmall_O",
        Text = "--",
        DT_VCENTER = true,
      },
    
      { -- BtnMouseCatcher
        Name = "BtnMouseCatcher",
        AnchorFill = true,
        IgnoreMouse = true,
        
        Events = {
          MouseEnter      = "OnWaypointContextMenuBtnMouseEnter",
          MouseExit       = "OnWaypointContextMenuBtnMouseExit",
          MouseButtonDown = "OnWaypointContextMenuBtnMouseDown",
        },
      },
    },
    
  }):GetInstance(o, p)
end






-----------------------------------------------------------------------------------------------
-- Map-Related Functions
-----------------------------------------------------------------------------------------------



--- Get the map type of the window
-- @param wnd the map window
-- @return "z" for ZoneMap, "m" for MiniMap
local function GetMapType(wnd)
	if wnd:GetName() == "ZoneMap" then
    return NavMate.CodeEnumMapType.ZoneMap
	elseif wnd:GetName() == "MapContent" and wnd:GetParent() ~= nil and wnd:GetParent():GetName() == "Minimap" then
    return NavMate.CodeEnumMapType.MiniMap
	end
end

--- Get the map objects at window point
-- @param wnd the map window
-- @param tPoint the coords on the map window
-- @return an array of map objects
local function GetMapObjects(wnd, tPoint)
	local tMapObjects
	local eMapType = GetMapType(wnd)

	if eMapType == NavMate.CodeEnumMapType.ZoneMap then
		tMapObjects = g_wndTheZoneMap:GetObjectsAt(tPoint.x, tPoint.y) -- all others
	elseif eMapType == NavMate.CodeEnumMapType.MiniMap then
		tMapObjects = g_wndTheMiniMap:GetObjectsAtPoint(tPoint.x, tPoint.y) -- all others
	end
	return tMapObjects
end

---------------------------------------------------------------------------------------------------
-- Waypoint Context Menu Functions
---------------------------------------------------------------------------------------------------
function NavMate:OnShowWaypointContextMenu(wndParent, tPoint, nMapMarkerType)
	if wndParent:GetName() == "NavMateArrow" then
		if self:GetModule("Arrow").waypoint ~= nil then
			self:CreateWaypointContextMenu(wndParent, self:GetModule("Arrow").waypoint)
		end
	else
		local tMapObjects = GetMapObjects(wndParent, tPoint)
    if tMapObjects ~= nil then
      self:ShowMapWaypointContextMenu(wndParent, tPoint, tMapObjects, nMapMarkerType)
    end
	end
end

function NavMate:ShowMapWaypointContextMenu(wndParent, tPoint, tMapObjects, nMapMarkerType)
  local eMapType = GetMapType(wndParent)
  for idx, tMapObject in ipairs(tMapObjects) do
    if tMapObject.eType == nMapMarkerType then
      local tWaypointData = waypoints:FindByMapId(eMapType, tMapObject.id)
      if tWaypointData ~= nil then
        -- display the waypoint context menu
        if eMapType == NavMate.CodeEnumMapType.MiniMap then
          self:CreateWaypointContextMenu(wndParent:GetParent(), tWaypointData)
          self:GetModule("MiniMapHooker"):RemovePing(tPoint)
        else
          self:CreateWaypointContextMenu(wndParent, tWaypointData)
        end
        break
      end
    end
  end
end

--- Create the waypoint context menu
-- @param wndParent window to become the parent for the context menu
-- @param tWaypoint waypoint
function NavMate:CreateWaypointContextMenu(wndParent, tWaypoint)
  if wndParent == nil or tWaypoint == nil then
    return
  end
  
  -- Are we receiving this from the Arrow Form?
  local bFromArrow = wndParent:GetName() == "NavMateArrow"
	local tCursor = wndParent:GetMouse()
  local tSCursor = Apollo.GetMouse()
  
  -- Rebuild the context menu form
	self:DestroyWaypointContextMenu()
	self.wndWaypointContextMenu = CreateWaypointContextMenuForm(self, wndParent)
	self.wndWaypointContextMenu:SetData(tWaypoint)
	self.wndWaypointContextMenu:ToFront()
  
  
	
  -- Generate the button list
	local wndButtonList = self.wndWaypointContextMenu:FindChild("ButtonList")
	local tContextBtns = {
		{ eType = "BtnRemoveWaypoint", 		strText = L["ContextMenu_RemoveWaypoint"] },
		{ eType = "BtnRemoveAllWaypoints", 	strText = L["ContextMenu_RemoveAllWaypoints"] },
	}
  if GroupLib.InGroup() then 
    table.insert(tContextBtns, { eType = "BtnSendWaypointToParty", strText = L["ContextMenu_SendWaypointToParty"] })
  end
  
	-- TODO: Implement Send Waypoint -- Send waypoint to >> { guild, circle }
  -- party should cover raid, warparty, instances and battlegrounds, though it requires more testing.
	
	if bFromArrow then
		-- Show lock/unlock the arrow
		local strLockUnlock = L["ContextMenu_" .. (self:GetModule("Arrow").bLocked and "UnlockArrow" or "LockArrow")]
		table.insert(tContextBtns, { eType = "BtnLockArrowToggle", strText = strLockUnlock })
		table.insert(tContextBtns, { eType = "BtnDisableArrow", strText = "Disable Arrow" })
  else
		-- Show "Set as arrow"
    table.insert(tContextBtns, 1, { eType = "BtnSetAsArrow", strText = L["ContextMenu_SetWaypointAsArrow"] })
	end
	
  
  -- Build the buttons
	for idx, tContextBtn in ipairs(tContextBtns) do
		self:HelperBuildWaypointContextMenuButton(wndButtonList, tContextBtn.eType, tContextBtn.strText)
	end
	
  
  -- Translate the context menu
  GLocale:TranslateWindow(L, self.wndWaypointContextMenu)
  
  local nWidth = self.wndWaypointContextMenu:GetWidth()
  -- sort and size the context menu
  local nHeight = wndButtonList:ArrangeChildrenVert(0)
  
  -- check the context menu boundaries
  local nLeft, nTop, nRight, nBottom = self:GetContextMenuOffsets(tCursor, tSCursor, nWidth, nHeight)
  self.wndWaypointContextMenu:SetAnchorOffsets(nLeft, nTop, nRight, nBottom)
end

-- ensures clamping to screen
function NavMate:GetContextMenuOffsets(wndCursor, scrCursor, nWidth, nHeight)
  local knOffset = 4
  local knHeightBuffer = 32
  local nScreenWidth, nScreenHeight = Apollo.GetScreenSize()
  local nSLeft, nSTop = scrCursor.x + knOffset, scrCursor.y + knOffset
  local nLeft, nTop = wndCursor.x + knOffset, wndCursor.y + knOffset
  
  if nSLeft + nWidth > nScreenWidth then
    nLeft = nLeft - (nSLeft + nWidth - nScreenWidth)
  elseif nSLeft < 0 then
    nLeft = 0
  end
  if nSTop + nHeight + knHeightBuffer > nScreenHeight then
    nTop = nTop - (nSTop + nHeight + knHeightBuffer - nScreenHeight)
  elseif nSTop < 0 then
    nTop = 0
  end
  
  local nRight = nLeft + nWidth
  local nBottom = nTop + nHeight + knHeightBuffer
  
  return nLeft, nTop, nRight, nBottom
end


--- Destroys the context menu if it exists and is valid
function NavMate:DestroyWaypointContextMenu()
	if self.wndWaypointContextMenu and self.wndWaypointContextMenu:IsValid() then
		self.wndWaypointContextMenu:Destroy()
	end
end

--- Destroy the context menu when it is closed
function NavMate:OnWaypointContextMenuClosed( wndHandler, wndControl )
  self:DestroyWaypointContextMenu()
end

--- Process which button was clicked on the context menu
function NavMate:ProcessWaypointContextClick(eButtonType)
	if not self.wndWaypointContextMenu or not self.wndWaypointContextMenu:IsValid() then
		return
	end
  
	local tWaypointData = self.wndWaypointContextMenu:GetData()
	if eButtonType == "BtnSetAsArrow" then
		self:GetModule("Arrow"):SetWaypoint(tWaypointData)
	elseif eButtonType == "BtnRemoveWaypoint" then
		waypoints:Remove(tWaypointData)
		self:GetModule("Arrow"):SetWaypoint()
		self:ForceUpdate()
  elseif eButtonType == "BtnSendWaypointToGuild" then
    -- figure out how to call SendMessage to guild without using the roster
    Print("Sending waypoints to guilds and circles is not implemented yet.")
  elseif eButtonType == "BtnSendWaypointToParty" then
    -- get a list of group member names
    local tGroupMembers = self:BuildGroupMemberList()
    if tGroupMembers and #tGroupMembers > 0 then
      self:GetModule("WaypointComm"):SendWaypoint(tWaypointData, tGroupMembers)
    end
	elseif eButtonType == "BtnRemoveAllWaypoints" then
		self:RemoveAllWaypoints()
	elseif eButtonType == "BtnLockArrowToggle" then
		self:GetModule("Arrow"):ToggleLock()
	elseif eButtonType == "BtnRemoveZoneWaypoints" then
  elseif eButtonType == "BtnDisableArrow" then
    self:GetModule("Arrow"):Disable()
	end
end

function NavMate:BuildGroupMemberList()
  local nMemberCount = GroupLib.GetMemberCount()
  if nMemberCount > 0 then
    local strPlayerName = GameLib.GetPlayerUnit():GetName()
    local tGroupMembers = {}
    for idx = 1, nMemberCount do
      local tMemberInfo = GroupLib.GetGroupMember(idx)
      if tMemberInfo ~= nil and tMemberInfo.strCharacterName ~= strPlayerName then
        table.insert(tGroupMembers, tMemberInfo.strCharacterName)
      end
    end
    return tGroupMembers
  end
end


function NavMate:OnWaypointContextMenuBtn( wndHandler, wndControl, eMouseButton )
	self:ProcessWaypointContextClick(wndHandler:GetData())
	self:OnWaypointContextMenuClosed()
end

function NavMate:OnWaypointContextMenuBtnMouseEnter( wndHandler, wndControl, x, y )
	wndHandler:GetParent():FindChild("BtnText"):SetTextColor("UI_BtnTextGrayListFlyby")
end

function NavMate:OnWaypointContextMenuBtnMouseExit( wndHandler, wndControl, x, y )
	wndHandler:GetParent():FindChild("BtnText"):SetTextColor("UI_BtnTextGrayListNormal")
end

function NavMate:OnWaypointContextMenuBtnMouseDown( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
	self:OnWaypointContextMenuBtn(wndHandler:GetParent(), wndHandler:GetParent())
end

--- Helper to create context menu buttons
-- @param wndButtonList the parent to host the button
-- @param eButtonType button type
-- @param strButtonText button text / label
function NavMate:HelperBuildWaypointContextMenuButton(wndButtonList, eButtonType, strButtonText)
	local wndCurr = CreateWaypointContextMenuButton(self, wndButtonList)
  wndCurr:SetData(eButtonType)
	wndCurr:FindChild("BtnText"):SetText(strButtonText)
	return wndCurr
end

--- Helper to enable or disable a context menu button
-- @param wndBtn button window
-- @param bEnable enable state
function NavMate:HelperEnableDisableWaypointContextMenuButton(wndBtn, bEnable)
	if bEnable and wndBtn:ContainsMouse() then
		wndBtn:FindChild("BtnText"):SetTextColor("UI_BtnTextGrayListFlyby")
	elseif bEnable then
		wndBtn:FindChild("BtnText"):SetTextColor("UI_BtnTextGrayListNormal")
	else
		wndBtn:FindChild("BtnText"):SetTextColor("UI_BtnTextGrayListDisabled")
	end
	wndBtn:Enable(bEnable)
end