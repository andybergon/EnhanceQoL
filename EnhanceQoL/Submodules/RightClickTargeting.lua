local parentAddonName = "EnhanceQoL"
local addonName, addon = ...
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

local RCT = addon.RightClickTargeting or {}
addon.RightClickTargeting = RCT

-- Calling MouselookStop() inside the WorldFrame OnMouseUp handler cancels the
-- right-click targeting action without affecting camera rotation.
-- Technique borrowed from the "Right Click Modifier" addon by Zevade.
local lastStopTime = 0

local function stopClick()
	lastStopTime = GetTime()
	MouselookStop()
end

WorldFrame:HookScript("OnMouseUp", function(self, button)
	if button ~= "RightButton" then return end
	local db = addon.db
	if not db then return end

	local blockRightClick, blockDoubleClick
	if UnitAffectingCombat("player") then
		blockRightClick = db.disableRightClickTargetingInCombat
		blockDoubleClick = db.disableDoubleClickTargetingInCombat
	else
		blockRightClick = db.disableRightClickTargetingOutOfCombat
		blockDoubleClick = db.disableDoubleClickTargetingOutOfCombat
	end

	if not blockRightClick then return end

	if blockDoubleClick then
		stopClick()
	else
		local threshold = db.doubleClickTimeFrame or 0.2
		if lastStopTime + threshold < GetTime() then
			stopClick()
		end
	end
end)
