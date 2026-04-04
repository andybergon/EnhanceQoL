local parentAddonName = "EnhanceQoL"
local addonName, addon = ...

if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

local tsort = table.sort
local CreateFrame = CreateFrame
local C_Item_RequestLoadItemDataByID = C_Item and C_Item.RequestLoadItemDataByID

addon.WeaponBuffs = addon.WeaponBuffs or {}
addon.WeaponBuffs.functions = addon.WeaponBuffs.functions or {}
addon.WeaponBuffs.filteredWeaponBuffs = addon.WeaponBuffs.filteredWeaponBuffs or {}
addon.WeaponBuffs.bagItemCountCache = addon.WeaponBuffs.bagItemCountCache or {}

addon.WeaponBuffs.items = addon.WeaponBuffs.items
	or {
		{ key = "RefulgentWeightstone1", id = 237367 },
		{ key = "RefulgentWeightstone2", id = 237369 },
		{ key = "RefulgentWhetstone1", id = 237370 },
		{ key = "RefulgentWhetstone2", id = 237371 },
		{ key = "ThalassianPhoenixOil1", id = 243733 },
		{ key = "ThalassianPhoenixOil2", id = 243734 },
		{ key = "OilOfDawn1", id = 243735 },
		{ key = "OilOfDawn2", id = 243736 },
		{ key = "SmugglersEnchantedEdge1", id = 243737 },
		{ key = "SmugglersEnchantedEdge2", id = 243738 },
		{ key = "LacedZoomshots1", id = 257749 },
		{ key = "LacedZoomshots2", id = 257750 },
		{ key = "WeightedBoomshots1", id = 257751 },
		{ key = "WeightedBoomshots2", id = 257752 },
	}

local function requestItemNameData()
	if not C_Item_RequestLoadItemDataByID then return end
	local items = addon.WeaponBuffs.items or {}
	for i = 1, #items do
		local entry = items[i]
		if entry and entry.id then C_Item_RequestLoadItemDataByID(entry.id) end
	end
end

requestItemNameData()

local function rebuildBagItemCountCache()
	local counts = {}
	local maxBag = tonumber(NUM_TOTAL_EQUIPPED_BAG_SLOTS) or tonumber(NUM_BAG_SLOTS) or 4

	if C_Container and C_Container.GetContainerNumSlots and C_Container.GetContainerItemInfo then
		for bag = 0, maxBag do
			local slotCount = C_Container.GetContainerNumSlots(bag) or 0
			for slot = 1, slotCount do
				local info = C_Container.GetContainerItemInfo(bag, slot)
				local itemId = info and tonumber(info.itemID) or nil
				if itemId and itemId > 0 then counts[itemId] = (counts[itemId] or 0) + (tonumber(info.stackCount) or 1) end
			end
		end
	elseif GetContainerNumSlots and GetContainerItemID and GetContainerItemInfo then
		for bag = 0, maxBag do
			local slotCount = GetContainerNumSlots(bag) or 0
			for slot = 1, slotCount do
				local itemId = tonumber(GetContainerItemID(bag, slot))
				if itemId and itemId > 0 then
					local _, stackCount = GetContainerItemInfo(bag, slot)
					counts[itemId] = (counts[itemId] or 0) + (tonumber(stackCount) or 1)
				end
			end
		end
	end

	addon.WeaponBuffs.bagItemCountCache = counts
	return counts
end

local function getBagItemCount(itemId)
	local counts = addon.WeaponBuffs.bagItemCountCache
	if type(counts) ~= "table" then counts = rebuildBagItemCountCache() end
	return tonumber(counts[itemId]) or 0
end

function addon.WeaponBuffs.functions.getAvailableCandidates()
	local items = addon.WeaponBuffs.items or {}
	local available = addon.WeaponBuffs.filteredWeaponBuffs or {}

	for i = #available, 1, -1 do
		available[i] = nil
	end

	for i = 1, #items do
		local entry = items[i]
		local itemId = tonumber(entry and entry.id)
		if itemId and itemId > 0 then
			local count = getBagItemCount(itemId)
			if count > 0 then
				available[#available + 1] = {
					key = entry.key,
					id = itemId,
					count = count,
				}
			end
		end
	end

	tsort(available, function(a, b)
		local aCount = tonumber(a and a.count) or 0
		local bCount = tonumber(b and b.count) or 0
		if aCount ~= bCount then return aCount > bCount end
		return (tonumber(a and a.id) or 0) < (tonumber(b and b.id) or 0)
	end)

	addon.WeaponBuffs.filteredWeaponBuffs = available
	return available
end

local bagItemCountCacheFrame = addon.WeaponBuffs.bagItemCountCacheFrame or CreateFrame("Frame")
addon.WeaponBuffs.bagItemCountCacheFrame = bagItemCountCacheFrame
bagItemCountCacheFrame:RegisterEvent("PLAYER_LOGIN")
bagItemCountCacheFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
bagItemCountCacheFrame:RegisterEvent("BAG_UPDATE_DELAYED")
bagItemCountCacheFrame:SetScript("OnEvent", function(_, event)
	if event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" or event == "BAG_UPDATE_DELAYED" then
		rebuildBagItemCountCache()
		addon.WeaponBuffs.functions.getAvailableCandidates()
	end
end)
