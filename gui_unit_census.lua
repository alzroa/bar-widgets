--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- 
--  Global Unit Census
--  Displays the total number of units owned by each team on the map
-- 
--  Author: C (BAR Widgets)
--  License: GNU GPL, v2 or later
-- 
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local widget = widget ---@type Widget

function widget:GetInfo()
	return {
		name      = "Global Unit Census",
		desc      = "Displays total unit counts for all players on the map",
		author    = "alzroa",
		date      = "2026-04-10",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = true,
	}
end

-- Localized Spring API
local spGetAllUnits = Spring.GetAllUnits
local spGetUnitTeam = Spring.GetUnitTeam
local spGetMyTeamID = Spring.GetMyTeamID
local spGetTeamInfo = Spring.GetTeamInfo

-- Configuration
local cfg = {
	posX = 0.98,
	posY = 0.02,
}

-- Colors
local colors = {
	text = {0.9, 0.9, 0.9, 1},
	myTeam = {0.3, 0.8, 1, 1},
	ally = {0.3, 0.9, 0.4, 1},
	enemy = {0.9, 0.3, 0.3, 1},
	neutral = {0.6, 0.6, 0.6, 1},
	background = {0.1, 0.1, 0.15, 0.85},
}

function widget:Initialize()
	self.lastUpdate = 0
end

function widget:Update()
	-- Update every 2 seconds to save performance
	if not self.lastUpdate or (Spring.GetGameFrame() - self.lastUpdate) > 60 then
		self:CensusUnits()
		self.lastUpdate = Spring.GetGameFrame()
	end
end

function widget:CensusUnits()
	local myTeamID = spGetMyTeamID()
	local counts = {}
	
	-- Get all units
	local allUnits = spGetAllUnits()
	
	for _, unitID in ipairs(allUnits) do
		local team = spGetUnitTeam(unitID)
		if team then
			counts[team] = (counts[team] or 0) + 1
		end
	end
	
	-- Sort teams by count descending
	local sortedTeams = {}
	for team, count in pairs(counts) do
		table.insert(sortedTeams, {team = team, count = count})
	end
	
	table.sort(sortedTeams, function(a, b) return a.count > b.count end)
	
	self.data = sortedTeams
end

function widget:DrawScreen()
	if not self.data then self:CensusUnits() end
	local teams = self.data
	
	local x = cfg.posX
	local y = cfg.posY
	
	-- Calculate panel height based on number of teams
	local rowHeight = 16
	local panelHeight = (#teams * rowHeight) + 20
	
	-- Background
	gl.Color(colors.background)
	gl.Rect(x - 120, y - panelHeight, x, y)
	
	-- Title
	gl.Color(colors.text)
	gl.Text("Unit Census", x - 110, y - 15, 14, "n")
	
	-- List teams
	for i, entry in ipairs(teams) do
		local teamID = entry.team
		local count = entry.count
		local teamInfo = spGetTeamInfo(teamID)
		local teamName = teamInfo and select(1, teamInfo) or "Unknown"
		
		-- Determine color
		local color = colors.text
		if teamID == spGetMyTeamID() then
			color = colors.myTeam
		elseif teamID == Spring.GetGaiaTeamID() then
			color = colors.neutral
		elseif Spring.AreTeamsAllied(spGetMyTeamID(), teamID) then
			color = colors.ally
		else
			color = colors.enemy
		end
		
		gl.Color(color)
		gl.Text(string.format("%s: %d", teamName, count), x - 110, y - 30 - (i * rowHeight), 11, "n")
	end
end
