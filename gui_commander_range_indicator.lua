--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- 
--  Commander Range Indicator
--  Displays the attack range of the commander
-- 
--  Author: C (BAR Widgets)
--  License: GNU GPL, v2 or later
-- 
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local widget = widget ---@type Widget

function widget:GetInfo()
	return {
		name      = "Commander Range Indicator",
		desc      = "Shows commander attack range",
		author    = "alzroa",
		date      = "2026-03-30",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = true,
	}
end

function widget:DrawWorld()
	local myTeamID = Spring.GetMyTeamID()
	local units = Spring.GetTeamUnits(myTeamID)
	
	for _, unitID in ipairs(units) do
		local unitDefID = Spring.GetUnitDefID(unitID)
		local unitDef = UnitDefs[unitDefID]
		
		-- Simple check for commander (usually 'corcom' or 'armcom')
		if unitDef and (unitDef.name:find("com")) then
			local x, y, z = Spring.GetUnitPosition(unitID)
			local range = unitDef.maxWeaponRange or 300
			
			gl.Color(1, 0, 0, 0.3)
			gl.DrawGroundCircle(x, y, z, range, 32)
		end
	end
end
