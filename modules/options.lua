local N = Apollo.GetAddon("NavMate")
local L = N.L
local GUILib  = Apollo.GetPackage("Gemini:GUI-1.0").tPackage
local GLocale = Apollo.GetPackage("Gemini:Locale-1.0").tPackage


local ktNodeIcons = {
  "MiniMapObject",
	"IconSprites:Icon_MapNode_Map_GroupMember",
	"IconSprites:Icon_MapNode_Map_Node_Mining",
	"IconSprites:Icon_MapNode_Map_Node_Relic",
	"IconSprites:Icon_MapNode_Map_Node_Tree",
	"IconSprites:Icon_MapNode_Map_Node_Plant",
	"IconSprites:Icon_MapNode_Map_Node_Fishing",
	
  "CRB_MinimapSprites:sprMM_Group",
  "CRB_MinimapSprites:sprMM_SmallIconSettler",
  "ClientSprites:MiniMapMarkerTiny",
  "IconSprites:Icon_MapNode_Map_AuctionHouse",
  "IconSprites:Icon_MapNode_Map_Bank",
  "IconSprites:Icon_MapNode_Map_Chat",
  "IconSprites:Icon_MapNode_Map_CityDirections",
  "IconSprites:Icon_MapNode_Map_CommoditiesExchange",
  "IconSprites:Icon_MapNode_Map_DyeSpecialist",
  "IconSprites:Icon_MapNode_Map_Explorer",
  "IconSprites:Icon_MapNode_Map_Explorer_Accepted",
  "IconSprites:Icon_MapNode_Map_Friend",
  "IconSprites:Icon_MapNode_Map_Gate",
  "IconSprites:Icon_MapNode_Map_GroupMember",
  "IconSprites:Icon_MapNode_Map_Mailbox",
  "IconSprites:Icon_MapNode_Map_Portal",
  "IconSprites:Icon_MapNode_Map_Quest",
  "IconSprites:Icon_MapNode_Map_Quest_Disabled",
  "IconSprites:Icon_MapNode_Map_Rival",
  "IconSprites:Icon_MapNode_Map_Scientist",
  "IconSprites:Icon_MapNode_Map_Scientist_Accepted",
  "IconSprites:Icon_MapNode_Map_Settler",
  "IconSprites:Icon_MapNode_Map_Settler_Accepted",
  "IconSprites:Icon_MapNode_Map_Soldier",
  "IconSprites:Icon_MapNode_Map_Soldier_Accepted",
  "IconSprites:Icon_MapNode_Map_Taxi",
  "IconSprites:Icon_MapNode_Map_Taxi_Undiscovered",
  "IconSprites:Icon_MapNode_Map_Tradeskill",
  "IconSprites:Icon_MapNode_Map_Trainer",
  "IconSprites:Icon_MapNode_Map_Vendor",
  "IconSprites:Icon_MapNode_Map_Vendor_Armor",
  "IconSprites:Icon_MapNode_Map_Vendor_Consumable",
  "IconSprites:Icon_MapNode_Map_Vendor_ElderGem",
  "IconSprites:Icon_MapNode_Map_Vendor_Flight",
  "IconSprites:Icon_MapNode_Map_Vendor_Housing",
  "IconSprites:Icon_MapNode_Map_Vendor_Mount",
  "IconSprites:Icon_MapNode_Map_Vendor_Prestige_Arena",
  "IconSprites:Icon_MapNode_Map_Vendor_Prestige_Battlegrounds",
  "IconSprites:Icon_MapNode_Map_Vendor_Prestige_Warplot",
  "IconSprites:Icon_MapNode_Map_Vendor_Renown",
  "IconSprites:Icon_MapNode_Map_Vendor_Reputation",
  "IconSprites:Icon_MapNode_Map_Vendor_ResourceConversion",
  "IconSprites:Icon_MapNode_Map_Vendor_Tradeskill",
  "IconSprites:Icon_MapNode_Map_Vendor_Weapon",
  "sprMM_QuestCompleteOngoing",
  "sprMM_QuestCompleteUntracked",
	
  "NavMate_sprMM_Group",
  "NavMate_sprMM_Settler",
  "NavMate_sprMM_Scientist",
  "NavMate_sprMM_Explorer",
  "NavMate_sprMM_Soldier",
  "NavMate_sprMM_Chat",
  "NavMate_sprMM_EldanStone",
  "NavMate_sprMM_Farm",
  "NavMate_sprMM_Relic",
  "NavMate_sprMM_Mine",
  "NavMate_sprMM_Wood",
  "sprMM_EldanStone",
  "sprMM_AuctionHouse",
  "sprMM_Bank",
  "sprMM_Battleground",
  "sprMM_BattlegroundActive",
  "sprMM_ChallengeArrow",
  "sprMM_Chat",
  "sprMM_Dungeon",
  "sprMM_EldanGateActive",
  "sprMM_EldanGateInactive",
  "sprMM_Group",
  "sprMM_InstancePortal",
  "sprMM_Mailbox",
  "sprMM_PathArrow",
  "sprMM_POI",
  "sprMM_Ring",
  "sprMM_SmallIconExplorer",
  "sprMM_SmallIconScientist",
  "sprMM_SmallIconSettler",
  "sprMM_SmallIconSoldier",
  "sprMM_TargetCreature",
  "sprMM_TargetObjective",
  "sprMM_Tradeskill",
  "sprMM_Transit",
  "sprMM_VendorArmor",
  "sprMM_VendorFlight",
  "sprMM_VendorGeneral",
  "sprMM_VendorHouse",
  "sprMM_VendorMount",
  "sprMM_VendorWeapon",
  "sprMM_ZoneBenefit",
  "sprMM_ZoneHazard",
  "sprMap_IconCompletion_Datacube",
}


local ktNodeTiers = {
  -- mining
  IronNode			          = 1,
  TitaniumNode	          = 2, 
  ZephyriteNode	          = 2, 
  PlatinumNode	          = 3, 
  HydrogemNode	          = 3, 
  XenociteNode	          = 4, 
  ShadeslateNode          = 4, 
  GalactiumNode	          = 5, 
  NovaciteNode	          = 5, 
  -- relic hunter   
  StandardRelicNode	      = 1,
  AcceleratedRelicNode    = 2,
  AdvancedRelicNode		    = 3,
  DynamicRelicNode		    = 4,
  KineticRelicNode		    = 5,
  -- survival
  AlgorocTreeNode			    = 1,
  CelestionTreeNode		    = 1,
  DeraduneTreeNode		    = 1,
  EllevarTreeNode			    = 1,
  GalerasTreeNode			    = 2,
  AuroriaTreeNode			    = 2,
  WhitevaleTreeNode		    = 3,
  DreadmoorTreeNode		    = 3,
  FarsideTreeNode			    = 3,
  CoralusTreeNode			    = 3,
  MurkmireTreeNode		    = 4,
  WilderrunTreeNode		    = 4,
  MalgraveTreeNode		    = 4,
  HalonRingTreeNode		    = 4,
  GrimvaultTreeNode		    = 5,
  -- farming
  SpirovineNode			      = 1,
  BladeleafNode			      = 1,
  YellowbellNode			    = 1,
  PummelgranateNode		    = 1,
  SerpentlilyNode			    = 1,
  GoldleafNode			      = 1,
  HoneywheatNode			    = 1,
  CrowncornNode			      = 1,
  CoralscaleNode			    = 1,
  LogicleafNode			      = 1,
  StoutrootNode			      = 1,
  GlowmelonNode			      = 1,
  FaerybloomNode			    = 1,
  WitherwoodNode			    = 1,
  FlamefrondNode			    = 1,
  GrimgourdNode			      = 1,
  MourningstarNode		    = 1,
  BloodbriarNode			    = 1,
  OctopodNode				      = 1,
  HeartichokeNode			    = 1,
  SmlGrowthshroomNode		  = 1,
  MedGrowthshroomNode		  = 1,
  LrgGrowthshroomNode		  = 1,
  SmlHarvestshroomNode	  = 1,
  MedHarvestshroomNode	  = 1,
  LrgHarvestshroomNode	  = 1,
  SmlRenewshroomNode		  = 1,
  MedRenewshroomNode		  = 1,
  LrgRenewshroomNode		  = 1,
}



local function UpdateGroupNodes()
  for strModuleName, oModule in N:IterateModules() do
    if type(oModule.DrawGroupMembers) == "function" then
      oModule:DrawGroupMembers()
    end
  end
end
local FillerCell = { AnchorPoints  = {0,0,0,0}, AnchorOffsets = {0,0,0,30}, IgnoreMouse = true, }
local function ArrangeOptions(_, wndHandler, wndControl)
  if wndHandler ~= wndControl then return end
  local nHeight = wndControl:ArrangeChildrenTiles()
  local nLeft, nTop, nRight, nBottom = wndControl:GetParent():GetAnchorOffsets()
  wndControl:GetParent():SetAnchorOffsets(nLeft, nTop, nRight, nTop + nHeight + 75)
end

local function ArrangeOptionsFrames(_, wndHandler, wndControl)
  if wndHandler ~= wndControl then return end
  local nSidePadding = 10
  local nMidPadding = 20
  local nMaxWidth = wndControl:GetWidth()
  
  local nTop, nLeft = nSidePadding, nSidePadding
  local nHeight, nRowHeight = 0, 0
  local tControls = wndControl:GetChildren()
  
  -- Required to sort the children as GetChildren() sorts them by ID.
  -- IDs are not guaranteed to be in the same order as the Children 
  -- table when GUILib:Create():GetInstance is called.
  table.sort(tControls, function(a,b) 
      if a:GetName() == b:GetName() then
        return a:GetId() < b:GetId()
      else
        return a:GetName() < b:GetName()
      end
  end)
  
  for i = 1, #tControls do
    local v = tControls[i]
    local nCtrlWidth = v:GetWidth()
    local nCtrlHeight = v:GetHeight()
    
    if nLeft + nCtrlWidth <= nMaxWidth then
      nRowHeight = (nRowHeight < nCtrlHeight) and nCtrlHeight or nRowHeight
      v:Move(nLeft, nTop, nCtrlWidth, nCtrlHeight)
    else
      nLeft = nSidePadding
      nTop = nTop + nMidPadding + nRowHeight
      nRowHeight = nCtrlHeight
      v:Move(nLeft, nTop, nCtrlWidth, nCtrlHeight)
    end
    nLeft = nLeft + nCtrlWidth + nMidPadding
    
    nHeight = nTop + nRowHeight
--    Print(v:GetName() .. " - w = " .. nCtrlWidth .. ", h = " .. nCtrlHeight .. ", l = " .. nLeft ..", t = " .. nTop .. ", id = " .. v:GetId())
  end
  if nHeight > wndControl:GetHeight() then
    local nLeft, nTop, nRight, nBottom = wndControl:GetAnchorOffsets()
    wndControl:Move(0, 0, wndControl:GetWidth(), nHeight)
  end
end

local wndIconPicker, wndPerNode
  
local function CreateIconPicker(wndAnchor, tIcons, nIconSize, strPrevSelected, fnCallback)
  if wndIconPicker ~= nil and wndIconPicker:IsValid() then
    wndIconPicker:Destroy()
  end
    
  local IconClicked = function(_, wndHandler, wndControl, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation)
    if wndHandler ~= wndControl then return end
    fnCallback(wndControl:GetSprite())
    wndControl:GetParent():GetParent():Close()
    return true
  end
  
  local tWndDef = {
    Name                 = "IconPicker",
    AnchorCenter         = {300, 150},
    Template             = "CRB_TooltipSimple",
    Escapable            = true,
    CloseOnExternalClick = true,
    NoClip               = true,
    Overlapped           = true,
    UseTemplateBG        = true,
    Border               = true,
    Picture              = true,
    NewWindowDepth       = true,
    SwallowMouseClicks   = true,
    Children = {
      {
        Name           = "IconContainer",
        AnchorFill = true,
        AnchorPoints   = {0,0,1,1}, AnchorOffsets  = {3,3,-3,-3},
        Template       = "CRB_NormalFramedThin",
        UseTemplateBG  = true,
        Border         = true,
        Children       = {},
        VScroll        = true,
        IgnoreMouse    = true,
        DT_CENTER      = true,
        DT_VCENTER     = true,
        DT_WORDBREAK   = true,
        SwallowMouseClicks   = true,
        Events = { 
          WindowLoad = function(_, wndHandler, wndControl)
            if wndHandler ~= wndControl then return end
            wndControl:ArrangeChildrenTiles(0)
          end,
        },
      },
    },
  }
  
  local tIconDef = tWndDef.Children[1].Children
  for i = 1, #tIcons do
    local nIdx = #tIconDef + 1
    tIconDef[nIdx] = {
      Name          = "Icon." .. i,
      Sprite        = tIcons[i],
      AnchorOffsets = {0,0,nIconSize+2,nIconSize+2},
      IgnoreMouse   = false,
      Overlapped    = true,
      SwallowMouseClicks = true,
      Events = {
        MouseButtonDown = IconClicked,
      },
    }
    if tIcons[i] == strPrevSelected then
      tIconDef[nIdx].Pixies = {
        { Line = true, AnchorPoints = {0,0,0,1}, BGColor = "red", Width = 2 },
        { Line = true, AnchorPoints = {0,0,1,0}, BGColor = "red", Width = 2 },
        { Line = true, AnchorPoints = {1,1,1,0}, BGColor = "red", Width = 2 },
        { Line = true, AnchorPoints = {0,1,1,1}, BGColor = "red", Width = 2 },
      }
    end
  end
  
  wndIconPicker = GUILib:Create(tWndDef):GetInstance(nil,wndAnchor)
end


local function ShowPerNodeCustomization(strNodeType)
  if wndPerNode ~= nil and wndPerNode:IsValid() then
    wndPerNode:Destroy()
  end

  local tWndDef = {
    Name                 = "PerNodeCustomization",
    AnchorCenter         = {408, 448},
		Sprite 							 = "BK3:UI_BK3_Holo_Framing_2",
		BGColor 						 = "ffffffff",
    Escapable            = true,
    NoClip               = true,
    Overlapped           = true,
    Picture              = true,
    NewWindowDepth       = true,
    Moveable             = true,
    Children = {
      {
        Name           = "NodeContainer",
        AnchorPoints   = {0,0,1,1}, AnchorOffsets  = {46,46,-46,-86},
				Template 			 = "Holo_List",
				Sprite 				 = "BK3:UI_BK3_Holo_InsetSimple",
				Border = false,
				UseTemplateBG = false,
        Children       = {},
        VScroll        = true,
        IgnoreMouse    = true,
        DT_CENTER      = true,
        DT_VCENTER     = true,
        DT_WORDBREAK   = true,
        Events = { 
          WindowLoad = function(_, wndHandler, wndControl)
            if wndHandler ~= wndControl then return end
            wndControl:ArrangeChildrenVert(0)
          end,
        },
      },
      
      { -- ResetButton
        WidgetType = "PushButton",
        AnchorPoints = {0,1,1,1}, AnchorOffsets = {36,-91, -36, -31},
				Base = "BK3:btnHolo_Blue_Med",
				Font = "CRB_InterfaceMedium",
				TextTheme = "UI_BtnTextBlue",
        Text = L["Reset to Defaults"],
        Events = {
          ButtonSignal = function(_, wndHandler, wndControl)
            if wndHandler ~= wndControl then return end
            for k,v in pairs(N.db.modules.map[strNodeType].perNode) do
              local rowWnd = wndControl:GetParent():FindChild("NodeContainer:NodeRow." .. k)
              N.db.modules.map[strNodeType].perNode[k].show = true
              rowWnd:FindChild("ShowCheckBox"):SetCheck(N.db.modules.map[strNodeType].perNode[k].show)
              N.db.modules.map[strNodeType].perNode[k].sprIcon = N.db.modules.map[strNodeType].sprIcon
              rowWnd:FindChild("IconFrame:IconSample"):SetSprite(N.db.modules.map[strNodeType].perNode[k].sprIcon)
							local cr = N.db.modules.map[strNodeType].color
              N.db.modules.map[strNodeType].perNode[k].color   = CColor.new(cr.r, cr.g, cr.b, cr.a)
              rowWnd:FindChild("ColorFrame:ColorSample"):SetBGColor(N.db.modules.map[strNodeType].perNode[k].color)
            end
            N:UpdateResourceNodes(true)
          end
        },
      },
      
      { -- CloseButton
        Name = "CloseButton",
        Class = "Button",
        ButtonType = "PushButton",
        Base = "BK3:btnHolo_Close", 
        WindowSoundTemplate = "CloseWindowPhys",
        AnchorPoints = "TOPRIGHT", AnchorOffsets = { -55, 30, -33, 52 },
        NoClip = true,
        Events = {
          ButtonSignal = function(_, wndHandler, wndControl) wndControl:GetParent():Close() end,
        },
      },
    },
  }
    
  local tNodes = tWndDef.Children[1].Children
  for k,v in pairs(N.db.modules.map[strNodeType].perNode) do
    local tRowDef = {
      Name = "NodeRow." .. k,
      AnchorPoints = "HFILL", AnchorOffsets = {0,0,0,36},
      Pixies = {
        { Text = k:gsub("Node$", "") .. " (T" .. ktNodeTiers[k] ..")", Font = "CRB_InterfaceSmall", AnchorPoints = "VFILL", AnchorOffsets = {100, 0, 295, 0}, DT_VCENTER = true },          
      },
      Children = {
--        { -- Show
--          WidgetType    = "NavMateCheckBox",
--          Name          = "ShowCheckBox",
--          AnchorPoints  = { 0,0,0,1 }, AnchorOffsets = { 10,0,40,0 },
--          Events = {
--            ButtonCheck   = function(_, wndHandler, wndControl)
--              if wndHandler ~= wndControl then return end
--              N.db.modules.map[strNodeType].perNode[k].show = wndControl:IsChecked()
--              N:UpdateResourceNodes(true)
--            end,
--            ButtonUncheck = "Event::ButtonCheck",
--            WindowLoad    = function(_, wndHandler, wndControl)
--              if wndHandler ~= wndControl then return end
--              wndControl:SetCheck(N.db.modules.map[strNodeType].perNode[k].show)
--            end,
--          },
--        },
        { -- IconFrame
          Name = "IconFrame",
          AnchorPoints  = { 0,0,0,1 }, AnchorOffsets = { 10,0,50,0 },
          
          Children = {
						{
							AnchorOffsets = { 3, 5, 27, 29 },
							RelativeToClient = true, 
							BGColor = "ffffffff", 
							TextColor = "UI_WindowTextDefault", 
							Name = "IconSample", 
							Sprite = "BasicSprites:WhiteFill", 
							Picture = true, 
							IgnoreMouse = true, 
							Events = {
								WindowLoad = function(_, wndHandler, wndControl)
									if wndHandler ~= wndControl then return end
									wndControl:SetSprite(N.db.modules.map[strNodeType].perNode[k].sprIcon)
								end,
							},

							Children = {
								{
									AnchorOffsets = { -10, -10, 10, 10 },
									AnchorPoints = "FILL",
									Class = "Button", 
									Base = "CRB_CraftingCircuitSprites:btnCircuit_SquareGlass_Blue", 
									Font = "DefaultButton", 
									ButtonType = "PushButton", 
									DT_VCENTER = true, 
									DT_CENTER = true, 
									BGColor = "UI_BtnBGDefault", 
									TextColor = "UI_BtnTextDefault", 
									NormalTextColor = "UI_BtnTextDefault", 
									PressedTextColor = "UI_BtnTextDefault", 
									FlybyTextColor = "UI_BtnTextDefault", 
									PressedFlybyTextColor = "UI_BtnTextDefault", 
									DisabledTextColor = "UI_BtnTextDefault", 
									Name = "IconPickerBtn", 
									NoClip = true, 
									Events = {
										ButtonSignal = function(self, wndHandler, wndControl)
											CreateIconPicker(wndControl:GetParent(), ktNodeIcons, 32, N.db.modules.map[strNodeType].perNode[k].sprIcon, function(strIcon)
												N.db.modules.map[strNodeType].perNode[k].sprIcon = strIcon
												wndControl:GetParent():SetSprite(strIcon)
												N:UpdateResourceNodes(true)
											end)
										end,
									},
								},
							},
						},
          },
        },
      
      
        { -- ColorFrame
          Name = "ColorFrame",
          AnchorPoints  = { 0,0,0,1 }, AnchorOffsets = { 55,0,95,0 },
          
          Children = {
						{
							AnchorOffsets = { 3, 5, 27, 29 },
							RelativeToClient = true, 
							BGColor = "xkcdLavender", 
							TextColor = "UI_WindowTextDefault", 
							Name = "ColorSample", 
							Sprite = "BasicSprites:WhiteFill", 
							Picture = true, 
							IgnoreMouse = true, 
							Events = {
								WindowLoad = function(_, wndHandler, wndControl)
									if wndHandler ~= wndControl then 
										return
									end
									wndControl:SetBGColor(N.db.modules.map[strNodeType].perNode[k].color)
								end,
							},

							Children = {
								{
									AnchorOffsets = { -10, -10, 10, 10 },
									AnchorPoints = "FILL",
									Class = "Button", 
									Base = "CRB_CraftingCircuitSprites:btnCircuit_SquareGlass_Blue", 
									Font = "DefaultButton", 
									ButtonType = "PushButton", 
									DT_VCENTER = true, 
									DT_CENTER = true, 
									BGColor = "UI_BtnBGDefault", 
									TextColor = "UI_BtnTextDefault", 
									NormalTextColor = "UI_BtnTextDefault", 
									PressedTextColor = "UI_BtnTextDefault", 
									FlybyTextColor = "UI_BtnTextDefault", 
									PressedFlybyTextColor = "UI_BtnTextDefault", 
									DisabledTextColor = "UI_BtnTextDefault", 
									Name = "ColorPickerBtn", 
									NoClip = true, 
									Events = {
										ButtonSignal = function(self, wndHandler, wndControl)
											N.DaiColorPicker.AdjustColor(N.db.modules.map[strNodeType].perNode[k].color, function(newColor, bIsFinal) 
												N.db.modules.map[strNodeType].perNode[k].color = newColor
												wndControl:GetParent():SetBGColor(newColor)
												N:UpdateResourceNodes()
											end)
										end,
									},
								},
							},
						},
          },
        },
      },
    }
    tNodes[#tNodes+1] = tRowDef
  end
  wndPerNode = GUILib:Create(tWndDef):GetInstance()
end




GUILib:RegisterWidgetType("NavMateCheckBox", function()
  local ctrl = GUILib.ControlBase:new()
  ctrl:SetOptions{
    Class            = "Button",
    Name             = "NavMateCheckBox",
    RelativeToClient = true,
    Font             = "CRB_InterfaceMedium",
    ButtonType       = "Check",
    TextColor        = "UI_WindowTextDefault",
    DrawAsCheckbox   = true,
    DT_VCENTER       = true,
    TextThemeColor   = "ffffffff",
    Base             = "BK3:btnHolo_Check",
  }
  return ctrl
end, 1)

GUILib:RegisterWidgetType("NavMateRadioButton", function()
  local ctrl = GUILib.ControlBase:new()
  ctrl:SetOptions{
    Class            = "Button",
    Name             = "NavMateRadioButton",
    RelativeToClient = true,
    Font             = "CRB_InterfaceMedium",
    ButtonType       = "Check",
    TextColor        = "UI_WindowTextDefault",
    DrawAsCheckbox   = true,
    DT_VCENTER       = true,
    TextThemeColor   = "ffffffff",
    Base             = "BK3:btnHolo_Radio_Small",
  }
  return ctrl
end, 1)
GUILib:RegisterWidgetType("NavMateSubOptionFrame", function()
  local ctrl = GUILib.ControlBase:new()
  ctrl:SetOptions{
    Class            = "Window",
    RelativeToClient = true,
    AnchorPoints = { 0, 0, 0, 0}, AnchorOffsets = { 0, 0, 450, 145 },
  }
  ctrl:AddPixie{ AnchorPoints = "FILL", AnchorOffsets = {0,27,0,-25}, Sprite = "CRB_Basekit:kitInnerFrame_Holo_SimpleInset" }
  ctrl:AddPixie{ AnchorPoints = {0,1,1,1}, AnchorOffsets = {0,-15,0,0}, Sprite = "CRB_Tooltips:sprTooltip_HorzDividerDiagonal" }
  return ctrl
end, 1)
GUILib:RegisterWidgetType("NavMateMainOptionFrame", function()
  local ctrl = GUILib.ControlBase:new()
  ctrl:SetOptions{
    Class            = "Window",
    RelativeToClient = true,
    AnchorFill       = true,
    IgnoreMouse      = true,
    Events = {
      WindowLoad = ArrangeOptionsFrames,
    },
  }
  return ctrl
end, 1)
    


   

local function CreateMainWindowDef()
  return {
    Name = "NavMateOptionsForm",
    AnchorCenter = { 540, 680 },
    Moveable = true,
    Escapable = true,
    Overlapped = true,
    
    Pixies = {
      { Sprite = "CRB_Basekit:kitAccent_Scanlines", AnchorPoints = {0,0,1,1}, AnchorOffsets = {29,78,-29,-28} },
      { Sprite = "CRB_Basekit:kitBase_HoloTeal_NoBorder", AnchorPoints = {0,0,1,1}, AnchorOffsets = {29,78,-29,-28} },
      { Sprite = "CRB_Basekit:kitBase_MetalGrey_Large", AnchorPoints = "FILL", AnchorOffsets = {20,20,-20,-20}, },
    },
    
    Children = {
      { -- CloseButton
        Name = "CloseButton",
        Class = "Button",
        ButtonType = "PushButton",
        Base = "CRB_Basekit:kitBtn_Close", 
        WindowSoundTemplate = "CloseWindowPhys",
        AnchorPoints = "TOPRIGHT", AnchorOffsets = { -36, 11, -9, 40 },
        Events = {
          ButtonSignal = function(_, wndHandler, wndControl) wndControl:GetParent():Close() end,
        },
      },
      { -- TabContainer
        Name = "TabContainer",
        AnchorPoints = {0,0,1,0}, AnchorOffsets = { 42, 22, -42, 67 },
        IgnoreMouse = true,
      },      
      { -- BGFrame
        Name = "BGFrame",
        AnchorFill = true,
        IgnoreMouse = true,
        Sprite = "CRB_Basekit:kitOuterFrame_MetalGold_Large",
        Picture = true,
        Pixies = {
          { Sprite = "CRB_Basekit:kitHeader_Hybrid_ButtonPanel", AnchorPoints = {0,0,1,0}, AnchorOffsets = {10,4,-10,87}, BGColor = "ffffffff", },
        },
      },
      { -- FrameContainer
        Name = "FrameContainer",
        AnchorPoints = "FILL", AnchorOffsets = { 29, 78, -29, -28 },
        Template = "CRB_Scroll_HoloSmall",
        VScroll = true,
        AutoHideScroll = true,
        IgnoreMouse = true,
      },
    },
    Events = {
      WindowLoad = function()
        N:GetModule("Coords").wnd:SetStyle("Moveable", true)
      end,
      WindowClosed = function(_, wndHandler, wndControl)
        if wndHandler ~= wndControl then return end
        N:GetModule("Coords").wnd:SetStyle("Moveable", false)
        wndControl:Destroy()
      end,
      
    },
  }
end


local function CreateGeneralTab()
  return {
    WidgetType = "NavMateMainOptionFrame",
    Children = {
      { -- Coords
        NewControlDepth = 2,
        Name = "SubOptions.2",
        WidgetType = "NavMateSubOptionFrame",
        Pixies = {
          { Text = L["Coordinates"], AnchorPoints = { 0,0,1,0 }, AnchorOffsets = { 0,0,0,20}, DT_CENTER = true, DT_VCENTER = true, TextColor = "UI_TextHoloTitle",  Font = "CRB_InterfaceLarge" },
        },        
        Children = {
          {
            AnchorPoints = "FILL", AnchorOffsets = {23,39,-23,99},
            Events = { WindowLoad = ArrangeOptions, },
            Children = {
              { -- CoordsEnableBtn
                WidgetType    = "NavMateCheckBox",
                Text          = "  " .. L["Enable"],
                AnchorPoints  = {0,0,0.5,0}, AnchorOffsets = {0,0,0,30},
                Events = {
                  ButtonCheck = function(_, wndHandler, wndControl)
                    if wndHandler ~= wndControl then return end
                    N:GetModule("Coords").config.enable = wndControl:IsChecked()
                  end,
                  ButtonUncheck = "Event::ButtonCheck",
                  WindowLoad = function(_, wndHandler, wndControl)
                    if wndHandler ~= wndControl then return end
                    wndControl:SetCheck(N:GetModule("Coords").config.enable)
                  end,
                },
              },
--              FillerCell,
--              FillerCell, 
--              FillerCell, 
              
--              { -- CoordsAnchorToMiniMapBtn
--                WidgetType    = "NavMateCheckBox",
--                Text          = "  " .. L["Dock to MiniMap"],
--                AnchorPoints  = {0,0,0.5,0}, AnchorOffsets = {0,0,0,30},
--                Events = {
--                  ButtonCheck = function(_, wndHandler, wndControl)
--                    if wndHandler ~= wndControl then return end
--                    N:GetModule("Coords").config.isDocked = wndControl:IsChecked()
--                    N:GetModule("Coords"):SetupWindow()
--                    N:GetModule("Coords").wnd:SetStyle("Moveable", true)
--                  end,
--                  ButtonUncheck = "Event::ButtonCheck",
--                  WindowLoad = function(_, wndHandler, wndControl)
--                    if wndHandler ~= wndControl then return end
--                    wndControl:SetCheck(N:GetModule("Coords").config.isDocked)
--										wndControl:Enable(false)
--                  end,
--                },
--              },
							{
								AnchorPoints = {0,0,0.5,0}, AnchorOffsets = {0,0,0,30},
								Children = {
									{ -- ResetPositionBtn
										WidgetType = "PushButton",
										Base = "BK3:btnHolo_Blue_Med",
										Text = L["Reset Position"],
										TextTheme = "UI_BtnTextBlue",
										AnchorPoints = "FILL",
										AnchorOffsets = { -10, -16, 10, 16 },
										NoClip = true,
										Events = {
											ButtonSignal = function() N:GetModule("Coords"):ResetPosition() end,
										},
									},
								},
							},
            },
          },
        },
      }, -- End of Coords Settings
      { -- Taxi Settings
        NewControlDepth = 3,
        WidgetType = "NavMateSubOptionFrame",
        Name = "SubOptions.3",
--        Name = "TaxiOptions",
        Pixies = {
          { Text = L["Taxi"], AnchorPoints = { 0,0,1,0 }, AnchorOffsets = { 0,0,0,20}, DT_CENTER = true, DT_VCENTER = true, TextColor = "UI_TextHoloTitle",  Font = "CRB_InterfaceLarge" },
        },
        Children = {
          {
            AnchorPoints = "FILL", AnchorOffsets = {23,39,-23,99},
            Events = { WindowLoad = ArrangeOptions, },
            Children = {
              { -- ShowAllTaxiNodesOnZoneMapBtn
                WidgetType    = "NavMateCheckBox",
                Text          = "  " .. L["Show Taxi Nodes on ZoneMap"],
                AnchorPoints  = {0,0,1,0}, AnchorOffsets = {0,0,0,30},
                Events = {
                  ButtonCheck = function(_, wndHandler, wndControl)
                    if wndHandler ~= wndControl then return end
                    N:GetModule("ZoneMapHooker").config.showTaxiNodes = wndControl:IsChecked()
                    N:GetModule("ZoneMapHooker"):UpdateTaxiMarkers()
                  end,
                  ButtonUncheck = "Event::ButtonCheck",
                  WindowLoad = function(_, wndHandler, wndControl)
                    if wndHandler ~= wndControl then return end
                    wndControl:SetCheck(N:GetModule("ZoneMapHooker").config.showTaxiNodes)
                  end,
                },
              },
              { -- MuteTaxiDriverBtn
                WidgetType    = "NavMateCheckBox",
                Text          = "  " .. L["Mute Taxi Driver"],
                AnchorPoints  = {0,0,1,0}, AnchorOffsets = {0,0,0,30},
                Events = {
                  ButtonCheck = function(_, wndHandler, wndControl)
                    if wndHandler ~= wndControl then return end
                    N:GetModule("Taxi").config.mute = wndControl:IsChecked()
                    N:GetModule("Taxi"):CheckTaxiState()
                  end,
                  ButtonUncheck = "Event::ButtonCheck",
                  WindowLoad = function(_, wndHandler, wndControl)
                    if wndHandler ~= wndControl then return end
                    wndControl:SetCheck(N:GetModule("Taxi").config.mute)
                  end,
                },
              },
            },
          },
        },
      }, -- End of Taxi Settings
    },
  }
end

local function CreateWaypointsTab()
  return {
    WidgetType = "NavMateMainOptionFrame",
    Children = {
      { -- Waypoint Arrival
        Name = "SubOptions.1",
        WidgetType = "NavMateSubOptionFrame",
        Pixies = {
          { Text = L["Waypoint Arrival"], AnchorPoints = { 0,0,1,0 }, AnchorOffsets = { 0,0,0,20}, DT_CENTER = true, DT_VCENTER = true, TextColor = "UI_TextHoloTitle",  Font = "CRB_InterfaceLarge" },
        },        
        Children = {
          {
            AnchorPoints = "FILL", AnchorOffsets = {23,39,-23,99},
            Events = { WindowLoad = ArrangeOptions, },
            Children = {
              { -- ArrivalDistanceSliderFrame
                Name = "ArrivalDistanceSliderFrame",
                AnchorPoints = "HFILL", AnchorOffsets = {0,0,0,30},
                IgnoreMouse = true,
                Pixies = {
                  {
                    AnchorPoints = {0,0,0.33,1}, AnchorOffsets = { 5, 0,1,0},
                    DT_VCENTER = true,
                    Text = L["Arrival Distance"],
                    Font             = "CRB_InterfaceMedium",
                    TextColor        = "UI_WindowTextDefault",
                  },
                },
                Children = {
                  { -- ArrivalDistanceSlider
                    WidgetType = "SliderBar",
                    Name = "ArrivalDistanceSlider",
                    AnchorPoints = {0.45, 0.5, 1, 0.5}, AnchorOffsets = { 0,-10,0,10},
                    Template = "CRB_Scroll_HoloLarge", 
                    UseButtons = true,
                    Middle = "CRB_Basekit:kitScrollbase_Horiz_Holo",
                    Min = 5,
                    Max = 50,
                    TickAmount = 0.5,
                    InitialValue = 10,
                    Events = {
                      WindowLoad = function(_, wndHandler, wndControl)
                        if wndHandler ~= wndControl then return end
                        wndControl:SetValue(N:GetModule("Arrow").config.waypointArrivalDistance)
                      end,
                      SliderBarChanged = function(_, _, wndControl, fNewValue)
                        wndControl:GetParent():GetParent():FindChild("ArrivalDistanceEditBox"):SetText(string.format("%.1f", fNewValue))
                        N:GetModule("Arrow").config.waypointArrivalDistance = fNewValue
                      end,
                    },
                  },
                  { -- ArrivalDistanceEditBox
                    Class = "EditBox",
                    Name = "ArrivalDistanceEditBox",
                    AnchorPoints = {0.45, 0, 0.45, 1}, AnchorOffsets = {-46, 0, -4, 0},
                    Text  = "10.0",
                    TextColor = "UI_TextHoloBodyHighlight",
                    Font = "CRB_InterfaceMedium",
                    NoClip = true,
                    ReadOnly = true,
                    DT_RIGHT = true,
                    DT_VCENTER = true,
                    Events = {
                      WindowLoad = function(_, wndHandler, wndControl)
                        if wndHandler ~= wndControl then return end
                        wndControl:SetText(string.format("%.0f", N:GetModule("Arrow").config.waypointArrivalDistance))
                      end,
                    },
                  },
                },
              },
              
              { -- ArrivalSoundBtn
                WidgetType = "NavMateCheckBox",
                AnchorPoints = {0,0,1,0}, AnchorOffsets = { 0,0,0,30 },
                Text = "  " .. L["Options_PlayArrivalSound"],
                Events = {
                  ButtonCheck = function(_, wndHandler, wndControl)
                    if wndHandler ~= wndControl then return end
                    N:GetModule("Arrow").config.waypointArrivalSound = wndControl:IsChecked()
                  end,
                  ButtonUncheck = "Event::ButtonCheck",
                  WindowLoad = function(_, wndHandler, wndControl)
                    if wndHandler ~= wndControl then return end
                    wndControl:SetCheck(N:GetModule("Arrow").config.waypointArrivalSound)
                  end,
                },
              },
              
            },
          },
        },
      }, -- End of Waypoint Arrival Settings
    
      { -- Arrow
        Name = "SubOptions.2",
        WidgetType = "NavMateSubOptionFrame",
        Pixies = {
          { Text = L["Arrow"], AnchorPoints = { 0,0,1,0 }, AnchorOffsets = { 0,0,0,20}, DT_CENTER = true, DT_VCENTER = true, TextColor = "UI_TextHoloTitle",  Font = "CRB_InterfaceLarge" },
        },        
        Children = {
          {
            AnchorPoints = "FILL", AnchorOffsets = {23,39,-23,99},
            Events = { WindowLoad = ArrangeOptions, },
            Children = {
              { -- ArrowEnableBtn
                WidgetType    = "NavMateCheckBox",
                AnchorPoints  = {0,0,0.33,0}, AnchorOffsets = { 0,0,0,30 },
                Text          = "  " .. L["Enable"],
                Events = {
                  ButtonCheck = function(_, wndHandler, wndControl)
                    if wndHandler ~= wndControl then return end
                    N:GetModule("Arrow").config.enable = wndControl:IsChecked()
                  end,
                  ButtonUncheck = "Event::ButtonCheck",
                  WindowLoad    = function(_, wndHandler, wndControl)
                    if wndHandler ~= wndControl then return end
                    wndControl:SetCheck(N:GetModule("Arrow").config.enable)
                  end,
                },
              },
              { -- ArrowInvertBtn
                WidgetType    = "NavMateCheckBox",
                AnchorPoints  = {0,0,0.33,0}, AnchorOffsets = { 0,0,0,30 },
                Text          = "  " .. L["Options_InvertArrow"],
                Events = {
                  ButtonCheck = function(_, wndHandler, wndControl)
                    if wndHandler ~= wndControl then return end
                    N:GetModule("Arrow").config.invert = wndControl:IsChecked()
                  end,
                  ButtonUncheck = "Event::ButtonCheck",
                  WindowLoad    = function(_, wndHandler, wndControl)
                    if wndHandler ~= wndControl then return end
                    wndControl:SetCheck(N:GetModule("Arrow").config.invert)
                  end,
                },
              },
              FillerCell,
              FillerCell,
              FillerCell,
              FillerCell,
              
              { -- HotColorFrame
                Name = "HotColorFrame",
                AnchorPoints  = {0,0,0.33,0}, AnchorOffsets = { 0,0,0,33 },
                
                Pixies = {
                  {
                    AnchorPoints = "FILL", AnchorOffsets = {38,0,0,0},
                    Text = L["Options_ArrowHot"],
                    Font = "CRB_InterfaceMedium",
                    TextColor = "UI_WindowTextDefault",
                    DT_VCENTER = true,
                  },
                },
                
                Children = {
									{
										AnchorOffsets = { 3, 5, 27, 29 },
										RelativeToClient = true, 
										BGColor = "xkcdLavender", 
										TextColor = "UI_WindowTextDefault", 
										Name = "HotColorSample", 
										Sprite = "BasicSprites:WhiteFill", 
										Picture = true, 
										IgnoreMouse = true, 
										Events = {
											WindowLoad = function(_, wndHandler, wndControl)
												if wndHandler ~= wndControl then 
													return
												end
												wndControl:SetBGColor(N:GetModule("Arrow").config.colors.hot)
											end,
										},

										Children = {
											{
												AnchorOffsets = { -10, -10, 10, 10 },
												AnchorPoints = "FILL",
												Class = "Button", 
												Base = "CRB_CraftingCircuitSprites:btnCircuit_SquareGlass_Blue", 
												Font = "DefaultButton", 
												ButtonType = "PushButton", 
												DT_VCENTER = true, 
												DT_CENTER = true, 
												BGColor = "UI_BtnBGDefault", 
												TextColor = "UI_BtnTextDefault", 
												NormalTextColor = "UI_BtnTextDefault", 
												PressedTextColor = "UI_BtnTextDefault", 
												FlybyTextColor = "UI_BtnTextDefault", 
												PressedFlybyTextColor = "UI_BtnTextDefault", 
												DisabledTextColor = "UI_BtnTextDefault", 
												Name = "HotColorPickerBtn", 
												NoClip = true, 
												Events = {
													ButtonSignal = function(self, wndHandler, wndControl)
														N.DaiColorPicker.AdjustColor(N:GetModule("Arrow").config.colors.hot, function(newColor, bIsFinal) 
															N:GetModule("Arrow").config.colors.hot = newColor
															wndControl:GetParent():SetBGColor(newColor)
														end)
													end,
												},
											},
										},
									},
                },
              },
              { -- WarmColorFrame
                Name = "WarmColorFrame",
                AnchorPoints  = {0,0,0.33,0}, AnchorOffsets = { 0,0,0,33 },
                
                Pixies = {
                  {
                    AnchorPoints = "FILL", AnchorOffsets = {38,0,0,0},
                    Text = L["Options_ArrowWarm"],
                    Font = "CRB_InterfaceMedium",
                    TextColor = "UI_WindowTextDefault",
                    DT_VCENTER = true,
                  },
                },
                
                Children = {
									{
										AnchorOffsets = { 3, 5, 27, 29 },
										RelativeToClient = true, 
										BGColor = "xkcdLavender", 
										TextColor = "UI_WindowTextDefault", 
										Name = "HotColorSample", 
										Sprite = "BasicSprites:WhiteFill", 
										Picture = true, 
										IgnoreMouse = true, 
										Events = {
											WindowLoad = function(_, wndHandler, wndControl)
												if wndHandler ~= wndControl then 
													return
												end
												wndControl:SetBGColor(N:GetModule("Arrow").config.colors.warm)
											end,
										},

										Children = {
											{
												AnchorOffsets = { -10, -10, 10, 10 },
												AnchorPoints = "FILL",
												Class = "Button", 
												Base = "CRB_CraftingCircuitSprites:btnCircuit_SquareGlass_Blue", 
												Font = "DefaultButton", 
												ButtonType = "PushButton", 
												DT_VCENTER = true, 
												DT_CENTER = true, 
												BGColor = "UI_BtnBGDefault", 
												TextColor = "UI_BtnTextDefault", 
												NormalTextColor = "UI_BtnTextDefault", 
												PressedTextColor = "UI_BtnTextDefault", 
												FlybyTextColor = "UI_BtnTextDefault", 
												PressedFlybyTextColor = "UI_BtnTextDefault", 
												DisabledTextColor = "UI_BtnTextDefault", 
												Name = "HotColorPickerBtn", 
												NoClip = true, 
												Events = {
													ButtonSignal = function(self, wndHandler, wndControl)
														N.DaiColorPicker.AdjustColor(N:GetModule("Arrow").config.colors.warm, function(newColor, bIsFinal) 
															N:GetModule("Arrow").config.colors.warm = newColor
															wndControl:GetParent():SetBGColor(newColor)
														end)
													end,
												},
											},
										},
									},
                },
              },

              { -- ColdColorFrame
                Name = "ColdColorFrame",
                AnchorPoints  = {0,0,0.33,0}, AnchorOffsets = { 0,0,0,33 },
                
                Pixies = {
                  {
                    AnchorPoints = "FILL", AnchorOffsets = {38,0,0,0},
                    Text = L["Options_ArrowCold"],
                    Font = "CRB_InterfaceMedium",
                    TextColor = "UI_WindowTextDefault",
                    DT_VCENTER = true,
                  },
                },
                
                Children = {
									{
										AnchorOffsets = { 3, 5, 27, 29 },
										RelativeToClient = true, 
										BGColor = "xkcdLavender", 
										TextColor = "UI_WindowTextDefault", 
										Name = "HotColorSample", 
										Sprite = "BasicSprites:WhiteFill", 
										Picture = true, 
										IgnoreMouse = true, 
										Events = {
											WindowLoad = function(_, wndHandler, wndControl)
												if wndHandler ~= wndControl then 
													return
												end
												wndControl:SetBGColor(N:GetModule("Arrow").config.colors.cold)
											end,
										},

										Children = {
											{
												AnchorOffsets = { -10, -10, 10, 10 },
												AnchorPoints = "FILL",
												Class = "Button", 
												Base = "CRB_CraftingCircuitSprites:btnCircuit_SquareGlass_Blue", 
												Font = "DefaultButton", 
												ButtonType = "PushButton", 
												DT_VCENTER = true, 
												DT_CENTER = true, 
												BGColor = "UI_BtnBGDefault", 
												TextColor = "UI_BtnTextDefault", 
												NormalTextColor = "UI_BtnTextDefault", 
												PressedTextColor = "UI_BtnTextDefault", 
												FlybyTextColor = "UI_BtnTextDefault", 
												PressedFlybyTextColor = "UI_BtnTextDefault", 
												DisabledTextColor = "UI_BtnTextDefault", 
												Name = "HotColorPickerBtn", 
												NoClip = true, 
												Events = {
													ButtonSignal = function(self, wndHandler, wndControl)
														N.DaiColorPicker.AdjustColor(N:GetModule("Arrow").config.colors.cold, function(newColor, bIsFinal) 
															N:GetModule("Arrow").config.colors.cold = newColor
															wndControl:GetParent():SetBGColor(newColor)
														end)
													end,
												},
											},
										},
									},
                },
              },
            },
          },
        },
      } -- End of Arrow Settings
      
    
    
    
      
    },
  }
end



local function CreateTradeSkillNodesTab()
  local tWndDef = {
    WidgetType = "NavMateMainOptionFrame",
    Name = "NavMateOptionsTradeSkillsTab",
    Children = {},
  }
  
  local tTradeSkills = { ["mining"] = "Mining", ["relic"] = "Relic Hunter", ["survival"] = "Survivalist", ["farming"] = "Farmer" }
  local nSectionCount = 0
  for strTradeSkill, strTradeSkillName in pairs(tTradeSkills) do
    nSectionCount = nSectionCount + 1
    local tSection = {
      Name = "SubOptions." .. nSectionCount,
      WidgetType = "NavMateSubOptionFrame",
      Pixies = {
        { Text = strTradeSkillName, AnchorPoints = { 0,0,1,0 }, AnchorOffsets = { 0,0,0,20}, DT_CENTER = true, DT_VCENTER = true, TextColor = "UI_TextHoloTitle",  Font = "CRB_InterfaceLarge" },
      },        
        Children = {
          {
            AnchorPoints = "FILL", AnchorOffsets = {23,39,-23,99},
            Events = { WindowLoad = ArrangeOptions, },
            Children = {
              { -- IconFrame
                Name = "IconFrame",
                AnchorPoints  = {0,0,0.5,0}, AnchorOffsets = { 0,0,0,30 },
                
                Pixies = {
                  {
                    AnchorPoints = "FILL", AnchorOffsets = {40,6,0,-6},
                    Text = " " .. L["Icon"],
                    Font = "CRB_InterfaceMedium",
                    TextColor = "UI_WindowTextDefault",
                    DT_VCENTER = true,
                  },
                },
                
                Children = {
									
									{
										AnchorOffsets = { 3, 5, 27, 29 },
										RelativeToClient = true, 
										BGColor = "ffffffff", 
										TextColor = "UI_WindowTextDefault", 
										Name = strTradeSkill .. "IconSample", 
										Sprite = "BasicSprites:WhiteFill", 
										Picture = true, 
										IgnoreMouse = true, 
										Events = {
											WindowLoad = function(_, wndHandler, wndControl)
												if wndHandler ~= wndControl then return end
												wndControl:SetSprite(N.db.modules.map[strTradeSkill].sprIcon)
											end,
										},

										Children = {
											{
												AnchorOffsets = { -10, -10, 10, 10 },
												AnchorPoints = "FILL",
												Class = "Button", 
												Base = "CRB_CraftingCircuitSprites:btnCircuit_SquareGlass_Blue", 
												Font = "DefaultButton", 
												ButtonType = "PushButton", 
												DT_VCENTER = true, 
												DT_CENTER = true, 
												BGColor = "UI_BtnBGDefault", 
												TextColor = "UI_BtnTextDefault", 
												NormalTextColor = "UI_BtnTextDefault", 
												PressedTextColor = "UI_BtnTextDefault", 
												FlybyTextColor = "UI_BtnTextDefault", 
												PressedFlybyTextColor = "UI_BtnTextDefault", 
												DisabledTextColor = "UI_BtnTextDefault", 
												Name = strTradeSkill .. "IconPickerBtn", 
												NoClip = true, 
												Events = {
													ButtonSignal = function(self, wndHandler, wndControl)
                            CreateIconPicker(wndControl:GetParent(), ktNodeIcons, 32, N.db.modules.map[strTradeSkill].sprIcon, function(strIcon)
                              N.db.modules.map[strTradeSkill].sprIcon = strIcon
                              wndControl:GetParent():SetSprite(strIcon)
                              N:UpdateResourceNodes(true)
                            end)
													end,
												},
											},
										},
									},
                },
              },
            
            
              { -- ColorFrame
                Name = "ColorFrame",
                AnchorPoints  = {0,0,0.5,0}, AnchorOffsets = { 0,0,0,33 },
                
                Pixies = {
                  {
                    AnchorPoints = "FILL", AnchorOffsets = {38,6,0,-6},
                    Text = L["Icon Color"],
                    Font = "CRB_InterfaceMedium",
                    TextColor = "UI_WindowTextDefault",
                    DT_VCENTER = true,
                  },
                },
                
                Children = {
									{
										AnchorOffsets = { 3, 5, 27, 29 },
										RelativeToClient = true, 
										BGColor = "xkcdLavender", 
										TextColor = "UI_WindowTextDefault", 
										Name = strTradeSkill .. "ColorSample", 
										Sprite = "BasicSprites:WhiteFill", 
										Picture = true, 
										IgnoreMouse = true, 
										Events = {
											WindowLoad = function(_, wndHandler, wndControl)
												if wndHandler ~= wndControl then 
													return
												end
												wndControl:SetBGColor(N.db.modules.map[strTradeSkill].color)
											end,
										},

										Children = {
											{
												AnchorOffsets = { -10, -10, 10, 10 },
												AnchorPoints = "FILL",
												Class = "Button", 
												Base = "CRB_CraftingCircuitSprites:btnCircuit_SquareGlass_Blue", 
												Font = "DefaultButton", 
												ButtonType = "PushButton", 
												DT_VCENTER = true, 
												DT_CENTER = true, 
												BGColor = "UI_BtnBGDefault", 
												TextColor = "UI_BtnTextDefault", 
												NormalTextColor = "UI_BtnTextDefault", 
												PressedTextColor = "UI_BtnTextDefault", 
												FlybyTextColor = "UI_BtnTextDefault", 
												PressedFlybyTextColor = "UI_BtnTextDefault", 
												DisabledTextColor = "UI_BtnTextDefault", 
												Name = strTradeSkill .. "ColorPickerBtn", 
												NoClip = true, 
												Events = {
													ButtonSignal = function(self, wndHandler, wndControl)
														N.DaiColorPicker.AdjustColor(N.db.modules.map[strTradeSkill].color, function(newColor, bIsFinal) 
															N.db.modules.map[strTradeSkill].color = newColor
															wndControl:GetParent():SetBGColor(newColor)
															N:UpdateResourceNodes()
														end)
													end,
												},
											},
										},
									},
                },
              },
            
              FillerCell,
              FillerCell,
						
              { -- Icon
                WidgetType    = "NavMateCheckBox",
                AnchorPoints  = {0,0,0.5,0}, AnchorOffsets = { 0,0,0,30 },
                Text          = "  " .. L["Use Per Node"],
                Events = {
                  ButtonCheck   = function(_, _, wndControl) 
                    N.db.modules.map[strTradeSkill].usePerNode = wndControl:IsChecked()
                    wndControl:GetParent():FindChild("NodeCustomizationButton"):Enable(N.db.modules.map[strTradeSkill].usePerNode)
                    N:UpdateResourceNodes(true)
                  end,
                  ButtonUncheck = "Event::ButtonCheck",
                  WindowLoad    = function(_, wndHandler, wndControl)
                    if wndHandler ~= wndControl then return end
                    wndControl:SetCheck(N.db.modules.map[strTradeSkill].usePerNode)
                  end,
                },
              },
							{
								AnchorPoints = { 0, 0, 0.5, 0 }, AnchorOffsets = {0,0,0,30},
								Children = {
									{
										WidgetType = "PushButton",
										Name = "NodeCustomizationButton",
										Base = "BK3:btnHolo_Blue_Med",
										TextTheme = "UI_BtnTextBlue",
										Text = L["Node Customization"],
										AnchorPoints = "FILL",
										AnchorOffsets = { -16, -16, 16, 16 },
										NoClip = true,
										Enabled = N.db.modules.map[strTradeSkill].usePerNode,
										Events = {
											ButtonSignal = function(_, wndHandler, wndControl)
												if wndHandler ~= wndControl then return end
												ShowPerNodeCustomization(strTradeSkill)
											end,
											WindowLoad = function(_, wndHandler, wndControl)
												if wndHandler ~= wndControl then return end
												wndControl:Enable(N.db.modules.map[strTradeSkill].usePerNode)
											end
										},
									},
								},
              },

            },
          },
        },
      } -- End of Settings
  
  
    table.insert(tWndDef.Children, tSection)
  end
  return tWndDef
end

local function CreateMapTab()
  local tMarkers = {}
  for _, strMarker in ipairs({"Datacube", "Path", "SettlerMinfrastructure"}) do
    local strText = L["MiniMapMarker_" .. strMarker]
      
    table.insert(tMarkers, 
      {
        WidgetType    = "NavMateCheckBox",
        AnchorPoints  = {0,0,1,0}, AnchorOffsets = { 0,0,0,30 },
        Text          = "  " .. strText,
        Events = {
          ButtonCheck   = function(_, wndHandler, wndControl)
            if wndHandler ~= wndControl then return end
            N:GetModule("MiniMapHooker"):EnableMarker(strMarker, wndControl:IsChecked())
          end,
          ButtonUncheck = "Event::ButtonCheck",
          WindowLoad    = function(_, wndHandler, wndControl)
            if wndHandler ~= wndControl then return end
            wndControl:SetCheck(N:GetModule("MiniMapHooker"):MarkerEnabledState(strMarker))
          end,
        },
      })
  end

  return {
    WidgetType = "NavMateMainOptionFrame",
    Children = {
      { -- Appearance
        Name = "SubOptions.1",
        WidgetType = "NavMateSubOptionFrame",
        Pixies = {
          { Text = L["MiniMap Appearance"], AnchorPoints = { 0,0,1,0 }, AnchorOffsets = { 0,0,0,20}, DT_CENTER = true, DT_VCENTER = true, TextColor = "UI_TextHoloTitle",  Font = "CRB_InterfaceLarge" },
        },
        Children = {
          {
            AnchorPoints = "FILL", AnchorOffsets = {23,39,-23,99},
            Events = { WindowLoad = ArrangeOptions, },
            Children = {
              { -- SquareMiniMapBtn
                WidgetType    = "NavMateCheckBox",
                AnchorPoints  = {0,0,1,0}, AnchorOffsets = { 0,0,0,30 },
                Text          = "  " .. L["Options_SquareMiniMap"],
                Tooltip       = L["Options_SquareMiniMap_Tooltip"],
                Events = {
                  ButtonCheck   = function(_, wndHandler, wndControl)
                    if wndHandler ~= wndControl then return end
                    N:GetModule("MiniMapHooker").config.mask = wndControl:IsChecked() and N:GetModule("MiniMapHooker").EnumMaskType.Square or N:GetModule("MiniMapHooker").EnumMaskType.Default
                    N:GetModule("MiniMapHooker"):SetMask(N:GetModule("MiniMapHooker").config.mask)
                  end,
                  ButtonUncheck = "Event::ButtonCheck",
                  WindowLoad    = function(_, wndHandler, wndControl)
                    if wndHandler ~= wndControl then return end
                    wndControl:SetCheck(N:GetModule("MiniMapHooker").config.mask == N:GetModule("MiniMapHooker").EnumMaskType.Square)
                  end,
                },
              },
              
            },
          },
        },
      },
      { -- Markers
        Name = "SubOptions.2",
        WidgetType = "NavMateSubOptionFrame",
        Pixies = {
          { Text = L["MiniMap Markers"], AnchorPoints = { 0,0,1,0 }, AnchorOffsets = { 0,0,0,20}, DT_CENTER = true, DT_VCENTER = true, TextColor = "UI_TextHoloTitle",  Font = "CRB_InterfaceLarge" },
        },
        Children = {
          {
            AnchorPoints = "FILL", AnchorOffsets = {23,39,-23,99},
            Events = { WindowLoad = ArrangeOptions, },
            Children = tMarkers,
          },
        },
      },
      { -- ZoneMap
        Name = "SubOptions.3",
        WidgetType = "NavMateSubOptionFrame",
        Pixies = {
          { Text = L["ZoneMap"], AnchorPoints = { 0,0,1,0 }, AnchorOffsets = { 0,0,0,20}, DT_CENTER = true, DT_VCENTER = true, TextColor = "UI_TextHoloTitle",  Font = "CRB_InterfaceLarge" },
        },
        Children = {
          {
            AnchorPoints = "FILL", AnchorOffsets = {23,39,-23,99},
            Events = { WindowLoad = ArrangeOptions, },
            Children = {
              { -- ShowAllTaxiNodesOnZoneMapBtn
                WidgetType    = "NavMateCheckBox",
                Text          = "  " .. L["Show Taxi Nodes"],
                AnchorPoints  = {0,0,1,0}, AnchorOffsets = { 0,0,0,30},
                Events = {
                  ButtonCheck = function(_, wndHandler, wndControl)
                    if wndHandler ~= wndControl then return end
                    N:GetModule("ZoneMapHooker").config.showTaxiNodes = wndControl:IsChecked()
                    N:GetModule("ZoneMapHooker"):UpdateTaxiMarkers()
                  end,
                  ButtonUncheck = "Event::ButtonCheck",
                  WindowLoad = function(_, wndHandler, wndControl)
                    if wndHandler ~= wndControl then return end
                    wndControl:SetCheck(N:GetModule("ZoneMapHooker").config.showTaxiNodes)
                  end,
                },
              },
            },
          },
        },
      },
      { -- Group Members
        Name = "SubOptions.4",
        WidgetType = "NavMateSubOptionFrame",
        Pixies = {
          { Text = L["Group Members"], AnchorPoints = { 0,0,1,0 }, AnchorOffsets = { 0,0,0,20}, DT_CENTER = true, DT_VCENTER = true, TextColor = "UI_TextHoloTitle",  Font = "CRB_InterfaceLarge" },
        },        
        Children = {
          {
            AnchorPoints = "FILL", AnchorOffsets = {23,39,-23,99},
            Events = { WindowLoad = ArrangeOptions, },
            Children = {
              { -- IconFrame
                Name = "IconFrame",
                AnchorPoints  = {0,0,0.33,0}, AnchorOffsets = { 0,0,0,30 },
                
                Pixies = {
                  {
                    AnchorPoints = "FILL", AnchorOffsets = {40,6,0,-6},
                    Text = L["Icon"],
                    Font = "CRB_InterfaceMedium",
                    TextColor = "UI_WindowTextDefault",
                    DT_VCENTER = true,
                  },
                },
                
                Children = {
									{
										AnchorOffsets = { 3, 5, 27, 29 },
										RelativeToClient = true, 
										BGColor = "ffffffff", 
										TextColor = "UI_WindowTextDefault", 
										Name = "GroupMemberIconSample", 
										Sprite = "BasicSprites:WhiteFill", 
										Picture = true, 
										IgnoreMouse = true, 
										Events = {
											WindowLoad = function(_, wndHandler, wndControl)
												if wndHandler ~= wndControl then return end
												wndControl:SetSprite(N.db.modules.map.group.sprIcon)
											end,
										},

										Children = {
											{
												AnchorOffsets = { -10, -10, 10, 10 },
												AnchorPoints = "FILL",
												Class = "Button", 
												Base = "CRB_CraftingCircuitSprites:btnCircuit_SquareGlass_Blue", 
												Font = "DefaultButton", 
												ButtonType = "PushButton", 
												DT_VCENTER = true, 
												DT_CENTER = true, 
												BGColor = "UI_BtnBGDefault", 
												TextColor = "UI_BtnTextDefault", 
												NormalTextColor = "UI_BtnTextDefault", 
												PressedTextColor = "UI_BtnTextDefault", 
												FlybyTextColor = "UI_BtnTextDefault", 
												PressedFlybyTextColor = "UI_BtnTextDefault", 
												DisabledTextColor = "UI_BtnTextDefault", 
												Name = "GroupMemberIconPickerBtn", 
												NoClip = true, 
												Events = {
													ButtonSignal = function(self, wndHandler, wndControl)
                            CreateIconPicker(wndControl:GetParent(), ktNodeIcons, 32, N.db.modules.map.group.sprIcon, function(strIcon)
                              N.db.modules.map.group.sprIcon = strIcon
                              wndControl:GetParent():SetSprite(strIcon)
                              UpdateGroupNodes()
                            end)
													end,
												},
											},
										},
									},
                },
              },
            
            
              { -- NormalColorFrame
                Name = "NormalColorFrame",
                AnchorPoints  = {0,0,0.33,0}, AnchorOffsets = { 0,0,0,33 },
                
                Pixies = {
                  {
                    AnchorPoints = "FILL", AnchorOffsets = {38,6,0,-6},
                    Text = L["Normal Color"],
                    Font = "CRB_InterfaceMedium",
                    TextColor = "UI_WindowTextDefault",
                    DT_VCENTER = true,
                  },
                },
                
                Children = {
									{
										AnchorOffsets = { 3, 5, 27, 29 },
										RelativeToClient = true, 
										BGColor = "xkcdLavender", 
										TextColor = "UI_WindowTextDefault", 
										Name = "GroupMemberNormalColorSample", 
										Sprite = "BasicSprites:WhiteFill", 
										Picture = true, 
										IgnoreMouse = true, 
										Events = {
											WindowLoad = function(_, wndHandler, wndControl)
												if wndHandler ~= wndControl then 
													return
												end
												wndControl:SetBGColor(N.db.modules.map.group.normalColor)
											end,
										},

										Children = {
											{
												AnchorOffsets = { -10, -10, 10, 10 },
												AnchorPoints = "FILL",
												Class = "Button", 
												Base = "CRB_CraftingCircuitSprites:btnCircuit_SquareGlass_Blue", 
												Font = "DefaultButton", 
												ButtonType = "PushButton", 
												DT_VCENTER = true, 
												DT_CENTER = true, 
												BGColor = "UI_BtnBGDefault", 
												TextColor = "UI_BtnTextDefault", 
												NormalTextColor = "UI_BtnTextDefault", 
												PressedTextColor = "UI_BtnTextDefault", 
												FlybyTextColor = "UI_BtnTextDefault", 
												PressedFlybyTextColor = "UI_BtnTextDefault", 
												DisabledTextColor = "UI_BtnTextDefault", 
												Name = "GroupMemberNormalColorPickerBtn", 
												NoClip = true, 
												Events = {
													ButtonSignal = function(self, wndHandler, wndControl)
														N.DaiColorPicker.AdjustColor(N.db.modules.map.group.normalColor, function(newColor, bIsFinal) 
															N.db.modules.map.group.normalColor = newColor
															wndControl:GetParent():SetBGColor(newColor)
															UpdateGroupNodes()
														end)
													end,
												},
											},
										},
									},
									
         
                },
              },
              { -- PvPColorFrame
                Name = "PvPColorFrame",
                AnchorPoints  = {0,0,0.33,0}, AnchorOffsets = { 0,0,0,33 },
                
                Pixies = {
                  {
                    AnchorPoints = "FILL", AnchorOffsets = {38,6,0,-6},
                    Text = L["PvP Combat"],
                    Font = "CRB_InterfaceMedium",
                    TextColor = "UI_WindowTextDefault",
                    DT_VCENTER = true,
                  },
                },
                
                Children = {
									{
										AnchorOffsets = { 3, 5, 27, 29 },
										RelativeToClient = true, 
										BGColor = "xkcdLavender", 
										TextColor = "UI_WindowTextDefault", 
										Name = "GroupMemberPvPColorSample", 
										Sprite = "BasicSprites:WhiteFill", 
										Picture = true, 
										IgnoreMouse = true, 
										Events = {
											WindowLoad = function(_, wndHandler, wndControl)
												if wndHandler ~= wndControl then 
													return
												end
												wndControl:SetBGColor(N.db.modules.map.group.pvpColor)
											end,
										},

										Children = {
											{
												AnchorOffsets = { -10, -10, 10, 10 },
												AnchorPoints = "FILL",
												Class = "Button", 
												Base = "CRB_CraftingCircuitSprites:btnCircuit_SquareGlass_Blue", 
												Font = "DefaultButton", 
												ButtonType = "PushButton", 
												DT_VCENTER = true, 
												DT_CENTER = true, 
												BGColor = "UI_BtnBGDefault", 
												TextColor = "UI_BtnTextDefault", 
												NormalTextColor = "UI_BtnTextDefault", 
												PressedTextColor = "UI_BtnTextDefault", 
												FlybyTextColor = "UI_BtnTextDefault", 
												PressedFlybyTextColor = "UI_BtnTextDefault", 
												DisabledTextColor = "UI_BtnTextDefault", 
												Name = "GroupMemberPvPColorPickerBtn", 
												NoClip = true, 
												Events = {
													ButtonSignal = function(self, wndHandler, wndControl)
														N.DaiColorPicker.AdjustColor(N.db.modules.map.group.pvpColor, function(newColor, bIsFinal) 
															N.db.modules.map.group.pvpColor = newColor
															wndControl:GetParent():SetBGColor(newColor)
															UpdateGroupNodes()
														end)
													end,
												},
											},
										},
									},
                },
              },
            },
          },
        },
      }
    },
  }
end

local function OnTabButtonCheck(_, _, wndControl)
  local fn = wndControl:GetData()
  if type(fn) == "function" then 
    local frameContainer = wndControl:GetParent():GetParent():FindChild("FrameContainer")
    frameContainer:DestroyChildren()
    GUILib:Create(fn):GetInstance(nil, frameContainer)
  end
end

local nTabCount = 0
local function AddTab(wndOptions, strTabName, fnCreateTabContent)
  nTabCount = nTabCount + 1
  local wndTabContainer = wndOptions:FindChild("TabContainer")
  local tBtn = GUILib:Create({
    Name                      = "TabButton" .. nTabCount,
    LuaData                   = fnCreateTabContent,
    Text                      = strTabName,
    Class                     = "Button",
    ButtonType                = "Check",
    Base                      = "CRB_Basekit:kitBtn_List_Holo",
    RadioGroup                = "NavMateOptionTab",
    Font                      = "CRB_InterfaceMedium_B",
    DT_CENTER                 = true,
    DT_VCENTER                = true,
    DT_WORDBREAK              = true,
    TextNormalColor           = "UI_TextHoloBody",
    PressedTextColor          = "ff31fcf6",
    PressedFlybyTextColor     = "ff31fcf6",
    FlybyTextColor            = "ff31fcf6",
    DisabledTextColor         = "ff717171",
    RadioDisallowNonSelection = true,
    Events = {
      ButtonCheck = OnTabButtonCheck,
    }
  }):GetInstance({}, wndTabContainer)
  
  local tChildren = wndTabContainer:GetChildren()
  if #tChildren == 0 then return end
  
  local nWidth = wndTabContainer:GetWidth()
  local nHeight = wndTabContainer:GetHeight()
  local nButtonWidth = nWidth / #tChildren
  for _, wndChild in ipairs(tChildren) do
    wndChild:SetAnchorOffsets(0, 0, nButtonWidth, nHeight)
  end
  wndTabContainer:ArrangeChildrenHorz(0)
end

local function SwitchToTab(wndOptions, nTab)
  wndOptions:FindChild("TabContainer"):SetRadioSel("NavMateOptionTab", nTab)
  local btnTab = wndOptions:FindChild("TabContainer"):GetRadioSelButton("NavMateOptionTab")
  if btnTab ~= nil then
    OnTabButtonCheck(nil, nil, btnTab)
  end
end


function N:ToggleOptionsWindow()
  if self.wndOptions and self.wndOptions:IsValid() and self.wndOptions:IsVisible() then 
    self:OnOptionsWindowClose()
  else
    if self.wndOptions == nil or not self.wndOptions:IsValid() then
      self.wndOptions = GUILib:Create(CreateMainWindowDef()):GetInstance()
      nTabCount = 0
    end
    
    local frameContainer = self.wndOptions:FindChild("FrameContainer")
    self.wndOptions:FindChild("TabContainer"):DestroyChildren()
    AddTab(self.wndOptions, "General",          CreateGeneralTab)
    AddTab(self.wndOptions, "Waypoints",        CreateWaypointsTab)
    AddTab(self.wndOptions, "TradeSkill Nodes", CreateTradeSkillNodesTab)
    AddTab(self.wndOptions, "Maps",             CreateMapTab)

    self.wndOptions:Show(true)
    
    self.nLastTabSelected = self.nLastTabSelected or 1
    SwitchToTab(self.wndOptions, self.nLastTabSelected)
  end
end