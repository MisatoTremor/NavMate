-----------------------------------------------------------------------------------------------
-- NavMate Waypoint Sharing Protocol
-----------------------------------------------------------------------------------------------
-- Notes on ICCommLib:
-- * The recipient name of SendPrivateMessage is case-sensitive. So sending a private comm 
--   message to 'sean' will NOT be received by 'Sean'.
-- * Sending incorrect parameters to SendMessage can cause the client to crash.
-- * JoinChannel requires the addon table provided to Apollo.RegisterAddon to work

-- @TODO convert string literals to localized strings

require "Apollo"
require "GameLib"
require "GroupLib"
require "ICCommLib"

local setmetatable, pairs, ipairs, type = setmetatable, pairs, ipairs, type
local tostring, tonumber = tostring, tonumber

local N = Apollo.GetAddon("NavMate")
local L = N.L

local ktModuleName = "WaypointComm"
local WaypointComm = N:NewModule(ktModuleName)

local Waypoint = N.Waypoint
local waypoints = N.waypoints

function WaypointComm:Initialize()
  self.addon = N
  self.ProtocolVersion = 1
  Apollo.RegisterTimerHandler("NavMate_WaypointComm_Init", "Start", self)
  self.bInitialized = true
  self:Start()
end

function WaypointComm:Start()
  if not GameLib.IsCharacterLoaded() then
    Apollo.CreateTimer("NavMate_WaypointComm_Init", 1, false)
    return
  end
  
  -- workaround for handling the JoinChannel requirements
  local wpComm = self
  self.addon.OnICCommMessage = function(self, channel, tMsg, strSender)
    wpComm:OnMessage(channel, tMsg, strSender)
  end
  
  self.channel = ICCommLib.JoinChannel("NavMateWaypointComm", "OnICCommMessage", self.addon)
end

function WaypointComm:OnMessage(channel, tMsg, strSender)
  if tonumber(tMsg.nProtocolVersion or 0) > self.ProtocolVersion then
    N:WriteToChat("NavMate Waypoint Communication: Received message for unknown version " .. tMsg.nProtocolVersion)
    return
  end
  
  if tMsg ~= nil and type(tMsg) == "table" then
    -- TEMP: verify that player is in a group with the sender
    -- This will need to be changed when waypoint sending is expanded beyond Send to Group
    if self:IsInYourGroup(strSender) then
      local tWaypoint = Waypoint.FromTable(tMsg)
      waypoints:Add(tWaypoint)
      N:WriteToChat("NavMate: Received waypoint from group member: " .. tostring(strSender or "[UNKNOWN]"))
    end
  end
end

function WaypointComm:IsInYourGroup(strSender)
  if GroupLib.InGroup() then 
    local tMembers = self.addon:BuildGroupMemberList()
    for _, strName in ipairs(tMembers) do
      if strName == strSender then
        return true
      end
    end
  end
end

function WaypointComm:SendWaypoint(tWaypoint, strRecipient)
  local tMsg = tWaypoint:ToTable()
  tMsg.nProtocolVersion = self.ProtocolVersion
  if strRecipient ~= nil then
    if type(strRecipient) == "string" then
      strRecipient = { strRecipient }
    end
    if type(strRecipient) ~= "table" then
      Print("[NavMate DEBUG]: Attempting to send waypoint to: " .. tostring(strRecipient))
      return
    end
    
    -- TODO: Is there a way to validate the recipient's character name casing?
    self.channel:SendPrivateMessage(strRecipient, tMsg)
--  else
--    self.channel:SendMessage(tMsg)
  end
end