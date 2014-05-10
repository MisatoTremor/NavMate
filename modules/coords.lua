-----------------------------------------------------------------------------------------------
-- Coordinates Block
-----------------------------------------------------------------------------------------------
require "Apollo"
require "GameLib"

local N = Apollo.GetAddon("NavMate")
local L = N.L
local GUILib = Apollo.GetPackage("Gemini:GUI-1.0").tPackage

local ktModuleName = "Coords"

local Coords = N:NewModule(ktModuleName)

-----------------------------------------------------------------------------------------------
-- UI Form Definition
-----------------------------------------------------------------------------------------------
local function CreateWindow(o, bDockToMiniMap)
  local tWndDef = {
    Name = "CoordsForm",
		AnchorPoints = { 0.5, 1, 1, 1 },
		AnchorOffsets = { 480, -24, -120, -4 },
    Font = "CRB_Header9",
		TextColor = "UI_TextHoloBodyCyan",
    IgnoreMouse = true,
    DT_CENTER = true,
    DT_VCENTER = true,
  }
  
  local wndParent = "FixedHudStratumHigh"
  return GUILib:Create(tWndDef):GetInstance(o, wndParent)
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





--- Reset the coords position to defaults
-- @param bForce Force position reset
function Coords:ResetPosition(bForce)
  if not self.config.enable then
    return
  end
  
	if self.wnd == nil then return end
	
	local nWidth, nHeight = Apollo.GetScreenSize()
	self.wnd:SetAnchorPoints(0.5,1,1,1)
	self.wnd:SetAnchorOffsets(480, -24, -120, -4)
end