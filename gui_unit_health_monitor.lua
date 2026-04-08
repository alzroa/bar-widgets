--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- 
--  Unit Health Monitor
--  Displays average health and critical warnings for selected units
-- 
--  Author: C (BAR Widgets)
--  License: GNU GPL, v2 or later
-- 
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local widget = widget ---@type Widget

function widget:GetInfo()
	return {
		name      = "Unit Health Monitor",
		desc      = "Displays average health and critical warnings for selected units",
		author    = "alzroa",
		date      = "2026-04-08",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = true,
	}
end

-- Localized Spring API
local spGetSelectedUnits = Spring.GetSelectedUnits
local spGetUnitHealth = Spring.GetUnitHealth
local spGetUnitMaxHealth = Spring.GetUnitMaxHealth

-- Configuration
local cfg = {
	posX = 0.02,
	posY = 0.65, -- Positioned below Unit Composition
	width = 160,
	height = 50,
	criticalThreshold = 0.25, -- 25% health is critical
}

-- Colors
local colors = {
	text = {0.9, 0.9, 1, 1},
	background = {0.1, 0.1, 0.15, 0.85},
	healthy = {0.3, 0.9, 0.3, 1},
	warning = {0.9, 0.7, 0.2, 1},
	critical = {0.9, 0.3, 0.3, 1},
	accent = {0.3, 0.8, 1, 1},
}

function widget:Initialize()
	self.avgHealth = 1.0
	self.count = 0
	self.criticalCount = 0
end

function widget:Update()
	-- Update every 10 frames for responsiveness during micro
	if not self.lastUpdate or (Spring.GetGameFrame() - self.lastUpdate) > 10 then
		self:CalculateHealth()
		self.lastUpdate = Spring.GetGameFrame()
	end
end

function widget:CalculateHealth()
	local selected = spGetSelectedUnits()
	if not selected or #selected == 0 then
		self.avgHealth = 1.0
		self.count = 0
		self.criticalCount = 0
		return
	end

	local totalHealthPerc = 0
	local criticalCount = 0
	local validUnits = 0

	for i = 1, #selected do
		local id = selected[i]
		local current = spGetUnitHealth(id)
		local max = spGetUnitMaxHealth(id)

		if current and max and max > 0 then
			local perc = current / max
			totalHealthPerc = totalHealthPerc + perc
			if perc < cfg.criticalThreshold then
				criticalCount = criticalCount + 1
			end
			validUnits = validUnits + 1
		end
	end

	if validUnits > 0 then
		self.avgHealth = totalHealthPerc / validUnits
		self.count = validUnits
		self.criticalCount = criticalCount
	else
		self.avgHealth = 1.0
		self.count = 0
		self.criticalCount = 0
	end
end

function widget:DrawScreen()
	if self.count == 0 then return end

	local x = cfg.posX
	local y = cfg.posY
	local w = cfg.width
	local h = cfg.height
	
	-- Background panel
	gl.Color(colors.background)
	gl.Rect(x, y - h, x + w, y)
	
	-- Accent border
	gl.Color(colors.accent)
	gl.Rect(x, y - 2, x + w, y)
	
	-- Title
	gl.Color(colors.text)
	gl.Text("Unit Health", x + 10, y - 12, 12, "n")
	
	-- Average Health Text
	local healthColor = colors.healthy
	if self.avgHealth < 0.5 then
		healthColor = colors.warning
	end
	if self.avgHealth < 0.3 then
		healthColor = colors.critical
	end
	
	gl.Color(healthColor)
	gl.Text(string.format("Avg: %.1f%% (%d units)", self.avgHealth * 100, self.count), x + 10, y - 24, 11, "n")
	
	-- Critical Warning
	if self.criticalCount > 0 then
		gl.Color(colors.critical)
		gl.Text(string.format("CRITICAL: %d units low!", self.criticalCount), x + 10, y - 36, 11, "b")
	end
end

function widget:Shutdown()
	-- No cleanup needed
end
