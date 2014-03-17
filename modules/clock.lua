-----------------------------------------------------------------------------------------------
-- Clock
-----------------------------------------------------------------------------------------------
require "Apollo"
require "GameLib"


local N = Apollo.GetAddon("NavMate")
local L = N.L
local DaiGUI = Apollo.GetPackage("DaiGUI-1.0").tPackage

local ktModuleName = "Clock"
local Clock = N:NewModule(ktModuleName)

-----------------------------------------------------------------------------------------------
-- UI Form Definition
-----------------------------------------------------------------------------------------------
local function CreateWindow(o, bDockToMiniMap)
  local tWndDef = {
    Name = "ClockForm",
    AnchorOffsets = {10,10,90,30},
    Font = "CRB_InterfaceMedium_BO",
    IgnoreMouse = true,
    DT_CENTER = true,
    DT_VCENTER = true,
  }
  
  local wndParent
  if bDockToMiniMap and g_wndTheMiniMap then 
    wndParent = g_wndTheMiniMap:GetParent()
    tWndDef.NoClip = true
  else
    wndParent = "FixedHudStratum"
  end
  
  return DaiGUI:Create(tWndDef):GetInstance(o, wndParent)
end

-----------------------------------------------------------------------------------------------
-- Utility Functions
-----------------------------------------------------------------------------------------------
local function MoveWindow(wnd, nLeft, nTop)
  if wnd == nil or nLeft == nil or nTop == nil then
    return
  end
  
	wnd:Move(nLeft, nTop, wnd:GetWidth(), wnd:GetHeight())
end

-----------------------------------------------------------------------------------------------
-- Clock Definition
-----------------------------------------------------------------------------------------------
function Clock:Initialize()
  self:InitConfig()
  
  self.config.enable      = true
  self.config.isMilitary  = false
  self.config.isLocal     = true
  self.config.isDocked    = true
  
  self:SetupWindow()
  
  self.bInitialized = true
end

function Clock:SetupWindow()
  if self.wnd ~= nil and self.wnd:IsValid() then
    self.wnd:Destroy()
  end
  self.wnd = CreateWindow(self, self.config.isDocked)
  self:ResetPosition()
end

function Clock:OnRestoreSettings()
  if self.config.position ~= nil then
    self:SetupWindow()
    MoveWindow(self.wnd, self.config.position.left, self.config.position.top)
  end
end

function Clock:OnSaveSettings()
  if self.wnd ~= nil and self.wnd.GetPos ~= nil then
    local nLeft, nTop = self.wnd:GetPos()
    self.config.position = { left = nLeft, top = nTop }  
  end
end


function Clock:Update()
  if not self.config.enable then
    if self.wnd ~= nil and self.wnd:IsValid() then
      self.wnd:Show(false, true)
    end
    
    return
  end
  
	-- calculate time
	local time = self.config.isLocal and GameLib.GetLocalTime() or GameLib.GetServerTime()
	local ttTime = self.config.isLocal and GameLib.GetServerTime() or GameLib.GetLocalTime()
	local strTooltipPrefix = self.config.isLocal and L["Server Time"] or L["Local Time"]
	
	if time ~= nil then
		if not self.config.isMilitary then
			self.wnd:SetText(self:TimeToString(time))
			self.wnd:SetTooltip(string.format("%s: %s", strTooltipPrefix, self:TimeToString(ttTime)))
		else
			self.wnd:SetText(string.format("%02d:%02d", time.nHour, time.nMinute))
			self.wnd:SetTooltip(string.format("%s: %02d:%02d", strTooltipPrefix, ttTime.nHour, ttTime.nMinute))
		end
		self.wnd:Show(true)	
	else
		self.wnd:Show(false)
	end
end

--- Translate 24H to 12H time
-- @param tTime table from GameLib.GetLocalTime() or GameLib.GetServerTime()
-- @param strFormat optional format string
-- @return formatted string
function Clock:TimeToString(tTime, strFormat)
  strFormat = strFormat or "%d:%02d %s"
  local hour = tTime.nHour
  local meridiem = hour >= 12 and "PM" or "AM"
  if hour > 12 then hour = hour - 12 end
  if hour == 0 then hour = 12 end
  return string.format(strFormat, hour, tTime.nMinute, meridiem)
end

--- Reset the clock position to defaults
-- @param bForce Force position reset
function Clock:ResetPosition(bForce)
  if not self.config.enable then
    return
  end
  
  if self.config.isDocked then
    local wndParent = self.wnd:GetParent()
    local nTop = 5 + wndParent:GetHeight() - self.wnd:GetHeight()
    local nLeft = (wndParent:GetWidth() - self.wnd:GetWidth()) / 2
    MoveWindow(self.wnd, nLeft, nTop)
  else
    local nWidth, nHeight = Apollo.GetScreenSize()
    MoveWindow(self.wnd, (nWidth - self.wnd:GetWidth()) / 2, (nHeight - (self.wnd:GetHeight() * 2)) / 2)
  end
end