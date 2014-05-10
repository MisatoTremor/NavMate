-----------------------------------------------------------------------------------------------
-- Arrow
-----------------------------------------------------------------------------------------------
require "Apollo"
require "GameLib"

local N = Apollo.GetAddon("NavMate")
local L = N.L
local GUILib = Apollo.GetPackage("Gemini:GUI-1.0").tPackage

local ktModuleName = "Arrow"

local Arrow = N:NewModule(ktModuleName)

local setmetatable, ipairs, pairs, type = setmetatable, ipairs, pairs, type

local PI2 = math.pi * 2
local etaTime, etaThrottle               = 0, 0.5
local refreshTime, refreshThrottle       = 0, 0.016
local nLastDistance, nSpeed, nSpeedCount = 0, 0, 0

-----------------------------------------------------------------------------------------------
-- Utility Functions
-----------------------------------------------------------------------------------------------
local function GetWindowPosition(wnd)
  if wnd == nil or wnd.GetPos == nil then
    return
  end
  
  local nLeft, nTop = wnd:GetPos()
  return { left = nLeft, top = nTop }  
end

local function MoveWindow(wnd, nLeft, nTop)
  if wnd == nil or nLeft == nil or nTop == nil then
    return
  end
  
	wnd:Move(nLeft, nTop, wnd:GetWidth(), wnd:GetHeight())
end





-----------------------------------------------------------------------------------------------
-- Distance and Angle Functions
-----------------------------------------------------------------------------------------------
local function CalculateAngle(nX, nZ)
	local nAngle = math.atan2(nX, -nZ)
	if nAngle > 0 then
		nAngle = PI2 - nAngle 
	else
		nAngle = -nAngle 
	end
	return nAngle
end

local function CalculateDistance3D(tPos1, tPos2)
	if not tPos1 or not tPos2 then
		return
	end
	
	local nDeltaX = tPos2.x - tPos1.x
	local nDeltaY = tPos2.y - tPos1.y
	local nDeltaZ = tPos2.z - tPos1.z
	
	local nDistance = math.sqrt(math.pow(nDeltaX, 2) + math.pow(nDeltaY, 2) + math.pow(nDeltaZ, 2)) 
	return nDistance, nDeltaX, nDeltaZ
end

local function CalculateDistance2D(tPos1, tPos2)
	if not tPos1 or not tPos2 then
		return
	end
	
	local nDeltaX = tPos2.x - tPos1.x
	local nDeltaZ = tPos2.z - tPos1.z
	
	local nDistance = math.sqrt(math.pow(nDeltaX, 2) + math.pow(nDeltaZ, 2))
	return nDistance, nDeltaX, nDeltaZ
end

local function GetVectorFromWaypoint(tWaypoint)
	if tWaypoint == nil then
		return
	end
	
	local tPosPlayer = GameLib.GetPlayerUnit():GetPosition()
	local tPosWaypoint = tWaypoint.tWorldLoc

	-- 3D distance doesn't really work when placing waypoints via a map or minimap.
	local nDistance, nDeltaX, nDeltaZ = CalculateDistance2D(tPosPlayer, tPosWaypoint)
	local nAngle = CalculateAngle(nDeltaX, nDeltaZ)

	return nDistance, nAngle 			
end

-----------------------------------------------------------------------------------------------
-- Color Functions
-----------------------------------------------------------------------------------------------
--- Get a color from within a gradient
-- @param percent through gradient (float)
-- @params ... collection of colors used in the gradient
-- @return An ApolloColor object
local function ColorGradient(perc, ...)
	local nCount = select('#', ...)
	
	local tColors = {}
	local strColorType = type(select(1, ...))

	if strColorType == "number" then -- individual rgb value
		for idx = 1, nCount, 3 do
			table.insert(tColors, { a = 1, r = select(idx, ...), g = select(idx + 1, ...), b = select(idx + 2, ...) })
		end
	else
		for idx = 1, nCount do
			local tColor = select(idx, ...)
			if strColorType == "string" then -- hexes or xkcd code
				tColor = ApolloColor.new(tColor):ToTable()
			elseif strColorType == "userdata" then -- ApolloColor or CColor object
				tColor = { a = tColor.a, r = tColor.r, g = tColor.g, b = tColor.b } -- CColor doesn't have ToTable()
			end
			table.insert(tColors, tColor)
		end
	end
	
	if perc == 1 then
		return ApolloColor.new(tColors[1])
	end

	local segment, relperc = math.modf(perc * 2)
	local c1, c2 = tColors[segment + 1], tColors[segment + 2]
	
	if not c2 then
		return ApolloColor.new(c1)
	else
		return ApolloColor.new({
			a = 1,
			r = c1.r + (c2.r - c1.r) * relperc,
			g = c1.g + (c2.g - c1.g) * relperc,
			b = c1.b + (c2.b - c1.b) * relperc,
		})
	end
end 

-----------------------------------------------------------------------------------------------
-- UI Components
-----------------------------------------------------------------------------------------------
local function CreateArrowForm(o)
  local tWndDef = {
    Name = "NavMateArrow",
    AnchorCenter = {306, 120},
    IgnoreMouse = true,
    NoClip = true,
    DoNotBlockTooltip = true,
    Sprite = "AbilitiesSprites:spr_StatVertProgBase",
    Picture = false,
    
    Children = {
      { -- Arrow
        Name = "Arrow",
        Sprite        = "NavMate_Sprites:NavMate_sprArrow",
        AnchorPoints  = "HCENTER",
        AnchorOffsets = {-36, 0, 36, 47},
        Events = {
          MouseButtonDown = "OnArrowMouseDown",
        },
      },
      
      { -- Name
        Class         = "MLWindow",
        Name          = "WaypointName",
        AnchorPoints  = {0.5, 1, 0.5, 1},
        AnchorOffsets = {-150, -70, 150, -32},
        Font          = "CRB_InterfaceSmall_O",
        IgnoreMouse   = true,
        DT_CENTER     = true,
        DT_VCENTER    = true,
        DT_WORDBREAK  = true,
      },
      
      { -- ZoneName
        Name          = "ZoneName",
        AnchorPoints  = {0, 1, 1, 1},
        AnchorOffsets = {0, -32, 0, -16},
        Font          = "CRB_InterfaceSmall_O",
        IgnoreMouse   = true,
        DT_CENTER     = true,
        DT_VCENTER    = true,
      },
      
      { -- Location
        Name          = "Location",
        AnchorPoints  = {0, 1, 1, 1},
        AnchorOffsets = {0, -32, 0, -16},
        Font          = "CRB_InterfaceSmall_O",
        IgnoreMouse   = true,
        DT_CENTER     = true,
        DT_VCENTER    = true,
        Visible = false,
      },
      
      { -- Distance
        Name          = "Distance",
        AnchorPoints  = {0, 1, 1, 1},
        AnchorOffsets = {0, -16, 0, 0},
        Font          = "CRB_InterfaceSmall_O",
        Text          = "0m",
        IgnoreMouse   = true,
        DT_CENTER     = true,
        DT_VCENTER    = true,
      },
    },
  }
  return GUILib:Create(tWndDef):GetInstance(o, "FixedHudStratum")
end



-----------------------------------------------------------------------------------------------
-- Arrow Definition
-----------------------------------------------------------------------------------------------
function Arrow:Initialize()
  self:InitConfig()
  
  self.config.enable      = true
  self.config.colors      = self.config.colors or {
    hot  = CColor.new(0.382078,1,0.375),
    warm = CColor.new(1,1,0.078431375324726),
    cold = CColor.new(0.898039,0,0.0194867),
  }
  self.config.invert      = false
  self.config.waypointArrivalDistance = 10.0
  self.config.waypointArrivalSound    = true
  self.bLocked = true
  self.bInCombat = false
  
  self.wnd = CreateArrowForm(self)
  Apollo.RegisterEventHandler("UnitEnteredCombat", "OnUnitEnteredCombat", self)
  self.bInitialized = true
end

---
-- UnitEnteredCombat event handler
-- @param unit
-- @param bInCombat
function Arrow:OnUnitEnteredCombat(unit, bInCombat)
	if unit:IsThePlayer() then
		self.bInCombat = bInCombat
	end
end

function Arrow:OnRestoreSettings()
  if self.config.position ~= nil then
    MoveWindow(self.wnd, self.config.position.left, self.config.position.top)
  end
end

function Arrow:OnSaveSettings()
  self.config.position = GetWindowPosition(self.wnd)
end

function Arrow:Update()
  if not self.config.enable then
    if self.wnd ~= nil and self.wnd:IsValid() then
      self.wnd:Show(false, true)
    end
    
    return
  end
  
	if self.waypoint and self.config.enable then
		self.wnd:FindChild("ZoneName"):SetText(self.waypoint.tZoneInfo.strName)
		self.wnd:FindChild("Location"):SetText(string.format("%.2f, %.2f", self.waypoint.tWorldLoc.x, self.waypoint.tWorldLoc.z))
		
		-- hide the arrow while in combat and not mounted
		local bShowArrow = not (self.bInCombat and not GameLib.GetPlayerUnit():IsMounted())
		self.wnd:Show(bShowArrow)
	else
		self.wnd:Show(false)
	end
  
  refreshTime = 0
end

--- Toggles the arrow lock
function Arrow:ToggleLock()
	self.bLocked = not self.bLocked
	if self.bLocked then
		self.wnd:SetStyle("Picture", false)
		self.wnd:SetStyle("Moveable", false)
	else
		self.wnd:SetStyle("Picture", true)
		self.wnd:SetStyle("Moveable", true)
	end
end

function Arrow:Disable()
  self.config.enable = false
end

function Arrow:Refresh()
	local nDistance, nAngle = GetVectorFromWaypoint(self.waypoint)
	if not nDistance or not nAngle then
		return -- we don't have a valid waypoint, let's get out of here!
	end	
	
	if nDistance <= self.config.waypointArrivalDistance then -- the carrier has arrived!
		Event_FireGenericEvent("NavMate_ArrivedAtWaypoint", self.waypoint)
	elseif self.config.enable then
		-- calculate arrow visuals
		local unitPlayer = GameLib.GetPlayerUnit()
    local nFacing, nFaceAngle
    local tFacing = unitPlayer:GetFacing()
    if type(tFacing) == "table" and tFacing.x and tFacing.z then
      nFacing = CalculateAngle(tFacing.x, tFacing.z)
      nFaceAngle = self.config.invert and (nAngle - nFacing) or (nFacing - nAngle)
    else
      nFacing = unitPlayer:GetHeading()
      nFaceAngle = self.config.invert and (nAngle - nFacing) or (nFacing - nAngle)
      if nFaceAngle < 0 then nFaceAngle = PI2 + nFaceAngle end
    end
    
		local nPct = math.abs((math.pi - math.abs(nFaceAngle)) / math.pi)
    -- Debug Output
    -- self.wnd:FindChild("WaypointName"):SetText("nFacing = " .. nFacing .. ", nAngle = " .. nAngle)
    -- self.wnd:FindChild("Distance"):SetText("nFaceAngle = " .. nFaceAngle .. ", nPct = " .. nPct)
    -- End Debug Output
    
		self:CalculateETA(nDistance)
	
		self.wnd:FindChild("Arrow"):SetBGColor(ColorGradient(nPct, self.config.colors.cold, self.config.colors.warm, self.config.colors.hot))
    local nRotation = nFaceAngle * (180 / math.pi)
		self.wnd:FindChild("Arrow"):SetRotation(nRotation)
		if self.waypointETA then
			self.wnd:FindChild("Distance"):SetText(string.format("%.2fm (%s)", nDistance, self.waypointETA))
		else
			self.wnd:FindChild("Distance"):SetText(string.format("%.2fm", nDistance))
		end
		self.wnd:FindChild("WaypointName"):SetAML("<P Align=\"Center\" Font=\"CRB_InterfaceSmall_O\">" .. self.waypoint.strName .. "</P>")
	end
  refreshTime = 0
end

function Arrow:Tick(elapsedTime)
		etaTime = etaTime + elapsedTime
		refreshTime = refreshTime + elapsedTime
		if refreshTime >= refreshThrottle then 
      self:Refresh()
			refreshTime = 0
		end  
end

--- Calculate the ETA
function Arrow:CalculateETA(nDistance)
	-- calculate ETA - throttled at approx. 1 update per second
	if etaTime >= etaThrottle then
		local nCurrentSpeed = (nLastDistance - nDistance) / etaTime
		etaTime = 0
		
		if nLastDistance == 0 then
			nCurrentSpeed = 0
		end
		
		if nSpeedCount < 2 then
			nSpeed = (nSpeed + nCurrentSpeed) / 2
			nSpeedCount = nSpeedCount + 1
		else
			nSpeedCount = 0
			nSpeed = nCurrentSpeed
		end
		
		if nSpeed > 0 then
			local eta = math.abs(nDistance / nSpeed)
			self.waypointETA = string.format("%s:%02d", math.floor(eta / 60), math.floor(eta % 60))
		else
			self.waypointETA = nil
		end
		
		nLastDistance = nDistance
	end
end


local kstrArrowSprite = "NavMate_sprArrow"
--- Set the current waypoint for the arrow
function Arrow:SetWaypoint(tWaypoint)
  self.waypoint = tWaypoint
  
  -- TODO: Figure out when to SetSprite so it's only done once
  if not Apollo.IsSpriteLoaded(kstrArrowSprite) then
    Apollo.LoadSprites("NavMate_Sprites.xml")
  end
  self.wnd:FindChild("Arrow"):SetSprite(kstrArrowSprite)
end

--- Handles right clicks on the arrow
function Arrow:OnArrowMouseDown( wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation )
	if wndHandler ~= wndControl 
    or self.waypoint == nil 
    or eMouseButton ~= 1 then
    
		return
	end
  
  N:OnShowWaypointContextMenu(wndControl:GetParent())
end