--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- 
--  Wind Metal Converter Calculator
--  Shows optimal wind binds per metal converter for efficient metal conversion
-- 
--  Author: C (BAR Widgets)
--  License: GNU GPL, v2 or later
-- 
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local widget = widget ---@type Widget

function widget:GetInfo()
	return {
		name      = "Wind Metal Converter Calculator",
		desc      = "Shows optimal wind binds per metal converter based on wind",
		author    = "C",
		date      = "2026-03-18",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = true,
	}
end

-- Localized Spring API
local spGetWind = Spring.GetWind
local spGetMetalMap = Spring.GetMetalMap
local spGetTeamResources = Spring.GetTeamResources
local spGetTeamUsages = Spring.GetTeamUsages

-- Configuration
local cfg = {
	posX = 0.98,
	posY = 0.5,
	width = 220,
	height = 180,
}

-- Colors
local colors = {
	title = {1, 0.8, 0.2, 1},
	header = {0.9, 0.9, 0.9, 1},
	metal = {0.3, 0.8, 1, 1},
	energy = {1, 0.9, 0.3, 1},
	warning = {1, 0.4, 0.4, 1},
	normal = {0.8, 0.8, 0.8, 1},
	background = {0.1, 0.1, 0.15, 0.85},
}

-- Constants (BAR defaults)
local WIND_POWER_PER_TURBINE = 25.5  -- Energy per wind turbine
local METAL_CONVERTER_COST = 35       -- Energy cost per metal extractor
local METAL_OUTPUT = 1                -- Metal per mex per second

function widget:Update()
	-- Update every second (not every frame for performance)
	if not self.lastUpdate or (Spring.GetGameFrame() - self.lastUpdate) > 30 then
		self:Recalculate()
		self.lastUpdate = Spring.GetGameFrame()
	end
end

function widget:Recalculate()
	-- Get current wind
	local windX, windZ = spGetWind()
	local windSpeed = math.sqrt(windX * windX + windZ * windZ)
	local maxWind = 12.5  -- Max wind in BAR
	
	-- Get team resources
	local _, _, _, storageM, _, _, prodM, _, useM = spGetTeamResources(Spring.GetMyTeamID(), 'metal')
	local _, _, _, storageE, _, _, prodE, _, useE = spGetTeamResources(Spring.GetMyTeamID(), 'energy')
	
	-- Calculate energy surplus
	local energySurplus = prodE - useE
	
	-- Calculate how many wind turbines needed per mex
	local energyPerMex = METAL_CONVERTER_COST
	local windsPerMex = energyPerMex / WIND_POWER_PER_TURBINE
	
	-- Adjust for current wind (higher wind = more energy from each turbine)
	local currentWindFactor = windSpeed / maxWind
	if currentWindFactor < 0.2 then currentWindFactor = 0.2 end  -- Minimum efficiency
	local effectiveWindsPerMex = windsPerMex / currentWindFactor
	
	-- How many mexes can current/wind energy support?
	local potentialMexes = 0
	if energySurplus > 0 then
		potentialMexes = energySurplus / energyPerMex
	end
	
	self.data = {
		windSpeed = windSpeed,
		maxWind = maxWind,
		windPercent = (windSpeed / maxWind) * 100,
		storageM = storageM or 0,
		storageE = storageE or 0,
		prodM = prodM or 0,
		prodE = prodE or 0,
		useM = useM or 0,
		useE = useE or 0,
		energySurplus = energySurplus or 0,
		windsPerMex = effectiveWindsPerMex,
		potentialMexes = potentialMexes,
	}
end

function widget:DrawScreen()
	if not self.data then self:Recalculate() end
	local d = self.data
	
	local x = cfg.posX
	local y = cfg.posY
	
	-- Background
	gl.Color(colors.background)
	gl.Rect(x - cfg.width, y - cfg.height, x, y)
	
	-- Title
	gl.Color(colors.title)
	gl.Text("Wind/Mex Calculator", x - cfg.width + 10, y - 20, 14, "n")
	
	-- Wind info
	gl.Color(colors.energy)
	gl.Text(string.format("Wind: %.1f / %.1f (%.0f%%)", d.windSpeed, d.maxWind, d.windPercent), 
		x - cfg.width + 10, y - 40, 12, "n")
	
	-- Optimal ratio
	local optimalText = string.format("%.1f wind turbines per Mex", d.windsPerMex)
	
	-- Warning if low wind
	if d.windPercent < 30 then
		gl.Color(colors.warning)
		optimalText = optimalText .. " (LOW WIND!)"
	else
		gl.Color(colors.normal)
	end
	gl.Text(optimalText, x - cfg.width + 10, y - 58, 11, "n")
	
	-- Current energy status
	local surplusColor = d.energySurplus >= 0 and colors.energy or colors.warning
	gl.Color(surplusColor)
	gl.Text(string.format("Energy: %.1f/s (surplus)", d.energySurplus), 
		x - cfg.width + 10, y - 76, 11, "n")
	
	-- How many mexes can be supported
	gl.Color(colors.metal)
	if d.energySurplus > 0 then
		local maxMex = math.floor(d.energySurplus / METAL_CONVERTER_COST)
		gl.Text(string.format("Can support ~%d Mex(es)", maxMex), 
			x - cfg.width + 10, y - 94, 12, "n")
	else
		gl.Text("Not enough energy for Mex!", x - cfg.width + 10, y - 94, 12, "n")
	end
	
	-- Metal production
	gl.Color(colors.normal)
	gl.Text(string.format("Metal: %.1f/s prod, %.0f stored", d.prodM, d.storageM), 
		x - cfg.width + 10, y - 114, 10, "n")
		
	-- Storage info
	gl.Text(string.format("Energy: %.1f/s prod, %.0f stored", d.prodE, d.storageE), 
		x - cfg.width + 10, y - 128, 10, "n")
end

function widget:Initialize()
	self.data = nil
end