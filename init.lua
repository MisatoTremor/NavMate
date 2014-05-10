local VERSION = "0.9.5"

local NavMate = Apollo.GetPackage("Gemini:Addon-1.0").tPackage:NewAddon("NavMate", true, {"ZoneMap", "MiniMap"})
NavMate.Version = VERSION

NavMate.L = Apollo.GetPackage("Gemini:Locale-1.0").tPackage:GetLocale("NavMate", false)

NavMate.waypoints = {}
NavMate.db = {}
NavMate.db.modules = {}

local strMiningDefaultIcon   = "IconSprites:Icon_MapNode_Map_Node_Mining"
local strRelicDefaultIcon    = "IconSprites:Icon_MapNode_Map_Node_Relic"
local strSurvivalDefaultIcon = "IconSprites:Icon_MapNode_Map_Node_Tree"
local strFarmingDefaultIcon  = "IconSprites:Icon_MapNode_Map_Node_Plant"
local crMiningDefault        = CColor.new(1.0, 1.0, 1.0, 1.0)
local crRelicDefault         = CColor.new(1.0, 1.0, 1.0, 1.0)
local crSurvivalDefault      = CColor.new(1.0, 1.0, 1.0, 1.0)
local crFarmingDefault       = CColor.new(1.0, 1.0, 1.0, 1.0)


NavMate.db.modules.map = {
  group = {
    normalColor = CColor.new(1,1,1,1),
    pvpColor    = CColor.new(0,1,0,1),
    sprIcon     = "IconSprites:Icon_MapNode_Map_GroupMember",
  },
  mining = {
    show       = true,
    usePerNode = false,
    sprIcon    = strMiningDefaultIcon,
    color      = crMiningDefault,
    perNode = {
      IronNode				        = { show = true, sprIcon = strMiningDefaultIcon, color = crMiningDefault },
      TitaniumNode			      = { show = true, sprIcon = strMiningDefaultIcon, color = crMiningDefault },
      ZephyriteNode			      = { show = true, sprIcon = strMiningDefaultIcon, color = crMiningDefault },
      PlatinumNode			      = { show = true, sprIcon = strMiningDefaultIcon, color = crMiningDefault },
      HydrogemNode			      = { show = true, sprIcon = strMiningDefaultIcon, color = crMiningDefault },
      XenociteNode			      = { show = true, sprIcon = strMiningDefaultIcon, color = crMiningDefault },
      ShadeslateNode		      = { show = true, sprIcon = strMiningDefaultIcon, color = crMiningDefault },
      GalactiumNode			      = { show = true, sprIcon = strMiningDefaultIcon, color = crMiningDefault },
      NovaciteNode			      = { show = true, sprIcon = strMiningDefaultIcon, color = crMiningDefault },
    },
  },
  relic = {
    show       = true,
    usePerNode = false,
    sprIcon    = strRelicDefaultIcon,
    color      = crRelicDefault,
    perNode = {
      StandardRelicNode	      = { show = true, sprIcon = strRelicDefaultIcon, color = crRelicDefault }, 
      AcceleratedRelicNode	  = { show = true, sprIcon = strRelicDefaultIcon, color = crRelicDefault }, 
      AdvancedRelicNode		    = { show = true, sprIcon = strRelicDefaultIcon, color = crRelicDefault }, 
      DynamicRelicNode		    = { show = true, sprIcon = strRelicDefaultIcon, color = crRelicDefault }, 
      KineticRelicNode		    = { show = true, sprIcon = strRelicDefaultIcon, color = crRelicDefault }, 
    },
  },
  survival = {
    show       = true,
    usePerNode = false,
    sprIcon    = strSurvivalDefaultIcon,
    color      = crSurvivalDefault,
    perNode = {
      AlgorocTreeNode			    = { show = true, sprIcon = strSurvivalDefaultIcon, color = crSurvivalDefault },
      CelestionTreeNode		    = { show = true, sprIcon = strSurvivalDefaultIcon, color = crSurvivalDefault },
      DeraduneTreeNode		    = { show = true, sprIcon = strSurvivalDefaultIcon, color = crSurvivalDefault },
      EllevarTreeNode			    = { show = true, sprIcon = strSurvivalDefaultIcon, color = crSurvivalDefault },
      GalerasTreeNode			    = { show = true, sprIcon = strSurvivalDefaultIcon, color = crSurvivalDefault },
      AuroriaTreeNode			    = { show = true, sprIcon = strSurvivalDefaultIcon, color = crSurvivalDefault },
      WhitevaleTreeNode		    = { show = true, sprIcon = strSurvivalDefaultIcon, color = crSurvivalDefault },
      DreadmoorTreeNode		    = { show = true, sprIcon = strSurvivalDefaultIcon, color = crSurvivalDefault },
      FarsideTreeNode			    = { show = true, sprIcon = strSurvivalDefaultIcon, color = crSurvivalDefault },
      CoralusTreeNode			    = { show = true, sprIcon = strSurvivalDefaultIcon, color = crSurvivalDefault },
      MurkmireTreeNode		    = { show = true, sprIcon = strSurvivalDefaultIcon, color = crSurvivalDefault },
      WilderrunTreeNode		    = { show = true, sprIcon = strSurvivalDefaultIcon, color = crSurvivalDefault },
      MalgraveTreeNode		    = { show = true, sprIcon = strSurvivalDefaultIcon, color = crSurvivalDefault },
      HalonRingTreeNode		    = { show = true, sprIcon = strSurvivalDefaultIcon, color = crSurvivalDefault },
      GrimvaultTreeNode		    = { show = true, sprIcon = strSurvivalDefaultIcon, color = crSurvivalDefault },
    },
  },
  farming = {
    show       = true,
    usePerNode = false,
    sprIcon    = strFarmingDefaultIcon,
    color      = crFarmingDefault,
    perNode = {
      SpirovineNode			      = { show = true, sprIcon = strFarmingDefaultIcon, color = crFarmingDefault },
      BladeleafNode			      = { show = true, sprIcon = strFarmingDefaultIcon, color = crFarmingDefault },
      YellowbellNode			    = { show = true, sprIcon = strFarmingDefaultIcon, color = crFarmingDefault },
      PummelgranateNode		    = { show = true, sprIcon = strFarmingDefaultIcon, color = crFarmingDefault },
      SerpentlilyNode			    = { show = true, sprIcon = strFarmingDefaultIcon, color = crFarmingDefault },
      GoldleafNode			      = { show = true, sprIcon = strFarmingDefaultIcon, color = crFarmingDefault },
      HoneywheatNode			    = { show = true, sprIcon = strFarmingDefaultIcon, color = crFarmingDefault },
      CrowncornNode			      = { show = true, sprIcon = strFarmingDefaultIcon, color = crFarmingDefault },
      CoralscaleNode			    = { show = true, sprIcon = strFarmingDefaultIcon, color = crFarmingDefault },
      LogicleafNode			      = { show = true, sprIcon = strFarmingDefaultIcon, color = crFarmingDefault },
      StoutrootNode			      = { show = true, sprIcon = strFarmingDefaultIcon, color = crFarmingDefault },
      GlowmelonNode			      = { show = true, sprIcon = strFarmingDefaultIcon, color = crFarmingDefault },
      FaerybloomNode			    = { show = true, sprIcon = strFarmingDefaultIcon, color = crFarmingDefault },
      WitherwoodNode			    = { show = true, sprIcon = strFarmingDefaultIcon, color = crFarmingDefault },
      FlamefrondNode			    = { show = true, sprIcon = strFarmingDefaultIcon, color = crFarmingDefault },
      GrimgourdNode			      = { show = true, sprIcon = strFarmingDefaultIcon, color = crFarmingDefault },
      MourningstarNode		    = { show = true, sprIcon = strFarmingDefaultIcon, color = crFarmingDefault },
      BloodbriarNode			    = { show = true, sprIcon = strFarmingDefaultIcon, color = crFarmingDefault },
      OctopodNode				      = { show = true, sprIcon = strFarmingDefaultIcon, color = crFarmingDefault },
      HeartichokeNode			    = { show = true, sprIcon = strFarmingDefaultIcon, color = crFarmingDefault },
      SmlGrowthshroomNode		  = { show = true, sprIcon = strFarmingDefaultIcon, color = crFarmingDefault },
      MedGrowthshroomNode		  = { show = true, sprIcon = strFarmingDefaultIcon, color = crFarmingDefault },
      LrgGrowthshroomNode		  = { show = true, sprIcon = strFarmingDefaultIcon, color = crFarmingDefault },
      SmlHarvestshroomNode	  = { show = true, sprIcon = strFarmingDefaultIcon, color = crFarmingDefault },
      MedHarvestshroomNode	  = { show = true, sprIcon = strFarmingDefaultIcon, color = crFarmingDefault },
      LrgHarvestshroomNode	  = { show = true, sprIcon = strFarmingDefaultIcon, color = crFarmingDefault },
      SmlRenewshroomNode		  = { show = true, sprIcon = strFarmingDefaultIcon, color = crFarmingDefault },
      MedRenewshroomNode		  = { show = true, sprIcon = strFarmingDefaultIcon, color = crFarmingDefault },
      LrgRenewshroomNode		  = { show = true, sprIcon = strFarmingDefaultIcon, color = crFarmingDefault },
    },
  },
}

function NavMate:WriteToChat(str, bExcludePrefix)
  ChatSystemLib.PostOnChannel(ChatSystemLib.ChatChannel_Command, string.format("%s%s", bExcludePrefix and "" or "NavMate :: ", str))
end

NavMate:SetDefaultModulePrototype({ 
  bInitialized = false, 
  InitConfig = function(self) 
    NavMate.db.modules = NavMate.db.modules or {}
    NavMate.db.modules[self:GetName()] = NavMate.db.modules[self:GetName()] or {}; 
    self.config = NavMate.db.modules[self:GetName()] 
  end 
})


function NavMate:InitializeModules()
  for _, strModuleName in self:IterateModules() do
    local oModule = self:GetModule(strModuleName)
    if oModule and oModule.Initialize and not oModule.bInitialized then
      oModule:Initialize()
    end
  end
end
