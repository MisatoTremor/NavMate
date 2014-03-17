-----------------------------------------------------------------------------------------------
-- Taxi
-----------------------------------------------------------------------------------------------
require "Apollo"
require "GameLib"


local N = Apollo.GetAddon("NavMate")
local L = N.L

local ktModuleName = "Taxi"
local Taxi = N:NewModule(ktModuleName)
local ktVoiceVolumeConsoleVar = "sound.volumeVoice"

-----------------------------------------------------------------------------------------------
-- Taxi Definition
-----------------------------------------------------------------------------------------------
function Taxi:Initialize()
  self:InitConfig()
  
  self.bOnTaxi = false
  self.config.mute = false
  Apollo.RegisterEventHandler("TaxiWindowClose", "OnTaxiWindowClose", self)
  Apollo.RegisterTimerHandler("NavMate_TaxiCheckTimer", "OnTaxiCheckTimer", self)
  
  self.bInitialized = true
end

local nCheckCount = 1
local nMaxChecks = 6
-- taxi unit creation might be delayed slightly, so check every 0.5 for 3 seconds
function Taxi:OnTaxiWindowClose()
  nCheckCount = 1
  Apollo.CreateTimer("NavMate_TaxiCheckTimer", 0.5, false)
end

function Taxi:OnTaxiCheckTimer()
  if self.bOnTaxi or nCheckCount > nMaxChecks then return end
  self:CheckTaxiState()
  nCheckCount = nCheckCount + 1
  Apollo.CreateTimer("NavMate_TaxiCheckTimer", 0.5, false)  
end

function Taxi:CheckTaxiState()
  if self.config.mute == false and self.config.restoreVolume ~= nil then
    self:RestoreVolume()
  end
  if self.config.mute ~= true then return end
  self.bOnTaxi = GameLib.GetPlayerTaxiUnit() ~= nil
  if self.bOnTaxi then
    -- jumped on a taxi. Mute the driver!
    self:MuteVolume()
  else
    -- restore volume if we have restoreVolume set
    self:RestoreVolume()
  end
end

function Taxi:MuteVolume()
  if self.config.restoreVolume == nil or self.config.restoreVolume == 0 then
    self.config.restoreVolume = Apollo.GetConsoleVariable(ktVoiceVolumeConsoleVar)
  end
  Apollo.SetConsoleVariable(ktVoiceVolumeConsoleVar, 0)
  N:WriteToChat(L["TaxiQuietModeEnabled"])
end

function Taxi:RestoreVolume()
  if self.config.restoreVolume ~= nil then
    N:WriteToChat(L["TaxiQuietModeDisabled"])
    Apollo.SetConsoleVariable(ktVoiceVolumeConsoleVar, self.config.restoreVolume)
    self.config.restoreVolume = nil
  end
end


function Taxi:OnRestoreSettings()
  self:CheckTaxiState()
end

function Taxi:Update()
  if self.config.mute ~= true or not self.bOnTaxi then return end
  
  -- check if the carrier has arrived
  self.bOnTaxi = GameLib.GetPlayerTaxiUnit() ~= nil
  if not self.bOnTaxi then
    self:RestoreVolume()
  end
end