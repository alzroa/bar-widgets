--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- 
--  Mex Counter
--  Displays the number of metal extractors (mexes) used, seen, and total on map
-- 
--  Author: C (BAR Widgets)
--  License: GNU GPL, v2 or later
-- 
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local widget = widget ---@type Widget

function widget:GetInfo()
	return {
		name      = "Mex Counter",
		desc      = "Displays number of meces used, seen and total on map",
		author    = "C",
		date      = "2026-03-18",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = true,
	}
end

-- Localized Spring API
local spGetAllUnits = Spring.GetAllUnits
local spGetUnitDefID = Spring.GetUnitDefID
local spGetUnitPosition = Spring.GetUnitPosition
local spGetMyTeamID = Spring.GetMyTeamID
local spGetUnitTeam = Spring.GetUnitTeam
local spGetUnitAllyTeam = Spring.GetUnitAllyTeam
local spGetAllyTeamList = Spring.GetAllyTeamList

-- Configuration
local cfg = {
	posX = 0.5,
	posY = 0.98,
}

-- Colors
local colors = {
	metal = {0.3, 0.8, 1, 1},
	ally = {0.3, 0.9, 0.4, 1},
	enemy = {0.9, 0.3, 0.3, 1},
	neutral = {0.6, 0.6, 0.6, 1},
	background = {0.1, 0.1, 0.15, 0.85},
}

-- Unit definitions
local MEX_DEF_IDS = {
	-- Arm mexes
	[UnitDefNames["armmex"].id] = true,
	[UnitDefNames["armmex_low"].id] = true,
	[UnitDefNames["armmex_uw"].id] = true,
	-- Cortex mexes
	[UnitDefNames["cormex"].id] = true,
	[UnitDefNames["cormex_low"].id] = true,
	[UnitDefNames["cormex_uw"].id] = true,
}

function widget:Initialize()
	self.lastUpdate = 0
end

function widget:Update()
	-- Update every second
	if not self.lastUpdate or (Spring.GetGameFrame() - self.lastUpdate) > 30 then
		self:CountMeces()
		self.lastUpdate = Spring.GetGameFrame()
	end
end

function widget:CountMeces()
	local myTeamID = spGetMyTeamID()
	local myAllyTeam = select(6, Spring.GetTeamInfo(myTeamID))
	
	local totalMeces = 0
	local allyMeces = 0
	local enemyMeces = 0
	local neutralMeces = 0
	
	-- Get all units
	local allUnits = spGetAllUnits()
	
	for _, unitID in ipairs(allUnits) do
		local defID = spGetUnitDefID(unitID)
		if defID and MEX_DEF_IDS[defID] then
			local unitTeam = spGetUnitTeam(unitID)
			local unitAlly = select(6, Spring.GetTeamInfo(unitTeam))
			
			totalMeces = totalMeces + 1
			
			if unitTeam == myTeamID or (unitTeam and Spring.AreTeamsAllied(myTeamID, unitTeam)) then
				allyMeces = allyMeces + 1
			elseif unitTeam and unitTeam ~= Spring.GetGaiaTeamID() then
				-- Check if visible
				local _, inLOS = Spring.GetUnitLosState(unitID, myAllyTeam)
				if inLOS and inLOS > 0 then
					enemyMeces = enemyMeces + 1
				end
			elseif unitTeam == Spring.GetGaiaTeamID() then
				neutralMeces = neutralMeces + 1
			end
		end
	end
	
	-- Get total metal spots on map
	local metalMap = spGetMetalMap()
	local totalSpots = 0
	if metalMap then
		-- Count metal spots (values > 0)
		for i = 1, #metalMap do
			if metalMap[i] and metalMap[i] > 0 then
				totalSpots = totalSpots + 1
			end
		end
	end
	
	-- Estimate map metal spots based on typical BAR maps if not available
	if totalSpots == 0 then
		totalSpots = totalMeces + neutralMeces + 5  -- Estimate
	end
	
	self.data = {
		total = totalMeces,
		ally = allyMeces,
		enemy = enemyMeces,
		neutral = neutralMeces,
		totalSpots = totalSpots,
		unclaimed = totalSpots - totalMeces,
	}
end

function widget:DrawScreen()
	if not self.data then self:CountMeces() end
	local d = self.data
	
	local x = cfg.posX
	local y = cfg.posY
	
	-- Background
	gl.Color(colors.background)
	gl.Rect(x - 100, y - 35, x + 100, y)
	
	-- Title
	gl.Color(colors.metal)
	gl.Text("Mex Counter", x - 90, y - 15, 14, "n")
	
	-- Counts
	gl.Color(colors.ally)
	gl.Text(string.format("Ally: %d", d.ally), x - 90, y - 28, 11, "n")
	
	gl.Color(colors.enemy)
	gl.Text(string.format("Enemy: %d", d.enemy), x - 10, y - 28, 11, "n")
	
	gl.Color(colors.neutral)
	gl.Text(string.format("Neutral: %d", d.neutral), x + 60, y - 28, 11, "n")
	
	-- Total spots info
	gl.Color({0.8, 0.8, 0.8, 1})
	gl.Text(string.format("Map: %d spots  (%d free)", d.totalSpots, d.unclaimed), x - 90, y - 42, 10, "n")
end