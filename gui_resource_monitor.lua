--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- 
--  Resource Monitor
--  Tracks metal/energy production, storage, and usage in real-time
--  Visualizes income, expenditure, and storage levels
-- 
--  Author: C (BAR Widgets)
--  License: GNU GPL, v2 or later
-- 
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local widget = widget ---@type Widget

function widget:GetInfo()
	return {
		name      = "Resource Monitor",
		desc      = "Tracks metal and energy production, storage and usage",
		author    = "alzroa",
		date      = "2026-03-18",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = true,
	}
end

-- Localized Spring API
local spGetTeamResources = Spring.GetTeamResources
local spGetTeamUsages = Spring.GetTeamUsages
local spGetMyTeamID = Spring.GetMyTeamID

-- Configuration
local cfg = {
	posX = 0.02,
	posY = 0.95,
	width = 200,
	height = 140,
	showHistory = true,
	historyLength = 60,  -- seconds of history
}

-- Colors
local colors = {
	metal = {0.3, 0.8, 1, 1},
	energy = {1, 0.9, 0.3, 1},
	income = {0.2, 0.9, 0.4, 1},
	expense = {0.9, 0.3, 0.3, 1},
	background = {0.1, 0.1, 0.15, 0.85},
	barBg = {0.2, 0.2, 0.25, 1},
	barFill = {0.5, 0.5, 0.6, 1},
}

-- History for graphs
local history = {
	metal = {},
	energy = {},
}

function widget:Initialize()
	self.historyTimer = 0
end

function widget:Update()
	-- Update every second
	if not self.lastUpdate or (Spring.GetGameFrame() - self.lastUpdate) > 30 then
		self:RecordResources()
		self.lastUpdate = Spring.GetGameFrame()
	end
end

function widget:RecordResources()
	local teamID = spGetMyTeamID()
	
	-- Get current metal
	local mCurrent, mStorage, _, mPull, mProd, mIncome, mExpense, mUsage = spGetTeamResources(teamID, 'metal')
	local eCurrent, eStorage, _, ePull, eProd, eIncome, eExpense, eUsage = spGetTeamResources(teamID, 'energy')
	
	local record = {
		mMetal = mCurrent or 0,
		mStorage = mStorage or 0,
		mIncome = mIncome or 0,
		mExpense = mExpense or 0,
		mUsage = mUsage or 0,
		eEnergy = eCurrent or 0,
		eStorage = eStorage or 0,
		eIncome = eIncome or 0,
		eExpense = eExpense or 0,
		eUsage = eUsage or 0,
	}
	
	-- Add to history
	table.insert(history.metal, record)
	table.insert(history.energy, record)
	
	-- Limit history length
	while #history.metal > cfg.historyLength do
		table.remove(history.metal, 1)
	end
	while #history.energy > cfg.historyLength do
		table.remove(history.energy, 1)
	end
	
	self.current = record
end

function widget:DrawScreen()
	if not self.current then self:RecordResources() end
	local d = self.current
	
	local x = cfg.posX
	local y = cfg.posY
	local w = cfg.width
	local h = cfg.height
	
	-- Background panel
	gl.Color(colors.background)
	gl.Rect(x, y - h, x + w, y)
	
	-- Title
	gl.Color(colors.metal)
	gl.Text("Resource Monitor", x + 10, y - 18, 14, "n")
	
	-- Metal section
	local yOff = y - 38
	gl.Color(colors.metal)
	gl.Text(string.format("Metal: %.0f", d.mMetal), x + 10, yOff, 12, "n")
	
	-- Metal storage bar
	local mPercent = math.min(d.mStorage / 2000, 1)  -- Assume 2000 max storage
	gl.Color(colors.barBg)
	gl.Rect(x + 10, yOff - 15, x + w - 10, yOff - 5)
	gl.Color(colors.metal)
	gl.Rect(x + 10, yOff - 15, x + 10 + (w - 20) * mPercent, yOff - 5)
	
	-- Metal income/expense
	local mNet = d.mIncome - d.mExpense
	local mColor = mNet >= 0 and colors.income or colors.expense
	gl.Color(mColor)
	gl.Text(string.format("+%.1f / -%.1f (%.1f/s)", d.mIncome, d.mExpense, mNet), x + 10, yOff - 28, 10, "n")
	
	-- Energy section
	yOff = yOff - 48
	gl.Color(colors.energy)
	gl.Text(string.format("Energy: %.0f", d.eEnergy), x + 10, yOff, 12, "n")
	
	-- Energy storage bar
	local ePercent = math.min(d.eStorage / 5000, 1)  -- Assume 5000 max storage
	gl.Color(colors.barBg)
	gl.Rect(x + 10, yOff - 15, x + w - 10, yOff - 5)
	gl.Color(colors.energy)
	gl.Rect(x + 10, yOff - 15, x + 10 + (w - 20) * ePercent, yOff - 5)
	
	-- Energy income/expense
	local eNet = d.eIncome - d.eExpense
	local eColor = eNet >= 0 and colors.income or colors.expense
	gl.Color(eColor)
	gl.Text(string.format("+%.1f / -%.1f (%.1f/s)", d.eIncome, d.eExpense, eNet), x + 10, yOff - 28, 10, "n")
	
	-- Usage breakdown
	yOff = yOff - 48
	gl.Color(colors.normal or {0.8, 0.8, 0.8, 1})
	gl.Text(string.format("Usage: M%.0f/s  E%.0f/s", d.mUsage, d.eUsage), x + 10, yOff, 10, "n")
end

function widget:Shutdown()
	-- Cleanup
	history.metal = {}
	history.energy = {}
end