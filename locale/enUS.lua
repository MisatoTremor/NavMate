--Localization.enUS.lua
local debug = false

local L = Apollo.GetPackage("GeminiLocale-1.0").tPackage:NewLocale("NavMate", "enUS", true, not debug)

if not L then
	return
end

L["NavMate"] = true
L["NavMate Options"] = true
L["Clock"] = true
L["Coordinates"] = true
L["Mailboxes"] = true
L["Banks"] = true
L["Datacubes"] = true
L["Path"] = true
L["Display Time"] = true
L["Local"] = true
L["Server"] = true
L["Reset Position"] = true
L["Show Taxi Nodes"] = true
L["Mute Taxi Driver"] = true
L["Dock to MiniMap"] = true
L["Show Taxi Nodes on ZoneMap"] = true
L["Arrival Distance"] = true
L["Show Nodes"] = true
L["Icon"] = true
L["Icon Color"] = true
L["Use Per Node"] = true
L["Node Customization"] = true
L["MiniMap Appearance"] = true
L["Options_SquareMiniMap"] = "Square MiniMap (BETA)"
L["Options_SquareMiniMap_Tooltip"] = "This feature is EXPERIMENTAL! The compass circle cannot be altered or hidden currently."
L["MiniMap Markers"] = true
L["ZoneMap"] = true
L["Normal Color"] = true
L["PvP Combat"] = true
L["Taxi"] = true
L["Waypoint Arrival"] = true
L["Arrow"] = true
L["Group Members"] = true
L["NavMate Slash Commands"] = true
L["SlashCommand_Options"] = "Toggles the NavMate options window"
L["SlashCommand_ClockToggle"] = "Toggles the clock display on or off"
L["SlashCommand_ResetClockPosition"] = "Resets the clock position"
L["SlashCommand_CoordsToggle"] = "Toggles the coords display on or off"
L["SlashCommand_ResetCoordsPosition"] = "Resets the coords position"
L["SlashCommand_ToggleArrowLock"] = "Toggles the arrow lock on or off"
L["Reset to Defaults"] = true

-- enUS localization table
L["ContextMenu_SetWaypointAsArrow"] 	= "Set Waypoint as Arrow"
L["ContextMenu_SendWaypointTo"] 		  = "Send Waypoint To"
L["ContextMenu_RemoveWaypoint"] 		  = "Remove Waypoint"
L["ContextMenu_RemoveZoneWaypoints"] 	= "Remove All Waypoints From This Zone"
L["ContextMenu_RemoveAllWaypoints"] 	= "Remove All Waypoints"
L["ContextMenu_SaveSessionWaypoint"] 	= "Save This Waypoint Between Sessions"
L["ContextMenu_LockArrow"]				    = "Lock Arrow"
L["ContextMenu_UnlockArrow"]			    = "Unlock Arrow"
L["ContextMenu_SendWaypointToParty"]  = "Send Waypoint To Party"
L["ContextMenu_SendWaypointToGuild"]  = "Send Waypoint To Guild"

L["Server Time"]						          = true
L["Local Time"]							          = true
L["Unknown Waypoint"]					        = true
L["Remove All Waypoints"]				      = true
L["Mission"]							            = true
L["Public Event"]						          = true
L["Challenge"]							          = true
L["HexGroup"]							            = true
L["Nemesis"]							            = true

L["Group"] 								            = true
L["Raid"] 								            = true
L["WarParty"] 							          = true
L["Guild"]								            = true
L["Instance"] 							          = true

L["WaypointContextMenuTitle"]         = "Waypoint Menu"
-- Options Window
L["Options_WaypointSettings"]         = "Waypoint Settings"
L["Options_ArrivalDistance"]          = "Arrival Distance"
L["Options_PlayArrivalSound"]         = "Play sound when you arrive at a waypoint"
L["Options_24HourClock"]              = "24 Hour Clock"
L["Options_LocalTime"]                = "Local Time"
L["Options_ServerTime"]               = "Server Time"
L["Enable"]                           = "Enable"
L["Options_InvertArrow"]              = "Use Old Rotation"
L["Options_ArrowHot"]                 = "Hot"
L["Options_ArrowWarm"]                = "Warm"
L["Options_ArrowCold"]                = "Cold"
L["Options_ArrowSettings"]            = "Arrow Settings"
L["Options_ClockSettings"]            = "Clock Settings"
L["Options_MapSettings"]              = "MiniMap & Zone Map Settings"
L["Options_DotNodeSprite"]            = "Use dot for resource nodes"
L["Options_ResourceNodeSettings"]     = "Resource Node Settings"
L["Mining Nodes"]                     = "Mining"
L["Farming Nodes"]                    = "Farming"
L["Relic Nodes"]                      = "Relic"
L["Survival Nodes"]                   = "Survival"
L["Fishing Nodes"]                    = "Fishing"

L["Options_GroupNodeSettings"]        = "Group Member Icon Settings"
L["Options_GroupDotNodeSprite"]       = "Use dot for group members"
L["Options_GroupNormalColor"]         = "Normal Color"
L["Options_GroupPvPColor"]            = "In PvP Color"

L["MiniMapMarker_Mailbox"]            = "Mailboxes"
L["MiniMapMarker_Bank"]               = "Banks"
L["MiniMapMarker_Datacube"]           = "Datacubes, Journals and Other Lore Collectables"
L["MiniMapMarker_Path"]               = "Path specific collectables and activations"
L["MiniMapMarker_SettlerMinfrastructure"]   = "Settler Minfrastructures"

L["TaxiQuietModeEnabled"] = "Taxi driver quiet mode engaged!"
L["TaxiQuietModeDisabled"] = "Taxi driver endless chatter mode restored!"