--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- 
--  Build Sequence Optimizer
--  Helps track and visualize build order sequences and queue efficiency
-- 
--  Author: C (BAR Widgets)
--  License: GNU GPL, v2 or later
-- 
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local widget = widget ---@type Widget

function widget:GetInfo()
	return {
		name      = "Build Sequence Optimizer",
		desc      = "Tracks and visualizes build order efficiency",
		author    = "alzroa",
		date      = "2026-03-30",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = true,
	}
end

-- Configuration
local cfg = {
	posX = 0.5,
	posY = 0.85,
}

-- Colors
local colors = {
	title = {0.8, 0.8, 0.2, 1},
	text = {1, 1, 1, 1},
	background = {0.1, 0.1, 0.1, 0.7},
}

function widget:Initialize()
	self.buildStats = {
		queueLength = 0,
		efficiency = 100,
	}
end

function widget:Update()
	-- Simple monitor for active build queues
	if Spring.GetGameFrame() % 30 == 0 then
		self:UpdateStats()
	end
end

function widget:UpdateStats()
	local myTeamID = Spring.GetMyTeamID()
	local units = Spring.GetTeamUnits(myTeamID)
	
	local factories = 0
	local queued = 0
	
	for _, unitID in ipairs(units) do
		local buildQueue = Spring.GetUnitBuildQueue(unitID)
		if buildQueue and #buildQueue > 0 then
			factories = factories + 1
			queued = queued + #buildQueue
		end
	end
	
	self.buildStats.factories = factories
	self.buildStats.queueLength = queued
	self.buildStats.efficiency = factories > 0 and (queued / factories) or 0
end

function widget:DrawScreen()
	local s = self.buildStats
	local x = cfg.posX
	local y = cfg.posY
	
	-- Background
	gl.Color(colors.background)
	gl.Rect(x - 80, y - 40, x + 80, y + 10)
	
	-- Display
	gl.Color(colors.title)
	gl.Text("Build Optimizer", x - 70, y, 12, "n")
	
	gl.Color(colors.text)
	gl.Text(string.format("Factories: %d", s.factories or 0), x - 70, y - 15, 10, "n")
	gl.Text(string.format("Total Queue: %d", s.queueLength or 0), x - 70, y - 25, 10, "n")
	gl.Text(string.format("Avg Q Length: %.1f", s.efficiency or 0), x - 70, y - 35, 10, "n")
end
