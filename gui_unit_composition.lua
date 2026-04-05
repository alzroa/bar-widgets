--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- 
--  Unit Composition
--  Displays the distribution of units by tier (T1, T2, T3) in the player's army
-- 
--  Author: C (BAR Widgets)
--  License: GNU GPL, v2 or later
-- 
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local widget = widget ---@type Widget

function widget:GetInfo()
	return {
		name      = "Unit Composition",
		desc      = "Displays army distribution by tier (T1, T2, T3)",
		author    = "alzroa",
		date      = "2026-04-05",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = true,
	}
end

-- Localized Spring API
local spGetUnits = Spring.GetUnits
local spGetMyTeamID = Spring.GetMyTeamID
local spGetUnitDefID = Spring.GetUnitDefID

-- Configuration
local cfg = {
	posX = 0.02,
	posY = 0.78, -- Positioned below Unit Counter
	width = 160,
	height = 60,
}

-- Colors
local colors = {
	text = {0.9, 0.9, 1, 1},
	background = {0.1, 0.1, 0.15, 0.85},
	t1 = {0.5, 0.8, 0.5, 1},
	t2 = {0.8, 0.8, 0.3, 1},
	t3 = {0.9, 0.4, 0.2, 1},
	accent = {0.3, 0.8, 1, 1},
}

function widget:Initialize()
	self.composition = {
		t1 = 0,
		t2 = 0,
		t3 = 0,
		other = 0,
		total = 0,
	}
end

function widget:Update()
	-- Update every 3 seconds to keep performance stable
	if not self.lastUpdate or (Spring.GetGameFrame() - self.lastUpdate) > 90 then
		self:CalculateComposition()
		self.lastUpdate = Spring.GetGameFrame()
	end
end

function widget:CalculateComposition()
	local teamID = spGetMyTeamID()
	local units = spGetUnits()
	local t1, t2, t3, other = 0, 0, 0, 0
	
	for i = 1, #units do
		if units[i].team == teamID then
			local defID = spGetUnitDefID(units[i].id)
			local defName = UnitDefNames[defID] or ""
			defName = defName:lower()
			
			-- Simple tier detection based on name patterns common in BAR
			if defName:find("_t1") or defName:find("t1_") or defName:find("basic") then
				t1 = t1 + 1
			elseif defName:find("_t2") or defName:find("t2_") or defName:find("advanced") then
				t2 = t2 + 1
			elseif defName:find("_t3") or defName:find("t3_") or defName:find("experimental") then
				t3 = t3 + 1
			else
				-- Fallback: check if it's a known tier-less unit or just 'other'
				other = other + 1
			end
		end
	end
	
	self.composition = {
		t1 = t1,
		t2 = t2,
		t3 = t3,
		other = other,
		total = t1 + t2 + t3 + other,
	}
end

function widget:DrawScreen()
	local x = cfg.posX
	local y = cfg.posY
	local w = cfg.width
	local h = cfg.height
	local c = self.composition
	
	-- Background panel
	gl.Color(colors.background)
	gl.Rect(x, y - h, x + w, y)
	
	-- Accent border
	gl.Color(colors.accent)
	gl.Rect(x, y - 2, x + w, y)
	
	-- Title
	gl.Color(colors.text)
	gl.Text("Unit Composition", x + 10, y - 12, 12, "n")
	
	-- Tier breakdown
	local startY = y - 24
	local stepY = 12
	
	local tiers = {
		{name = "T1", val = c.t1, col = colors.t1},
		{name = "T2", val = c.t2, col = colors.t2},
		{name = "T3", val = c.t3, col = colors.t3},
	}
	
	for i, tier in ipairs(tiers) do
		local perc = c.total > 0 and (tier.val / c.total) * 100 or 0
		gl.Color(tier.col)
		gl.Text(string.format("%s: %d (%.1f%%)", tier.name, tier.val, perc), x + 10, startY - (i-1)*stepY, 11, "n")
	end
	
	if c.other > 0 then
		gl.Color({0.7, 0.7, 0.7, 1})
		local perc = c.total > 0 and (c.other / c.total) * 100 or 0
		gl.Text(string.format("Other: %d (%.1f%%)", c.other, perc), x + 10, startY - 3*stepY, 11, "n")
	end
end

function widget:Shutdown()
	-- No cleanup needed
end
