--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- 
--  Unit Counter
--  Tracks the total number of active units in the player's army
-- 
--  Author: C (BAR Widgets)
--  License: GNU GPL, v2 or later
-- 
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local widget = widget ---@type Widget

function widget:GetInfo()
	return {
		name      = "Unit Counter",
		desc      = "Displays the total number of units in your army",
		author    = "alzroa",
		date      = "2026-04-03",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = true,
	}
end

-- Localized Spring API
local spGetUnits = Spring.GetUnits
local spGetMyTeamID = Spring.GetMyTeamID

-- Configuration
local cfg = {
	posX = 0.02,
	posY = 0.82, -- Positioned above Resource Monitor
	width = 150,
	height = 40,
}

-- Colors
local colors = {
	text = {0.9, 0.9, 1, 1},
	background = {0.1, 0.1, 0.15, 0.85},
	accent = {0.3, 0.8, 1, 1},
}

function widget:Initialize()
	self.unitCount = 0
end

function widget:Update()
	-- Update every 2 seconds to avoid performance hit
	if not self.lastUpdate or (Spring.GetGameFrame() - self.lastUpdate) > 60 then
		self:CountUnits()
		self.lastUpdate = Spring.GetGameFrame()
	end
end

function widget:CountUnits()
	local teamID = spGetMyTeamID()
	local units = spGetUnits()
	local count = 0
	
	for i = 1, #units do
		if units[i].team == teamID then
			count = count + 1
		end
	end
	
	self.unitCount = count
end

function widget:DrawScreen()
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
	
	-- Text
	gl.Color(colors.text)
	gl.Text(string.format("Army Size: %d", self.unitCount), x + 10, y - 22, 14, "n")
end

function widget:Shutdown()
	-- No cleanup needed
end
