-----------------------------------------------------------------------------------------------
-- Coordinates Block
-----------------------------------------------------------------------------------------------
require "Apollo"
require "GameLib"

local N = Apollo.GetAddon("NavMate")
local L = N.L
local DaiGUI = Apollo.GetPackage("DaiGUI-1.0").tPackage

local ktModuleName = "Coords"

local Coords = N:NewModule(ktModuleName)

-----------------------------------------------------------------------------------------------
-- UI Form Definition
-----------------------------------------------------------------------------------------------
local function CreateWindow(o, bDockToMiniMap)
  local tWndDef = {
    Name = "CoordsForm",
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

local function GetMiniMapPosition()
  local wndMMParent     = g_wndTheMiniMap:GetParent()
  local nLeft, nTop     = wndMMParent:GetPos()
  local nWidth, nHeight = wndMMParent:GetWidth(), wndMMParent:GetHeight()
  return nLeft, nTop, nWidth, nHeight
end


-----------------------------------------------------------------------------------------------
-- Coordinates Block Definition
-----------------------------------------------------------------------------------------------
function Coords:Initialize()
  self:InitConfig()
  self.config.enable = true
  self.config.isDocked = true
  self:SetupWindow()
  self.bInitialized = true
end

function Coords:SetupWindow()
  if self.wnd ~= nil and self.wnd:IsValid() then
    self.wnd:Destroy()
  end
  self.wnd = CreateWindow(self, self.config.isDocked)
  self:ResetPosition()
end

function Coords:OnRestoreSettings()
  if self.config.position ~= nil then
    self:SetupWindow()
    MoveWindow(self.wnd, self.config.position.left, self.config.position.top)
  end
end

function Coords:OnSaveSettings()
  if self.wnd ~= nil and self.wnd.GetPos ~= nil then
    local nLeft, nTop = self.wnd:GetPos()
    self.config.position = { left = nLeft, top = nTop }  
  end
end

function Coords:Update()
  if not self.config.enable then
    if self.wnd ~= nil and self.wnd:IsValid() then
      self.wnd:Show(false, true)
    end
    
    return
  end
  
  
  local tPlayerPos = GameLib.GetPlayerUnit():GetPosition()
  self.wnd:SetText(string.format("%d, %d", tPlayerPos.x, tPlayerPos.z))
  self.wnd:Show(true)
end





--- Reset the clock position to defaults
-- @param bForce Force position reset
function Coords:ResetPosition(bForce)
  if not self.config.enable then
    return
  end
  
  if self.config.isDocked then
    local wndParent = self.wnd:GetParent()
    local nTop = wndParent:GetHeight()
    local nLeft = (wndParent:GetWidth() - self.wnd:GetWidth()) / 2
    MoveWindow(self.wnd, nLeft, nTop)
  else
    local nWidth, nHeight = Apollo.GetScreenSize()
    MoveWindow(self.wnd, (nWidth - self.wnd:GetWidth()) / 2, (nHeight - self.wnd:GetHeight()) / 2)
  end
end