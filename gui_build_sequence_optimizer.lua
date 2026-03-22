--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- 
--  Build Sequence Optimizer
--  Displays an optimal build order checklist for the early game
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
		desc      = "Visualizes an optimal early game build sequence",
		author    = "C",
		date      = "2026-03-22",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = true,
	}
end

-- Configuration
local cfg = {
	posX = 0.5,
	posY = 0.7,
	width = 150,
	height = 200,
}

-- Basic Build Order (Example)
local buildOrder = {
	{name = "Energy", id = "arm_solar"},
	{name = "Metal Extractor", id = "arm_mex"},
	{name = "Energy", id = "arm_solar"},
	{name = "Barracks", id = "arm_lab"},
}

function widget:Initialize()
	self.completedCount = 0
end

function widget:Update()
	-- Simple logic: Check for completed units
	-- In a real app, this would track the actual build queue or unit completion
	-- For now, we simulate tracking by checking total units built
	local totalUnits = Spring.GetTeamUnitCount(Spring.GetMyTeamID())
	self.completedCount = math.min(totalUnits, #buildOrder)
end

function widget:DrawScreen()
	local x = cfg.posX
	local y = cfg.posY
	
	-- Background
	gl.Color(0.1, 0.1, 0.15, 0.85)
	gl.Rect(x - cfg.width/2, y - cfg.height, x + cfg.width/2, y)
	
	-- Title
	gl.Color(0.3, 0.8, 1, 1)
	gl.Text("Build Sequence", x - 60, y - 20, 14, "n")
	
	-- List
	for i, step in ipairs(buildOrder) do
		local color = (i <= self.completedCount) and {0.3, 0.9, 0.4, 1} or {0.8, 0.8, 0.8, 1}
		gl.Color(color)
		local status = (i <= self.completedCount) and "[X]" or "[ ]"
		gl.Text(status .. " " .. step.name, x - 60, y - 40 - (i * 20), 12, "n")
	end
end
