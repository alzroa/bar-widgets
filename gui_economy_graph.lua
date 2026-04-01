--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- 
--  Economy Graph
--  Visualizes metal and energy income/expenditure over time
-- 
--  Author: C (BAR Widgets)
--  License: GNU GPL, v2 or later
-- 
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local widget = widget ---@type Widget

function widget:GetInfo()
	return {
		name      = "Economy Graph",
		desc      = "Visualizes resource trends over time",
		author    = "alzroa",
		date      = "2026-04-01",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = true,
	}
end

-- Configuration
local cfg = {
	posX = 0.8,
	posY = 0.2,
}

function widget:Initialize()
	self.history = { metal = {}, energy = {} }
end

function widget:Update()
	if Spring.GetGameFrame() % 90 == 0 then
		local _, metal, _, _, energy, _, _, _ = Spring.GetTeamResources(Spring.GetMyTeamID(), "income")
		table.insert(self.history.metal, metal)
		table.insert(self.history.energy, energy)
		
		if #self.history.metal > 20 then
			table.remove(self.history.metal, 1)
			table.remove(self.history.energy, 1)
		end
	end
end

function widget:DrawScreen()
	local x, y = cfg.posX, cfg.posY
	
	gl.Color(0.2, 0.2, 0.2, 0.5)
	gl.Rect(x - 50, y - 50, x + 50, y + 50)
	
	gl.Color(0.8, 0.8, 0.2, 1)
	gl.Text("Economy Graph", x - 40, y + 40, 10, "n")
end
