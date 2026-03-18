--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- 
--  Geo Counter
--  Displays the number of geothermal generators (geos) used, seen, and total on map
-- 
--  Author: C (BAR Widgets)
--  License: GNU GPL, v2 or later
-- 
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local widget = widget ---@type Widget

function widget:GetInfo()
	return {
		name      = "Geo Counter",
		desc      = "Displays number of geos used, seen and total on map",
		author    = "alzroa",
		date      = "2026-03-18",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = true,
	}
end

-- Localized Spring API
local spGetAllUnits = Spring.GetAllUnits
local spGetUnitDefID = Spring.GetUnitDefID
local spGetMyTeamID = Spring.GetMyTeamID
local spGetUnitTeam = Spring.GetUnitTeam
local spGetFeatures = Spring.GetFeatures
local spGetFeatureDefID = Spring.GetFeatureDefID
local spGetGroundHeight = Spring.GetGroundHeight

-- Configuration
local cfg = {
	posX = 0.5,
	posY = 0.02,
}

-- Colors
local colors = {
	geo = {1, 0.5, 0.2, 1},
	ally = {0.3, 0.9, 0.4, 1},
	enemy = {0.9, 0.3, 0.3, 1},
	background = {0.1, 0.1, 0.15, 0.85},
}

-- Geo unit definitions (both factions)
local GEO_DEF_IDS = {
	-- Arm geos
	[UnitDefNames["armgeo"].id] = true,
	[UnitDefNames["armgeo_uw"].id] = true,
	-- Cortex geos
	[UnitDefNames["corgeo"].id] = true,
	[UnitDefNames["corgeo_uw"].id] = true,
}

-- Geo feature IDs (unbuilt/stranded geos)
local GEO_FEATURE_IDS = {
	[FeatureNames["GeoCore"].id] = true,
	[FeatureNames["GeoCoreSpaced"].id] = true,
}

function widget:Initialize()
	self.lastUpdate = 0
end

function widget:Update()
	-- Update every second
	if not self.lastUpdate or (Spring.GetGameFrame() - self.lastUpdate) > 30 then
		self:CountGeos()
		self.lastUpdate = Spring.GetGameFrame()
	end
end

function widget:CountGeos()
	local myTeamID = spGetMyTeamID()
	
	local totalGeos = 0
	local allyGeos = 0
	local enemyGeos = 0
	local unbuiltGeos = 0
	
	-- Count built geos
	local allUnits = spGetAllUnits()
	for _, unitID in ipairs(allUnits) do
		local defID = spGetUnitDefID(unitID)
		if defID and GEO_DEF_IDS[defID] then
			local unitTeam = spGetUnitTeam(unitID)
			totalGeos = totalGeos + 1
			
			if unitTeam == myTeamID or (unitTeam and Spring.AreTeamsAllied(myTeamID, unitTeam)) then
				allyGeos = allyGeos + 1
			elseif unitTeam and unitTeam ~= Spring.GetGaiaTeamID() then
				enemyGeos = enemyGeos + 1
			end
		end
	end
	
	-- Count unbuilt geo features (map features)
	local allFeatures = spGetFeatures()
	for _, featureID in ipairs(allFeatures) do
		local featureDefID = spGetFeatureDefID(featureID)
		if featureDefID and GEO_FEATURE_IDS[featureDefID] then
			unbuiltGeos = unbuiltGeos + 1
		end
	end
	
	-- Total potential geos on map
	local totalMapGeos = totalGeos + unbuiltGeos
	
	self.data = {
		total = totalGeos,
		ally = allyGeos,
		enemy = enemyGeos,
		unbuilt = unbuiltGeos,
		totalMap = totalMapGeos,
	}
end

function widget:DrawScreen()
	if not self.data then self:CountGeos() end
	local d = self.data
	
	local x = cfg.posX
	local y = cfg.posY
	
	-- Background
	gl.Color(colors.background)
	gl.Rect(x - 100, y, x + 100, y + 35)
	
	-- Title
	gl.Color(colors.geo)
	gl.Text("Geo Counter", x - 90, y + 22, 14, "n")
	
	-- Counts
	gl.Color(colors.ally)
	gl.Text(string.format("Ally: %d", d.ally), x - 90, y + 8, 11, "n")
	
	gl.Color(colors.enemy)
	gl.Text(string.format("Enemy: %d", d.enemy), x - 10, y + 8, 11, "n")
	
	-- Unbuilt
	gl.Color({0.6, 0.6, 0.6, 1})
	gl.Text(string.format("Unbuilt: %d", d.unbuilt), x + 55, y + 8, 11, "n")
	
	-- Total
	gl.Color({0.8, 0.8, 0.8, 1})
	gl.Text(string.format("Map: %d total", d.totalMap), x - 90, y - 6, 10, "n")
end