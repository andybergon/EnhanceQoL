-- luacheck: globals BagsItemButton_OnLoad ItemButtonUtil ContainerFrameItemButtonMixin ScrollFrameTemplate_OnMouseWheel IsAnyStandardHeldBagOpen BackpackTokenFrame BagItemAutoSortButton ITEM_SEARCHBAR_LIST BagSearch_OnHide BagSearch_OnTextChanged BagSearch_OnChar UIPanelScrollFrame_OnLoad ClearItemButtonOverlay SetItemButtonQuality SetItemButtonCount SetItemButtonDesaturated ContainerFrame_AllowedToOpenBags C_Cursor COPPER_PER_GOLD COPPER_PER_SILVER NUM_BAG_SLOTS NUM_REAGENTBAG_SLOTS GetInventoryItemTexture GetInventoryItemID GetInventoryItemQuality GetInventorySlotInfo PickupBagFromSlot PutItemInBag CloseAllBags BAGS EQUIP_CONTAINER EQUIP_CONTAINER_REAGENT
local addonName, addon = ...
addon = addon or {}
_G[addonName] = addon

addon.Bags = addon.Bags or {}
addon.Bags.functions = addon.Bags.functions or {}
addon.Bags.variables = addon.Bags.variables or {}

local Bags = addon.Bags
local L = addon.L or {}
Bags.Core = Bags.Core or {}
local Core = Bags.Core

Core.BACKPACK_ID = Enum and Enum.BagIndex and Enum.BagIndex.Backpack or 0
Core.LAST_CHARACTER_BAG_ID = NUM_TOTAL_EQUIPPED_BAG_SLOTS or 5
Core.REAGENT_BAG_ID = Enum and Enum.BagIndex and Enum.BagIndex.ReagentBag or 5
Core.ITEM_CLASS = Enum and Enum.ItemClass or {}
Core.ITEM_QUALITY_POOR = Enum and Enum.ItemQuality and Enum.ItemQuality.Poor or 0

Core.BUTTON_SIZE = 37
Core.BUTTON_SPACING = 4
Core.COLUMN_COUNT = 10
Core.FRAME_PADDING = 10
Core.HEADER_HEIGHT = 34
Core.FOOTER_BASE_HEIGHT = 42
Core.FOOTER_ROW_HEIGHT = 18
Core.FOOTER_ROW_SPACING = 4
Core.FOOTER_SECTION_SPACING = 6
Core.FOOTER_DIVIDER_OFFSET = 6
Core.SECTION_HEADER_HEIGHT = 18
Core.GROUP_HEADER_HEIGHT = Core.SECTION_HEADER_HEIGHT
Core.GROUP_HEADER_GAP = 4
Core.SECTION_CONTENT_TOP_PADDING = 6
Core.SECTION_GAP = 10
Core.SECTION_HORIZONTAL_GAP = 8
Core.CLUSTER_GAP = 12
Core.MIN_FRAME_WIDTH = 240
Core.MIN_SCROLL_CONTENT_HEIGHT = 160
Core.MAX_FRAME_SCREEN_MARGIN = 120
Core.SCROLL_BAR_RESERVED_WIDTH = 22
Core.FOOTER_MONEY_RIGHT_PADDING = 6
Core.CATEGORY_ASSIGN_BUTTON_SIZE = 22
Core.MIN_SEARCH_BOX_WIDTH = 120
Core.BAG_SLOT_BUTTON_SIZE = 36
Core.BAG_SLOT_BUTTON_SPACING = 5
Core.MAX_WATCHED_CURRENCIES = 12
Core.MIN_ITEM_LEVEL_COLOR_QUALITY = Enum and Enum.ItemQuality and Enum.ItemQuality.Uncommon or 2
Core.SECTION_TOGGLE_LEFT_ATLAS = "Options_ListExpand_Left"
Core.SECTION_TOGGLE_COLLAPSED_ATLAS = "Options_ListExpand_Right"
Core.SECTION_TOGGLE_EXPANDED_ATLAS = "Options_ListExpand_Right_Expanded"
Core.SECTION_TOGGLE_LEFT_WIDTH = 4
Core.SECTION_TOGGLE_RIGHT_WIDTH = Core.SECTION_HEADER_HEIGHT
Core.SECTION_TOGGLE_WIDTH = Core.SECTION_TOGGLE_LEFT_WIDTH + Core.SECTION_TOGGLE_RIGHT_WIDTH
Core.REAGENT_SLOT_ICON_ATLAS = "bags-icon-reagents"
Core.GET_BAG_ITEM_TOOLTIP = C_TooltipInfo and C_TooltipInfo.GetBagItem
Core.ACTIVE_BAG_EVENTS = {
	"ITEM_LOCK_CHANGED",
	"BAG_UPDATE_COOLDOWN",
	"PLAYER_MONEY",
	"ACCOUNT_MONEY",
	"CURRENCY_DISPLAY_UPDATE",
	"ACCOUNT_CHARACTER_CURRENCY_DATA_RECEIVED",
	"INVENTORY_SEARCH_UPDATE",
	"MODIFIER_STATE_CHANGED",
	"PLAYER_LEVEL_UP",
}
Core.PASSIVE_BAG_EVENTS = {
	"BAG_UPDATE",
	"BAG_UPDATE_DELAYED",
	"BAG_NEW_ITEMS_UPDATED",
	"ITEM_DATA_LOAD_RESULT",
}
Core.ACTIVE_BAG_UNIT_EVENTS = {
	{
		name = "UNIT_INVENTORY_CHANGED",
		unit = "player",
	},
	{
		name = "PLAYER_SPECIALIZATION_CHANGED",
		unit = "player",
	},
}
Core.DEFAULT_FRAME_POINT = {
	point = "RIGHT",
	relativePoint = "RIGHT",
	x = -420,
	y = 0,
}

Core.FREE_SLOTS_SECTION_ID = "freeSlots"
Core.FREE_SLOTS_DEFINITION = {
	id = Core.FREE_SLOTS_SECTION_ID,
	labelKey = "categoryFreeSlots",
	color = { 0.9, 0.78, 0.28 },
}

Core.HEARTHSTONE_ITEM_IDS = {
	[6948] = true,
	[110560] = true,
	[140192] = true,
}

Core.IGNORED_ITEM_LEVEL_EQUIP_LOCS = {
	[""] = true,
	INVTYPE_BAG = true,
	INVTYPE_BODY = true,
	INVTYPE_NON_EQUIP_IGNORE = true,
	INVTYPE_QUIVER = true,
	INVTYPE_TABARD = true,
}

Core.EQUIP_LOCATION_COMPARISON_SLOTS = {
	INVTYPE_HEAD = { INVSLOT_HEAD or 1 },
	INVTYPE_NECK = { INVSLOT_NECK or 2 },
	INVTYPE_SHOULDER = { INVSLOT_SHOULDER or 3 },
	INVTYPE_CHEST = { INVSLOT_CHEST or 5 },
	INVTYPE_ROBE = { INVSLOT_CHEST or 5 },
	INVTYPE_WAIST = { INVSLOT_WAIST or 6 },
	INVTYPE_LEGS = { INVSLOT_LEGS or 7 },
	INVTYPE_FEET = { INVSLOT_FEET or 8 },
	INVTYPE_WRIST = { INVSLOT_WRIST or 9 },
	INVTYPE_HAND = { INVSLOT_HAND or 10 },
	INVTYPE_FINGER = { INVSLOT_FINGER1 or 11, INVSLOT_FINGER2 or 12 },
	INVTYPE_TRINKET = { INVSLOT_TRINKET1 or 13, INVSLOT_TRINKET2 or 14 },
	INVTYPE_CLOAK = { INVSLOT_BACK or 15 },
	INVTYPE_WEAPON = { INVSLOT_MAINHAND or 16, INVSLOT_OFFHAND or 17 },
	INVTYPE_SHIELD = { INVSLOT_OFFHAND or 17 },
	INVTYPE_2HWEAPON = { INVSLOT_MAINHAND or 16 },
	INVTYPE_WEAPONMAINHAND = { INVSLOT_MAINHAND or 16 },
	INVTYPE_WEAPONOFFHAND = { INVSLOT_OFFHAND or 17 },
	INVTYPE_HOLDABLE = { INVSLOT_OFFHAND or 17 },
	INVTYPE_RANGED = { INVSLOT_MAINHAND or 16 },
	INVTYPE_RANGEDRIGHT = { INVSLOT_MAINHAND or 16 },
}

local state = Bags.variables.state or {}
Bags.variables.state = state
state.buttons = state.buttons or {}
state.slotMappings = state.slotMappings or {}
state.sectionHeaders = state.sectionHeaders or {}
state.currencyButtons = state.currencyButtons or {}
state.itemRuleDataCache = state.itemRuleDataCache or {}
state.tooltipBindTypeCache = state.tooltipBindTypeCache or {}
state.slotCategoryCache = state.slotCategoryCache or {}
state.openSessionNewItems = state.openSessionNewItems or {}
state.forceDynamicRefresh = false
if state.playerRuleRevision == nil then
	state.playerRuleRevision = 0
end
if state.footerDirty == nil then
	state.footerDirty = true
end
if state.manualVisible == nil then
	state.manualVisible = false
end
if state.awaitingRuleItemData == nil then
	state.awaitingRuleItemData = false
end
state.pendingRuleItemDataIDs = state.pendingRuleItemDataIDs or {}
state.bagSlotPanels = state.bagSlotPanels or {}

local applyConfiguredOverlayAnchors
local applyConfiguredItemButtonFonts
local applyActiveSkin
local applyItemButtonSkinIfNeeded
local getCachedRuleItemInfo
local scheduleUpdate
local installVisibilityHooks
local installTokenWatcherHooks
local cachedOverlayRuntimeConfig
local updateReagentBagVisuals
local itemLevelEligibilityCache = {}
local BagSlotPanel = {}

function BagsItemButton_OnLoad(self)
	if not self or not self.ItemLevelText then
		return
	end

	if not self._bagsManagedPreClickHookInstalled and self.HookScript then
		self:HookScript("PreClick", function(button, mouseButton)
			if not addon.PreClickHandleCustomBankTransfer then
				return
			end

			local bagID = button.GetBagID and button:GetBagID() or nil
			local slotID = button.GetID and button:GetID() or nil
			addon.PreClickHandleCustomBankTransfer(mouseButton, bagID, slotID)
		end)
		self._bagsManagedPreClickHookInstalled = true
	end
	if not self._bagsVendorClickHookInstalled and self.HookScript then
		self:HookScript("OnClick", function(button, mouseButton)
			if addon.Vendor and addon.Vendor.functions and addon.Vendor.functions.HandleItemButtonClick then
				addon.Vendor.functions.HandleItemButtonClick(button, mouseButton)
			end
		end)
		self._bagsVendorClickHookInstalled = true
	end

	applyConfiguredItemButtonFonts(self)
	self.ItemLevelText:Hide()
	if self.ItemUpgradeText then
		self.ItemUpgradeText:Hide()
	end
	if self.ReagentTint then
		self.ReagentTint:Hide()
	end
	if applyItemButtonSkinIfNeeded then
		applyItemButtonSkinIfNeeded(self, nil, true)
	end
	if updateReagentBagVisuals then
		updateReagentBagVisuals(self)
	end
	if applyConfiguredOverlayAnchors then
		applyConfiguredOverlayAnchors(self)
	end
end

local function getSettings()
	if addon.GetSettings then
		return addon.GetSettings()
	end

	addon.DB = addon.DB or {}
	addon.DB.settings = addon.DB.settings or {}
	return addon.DB.settings
end

local function getVisibleFlatBankContexts()
	return {}
end

local function isNewItemAtSlot(bagID, slotID)
	return C_NewItems and C_NewItems.IsNewItem and C_NewItems.IsNewItem(bagID, slotID) or false
end

local function resetOpenSessionNewItems()
	if wipe then
		wipe(state.openSessionNewItems)
	else
		state.openSessionNewItems = {}
	end
end

local function getOpenSessionNewItemIdentity(bagID, slotID, info)
	if not (info and info.iconFileID) then
		return false
	end

	if ItemLocation and C_Item and C_Item.DoesItemExist and C_Item.GetItemGUID then
		local itemLocation = ItemLocation:CreateFromBagAndSlot(bagID, slotID)
		if itemLocation and C_Item.DoesItemExist(itemLocation) then
			local itemGUID = C_Item.GetItemGUID(itemLocation)
			if itemGUID then
				return itemGUID
			end
		end
	end

	return info.hyperlink or info.itemID or false
end

local function getOpenSessionNewItemsBucket(bagID, create)
	local bucket = state.openSessionNewItems[bagID]
	if not bucket and create then
		bucket = {}
		state.openSessionNewItems[bagID] = bucket
	end
	return bucket
end

local function isOpenSessionNewItem(bagID, slotID, info)
	local identity = getOpenSessionNewItemIdentity(bagID, slotID, info)
	local bucket = getOpenSessionNewItemsBucket(bagID, false)
	if not identity then
		if bucket then
			bucket[slotID] = nil
		end
		return false
	end

	local storedIdentity = bucket and bucket[slotID]
	if storedIdentity ~= nil then
		if storedIdentity == identity then
			return true
		end
		bucket[slotID] = nil
	end

	if isNewItemAtSlot(bagID, slotID) then
		getOpenSessionNewItemsBucket(bagID, true)[slotID] = identity
		return true
	end

	return false
end

local function getCollapsedSectionsTable()
	local settings = getSettings()
	settings.collapsedSections = settings.collapsedSections or {}
	return settings.collapsedSections
end

local function hasActiveSearchText()
	if not state.frame or not state.frame.SearchBox then
		return false
	end

	local searchText = state.frame.SearchBox:GetText()
	return searchText ~= nil and searchText ~= ""
end

local function isSectionCollapsed(sectionID)
	if not sectionID or hasActiveSearchText() then
		return false
	end

	return getCollapsedSectionsTable()[sectionID] == true
end

local function toggleSectionCollapsed(sectionID)
	if not sectionID then
		return
	end

	local collapsedSections = getCollapsedSectionsTable()
	if collapsedSections[sectionID] then
		collapsedSections[sectionID] = nil
	else
		collapsedSections[sectionID] = true
	end

	if scheduleUpdate then
		scheduleUpdate(true, true)
	end
end

local function isCategoryAssignModeActive()
	return IsAltKeyDown and IsAltKeyDown()
end

local function tryAssignCursorItemToSection(sectionID)
	local cursorType, itemID, itemLink = GetCursorInfo()
	if cursorType ~= "item" or not sectionID or not addon.AddCustomCategoryItemID then
		return false
	end

	local added = addon.AddCustomCategoryItemID(sectionID, itemLink or itemID)
	if added then
		ClearCursor()
	end

	return added
end

local function getOverlayElements()
	return addon.GetOverlayElements and addon.GetOverlayElements() or {}
end

local function applyConfiguredFont(fontString, size, elementID)
	if addon.ApplyConfiguredFont then
		addon.ApplyConfiguredFont(fontString, size, elementID)
	elseif fontString and fontString.SetFont then
		fontString:SetFont(STANDARD_TEXT_FONT, size or 12, "OUTLINE")
	end
end

local function getResolvedTextAppearance(elementID)
	if addon.GetResolvedTextAppearance then
		return addon.GetResolvedTextAppearance(elementID)
	end

	return {
		size = 12,
		fontPath = STANDARD_TEXT_FONT,
		outlineFlags = "OUTLINE",
		signature = "fallback",
	}
end

local function getDefaultItemContextMatchResult(button)
	if not button then
		if ItemButtonUtil and ItemButtonUtil.ItemContextMatchResult then
			return ItemButtonUtil.ItemContextMatchResult.DoesNotApply
		end

		return 3
	end

	if ContainerFrameItemButtonMixin and ContainerFrameItemButtonMixin.GetItemContextMatchResult then
		return ContainerFrameItemButtonMixin.GetItemContextMatchResult(button)
	end

	if ItemButtonUtil and ItemButtonUtil.ItemContextMatchResult then
		return ItemButtonUtil.ItemContextMatchResult.DoesNotApply
	end

	return 3
end

local function getCustomItemContextMatchResult(button)
	if not button then
		return getDefaultItemContextMatchResult()
	end

	local bagID = button.GetBagID and button:GetBagID() or nil
	local slotID = button.GetID and button:GetID() or nil
	if bagID == nil or slotID == nil then
		return getDefaultItemContextMatchResult(button)
	end

	local itemLocation = ItemLocation:CreateFromBagAndSlot(bagID, slotID)
	local customResult = addon.GetCustomBankItemContextMatchResult and addon.GetCustomBankItemContextMatchResult(itemLocation) or nil
	if customResult ~= nil then
		return customResult
	end

	return getDefaultItemContextMatchResult(button)
end

local function getOutsideHeaderPadding(settings)
	if addon.GetOutsideHeaderPadding then
		return addon.GetOutsideHeaderPadding()
	end

	local padding = math.floor((tonumber(settings and settings.outsideHeaderPadding) or 0) + 0.5)
	if padding < 0 then
		padding = 0
	elseif padding > 24 then
		padding = 24
	end

	return padding
end

local function getOutsideFooterPadding(settings)
	if addon.GetOutsideFooterPadding then
		return addon.GetOutsideFooterPadding()
	end

	local padding = math.floor((tonumber(settings and settings.outsideFooterPadding) or tonumber(settings and settings.outerPadding) or Core.FRAME_PADDING) + 0.5)
	if padding < 0 then
		padding = 0
	elseif padding > 24 then
		padding = 24
	end

	return padding
end

local function getInsideHorizontalPadding(settings)
	if addon.GetInsideHorizontalPadding then
		return addon.GetInsideHorizontalPadding()
	end

	local padding = math.floor((tonumber(settings and settings.insideHorizontalPadding) or tonumber(settings and settings.outerPadding) or Core.FRAME_PADDING) + 0.5)
	if padding < 0 then
		padding = 0
	elseif padding > 24 then
		padding = 24
	end

	return padding
end

local function getInsideTopPadding(settings)
	if addon.GetInsideTopPadding then
		return addon.GetInsideTopPadding()
	end

	local legacyPadding = (tonumber(settings and settings.outerPadding) or Core.FRAME_PADDING) + (tonumber(settings and settings.headerPadding) or 0)
	local padding = math.floor((tonumber(settings and settings.insideTopPadding) or legacyPadding) + 0.5)
	if padding < 0 then
		padding = 0
	elseif padding > 24 then
		padding = 24
	end

	return padding
end

local function getInsideBottomPadding(settings)
	if addon.GetInsideBottomPadding then
		return addon.GetInsideBottomPadding()
	end

	local padding = math.floor((tonumber(settings and settings.insideBottomPadding) or 0) + 0.5)
	if padding < 0 then
		padding = 0
	elseif padding > 24 then
		padding = 24
	end

	return padding
end

local function getMinimumFooterHeight(settings)
	local padding = getOutsideFooterPadding(settings)
	if settings and settings.showFooterSlotSummary == false then
		return Core.FOOTER_ROW_HEIGHT + Core.FOOTER_DIVIDER_OFFSET + (padding * 2)
	end
	return Core.FOOTER_BASE_HEIGHT + (padding * 2)
end

local function getFooterHeight(settings)
	return math.max(getMinimumFooterHeight(settings), tonumber(state.desiredFooterHeight) or 0)
end

local function getContentBottomGap(settings)
	return Core.FOOTER_DIVIDER_OFFSET + 6
end

local function getLayoutContentHeight(settings, rawContentHeight)
	return math.max(1, (tonumber(rawContentHeight) or 1) + getContentBottomGap(settings))
end

local function getItemScale(settings)
	if addon.GetItemScale then
		return addon.GetItemScale()
	end

	return math.floor((tonumber(settings and settings.itemScale) or 100) + 0.5)
end

local function getMaxColumns(settings)
	if addon.GetMaxColumns then
		return addon.GetMaxColumns()
	end

	local value = math.floor((tonumber(settings and settings.maxColumns) or Core.COLUMN_COUNT) + 0.5)
	if value < 4 then
		value = 4
	elseif value > 24 then
		value = 24
	end

	return value
end

local function getScreenMaxFrameWidth()
	local parentWidth = UIParent and UIParent:GetWidth() or nil
	local screenWidth = (parentWidth and parentWidth > 0) and parentWidth or 1440
	return math.max(Core.MIN_FRAME_WIDTH, math.floor(screenWidth - Core.MAX_FRAME_SCREEN_MARGIN))
end

local function getMinimumFrameWidth(settings)
	local insideHorizontalPadding = getInsideHorizontalPadding(settings)
	local titleWidth = 48
	local settingsButtonWidth = 18
	if state.frame and state.frame.Title and state.frame.Title.GetStringWidth then
		titleWidth = math.max(titleWidth, math.ceil((state.frame.Title:GetStringWidth() or 0) + 0.5))
	end
	if state.frame and state.frame.SettingsButton and state.frame.SettingsButton.GetWidth then
		settingsButtonWidth = math.max(settingsButtonWidth, math.ceil((state.frame.SettingsButton:GetWidth() or 0) + 0.5))
	end
	if state.frame and state.frame.CloseButton and state.frame.CloseButton.GetWidth and (addon.GetShowCloseButton == nil or addon.GetShowCloseButton()) then
		settingsButtonWidth = settingsButtonWidth + math.ceil((state.frame.CloseButton:GetWidth() or 0) + 4.5)
	end
	if state.frame and state.frame.BagSlotsButton and state.frame.BagSlotsButton.GetWidth then
		settingsButtonWidth = settingsButtonWidth + math.ceil((state.frame.BagSlotsButton:GetWidth() or 0) + 8.5)
	end

	local minimumWidth = math.max(
		Core.MIN_FRAME_WIDTH,
		(insideHorizontalPadding * 2) + titleWidth + 18 + Core.MIN_SEARCH_BOX_WIDTH + 10 + settingsButtonWidth
	)
	local minimumFooterContentWidth = tonumber(state.minimumFooterContentWidth) or 0
	if minimumFooterContentWidth > 0 then
		minimumWidth = math.max(minimumWidth, minimumFooterContentWidth + (Core.FRAME_PADDING * 2))
	end
	return minimumWidth
end

local function getButtonSize(settings)
	local scale = getItemScale(settings) / 100
	return math.max(24, math.floor((Core.BUTTON_SIZE * scale) + 0.5))
end

local function getButtonSpacing(settings)
	local scale = getItemScale(settings) / 100
	return math.max(2, math.floor((Core.BUTTON_SPACING * scale) + 0.5))
end

local function getFramePaddingSignature(settings)
	return string.format(
		"%d:%d:%d:%d:%d:%d:%d:%d:%d:%d",
		getOutsideHeaderPadding(settings),
		getOutsideFooterPadding(settings),
		getInsideHorizontalPadding(settings),
		getInsideTopPadding(settings),
		getInsideBottomPadding(settings),
		getItemScale(settings),
		getMaxColumns(settings),
		(addon.GetCompactCategoryLayout and addon.GetCompactCategoryLayout()) and 1 or 0,
		addon.GetCompactCategoryGap and addon.GetCompactCategoryGap() or Core.SECTION_HORIZONTAL_GAP,
		(addon.GetShowCloseButton and addon.GetShowCloseButton()) and 1 or 0
	)
end

local function applyFramePadding(settings)
	if not state.frame then
		return
	end

	local insideHorizontalPadding = getInsideHorizontalPadding(settings)
	local outsideHeaderPadding = getOutsideHeaderPadding(settings)
	local frame = state.frame

	if frame.Title then
		frame.Title:ClearAllPoints()
		frame.Title:SetPoint("TOPLEFT", frame, "TOPLEFT", insideHorizontalPadding, -10)
	end

	local showCloseButton = addon.GetShowCloseButton == nil or addon.GetShowCloseButton()
	if frame.CloseButton then
		frame.CloseButton:ClearAllPoints()
		frame.CloseButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -insideHorizontalPadding + 4, -4)
		frame.CloseButton:SetShown(showCloseButton)
	end

	if frame.SettingsButton then
		frame.SettingsButton:ClearAllPoints()
		if showCloseButton and frame.CloseButton then
			frame.SettingsButton:SetPoint("RIGHT", frame.CloseButton, "LEFT", -4, 0)
		else
			frame.SettingsButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -insideHorizontalPadding, -8)
		end
	end
	if frame.BagSlotsButton then
		frame.BagSlotsButton:ClearAllPoints()
		frame.BagSlotsButton:SetPoint("RIGHT", frame.SettingsButton or frame, frame.SettingsButton and "LEFT" or "RIGHT", frame.SettingsButton and -8 or -insideHorizontalPadding, frame.SettingsButton and 0 or -8)
	end
	if frame.SearchBox then
		frame.SearchBox:ClearAllPoints()
		frame.SearchBox:SetPoint("TOPLEFT", frame.Title, "TOPRIGHT", 18, 2)
		frame.SearchBox:SetPoint("TOPRIGHT", frame.BagSlotsButton or frame.SettingsButton, "TOPLEFT", -10, -1)
	end
	if frame.BagSlotsPanel then
		frame.BagSlotsPanel:ClearAllPoints()
		frame.BagSlotsPanel:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -insideHorizontalPadding, -(Core.HEADER_HEIGHT + outsideHeaderPadding))
	end

	if frame.Divider then
		frame.Divider:ClearAllPoints()
		frame.Divider:SetPoint("TOPLEFT", frame, "TOPLEFT", insideHorizontalPadding, -(Core.HEADER_HEIGHT + outsideHeaderPadding))
		frame.Divider:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -insideHorizontalPadding, -(Core.HEADER_HEIGHT + outsideHeaderPadding))
	end

	if frame.Footer then
		frame.Footer:ClearAllPoints()
		frame.Footer:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", insideHorizontalPadding, 0)
		frame.Footer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -insideHorizontalPadding, 0)
	end
end

local function unpackSkinColor(color, defaultR, defaultG, defaultB, defaultA)
	return color and color[1] or defaultR or 1,
		color and color[2] or defaultG or 1,
		color and color[3] or defaultB or 1,
		color and color[4] or defaultA or 1
end

local function getActiveFrameSkin()
	local definition = addon.GetActiveSkinDefinition and addon.GetActiveSkinDefinition() or nil
	return definition and definition.frame or nil
end

local function applySectionHeaderSkin(header, skin)
	if not header or not skin then
		return
	end

	if header.HighlightTexture then
		header.HighlightTexture:SetColorTexture(unpackSkinColor(skin.sectionHighlightColor, 1, 1, 1, 0.08))
	end

	if header.AssignButton and skin.assignButton then
		header.AssignButton:SetBackdropColor(unpackSkinColor(skin.assignButton.backdropColor, 0.08, 0.08, 0.10, 0.92))
		header.AssignButton:SetBackdropBorderColor(unpackSkinColor(skin.assignButton.borderColor, 0.78, 0.64, 0.18, 0.90))
		if header.AssignButton.Plus then
			header.AssignButton.Plus:SetTextColor(unpackSkinColor(skin.assignButton.plusColor, 1, 0.82, 0.00, 1))
		end
	end
end

applyActiveSkin = function()
	local skin = getActiveFrameSkin()
	if not skin then
		state.currentSkinSignature = addon.GetSkinSignature and addon.GetSkinSignature() or nil
		return
	end

	if state.frame then
		local frame = state.frame
		if addon.ApplyFrameBackgroundSkin then
			addon.ApplyFrameBackgroundSkin(frame, skin)
		else
			frame:SetBackdropColor(unpackSkinColor(skin.backdropColor, 0.05, 0.06, 0.08, 0.94))
		end
		frame:SetBackdropBorderColor(unpackSkinColor(skin.borderColor, 0.35, 0.35, 0.42, 1))

		if frame.Divider then
			frame.Divider:SetColorTexture(unpackSkinColor(skin.dividerColor, 1, 1, 1, 0.08))
		end
		if frame.FooterDivider then
			frame.FooterDivider:SetColorTexture(unpackSkinColor(skin.dividerColor, 1, 1, 1, 0.08))
		end
		if frame.Title then
			frame.Title:SetTextColor(unpackSkinColor(skin.titleColor, 1, 0.82, 0.00, 1))
		end
		if frame.SettingsButton and frame.SettingsButton.HighlightTexture then
			frame.SettingsButton.HighlightTexture:SetVertexColor(unpackSkinColor(skin.accentColor, 1, 1, 1, 1))
			frame.SettingsButton.HighlightTexture:SetAlpha(0.4)
		end
		if frame.BagSlotsButton and frame.BagSlotsButton.HighlightTexture then
			frame.BagSlotsButton.HighlightTexture:SetVertexColor(unpackSkinColor(skin.accentColor, 1, 1, 1, 1))
			frame.BagSlotsButton.HighlightTexture:SetAlpha(0.35)
		end
		if frame.BagSlotsPanel then
			frame.BagSlotsPanel:SetBackdropColor(unpackSkinColor(skin.backdropColor, 0.03, 0.03, 0.04, 0.96))
			frame.BagSlotsPanel:SetBackdropBorderColor(unpackSkinColor(skin.borderColor, 0.78, 0.64, 0.18, 0.85))
			BagSlotPanel.Refresh()
		end
		if frame.SearchBox and frame.SearchBox.Instructions then
			frame.SearchBox.Instructions:SetTextColor(unpackSkinColor(skin.accentColor, 0.78, 0.78, 0.78, 1))
		end
		if frame.Footer and frame.Footer.MoneyText then
			frame.Footer.MoneyText:SetTextColor(unpackSkinColor(skin.titleColor, 1, 1, 1, 1))
		end
	end

	for _, header in ipairs(state.sectionHeaders or {}) do
		applySectionHeaderSkin(header, skin)
	end

	for _, button in ipairs(state.currencyButtons or {}) do
		if button and button.Count then
			button.Count:SetTextColor(unpackSkinColor(skin.accentColor, 1, 1, 1, 1))
		end
	end

	for _, button in ipairs(state.buttons or {}) do
		if button then
			updateReagentBagVisuals(button)
		end
	end

	state.currentSkinSignature = addon.GetSkinSignature and addon.GetSkinSignature() or nil
end

local function getConfiguredBaseTextSize()
	local appearance = getResolvedTextAppearance()
	return tonumber(appearance and appearance.size) or 12
end

local function getTextAppearanceSignature(appearance)
	appearance = appearance or getResolvedTextAppearance()
	local baseSize = tonumber(appearance and appearance.size) or 12
	local overlaySize = tonumber(appearance and appearance.overlaySize) or baseSize
	return string.format(
		"%s:%s:%s:%s:%s:%s:%s",
		tostring(appearance and appearance.elementID or ""),
		tostring(appearance and appearance.fontPath or ""),
		tostring(baseSize),
		tostring(overlaySize),
		tostring(appearance and appearance.outline or ""),
		tostring(appearance and appearance.outlineFlags or ""),
		tostring(appearance and appearance.globalVersion or "")
	)
end

local function getItemButtonTextAppearanceSignature(appearance)
	local stackAppearance = getResolvedTextAppearance("stackCount")
	return getTextAppearanceSignature(appearance or getResolvedTextAppearance("overlays")) .. ":" .. getTextAppearanceSignature(stackAppearance)
end

local function getMaxFrameHeight()
	local parentHeight = UIParent and UIParent:GetHeight() or nil
	local screenHeight = (parentHeight and parentHeight > 0) and parentHeight or 900
	return math.max(320, math.floor(screenHeight - Core.MAX_FRAME_SCREEN_MARGIN))
end

local function updateScrollFrameLayout(contentWidth, contentHeight)
	if not state.frame or not state.scrollFrame or not state.content then
		return 1, 1
	end

	local settings = getSettings()
	local buttonSize = getButtonSize(settings)
	local buttonSpacing = getButtonSpacing(settings)
	local outsideHeaderPadding = getOutsideHeaderPadding(settings)
	local insideHorizontalPadding = getInsideHorizontalPadding(settings)
	local insideTopPadding = getInsideTopPadding(settings)
	local insideBottomPadding = getInsideBottomPadding(settings)
	local fixedHeight = Core.HEADER_HEIGHT + outsideHeaderPadding + insideTopPadding + insideBottomPadding + Core.FOOTER_DIVIDER_OFFSET + getFooterHeight(settings)
	local maxContentHeight = math.max(Core.MIN_SCROLL_CONTENT_HEIGHT, getMaxFrameHeight() - fixedHeight)
	local viewportHeight = math.max(1, math.min(contentHeight, maxContentHeight))
	local needsScroll = contentHeight > viewportHeight
	local reservedWidth = needsScroll and Core.SCROLL_BAR_RESERVED_WIDTH or 0
	local minimumFrameWidth = getMinimumFrameWidth(settings)
	local frameWidth = math.max(
		minimumFrameWidth,
		math.min(getScreenMaxFrameWidth(), contentWidth + (insideHorizontalPadding * 2) + reservedWidth)
	)
	local viewportWidth = math.max(1, frameWidth - (insideHorizontalPadding * 2) - reservedWidth)
	local resolvedContentWidth = math.max(contentWidth, viewportWidth)
	local resolvedContentHeight = math.max(1, contentHeight)
	local frameHeight = fixedHeight + viewportHeight
	local currentScroll = state.scrollFrame:GetVerticalScroll() or 0

	if state.scrollLayoutFrameWidth ~= frameWidth
		or state.scrollLayoutViewportWidth ~= viewportWidth
		or state.scrollLayoutViewportHeight ~= viewportHeight
		or state.scrollLayoutContentWidth ~= resolvedContentWidth
		or state.scrollLayoutContentHeight ~= resolvedContentHeight
		or state.scrollLayoutFrameHeight ~= frameHeight
	then
		state.scrollFrame:ClearAllPoints()
		state.scrollFrame:SetPoint("TOPLEFT", state.frame, "TOPLEFT", insideHorizontalPadding, -(Core.HEADER_HEIGHT + outsideHeaderPadding + insideTopPadding))
		state.scrollFrame:SetSize(viewportWidth, viewportHeight)
		state.content:SetSize(resolvedContentWidth, resolvedContentHeight)
		state.scrollFrame:UpdateScrollChildRect()
		state.frame:SetSize(frameWidth, frameHeight)
		state.scrollLayoutFrameWidth = frameWidth
		state.scrollLayoutViewportWidth = viewportWidth
		state.scrollLayoutViewportHeight = viewportHeight
		state.scrollLayoutContentWidth = resolvedContentWidth
		state.scrollLayoutContentHeight = resolvedContentHeight
		state.scrollLayoutFrameHeight = frameHeight
	end

	if state.scrollFrame.ScrollBar then
		state.scrollFrame.ScrollBar.scrollStep = buttonSize + buttonSpacing
	end

	local scrollRange = state.scrollFrame:GetVerticalScrollRange() or 0
	local clampedScroll = math.min(math.max(0, currentScroll), scrollRange)
	if state.scrollFrame.ScrollBar then
		state.scrollFrame.ScrollBar:SetValue(clampedScroll)
	end

	return frameWidth, viewportHeight
end

local function handleScrollWheel(delta)
	if state.scrollFrame then
		ScrollFrameTemplate_OnMouseWheel(state.scrollFrame, delta)
	end
end

applyConfiguredItemButtonFonts = function(button, appearance, signature)
	if not button then
		return
	end

	appearance = appearance or getResolvedTextAppearance("overlays")
	local stackAppearance = getResolvedTextAppearance("stackCount")
	local overlayBaseSize = tonumber(appearance and appearance.size) or 12
	local stackBaseSize = tonumber(stackAppearance and stackAppearance.size) or overlayBaseSize
	signature = signature or getItemButtonTextAppearanceSignature(appearance)
	if button._bagsFontSignature == signature then
		return
	end

	button._bagsFontSignature = signature
	if button.ItemLevelText then
		applyConfiguredFont(button.ItemLevelText, overlayBaseSize, "overlays")
		button.ItemLevelText:SetJustifyH("RIGHT")
	end
	if button.ItemUpgradeText then
		applyConfiguredFont(button.ItemUpgradeText, math.max(8, overlayBaseSize - 2), "overlays")
		button.ItemUpgradeText:SetJustifyH("RIGHT")
	end
	if button.Count then
		applyConfiguredFont(button.Count, stackBaseSize, "stackCount")
	end
end

local function getOverlayRuntimeConfig()
	if addon.GetOverlayRuntimeConfig then
		return addon.GetOverlayRuntimeConfig()
	end

	if not cachedOverlayRuntimeConfig then
		local runtime = {
			version = 0,
			entries = {},
			byID = {},
		}

		for _, definition in ipairs(getOverlayElements()) do
			local anchorID = addon.GetOverlayElementAnchor and addon.GetOverlayElementAnchor(definition.id) or definition.defaultAnchor
			local anchorInfo = addon.GetOverlayAnchorInfo and addon.GetOverlayAnchorInfo(anchorID)
			local entry = {
				id = definition.id,
				frameKey = definition.frameKey,
				enabled = addon.IsOverlayElementEnabled and addon.IsOverlayElementEnabled(definition.id) or definition.defaultEnabled ~= false,
				anchorInfo = anchorInfo,
			}
			runtime.entries[#runtime.entries + 1] = entry
			runtime.byID[definition.id] = entry
		end

		cachedOverlayRuntimeConfig = runtime
	end

	return cachedOverlayRuntimeConfig
end

local function applyConfiguredFrameFonts()
	if not state.frame then
		return
	end

	local appearance = getResolvedTextAppearance()
	local baseSize = tonumber(appearance and appearance.size) or 12
	if state.frame.Title then
		applyConfiguredFont(state.frame.Title, baseSize + 2)
	end
	if state.frame.SearchBox and state.frame.SearchBox.SetFont then
		applyConfiguredFont(state.frame.SearchBox, math.max(10, baseSize - 1))
		if state.frame.SearchBox.Instructions then
			applyConfiguredFont(state.frame.SearchBox.Instructions, math.max(10, baseSize - 1))
		end
	end

	if state.frame.Footer then
		if state.frame.Footer.NormalSlotsText then
			applyConfiguredFont(state.frame.Footer.NormalSlotsText, math.max(8, baseSize - 1))
		end
		if state.frame.Footer.ReagentSlotsText then
			applyConfiguredFont(state.frame.Footer.ReagentSlotsText, math.max(8, baseSize - 1))
		end
		if state.frame.Footer.MoneyText then
			applyConfiguredFont(state.frame.Footer.MoneyText, baseSize)
		end
	end

	for _, button in ipairs(state.currencyButtons or {}) do
		if button.Count then
			applyConfiguredFont(button.Count, math.max(8, baseSize - 2))
		end
	end

	for _, header in ipairs(state.sectionHeaders or {}) do
		if header.Text then
			applyConfiguredFont(header.Text, nil, header._bagsTextElementID or "subcategoryHeader")
		end
	end

	if applyActiveSkin then
		applyActiveSkin()
	end
end

applyConfiguredOverlayAnchors = function(button, overlayRuntime)
	if not button then
		return
	end

	overlayRuntime = overlayRuntime or getOverlayRuntimeConfig()
	local version = overlayRuntime and overlayRuntime.version or 0
	if button._bagsOverlayVersion == version then
		return
	end

	button._bagsOverlayVersion = version
	for _, entry in ipairs((overlayRuntime and overlayRuntime.entries) or {}) do
		local region = entry.frameKey and button[entry.frameKey]
		local anchorInfo = entry.anchorInfo
		if region and anchorInfo then
			region:ClearAllPoints()
			region:SetPoint(anchorInfo.point, button, anchorInfo.relativePoint, anchorInfo.x, anchorInfo.y)
			if region.SetJustifyH and anchorInfo.justifyH then
				region:SetJustifyH(anchorInfo.justifyH)
			end
			if region.SetJustifyV and anchorInfo.justifyV then
				region:SetJustifyV(anchorInfo.justifyV)
			end
		end
	end
end

local function getFrameDB()
	addon.DB = addon.DB or {}
	addon.DB.frame = addon.DB.frame or {}
	return addon.DB.frame
end

local function setManualVisibility(isVisible)
	local settings = getSettings()
	state.manualVisible = not not isVisible
	settings.manualVisible = state.manualVisible
end

local function isStandardBagID(bagID)
	return type(bagID) == "number" and bagID >= Core.BACKPACK_ID and bagID <= Core.LAST_CHARACTER_BAG_ID
end

local function isManagedBagUpdateID(bagID)
	if isStandardBagID(bagID) then
		return true
	end

	for _, context in ipairs(getVisibleFlatBankContexts()) do
		for _, contextBagID in ipairs(context.bagIDs or {}) do
			if bagID == contextBagID then
				return true
			end
		end
	end

	return false
end

local function isNativeStandardBagOpen()
	if type(_G.IsAnyStandardHeldBagOpen) == "function" and IsAnyStandardHeldBagOpen() then
		return true
	end

	if type(_G.IsBagOpen) == "function" then
		for bagID = Core.BACKPACK_ID, Core.LAST_CHARACTER_BAG_ID do
			if IsBagOpen(bagID) then
				return true
			end
		end
	end

	if ContainerFrameCombinedBags then
		if type(ContainerFrameCombinedBags.IsBagOpen) == "function" then
			for bagID = Core.BACKPACK_ID, Core.LAST_CHARACTER_BAG_ID do
				if ContainerFrameCombinedBags:IsBagOpen(bagID) then
					return true
				end
			end
		end

		if ContainerFrameCombinedBags:IsShown() then
			return true
		end
	end

	local frames = ContainerFrameContainer and ContainerFrameContainer.ContainerFrames or {}
	for _, frame in ipairs(frames) do
		if frame and frame:IsShown() and frame.GetBagID then
			local bagID = frame:GetBagID()
			if isStandardBagID(bagID) then
				return true
			end
		end
	end

	return false
end

local function shouldShowSimpleBags()
	return isNativeStandardBagOpen()
end

local function shouldShowBankManagedBags()
	return addon.AreAnyBankContextsViewable and addon.AreAnyBankContextsViewable() or false
end

local function shouldShowManagedContainerFrame()
	if shouldShowSimpleBags() then
		return true
	end

	if shouldShowBankManagedBags() then
		return true
	end

	return false
end

local function shouldProcessVisibleBagUpdates()
	if state.manualVisible then
		return true
	end

	if state.explicitToggleVisible then
		return true
	end

	if state.frame and state.frame:IsShown() then
		return true
	end

	return shouldShowManagedContainerFrame()
end

local function setActiveBagEventRegistration(enabled)
	if not state.eventFrame then
		return
	end

	enabled = not not enabled
	if state.activeBagEventsRegistered == enabled then
		return
	end

	state.activeBagEventsRegistered = enabled
	for _, eventName in ipairs(Core.ACTIVE_BAG_EVENTS) do
		if enabled then
			state.eventFrame:RegisterEvent(eventName)
		else
			state.eventFrame:UnregisterEvent(eventName)
		end
	end
	for _, entry in ipairs(Core.ACTIVE_BAG_UNIT_EVENTS) do
		if enabled then
			state.eventFrame:RegisterUnitEvent(entry.name, entry.unit)
		else
			state.eventFrame:UnregisterEvent(entry.name)
		end
	end
end

local function registerPassiveBagEvents()
	if not state.eventFrame or state.passiveBagEventsRegistered then
		return
	end

	state.passiveBagEventsRegistered = true
	for _, eventName in ipairs(Core.PASSIVE_BAG_EVENTS) do
		state.eventFrame:RegisterEvent(eventName)
	end
end

local function getAnchorTargetFrame()
	if ContainerFrameCombinedBags and ContainerFrameCombinedBags:IsShown() then
		return ContainerFrameCombinedBags
	end

	local frames = ContainerFrameContainer and ContainerFrameContainer.ContainerFrames or {}
	local fallbackFrame
	local bestFrame
	local bestLeft

	for _, frame in ipairs(frames) do
		if frame and frame:IsShown() and frame.GetBagID then
			local bagID = frame:GetBagID()
			if type(bagID) == "number" and bagID >= Core.BACKPACK_ID and bagID <= Core.LAST_CHARACTER_BAG_ID then
				fallbackFrame = fallbackFrame or frame
				local left = frame:GetLeft()
				if left and (not bestLeft or left < bestLeft) then
					bestLeft = left
					bestFrame = frame
				end
			end
		end
	end

	if bestFrame or fallbackFrame then
		return bestFrame or fallbackFrame
	end

	return nil
end

local function getTotalSlotCount()
	local total = 0
	for bagID = Core.BACKPACK_ID, Core.LAST_CHARACTER_BAG_ID do
		total = total + (C_Container.GetContainerNumSlots(bagID) or 0)
	end
	for _, context in ipairs(getVisibleFlatBankContexts()) do
		for _, bagID in ipairs(context.bagIDs or {}) do
			total = total + (C_Container.GetContainerNumSlots(bagID) or 0)
		end
	end
	return total
end

local function getManagedBagContentSignature(bagID)
	local parts = state.bagContentSignatureParts or {}
	state.bagContentSignatureParts = parts
	if wipe then
		wipe(parts)
	else
		parts = {}
		state.bagContentSignatureParts = parts
	end

	local slotCount = C_Container.GetContainerNumSlots(bagID) or 0
	parts[#parts + 1] = slotCount
	for slotID = 1, slotCount do
		local info = C_Container.GetContainerItemInfo(bagID, slotID)
		parts[#parts + 1] = "|"
		parts[#parts + 1] = slotID
		parts[#parts + 1] = ":"
		if info then
			local questInfo = C_Container.GetContainerItemQuestInfo and C_Container.GetContainerItemQuestInfo(bagID, slotID) or nil
			parts[#parts + 1] = info.hyperlink or ""
			parts[#parts + 1] = ":"
			parts[#parts + 1] = info.itemID or ""
			parts[#parts + 1] = ":"
			parts[#parts + 1] = info.stackCount or ""
			parts[#parts + 1] = ":"
			parts[#parts + 1] = info.quality or ""
			parts[#parts + 1] = ":"
			parts[#parts + 1] = info.isBound and 1 or 0
			parts[#parts + 1] = ":"
			parts[#parts + 1] = info.hasNoValue and 1 or 0
			parts[#parts + 1] = ":"
			parts[#parts + 1] = isNewItemAtSlot(bagID, slotID) and 1 or 0
			parts[#parts + 1] = ":"
			parts[#parts + 1] = questInfo and questInfo.questID or ""
			parts[#parts + 1] = ":"
			parts[#parts + 1] = questInfo and questInfo.isQuestItem and 1 or 0
			parts[#parts + 1] = ":"
			parts[#parts + 1] = questInfo and questInfo.isActive and 1 or 0
		end
	end

	local signature = table.concat(parts)
	if wipe then
		wipe(parts)
	end
	return signature
end

local function refreshManagedBagContentSignature(bagID)
	state.bagContentSignatures = state.bagContentSignatures or {}
	local signature = getManagedBagContentSignature(bagID)
	local previousSignature = state.bagContentSignatures[bagID]
	state.bagContentSignatures[bagID] = signature
	return previousSignature ~= nil and previousSignature ~= signature
end

local function refreshAllManagedBagContentSignatures()
	state.bagContentSignatures = state.bagContentSignatures or {}
	for bagID = Core.BACKPACK_ID, Core.LAST_CHARACTER_BAG_ID do
		state.bagContentSignatures[bagID] = getManagedBagContentSignature(bagID)
	end
	for _, context in ipairs(getVisibleFlatBankContexts()) do
		for _, bagID in ipairs(context.bagIDs or {}) do
			state.bagContentSignatures[bagID] = getManagedBagContentSignature(bagID)
		end
	end
end

local function saveFramePosition(frame)
	local point, _, relativePoint, x, y = frame:GetPoint(1)
	if not point or not relativePoint then
		return
	end

	local frameDB = getFrameDB()
	frameDB.point = point
	frameDB.relativePoint = relativePoint
	frameDB.x = x
	frameDB.y = y
	frameDB.userPlaced = true
	state.userMoved = true
end

local function applySavedFramePosition(frame)
	local frameDB = getFrameDB()
	if not frameDB.userPlaced then
		return false
	end

	frame:ClearAllPoints()
	frame:SetPoint(
		frameDB.point or Core.DEFAULT_FRAME_POINT.point,
		UIParent,
		frameDB.relativePoint or Core.DEFAULT_FRAME_POINT.relativePoint,
		frameDB.x or Core.DEFAULT_FRAME_POINT.x,
		frameDB.y or Core.DEFAULT_FRAME_POINT.y
	)
	state.userMoved = true
	return true
end

local function setHeaderTextLayout(header)
	if not header or not header.Text or not header.Icon then
		return
	end

	header.Text:ClearAllPoints()
	if header.Icon:IsShown() then
		header.Text:SetPoint("LEFT", header.Icon, "RIGHT", 6, 0)
	else
		header.Text:SetPoint("LEFT", header, "LEFT", 0, 0)
	end
	if header.AssignButton and header.AssignButton:IsShown() then
		header.Text:SetPoint("RIGHT", header.AssignButton, "LEFT", -6, 0)
	else
		header.Text:SetPoint("RIGHT", header, "RIGHT", 0, 0)
	end
end

local function configureSectionHeader(header, options)
	if not header or not options then
		return
	end

	local isCollapsed = not not options.collapsed
	local isCollapsible = options.collapsible ~= false
	local color = options.color or { 1, 1, 1 }
	local showAssignButton = options.isCustom and isCategoryAssignModeActive()

	header:SetHeight(Core.SECTION_HEADER_HEIGHT)
	header.sectionID = options.collapseID or options.sectionID
	header.categoryID = options.sectionID
	header.categoryLabel = options.label or ""
	header.categoryColor = color
	header.isCustomCategory = not not options.isCustom
	header.canCollapse = isCollapsible
	header._bagsTextElementID = options.textElementID or "subcategoryHeader"
	if isCollapsible then
		header.Icon.Left:SetAtlas(Core.SECTION_TOGGLE_LEFT_ATLAS, false)
		header.Icon.Right:SetAtlas(isCollapsed and Core.SECTION_TOGGLE_COLLAPSED_ATLAS or Core.SECTION_TOGGLE_EXPANDED_ATLAS, false)
		header.Icon.Left:SetSize(Core.SECTION_TOGGLE_LEFT_WIDTH, Core.SECTION_HEADER_HEIGHT)
		header.Icon.Right:SetSize(Core.SECTION_TOGGLE_RIGHT_WIDTH, Core.SECTION_HEADER_HEIGHT)
		header.Icon.Left:SetVertexColor(color[1] or 1, color[2] or 1, color[3] or 1, 1)
		header.Icon.Right:SetVertexColor(color[1] or 1, color[2] or 1, color[3] or 1, 1)
		header.Icon:Show()
	else
		header.Icon:Hide()
	end
	if header.HighlightTexture then
		header.HighlightTexture:SetShown(isCollapsible)
	end
	header.Text:SetText(addon.FormatTextElement and addon.FormatTextElement(header._bagsTextElementID, options.label or "") or options.label or "")
	header.Text:SetTextColor(color[1] or 1, color[2] or 1, color[3] or 1)
	applyConfiguredFont(header.Text, nil, header._bagsTextElementID)

	if header.AssignButton then
		header.AssignButton.sectionID = options.sectionID
		header.AssignButton.categoryLabel = options.label
		header.AssignButton:SetShown(showAssignButton)
	end

	applySectionHeaderSkin(header, getActiveFrameSkin())
	setHeaderTextLayout(header)
end

local function acquireSectionHeader(index)
	local header = state.sectionHeaders[index]
	if header then
		return header
	end

	header = CreateFrame("Button", nil, state.content)
	header:SetHeight(Core.SECTION_HEADER_HEIGHT)
	header:RegisterForClicks("LeftButtonUp")
	header:EnableMouseWheel(true)
	header:SetScript("OnMouseWheel", function(_, delta)
		handleScrollWheel(delta)
	end)

	local highlight = header:CreateTexture(nil, "HIGHLIGHT")
	highlight:SetPoint("TOPLEFT", header, "TOPLEFT", -2, 0)
	highlight:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", 4, 0)
	highlight:SetColorTexture(1, 1, 1, 0.08)
	header.HighlightTexture = highlight

	local icon = CreateFrame("Frame", nil, header)
	icon:SetSize(Core.SECTION_TOGGLE_WIDTH, Core.SECTION_HEADER_HEIGHT)
	icon:SetPoint("LEFT", header, "LEFT", 0, 0)
	header.Icon = icon
	icon.Left = icon:CreateTexture(nil, "ARTWORK")
	icon.Left:SetPoint("LEFT", icon, "LEFT", 0, 0)
	icon.Right = icon:CreateTexture(nil, "ARTWORK")
	icon.Right:SetPoint("LEFT", icon.Left, "RIGHT", 0, 0)

	local text = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	text:SetPoint("LEFT", icon, "RIGHT", 6, 0)
	text:SetPoint("RIGHT", header, "RIGHT", 0, 0)
	text:SetJustifyH("LEFT")
	text:SetWordWrap(false)
	header.Text = text

	local assignButton = CreateFrame("Button", nil, header, "BackdropTemplate")
	assignButton:SetSize(Core.CATEGORY_ASSIGN_BUTTON_SIZE, Core.CATEGORY_ASSIGN_BUTTON_SIZE)
	assignButton:SetPoint("RIGHT", header, "RIGHT", 0, 0)
	assignButton:RegisterForClicks("LeftButtonUp")
	assignButton:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8x8",
		edgeFile = "Interface\\Buttons\\WHITE8x8",
		edgeSize = 1,
	})
	assignButton:SetBackdropColor(0.08, 0.08, 0.1, 0.92)
	assignButton:SetBackdropBorderColor(0.78, 0.64, 0.18, 0.9)
	assignButton:Hide()

	local assignPlus = assignButton:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
	assignPlus:SetPoint("CENTER", assignButton, "CENTER", 0, -1)
	assignPlus:SetText("+")
	assignButton.Plus = assignPlus

	assignButton:SetScript("OnMouseUp", function(self)
		if self.sectionID and tryAssignCursorItemToSection(self.sectionID) then
			scheduleUpdate(true, true)
		end
	end)
	assignButton:SetScript("OnReceiveDrag", function(self)
		if self.sectionID and tryAssignCursorItemToSection(self.sectionID) then
			scheduleUpdate(true, true)
		end
	end)
	assignButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:SetText(L["bagAssignToCategoryTooltipTitle"] or "Assign item", 1, 0.82, 0)
		GameTooltip:AddLine(
			string.format(
				L["bagAssignToCategoryTooltipText"] or "Hold Alt and drag an item here to pin it to %s.",
				self.categoryLabel or (L["settingsCategoryCustomDefaultName"] or "this category")
			),
			nil,
			nil,
			nil,
			true
		)
		GameTooltip:Show()
	end)
	assignButton:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	header.AssignButton = assignButton

	header:SetScript("OnClick", function(self)
		if self.canCollapse then
			toggleSectionCollapsed(self.sectionID)
		end
	end)
	header:SetScript("OnEnter", function(self)
		if not self.categoryLabel or self.categoryLabel == "" then
			return
		end

		local color = self.categoryColor or { 1, 1, 1 }
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:SetText(self.categoryLabel, color[1] or 1, color[2] or 1, color[3] or 1)
		GameTooltip:Show()
	end)
	header:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	applyConfiguredFrameFonts()
	applySectionHeaderSkin(header, getActiveFrameSkin())
	state.sectionHeaders[index] = header
	return header
end

local function formatTrackedCurrencyQuantity(quantity)
	return BreakUpLargeNumbers(tonumber(quantity) or 0)
end

local function formatFooterCurrencyQuantity(quantity)
	local formattedQuantity = BreakUpLargeNumbers(tonumber(quantity) or 0)
	if strlenutf8 and strlenutf8(formattedQuantity) > 5 then
		formattedQuantity = AbbreviateNumbers(tonumber(quantity) or 0)
	end
	return formattedQuantity
end

local function getTrackedCurrencyCharacterColor(classToken)
	local classColors = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
	return classColors and classToken and classColors[classToken] or nil
end

local function getTrackedCurrencyCharacterDisplayName(entry)
	local name = entry and (entry.characterName or UNKNOWN) or UNKNOWN
	if entry and entry.isCurrent then
		name = string.format("%s (%s)", name, L["settingsTrackedCharacterCurrent"] or "Current")
	end
	return name
end

local function getConfiguredTrackedCurrencyTooltipColor(mode, classToken)
	if mode == "class" then
		local classColor = getTrackedCurrencyCharacterColor(classToken)
		if classColor then
			return classColor.r or 1, classColor.g or 1, classColor.b or 1
		end
	end

	return 1, 1, 1
end

local function addTrackedCurrencyTooltipTotalLine(tooltip, totalQuantity)
	tooltip:AddDoubleLine(
		string.format("%s:", TOTAL or "Total"),
		formatTrackedCurrencyQuantity(totalQuantity),
		1,
		0.82,
		0,
		1,
		1,
		1
	)
end

local function appendFooterCurrencyTooltipCharacterBreakdown(tooltip, currencyID)
	if not tooltip or not currencyID or not addon.GetTrackedCurrencyCharacterEntries then
		return
	end

	local entries, isReady, isSupported = addon.GetTrackedCurrencyCharacterEntries(currencyID)
	if not isSupported then
		return
	end

	if not isReady then
		tooltip:AddLine(" ")
		tooltip:AddLine(L["currencyTooltipTrackedCharactersTitle"] or "Warband characters", 1, 0.82, 0)
		tooltip:AddLine(L["currencyTooltipTrackedCharactersLoading"] or "Loading warband character currency data...", nil, nil, nil, true)
		return
	end

	if #entries == 0 then
		return
	end

	local totalQuantity = 0
	for _, entry in ipairs(entries) do
		totalQuantity = totalQuantity + (tonumber(entry.quantity) or 0)
	end

	local totalPosition = addon.GetTrackedCurrencyTooltipTotalPosition and addon.GetTrackedCurrencyTooltipTotalPosition() or "top"
	local nameColorMode = addon.GetTrackedCurrencyTooltipNameColorMode and addon.GetTrackedCurrencyTooltipNameColorMode() or "default"
	local countColorMode = addon.GetTrackedCurrencyTooltipCountColorMode and addon.GetTrackedCurrencyTooltipCountColorMode() or "default"

	tooltip:AddLine(" ")
	tooltip:AddLine(L["currencyTooltipTrackedCharactersTitle"] or "Warband characters", 1, 0.82, 0)
	if totalPosition == "top" then
		addTrackedCurrencyTooltipTotalLine(tooltip, totalQuantity)
		tooltip:AddLine(" ")
	end

	for _, entry in ipairs(entries) do
		local leftR, leftG, leftB = getConfiguredTrackedCurrencyTooltipColor(nameColorMode, entry.class)
		local rightR, rightG, rightB = getConfiguredTrackedCurrencyTooltipColor(countColorMode, entry.class)
		tooltip:AddDoubleLine(
			getTrackedCurrencyCharacterDisplayName(entry),
			formatTrackedCurrencyQuantity(entry.quantity),
			leftR,
			leftG,
			leftB,
			rightR,
			rightG,
			rightB
		)
	end

	if totalPosition == "bottom" then
		tooltip:AddLine(" ")
		addTrackedCurrencyTooltipTotalLine(tooltip, totalQuantity)
	end
end

local function showFooterCurrencyTooltip(owner)
	if not owner or not owner.currencyID then
		return
	end

	if addon.RequestTrackedCurrencyCharacterData then
		addon.RequestTrackedCurrencyCharacterData(false)
	end

	GameTooltip:SetOwner(owner, "ANCHOR_TOP")
	GameTooltip:SetCurrencyByID(owner.currencyID)
	appendFooterCurrencyTooltipCharacterBreakdown(GameTooltip, owner.currencyID)
	GameTooltip:Show()
end

local function refreshVisibleFooterCurrencyTooltip()
	local tooltipOwner = GameTooltip and GameTooltip.GetOwner and GameTooltip:GetOwner() or nil
	if not tooltipOwner or not tooltipOwner.isFooterCurrencyButton or not tooltipOwner.currencyID then
		return
	end

	showFooterCurrencyTooltip(tooltipOwner)
end

local function acquireCurrencyButton(index)
	local button = state.currencyButtons[index]
	if button then
		return button
	end

	button = CreateFrame("Button", nil, state.frame.Footer.CurrencyContainer)
	button:SetHeight(18)
	button.Icon = button:CreateTexture(nil, "ARTWORK")
	button.Icon:SetSize(16, 16)
	button.Icon:SetPoint("LEFT", button, "LEFT", 0, 0)

	button.Count = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	button.Count:SetPoint("LEFT", button.Icon, "RIGHT", 4, 0)
	button.Count:SetJustifyH("LEFT")

	button:SetScript("OnEnter", function(self)
		showFooterCurrencyTooltip(self)
	end)
	button:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	button.isFooterCurrencyButton = true

	state.currencyButtons[index] = button
	applyConfiguredFrameFonts()
	if applyActiveSkin then
		applyActiveSkin()
	end
	return button
end

local function formatFooterMoneyString(amount)
	amount = math.max(0, tonumber(amount) or 0)
	if addon.GetMoneyFormat and addon.GetMoneyFormat() == "letters" then
		local gold = math.floor(amount / COPPER_PER_GOLD)
		local silver = math.floor((amount % COPPER_PER_GOLD) / COPPER_PER_SILVER)
		local copper = amount % COPPER_PER_SILVER
		return string.format("%dg %ds %db", gold, silver, copper)
	end
	if type(GetMoneyString) == "function" then
		return GetMoneyString(amount, true)
	elseif C_CurrencyInfo and C_CurrencyInfo.GetCoinTextureString then
		return C_CurrencyInfo.GetCoinTextureString(amount, 12)
	end

	return tostring(amount)
end

local function getTrackedCharacterDisplayName(entry)
	local name = entry and entry.name or UNKNOWN
	local realm = entry and entry.realm
	local currentRealm = GetRealmName and GetRealmName() or nil
	if realm and realm ~= "" and realm ~= currentRealm then
		name = string.format("%s - %s", name, realm)
	end
	if entry and entry.isCurrent then
		name = string.format("%s (%s)", name, L["settingsTrackedCharacterCurrent"] or "Current")
	end
	return name
end

local function getTrackedCharacterColor(classToken)
	local classColors = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
	return classColors and classToken and classColors[classToken] or nil
end

local function showFooterMoneyTooltip(owner)
	if not owner then
		return
	end

	local entries = addon.GetTrackedCharacterGoldEntries and addon.GetTrackedCharacterGoldEntries() or {}
	local warbandGold = addon.GetWarbandGold and addon.GetWarbandGold() or 0
	GameTooltip:SetOwner(owner, "ANCHOR_TOP")
	GameTooltip:SetText(L["settingsTrackedCharacters"] or "Tracked characters", 1, 0.82, 0)

	if warbandGold > 0 then
		GameTooltip:AddDoubleLine(
			L["warbandGold"] or "Warband gold",
			formatFooterMoneyString(warbandGold),
			1,
			1,
			1,
			1,
			1,
			1
		)
	end

	if #entries == 0 then
		if warbandGold > 0 then
			GameTooltip:AddLine(" ")
		end
		GameTooltip:AddLine(L["settingsTrackedCharactersEmpty"] or "No tracked characters yet.", nil, nil, nil, true)
		GameTooltip:Show()
		return
	end

	if warbandGold > 0 then
		GameTooltip:AddLine(" ")
	end

	local totalMoney = 0
	for _, entry in ipairs(entries) do
		totalMoney = totalMoney + (tonumber(entry.money) or 0)
		local name = getTrackedCharacterDisplayName(entry)
		local color = getTrackedCharacterColor(entry.class)
		local leftR, leftG, leftB = 1, 1, 1
		if color then
			leftR, leftG, leftB = color.r or 1, color.g or 1, color.b or 1
		end
		GameTooltip:AddDoubleLine(
			name,
			formatFooterMoneyString(entry.money),
			leftR,
			leftG,
			leftB,
			1,
			1,
			1
		)
	end

	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(TOTAL or "Total", formatFooterMoneyString(totalMoney), 1, 1, 1, 1, 1, 1)
	GameTooltip:Show()
end

local hiddenBagFrameParent = CreateFrame("Frame")
hiddenBagFrameParent:Hide()

local function detachDefaultBagFrames()
	for index = 1, 6 do
		local frame = _G["ContainerFrame" .. index]
		if frame then
			frame:SetParent(hiddenBagFrameParent)
		end
	end

	if ContainerFrameCombinedBags then
		ContainerFrameCombinedBags:SetParent(hiddenBagFrameParent)
	end

	if BagItemSearchBox then
		if BagItemSearchBox.ClearFocus then
			BagItemSearchBox:ClearFocus()
		end
		BagItemSearchBox:Hide()
	end

	if BagItemAutoSortButton then
		BagItemAutoSortButton:Hide()
	end
end

function BagSlotPanel.GetBagIDs()
	local bagIDs = {}
	local normalSlots = tonumber(NUM_BAG_SLOTS) or 4
	for bagID = 1, normalSlots do
		bagIDs[#bagIDs + 1] = bagID
	end

	if (tonumber(NUM_REAGENTBAG_SLOTS) or 0) > 0 and Enum and Enum.BagIndex and Enum.BagIndex.ReagentBag then
		bagIDs[#bagIDs + 1] = Enum.BagIndex.ReagentBag
	end

	return bagIDs
end

function BagSlotPanel.GetInventorySlot(bagID)
	if not bagID or not C_Container or not C_Container.ContainerIDToInventoryID then
		return nil
	end

	return C_Container.ContainerIDToInventoryID(bagID)
end

function BagSlotPanel.GetCursorContainerLocation()
	if not C_Cursor or not C_Cursor.GetCursorItem or not C_Item then
		return nil, nil
	end

	local location = C_Cursor.GetCursorItem()
	if not location or not location.HasAnyLocation or not location:HasAnyLocation() then
		return nil, nil
	end
	if not C_Item.DoesItemExist or not C_Item.DoesItemExist(location) then
		return nil, nil
	end

	local itemID = C_Item.GetItemID and C_Item.GetItemID(location) or nil
	local classID = itemID and C_Item.GetItemInfoInstant and select(6, C_Item.GetItemInfoInstant(itemID)) or nil
	if not (Enum and Enum.ItemClass and classID == Enum.ItemClass.Container) then
		return nil, nil
	end
	if not location.GetBagAndSlot then
		return nil, nil
	end

	return location:GetBagAndSlot()
end

function BagSlotPanel.ApplyCursorToBagSlot(bagID)
	local inventorySlot = BagSlotPanel.GetInventorySlot(bagID)
	if not inventorySlot then
		return
	end

	local sourceBagID, sourceSlotID = BagSlotPanel.GetCursorContainerLocation()
	if sourceBagID == bagID and sourceSlotID and C_Container and C_Container.PickupContainerItem then
		local backpackSlot = { bagID = 0, slotIndex = 1 }
		if C_Item and C_Item.DoesItemExist and C_Item.DoesItemExist(backpackSlot) and C_Item.IsLocked and C_Item.IsLocked(backpackSlot) then
			PutItemInBag(inventorySlot)
			return
		end

		ClearCursor()
		C_Container.PickupContainerItem(sourceBagID, sourceSlotID)
		C_Container.PickupContainerItem(0, 1)

		local swapFrame = state.bagSlotSwapFrame or CreateFrame("Frame")
		state.bagSlotSwapFrame = swapFrame
		swapFrame:UnregisterAllEvents()
		swapFrame:RegisterEvent("BAG_UPDATE_DELAYED")
		local completed = false
		local function finishSwap()
			if completed then
				return
			end
			completed = true
			swapFrame:UnregisterAllEvents()
			C_Timer.After(0, function()
				C_Container.PickupContainerItem(0, 1)
				PutItemInBag(inventorySlot)
				BagSlotPanel.Refresh()
			end)
		end
		swapFrame:SetScript("OnEvent", finishSwap)
		C_Timer.After(0.2, finishSwap)
	else
		PutItemInBag(inventorySlot)
		C_Timer.After(0, BagSlotPanel.Refresh)
	end
end

function BagSlotPanel.RefreshButton(button)
	if not button or not button.bagID then
		return
	end

	button:Show()
	local inventorySlot = BagSlotPanel.GetInventorySlot(button.bagID)
	local texture = inventorySlot and GetInventoryItemTexture("player", inventorySlot) or nil
	local quality = inventorySlot and GetInventoryItemQuality("player", inventorySlot) or nil
	local freeSlots = texture and C_Container.GetContainerNumFreeSlots(button.bagID) or nil
	local backgroundTexture = button.EmptySlotTexture or (select(2, GetInventorySlotInfo("Bag1")))

	button:SetID(button.bagID)
	if button.Icon then
		button.Icon:SetTexture(texture or backgroundTexture)
		button.Icon:SetAlpha(texture and 1 or 0.35)
	end
	if button.Count then
		if freeSlots and freeSlots >= 0 then
			button.Count:SetText(freeSlots)
			button.Count:Show()
		else
			button.Count:SetText("")
			button.Count:Hide()
		end
	end
	if quality and C_Item and C_Item.GetItemQualityColor then
		local colorR, colorG, colorB = C_Item.GetItemQualityColor(quality)
		if type(colorR) == "table" then
			button:SetBackdropBorderColor(colorR.r or 1, colorR.g or 1, colorR.b or 1, 1)
		elseif colorR and colorG and colorB then
			button:SetBackdropBorderColor(colorR, colorG, colorB, 1)
		else
			button:SetBackdropBorderColor(0.78, 0.64, 0.18, 0.9)
		end
	elseif texture then
		button:SetBackdropBorderColor(0.78, 0.64, 0.18, 0.9)
	else
		button:SetBackdropBorderColor(0.35, 0.35, 0.42, 0.9)
	end
end

function BagSlotPanel.RefreshPanel(panel)
	if not panel or not panel.Buttons then
		return
	end

	for _, button in ipairs(panel.Buttons) do
		BagSlotPanel.RefreshButton(button)
	end
end

function BagSlotPanel.Refresh()
	for index = #state.bagSlotPanels, 1, -1 do
		local panel = state.bagSlotPanels[index]
		if panel and panel.Buttons then
			BagSlotPanel.RefreshPanel(panel)
		else
			table.remove(state.bagSlotPanels, index)
		end
	end
end

function BagSlotPanel.ShowTooltip(button)
	if not button or not GameTooltip then
		return
	end

	local inventorySlot = BagSlotPanel.GetInventorySlot(button.bagID)
	GameTooltip:SetOwner(button, "ANCHOR_TOP")
	if inventorySlot and GameTooltip:SetInventoryItem("player", inventorySlot) then
		GameTooltip:Show()
		return
	end

	if button.bagID == (Enum and Enum.BagIndex and Enum.BagIndex.ReagentBag) then
		GameTooltip:SetText(EQUIP_CONTAINER_REAGENT or EQUIP_CONTAINER or BAGS or "Bags", 1, 0.82, 0)
	else
		GameTooltip:SetText(EQUIP_CONTAINER or BAGS or "Bags", 1, 0.82, 0)
	end
	GameTooltip:Show()
end

function BagSlotPanel.Create(parent)
	local panel = CreateFrame("Frame", nil, parent, "BackdropTemplate")
	panel:SetFrameLevel(parent:GetFrameLevel() + 20)
	panel:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8x8",
		edgeFile = "Interface\\Buttons\\WHITE8x8",
		edgeSize = 1,
	})
	panel:SetBackdropColor(0.03, 0.03, 0.04, 0.96)
	panel:SetBackdropBorderColor(0.78, 0.64, 0.18, 0.85)
	panel:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -Core.FRAME_PADDING, -Core.HEADER_HEIGHT)
	panel:Hide()
	panel.Buttons = {}
	state.bagSlotPanels[#state.bagSlotPanels + 1] = panel

	local bagIDs = BagSlotPanel.GetBagIDs()
	local width = (#bagIDs * Core.BAG_SLOT_BUTTON_SIZE) + ((#bagIDs - 1) * Core.BAG_SLOT_BUTTON_SPACING) + 16
	panel:SetSize(width, Core.BAG_SLOT_BUTTON_SIZE + 16)

	local previousButton
	for _, bagID in ipairs(bagIDs) do
		local button = CreateFrame("Button", nil, panel, "BackdropTemplate")
		button:SetSize(Core.BAG_SLOT_BUTTON_SIZE, Core.BAG_SLOT_BUTTON_SIZE)
		button:Show()
		button:SetBackdrop({
			bgFile = "Interface\\Buttons\\WHITE8x8",
			edgeFile = "Interface\\Buttons\\WHITE8x8",
			edgeSize = 1,
		})
		button:SetBackdropColor(0.02, 0.02, 0.025, 0.94)
		button:SetBackdropBorderColor(0.35, 0.35, 0.42, 0.9)
		button.bagID = bagID
		button.EmptySlotTexture = select(2, GetInventorySlotInfo("Bag1"))

		local icon = button:CreateTexture(nil, "ARTWORK")
		icon:SetPoint("TOPLEFT", button, "TOPLEFT", 3, -3)
		icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -3, 3)
		icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		button.Icon = icon

		local highlight = button:CreateTexture(nil, "HIGHLIGHT")
		highlight:SetAllPoints(button)
		highlight:SetColorTexture(1, 1, 1, 0.12)
		highlight:SetBlendMode("ADD")
		button.HighlightTexture = highlight

		local count = button:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
		count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 1)
		count:SetJustifyH("RIGHT")
		button.Count = count

		button:RegisterForClicks("AnyUp")
		button:RegisterForDrag("LeftButton")
		if previousButton then
			button:SetPoint("LEFT", previousButton, "RIGHT", Core.BAG_SLOT_BUTTON_SPACING, 0)
		else
			button:SetPoint("LEFT", panel, "LEFT", 8, 0)
		end
		button:SetScript("OnClick", function(self, mouseButton)
			if mouseButton == "RightButton" then
				return
			end
			if IsModifiedClick("PICKUPITEM") then
				local inventorySlot = BagSlotPanel.GetInventorySlot(self.bagID)
				if inventorySlot then
					PickupBagFromSlot(inventorySlot)
				end
			else
				BagSlotPanel.ApplyCursorToBagSlot(self.bagID)
			end
		end)
		button:SetScript("OnDragStart", function(self)
			local inventorySlot = BagSlotPanel.GetInventorySlot(self.bagID)
			if inventorySlot then
				PickupBagFromSlot(inventorySlot)
			end
		end)
		button:SetScript("OnReceiveDrag", function(self)
			BagSlotPanel.ApplyCursorToBagSlot(self.bagID)
		end)
		button:SetScript("OnEnter", BagSlotPanel.ShowTooltip)
		button:SetScript("OnLeave", function()
			GameTooltip:Hide()
		end)
		panel.Buttons[#panel.Buttons + 1] = button
		previousButton = button
	end

	return panel
end

function BagSlotPanel.Toggle(panel)
	panel = panel or (state.frame and state.frame.BagSlotsPanel or nil)
	if not panel then
		return
	end

	if panel:IsShown() then
		panel:Hide()
	else
		BagSlotPanel.RefreshPanel(panel)
		panel:Show()
	end
end

function BagSlotPanel.CreateToggleButton(parent, panel)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(18, 18)
	button:SetHitRectInsets(-4, -4, -4, -4)
	button:RegisterForClicks("LeftButtonUp")
	button.Icon = button:CreateTexture(nil, "ARTWORK")
	button.Icon:SetPoint("CENTER")
	button.Icon:SetTexture("Interface\\Icons\\INV_Misc_Bag_08")
	button.Icon:SetSize(16, 16)
	button.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

	local highlight = button:CreateTexture(nil, "HIGHLIGHT")
	highlight:SetAllPoints(button.Icon)
	highlight:SetTexture("Interface\\Icons\\INV_Misc_Bag_08")
	highlight:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	highlight:SetBlendMode("ADD")
	highlight:SetAlpha(0.35)
	button.HighlightTexture = highlight

	button:SetScript("OnMouseDown", function(self)
		self.Icon:AdjustPointsOffset(1, -1)
	end)
	button:SetScript("OnMouseUp", function(self)
		self.Icon:AdjustPointsOffset(-1, 1)
	end)
	button:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:SetText(BAGS or "Bags", 1, 0.82, 0)
		GameTooltip:Show()
	end)
	button:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	button:SetScript("OnClick", function()
		BagSlotPanel.Toggle(panel)
	end)
	return button
end

function Bags.functions.CreateEquippedBagSlotPanel(parent)
	return BagSlotPanel.Create(parent)
end

function Bags.functions.CreateEquippedBagSlotsButton(parent, panel)
	return BagSlotPanel.CreateToggleButton(parent, panel)
end

function Bags.functions.RefreshEquippedBagSlotPanels()
	BagSlotPanel.Refresh()
end

local function closeNativeBagsFromCustomHide()
	if state.suppressNativeBagClose then
		return
	end
	if not isNativeStandardBagOpen() or type(CloseAllBags) ~= "function" then
		return
	end

	state.suppressNativeBagClose = true
	CloseAllBags()
	state.suppressNativeBagClose = false
end

local function createMainFrame()
	if state.frame then
		return state.frame
	end

	local frame = CreateFrame("Frame", "BagsMainFrame", UIParent, "BackdropTemplate")
	frame:SetFrameStrata("HIGH")
	frame:SetToplevel(true)
	frame:SetMovable(true)
	frame:SetClampedToScreen(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", function(self)
		self:StartMoving()
	end)
	frame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		saveFramePosition(self)
	end)
	frame:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8x8",
		edgeFile = "Interface\\Buttons\\WHITE8x8",
		edgeSize = 1,
	})
	frame:SetBackdropColor(0.05, 0.06, 0.08, 0.94)
	frame:SetBackdropBorderColor(0.35, 0.35, 0.42, 1)
	frame:SetSize(Core.MIN_FRAME_WIDTH, 1)
	frame:Hide()

	local backgroundTexture = frame:CreateTexture(nil, "BACKGROUND", nil, -8)
	backgroundTexture:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1)
	backgroundTexture:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1)
	backgroundTexture:Hide()
	frame.BackgroundTexture = backgroundTexture

	local backgroundShade = frame:CreateTexture(nil, "BACKGROUND", nil, -7)
	backgroundShade:SetAllPoints(backgroundTexture)
	backgroundShade:Hide()
	frame.BackgroundShade = backgroundShade
	tinsert(UISpecialFrames, "BagsMainFrame")
	frame:SetScript("OnHide", function(self)
		state.manualVisible = false
		state.explicitToggleVisible = false
		local settings = getSettings()
		settings.manualVisible = false
		if self.SearchBox and self.SearchBox.ClearFocus then
			self.SearchBox:ClearFocus()
		end
		if self.BagSlotsPanel then
			self.BagSlotsPanel:Hide()
		end
		closeNativeBagsFromCustomHide()
	end)

	local title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	title:SetPoint("TOPLEFT", frame, "TOPLEFT", Core.FRAME_PADDING, -10)
	title:SetText(L["simpleBagsTitle"] or addonName)
	frame.Title = title

	local settingsButton = CreateFrame("Button", nil, frame)
	settingsButton:SetSize(18, 18)
	settingsButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -Core.FRAME_PADDING, -8)
	settingsButton:SetHitRectInsets(-4, -4, -4, -4)
	settingsButton:RegisterForClicks("LeftButtonUp")
	settingsButton.Icon = settingsButton:CreateTexture(nil, "ARTWORK")
	settingsButton.Icon:SetPoint("CENTER")
	local hasQuestLogSettingsAtlas = C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo("questlog-icon-setting")
	if hasQuestLogSettingsAtlas then
		settingsButton.Icon:SetAtlas("questlog-icon-setting", true)
	else
		settingsButton.Icon:SetTexture("Interface\\Buttons\\UI-OptionsButton")
		settingsButton.Icon:SetSize(16, 16)
	end

	local highlight = settingsButton:CreateTexture(nil, "HIGHLIGHT")
	highlight:SetPoint("CENTER", settingsButton.Icon, "CENTER")
	if hasQuestLogSettingsAtlas then
		highlight:SetAtlas("questlog-icon-setting", true)
	else
		highlight:SetTexture("Interface\\Buttons\\UI-OptionsButton")
		highlight:SetSize(16, 16)
	end
	highlight:SetBlendMode("ADD")
	highlight:SetAlpha(0.4)
	settingsButton.HighlightTexture = highlight

	settingsButton:SetScript("OnMouseDown", function(self)
		self.Icon:AdjustPointsOffset(1, -1)
	end)
	settingsButton:SetScript("OnMouseUp", function(self)
		self.Icon:AdjustPointsOffset(-1, 1)
	end)
	settingsButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:SetText(SETTINGS, 1, 0.82, 0)
		GameTooltip:Show()
	end)
	settingsButton:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	settingsButton:SetScript("OnClick", function()
		if addon.ToggleSettings then
			addon.ToggleSettings()
		end
	end)
	frame.SettingsButton = settingsButton

	local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButtonNoScripts")
	closeButton:SetSize(22, 22)
	closeButton:SetHitRectInsets(-2, -2, -2, -2)
	closeButton:SetScript("OnClick", function()
		if Bags.functions and Bags.functions.HideFrame then
			Bags.functions.HideFrame()
		else
			frame:Hide()
		end
	end)
	frame.CloseButton = closeButton

	frame.BagSlotsPanel = BagSlotPanel.Create(frame)

	local bagSlotsButton = BagSlotPanel.CreateToggleButton(frame, frame.BagSlotsPanel)
	bagSlotsButton:SetPoint("RIGHT", settingsButton, "LEFT", -8, 0)
	frame.BagSlotsButton = bagSlotsButton

	local searchBox = CreateFrame("EditBox", "BagsItemSearchBox", frame, "BagSearchBoxTemplate")
	searchBox.instructionText = ""
	if searchBox.Instructions then
		searchBox.Instructions:SetText("")
	end
	if ITEM_SEARCHBAR_LIST then
		local alreadyRegistered = false
		for _, barName in ipairs(ITEM_SEARCHBAR_LIST) do
			if barName == "BagsItemSearchBox" then
				alreadyRegistered = true
				break
			end
		end
		if not alreadyRegistered then
			ITEM_SEARCHBAR_LIST[#ITEM_SEARCHBAR_LIST + 1] = "BagsItemSearchBox"
		end
	end
	searchBox:SetHeight(20)
	searchBox:SetPoint("TOPLEFT", title, "TOPRIGHT", 18, 2)
	searchBox:SetPoint("TOPRIGHT", bagSlotsButton, "TOPLEFT", -10, -1)
	searchBox:SetScript("OnHide", function(self)
		BagSearch_OnHide(self)
	end)
	searchBox:SetScript("OnTextChanged", function(self, userChanged)
		BagSearch_OnTextChanged(self, userChanged)
	end)
	searchBox:SetScript("OnChar", BagSearch_OnChar)
	frame.SearchBox = searchBox

	local divider = frame:CreateTexture(nil, "BORDER")
	divider:SetColorTexture(1, 1, 1, 0.08)
	divider:SetHeight(1)
	divider:SetPoint("TOPLEFT", frame, "TOPLEFT", Core.FRAME_PADDING, -Core.HEADER_HEIGHT)
	divider:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -Core.FRAME_PADDING, -Core.HEADER_HEIGHT)
	frame.Divider = divider

	local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
	scrollFrame.scrollBarHideable = true
	scrollFrame:EnableMouseWheel(true)
	scrollFrame:SetClipsChildren(true)
	UIPanelScrollFrame_OnLoad(scrollFrame)
	if scrollFrame.ScrollBar then
		scrollFrame.ScrollBar.scrollStep = Core.BUTTON_SIZE + Core.BUTTON_SPACING
	end
	frame.ScrollFrame = scrollFrame

	local content = CreateFrame("Frame", nil, scrollFrame)
	function content:IsCombinedBagContainer()
		return true
	end
	scrollFrame:SetScrollChild(content)
	frame.Content = content

	local footer = CreateFrame("Frame", nil, frame)
	footer:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", Core.FRAME_PADDING, 0)
	footer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -Core.FRAME_PADDING, 0)
	footer:SetHeight(getFooterHeight(getSettings()))
	frame.Footer = footer

	local footerDivider = frame:CreateTexture(nil, "BORDER")
	footerDivider:SetColorTexture(1, 1, 1, 0.08)
	footerDivider:SetHeight(1)
	footerDivider:SetPoint("BOTTOMLEFT", footer, "TOPLEFT", 0, Core.FOOTER_DIVIDER_OFFSET)
	footerDivider:SetPoint("BOTTOMRIGHT", footer, "TOPRIGHT", 0, Core.FOOTER_DIVIDER_OFFSET)
	frame.FooterDivider = footerDivider

	footer.NormalSlotsText = footer:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	footer.NormalSlotsText:SetPoint("TOPLEFT", footer, "TOPLEFT", 0, 0)
	footer.NormalSlotsText:SetJustifyH("LEFT")

	footer.ReagentSlotsText = footer:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	footer.ReagentSlotsText:SetPoint("LEFT", footer.NormalSlotsText, "RIGHT", 18, 0)
	footer.ReagentSlotsText:SetJustifyH("LEFT")

	footer.CurrencyContainer = CreateFrame("Frame", nil, footer)
	footer.CurrencyContainer:SetPoint("BOTTOMLEFT", footer, "BOTTOMLEFT", 0, 0)
	footer.CurrencyContainer:SetHeight(Core.FOOTER_ROW_HEIGHT)

	footer.MoneyButton = CreateFrame("Button", nil, footer)
	footer.MoneyButton:SetPoint("BOTTOMRIGHT", footer, "BOTTOMRIGHT", 0, 0)
	footer.MoneyButton:SetHeight(Core.FOOTER_ROW_HEIGHT)
	footer.MoneyButton:SetScript("OnEnter", function(self)
		showFooterMoneyTooltip(self)
	end)
	footer.MoneyButton:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	footer.MoneyText = footer.MoneyButton:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	footer.MoneyText:SetPoint("RIGHT", footer.MoneyButton, "RIGHT", -Core.FOOTER_MONEY_RIGHT_PADDING, 0)
	footer.MoneyText:SetJustifyH("RIGHT")

	state.frame = frame
	state.scrollFrame = scrollFrame
	state.content = content
	state.buttonPool = CreateFramePool("ItemButton", content, "BagsItemButtonTemplate")
	applyFramePadding(getSettings())

	if not applySavedFramePosition(frame) then
		frame:SetPoint(
			Core.DEFAULT_FRAME_POINT.point,
			UIParent,
			Core.DEFAULT_FRAME_POINT.relativePoint,
			Core.DEFAULT_FRAME_POINT.x,
			Core.DEFAULT_FRAME_POINT.y
		)
	end

	applyConfiguredFrameFonts()
	applyActiveSkin()

	return frame
end

local function shouldDisplayItemLevel(itemRef)
	if not itemRef then
		return false
	end

	local cacheKey = tostring(itemRef)
	local cached = itemLevelEligibilityCache[cacheKey]
	if cached ~= nil then
		return cached
	end

	local equipLoc = select(4, GetItemInfoInstant(itemRef))
	local shouldDisplay = equipLoc ~= nil and not Core.IGNORED_ITEM_LEVEL_EQUIP_LOCS[equipLoc]
	itemLevelEligibilityCache[cacheKey] = shouldDisplay
	return shouldDisplay
end

local function shouldCombineDuplicateItem(itemRef, settings)
	if not itemRef or not settings or not settings.combineUnstackableItems then
		return false
	end

	return true
end

local function getCollapsedItemCount(info)
	local stackCount = info and tonumber(info.stackCount) or nil
	return (stackCount and stackCount > 0) and stackCount or 1
end

local function getCollapsedItemRef(info, ruleItemInfo)
	if not info then
		return nil
	end

	local itemRef = info.hyperlink or info.itemID
	if not itemRef then
		return nil
	end

	local collapseRef = itemRef
	local itemID = tonumber(info.itemID)
	local stackCount = tonumber(info.stackCount) or 0

	if itemID then
		if stackCount > 1 then
			collapseRef = itemID
		else
			local itemInfo = ruleItemInfo or getCachedRuleItemInfo(itemRef)
			local maxStackCount = itemInfo and tonumber(itemInfo.itemStackCount) or nil
			if maxStackCount and maxStackCount > 1 then
				collapseRef = itemID
			end
		end
	end

	return collapseRef
end

local function getCollapsedItemKey(sectionID, info, ruleItemInfo)
	local collapseRef = getCollapsedItemRef(info, ruleItemInfo)
	if collapseRef == nil then
		return nil
	end

	return string.format("%s:%s", tostring(sectionID), tostring(collapseRef))
end

local function hideButtonOverlayText(button, textRegion, cacheField, hiddenKey)
	if button[cacheField] == hiddenKey then
		return
	end

	textRegion:SetText("")
	textRegion:Hide()
	button[cacheField] = hiddenKey
end

local function isKeystoneItem(itemID)
	return itemID and C_Item and C_Item.IsItemKeystoneByID and C_Item.IsItemKeystoneByID(itemID) or false
end

local function getKeystoneLevelFromItemLink(itemLink)
	if type(itemLink) ~= "string" then
		return nil
	end

	return tonumber(itemLink:match("keystone:[^:]*:[^:]*:(%d+)"))
end

local function getKeystoneLevelTextColor(level)
	if not level or not C_ChallengeMode or not C_ChallengeMode.GetKeystoneLevelRarityColor then
		return nil
	end

	local color = C_ChallengeMode.GetKeystoneLevelRarityColor(level)
	if type(color) ~= "table" then
		return nil
	end

	return color.r or color[1], color.g or color[2], color.b or color[3]
end

local function isRuleHearthstoneItem(itemID)
	itemID = tonumber(itemID)
	return itemID ~= nil and Core.HEARTHSTONE_ITEM_IDS[itemID] == true or false
end

local function updateJunkCoinIcon(button, quality)
	if not button or not button.JunkIcon then
		return
	end

	if quality == Core.ITEM_QUALITY_POOR then
		button.JunkIcon:SetAtlas("bags-junkcoin", true)
		button.JunkIcon:Show()
	else
		button.JunkIcon:Hide()
	end
end

local function updateItemLevelText(button, itemLink, itemID, quality, overlayRuntime)
	if not button or not button.ItemLevelText then
		return
	end

	local text = button.ItemLevelText
	local overlayEntry = overlayRuntime and overlayRuntime.byID and overlayRuntime.byID.itemLevel or nil
	local overlayVersion = overlayRuntime and overlayRuntime.version or 0
	local itemRef = itemLink or itemID
	local evalKey = string.format("%s:%s:%s", tostring(itemRef or 0), tostring(quality or 0), tostring(overlayVersion))

	if not (overlayEntry and overlayEntry.enabled) then
		hideButtonOverlayText(button, text, "_bagsItemLevelEvalKey", "hidden:" .. evalKey)
		return
	end

	local keystoneLevel = isKeystoneItem(itemID) and getKeystoneLevelFromItemLink(itemLink) or nil
	if keystoneLevel then
		local keystoneEvalKey = "keystone:" .. evalKey
		if button._bagsItemLevelEvalKey == keystoneEvalKey then
			return
		end

		text:SetText(addon.FormatTextElement and addon.FormatTextElement("overlays", tostring(keystoneLevel)) or keystoneLevel)
		local r, g, b = getKeystoneLevelTextColor(keystoneLevel)
		if r then
			text:SetTextColor(r, g, b)
		else
			text:SetTextColor(1, 1, 1)
		end
		text:Show()
		button._bagsItemLevelEvalKey = keystoneEvalKey
		return
	end

	if not shouldDisplayItemLevel(itemRef) then
		hideButtonOverlayText(button, text, "_bagsItemLevelEvalKey", "ignored:" .. evalKey)
		return
	end

	if button._bagsItemLevelEvalKey == evalKey then
		return
	end

	local itemLocation = ItemLocation:CreateFromBagAndSlot(button:GetBagID(), button:GetID())
	local itemLevel
	if itemLocation and C_Item.DoesItemExist(itemLocation) then
		itemLevel = C_Item.GetCurrentItemLevel(itemLocation)
	end
	if (not itemLevel or itemLevel <= 0) and itemRef and C_Item.GetDetailedItemLevelInfo then
		itemLevel = C_Item.GetDetailedItemLevelInfo(itemRef)
	end
	itemLevel = tonumber(itemLevel)
	if not itemLevel or itemLevel <= 1 then
		button._bagsItemLevelEvalKey = nil
		text:SetText("")
		text:Hide()
		return
	end

	text:SetText(addon.FormatTextElement and addon.FormatTextElement("overlays", tostring(itemLevel)) or itemLevel)
	if overlayEntry and overlayEntry.colorMode == "custom" and type(overlayEntry.customColor) == "table" then
		text:SetTextColor(
			tonumber(overlayEntry.customColor[1]) or 1,
			tonumber(overlayEntry.customColor[2]) or 1,
			tonumber(overlayEntry.customColor[3]) or 1
		)
	elseif quality and quality >= Core.MIN_ITEM_LEVEL_COLOR_QUALITY and C_Item.GetItemQualityColor then
		local r, g, b = C_Item.GetItemQualityColor(quality)
		if r then
			text:SetTextColor(r, g, b)
		else
			text:SetTextColor(1, 1, 1)
		end
	else
		text:SetTextColor(1, 1, 1)
	end
	text:Show()
	button._bagsItemLevelEvalKey = evalKey
end

local function updateItemUpgradeText(button, itemLink, itemID, overlayRuntime)
	if not button or not button.ItemUpgradeText then
		return
	end

	local text = button.ItemUpgradeText
	local overlayEntry = overlayRuntime and overlayRuntime.byID and overlayRuntime.byID.upgradeTrack or nil
	local overlayVersion = overlayRuntime and overlayRuntime.version or 0
	local itemRef = itemLink or itemID
	local evalKey = string.format("%s:%s", tostring(itemRef or 0), tostring(overlayVersion))

	if not (overlayEntry and overlayEntry.enabled) then
		hideButtonOverlayText(button, text, "_bagsItemUpgradeEvalKey", "hidden:" .. evalKey)
		return
	end

	if not itemRef or not addon.GetItemUpgradeInfoForItem then
		hideButtonOverlayText(button, text, "_bagsItemUpgradeEvalKey", "empty:" .. evalKey)
		return
	end

	if button._bagsItemUpgradeEvalKey == evalKey then
		return
	end

	local upgradeInfo = addon.GetItemUpgradeInfoForItem(itemRef)
	if not upgradeInfo or not upgradeInfo.displayText or upgradeInfo.displayText == "" then
		button._bagsItemUpgradeEvalKey = nil
		text:SetText("")
		text:Hide()
		return
	end
	if addon.IsUpgradeTrackOverlayTrackEnabled and not addon.IsUpgradeTrackOverlayTrackEnabled(upgradeInfo.key) then
		hideButtonOverlayText(button, text, "_bagsItemUpgradeEvalKey", "filtered:" .. evalKey .. ":" .. tostring(upgradeInfo.key))
		return
	end

	text:SetText(addon.FormatTextElement and addon.FormatTextElement("overlays", upgradeInfo.displayText) or upgradeInfo.displayText)
	if addon.GetUpgradeTrackColor then
		local r, g, b = addon.GetUpgradeTrackColor(upgradeInfo.key)
		text:SetTextColor(r or 1, g or 1, b or 1)
	else
		text:SetTextColor(1, 1, 1)
	end
	text:Show()
	button._bagsItemUpgradeEvalKey = evalKey
end

updateReagentBagVisuals = function(button)
	if not button then
		return
	end

	if not button.BagsReagentSlotIcon then
		local icon = button:CreateTexture(nil, "ARTWORK", nil, -1)
		icon:SetPoint("CENTER", button, "CENTER", 0, 0)
		icon:Hide()
		button.BagsReagentSlotIcon = icon
	end

	local isReagentBag = button:GetBagID() == Core.REAGENT_BAG_ID
	local pendingTexture = button._bagsHasPendingRenderTexture and button._bagsPendingRenderTexture or nil
	local renderTexture = pendingTexture
	if renderTexture == nil then
		renderTexture = button._bagsRenderTexture
	end
	local freeSlotDisplayMode = button._bagsFreeSlotDisplayMode
	local isColoredFreeSlot = freeSlotDisplayMode == "colors" and button._bagsFreeSlotGroup ~= nil
	local shouldShowReagentSlotIcon = isReagentBag and renderTexture == nil and freeSlotDisplayMode ~= "texture" and not isColoredFreeSlot
	local skin = getActiveFrameSkin()
	local accentR, accentG, accentB = unpackSkinColor(skin and skin.accentColor, 0.72, 1, 0.78, 1)
	if button.ReagentTint then
		button.ReagentTint:SetColorTexture(accentR, accentG, accentB, 0.16)
		button.ReagentTint:SetShown(isReagentBag)
	end

	if button.ItemSlotBackground then
		if isColoredFreeSlot and button._bagsFreeSlotColor then
			button.ItemSlotBackground:SetVertexColor(button._bagsFreeSlotColor[1] or 1, button._bagsFreeSlotColor[2] or 1, button._bagsFreeSlotColor[3] or 1)
		elseif isReagentBag then
			button.ItemSlotBackground:SetVertexColor(
				math.min(1, 0.55 + (accentR * 0.45)),
				math.min(1, 0.55 + (accentG * 0.45)),
				math.min(1, 0.55 + (accentB * 0.45))
			)
		else
			button.ItemSlotBackground:SetVertexColor(1, 1, 1)
		end
	end

	if button.BagsReagentSlotIcon then
		if shouldShowReagentSlotIcon then
			local iconSize = math.max(14, math.floor(((button.GetWidth and button:GetWidth() or 37) * 0.48) + 0.5))
			button.BagsReagentSlotIcon:ClearAllPoints()
			button.BagsReagentSlotIcon:SetPoint("CENTER", button, "CENTER", 0, 0)
			button.BagsReagentSlotIcon:SetAtlas(Core.REAGENT_SLOT_ICON_ATLAS)
			button.BagsReagentSlotIcon:SetSize(iconSize, iconSize)
			button.BagsReagentSlotIcon:SetVertexColor(1, 1, 1, 0.92)
			button.BagsReagentSlotIcon:Show()
		else
			button.BagsReagentSlotIcon:Hide()
		end
	end
end

local function getFreeSlotRenderSignature(freeSlotGroup)
	if not freeSlotGroup then
		return ""
	end

	local displayMode = addon.GetFreeSlotDisplayMode and addon.GetFreeSlotDisplayMode() or "icons"
	if displayMode ~= "colors" then
		return tostring(freeSlotGroup) .. ":" .. tostring(displayMode)
	end

	local color = addon.GetFreeSlotColor and addon.GetFreeSlotColor(freeSlotGroup) or nil
	return string.format(
		"%s:colors:%.3f:%.3f:%.3f",
		tostring(freeSlotGroup),
		tonumber(color and color[1]) or 0,
		tonumber(color and color[2]) or 0,
		tonumber(color and color[3]) or 0
	)
end

local function hasMatchingButtonRenderState(
	button,
	bagID,
	slotID,
	texture,
	displayCount,
	locked,
	quality,
	readable,
	itemLink,
	itemID,
	noValue,
	isBound,
	questIsQuestItem,
	questID,
	questIsActive,
	isNewItem,
	overlayVersion,
	fontSignature,
	freeSlotSignature
)
	return button._bagsRenderBagID == bagID
		and button._bagsRenderSlotID == slotID
		and button._bagsRenderTexture == texture
		and button._bagsRenderDisplayCount == displayCount
		and button._bagsRenderLocked == locked
		and button._bagsRenderQuality == quality
		and button._bagsRenderReadable == readable
		and button._bagsRenderItemLink == itemLink
		and button._bagsRenderItemID == itemID
		and button._bagsRenderNoValue == noValue
		and button._bagsRenderBound == isBound
		and button._bagsRenderQuestItem == questIsQuestItem
		and button._bagsRenderQuestID == questID
		and button._bagsRenderQuestActive == questIsActive
		and button._bagsRenderNewItem == isNewItem
		and button._bagsRenderOverlayVersion == overlayVersion
		and button._bagsRenderFontSignature == fontSignature
		and button._bagsRenderFreeSlotSignature == freeSlotSignature
end

local function updateButtonSearchState(button, isFiltered)
	button:SetMatchesSearch(not isFiltered)
	button._bagsRenderFiltered = isFiltered
end

local function storeButtonRenderState(
	button,
	bagID,
	slotID,
	texture,
	displayCount,
	locked,
	quality,
	readable,
	itemLink,
	itemID,
	isFiltered,
	noValue,
	isBound,
	questIsQuestItem,
	questID,
	questIsActive,
	isNewItem,
	overlayVersion,
	fontSignature,
	freeSlotSignature
)
	button._bagsRenderBagID = bagID
	button._bagsRenderSlotID = slotID
	button._bagsRenderTexture = texture
	button._bagsRenderDisplayCount = displayCount
	button._bagsRenderLocked = locked
	button._bagsRenderQuality = quality
	button._bagsRenderReadable = readable
	button._bagsRenderItemLink = itemLink
	button._bagsRenderItemID = itemID
	button._bagsRenderFiltered = isFiltered
	button._bagsRenderNoValue = noValue
	button._bagsRenderBound = isBound
	button._bagsRenderQuestItem = questIsQuestItem
	button._bagsRenderQuestID = questID
	button._bagsRenderQuestActive = questIsActive
	button._bagsRenderNewItem = isNewItem
	button._bagsRenderOverlayVersion = overlayVersion
	button._bagsRenderFontSignature = fontSignature
	button._bagsRenderFreeSlotSignature = freeSlotSignature
end

local function getCurrentItemButtonSkinSignature()
	return state.currentSkinSignature or (addon.GetSkinSignature and addon.GetSkinSignature()) or false
end

applyItemButtonSkinIfNeeded = function(button, quality, force)
	if not button or not addon.ApplyItemButtonSkin then
		return
	end

	local skinSignature = getCurrentItemButtonSkinSignature()
	if not force and button._bagsAppliedSkinSignature == skinSignature then
		return
	end

	addon.ApplyItemButtonSkin(button, quality)
	button._bagsAppliedSkinSignature = skinSignature
end

local function updateButtonData(button, mapping, overlayRuntime, textAppearance, fontSignature, tooltipOwner, forceDynamicUpdate)
	if not button then
		return
	end

	if mapping and mapping.sectionCollapsed then
		button:Hide()
		return
	end

	local bagID = button:GetBagID()
	local slotID = button:GetID()
	local info = (mapping and mapping.itemInfo) or C_Container.GetContainerItemInfo(bagID, slotID)
	local texture = info and info.iconFileID
	local itemCount = info and info.stackCount
	local displayItemCount = mapping and mapping.itemCount
	local locked = info and info.isLocked
	local quality = info and info.quality
	local readable = info and (info.IsReadable or info.isReadable)
	local itemLink = info and info.hyperlink
	local itemID = info and info.itemID
	local isFiltered = info and info.isFiltered
	local noValue = info and info.hasNoValue
	local isBound = info and info.isBound
	local questInfo = (mapping and mapping.questInfo) or C_Container.GetContainerItemQuestInfo(bagID, slotID)
	local freeSlotCount = mapping and mapping.freeSlotCount
	local displayCount = freeSlotCount or displayItemCount or itemCount
	local questIsQuestItem = questInfo and questInfo.isQuestItem or false
	local questID = questInfo and questInfo.questID or nil
	local questIsActive = questInfo and questInfo.isActive or false
	local isNewItem = isNewItemAtSlot(bagID, slotID)
	local freeSlotGroup = mapping and mapping.freeSlotGroup or nil
	local freeSlotSignature = getFreeSlotRenderSignature(freeSlotGroup)
	overlayRuntime = overlayRuntime or getOverlayRuntimeConfig()
	fontSignature = fontSignature or getTextAppearanceSignature(textAppearance)
	local overlayVersion = overlayRuntime and overlayRuntime.version or 0

	if hasMatchingButtonRenderState(
		button,
		bagID,
		slotID,
		texture,
		displayCount,
		locked,
		quality,
		readable,
		itemLink,
		itemID,
		noValue,
		isBound,
		questIsQuestItem,
		questID,
		questIsActive,
		isNewItem,
		overlayVersion,
		fontSignature,
		freeSlotSignature
	) then
		if not button:IsShown() then
			button:Show()
		end
		applyItemButtonSkinIfNeeded(button, quality, false)
		updateReagentBagVisuals(button)
		if button._bagsRenderFiltered ~= isFiltered then
			updateButtonSearchState(button, isFiltered)
		end
		if forceDynamicUpdate then
			button:UpdateCooldown(texture)
			if addon.RefreshItemButtonCooldownMask then
				addon.RefreshItemButtonCooldownMask(button)
			end
			if tooltipOwner then
				button:CheckUpdateTooltip(tooltipOwner)
			end
		end
		return
	end

	if ClearItemButtonOverlay then
		ClearItemButtonOverlay(button)
	end

	button:SetHasItem(texture)
	button:SetItemButtonTexture(texture)
	SetItemButtonQuality(button, quality, itemLink, false, isBound)
	SetItemButtonCount(button, displayCount)
	SetItemButtonDesaturated(button, locked)
	button:UpdateExtended()
	button:UpdateQuestItem(questIsQuestItem, questID, questIsActive)
	button:UpdateNewItem(quality)
	button:UpdateJunkItem(quality, noValue)
	updateJunkCoinIcon(button, quality)
	button:UpdateItemContextMatching()
	button:UpdateCooldown(texture)
	button:SetReadable(readable)
	updateButtonSearchState(button, isFiltered)
	button._bagsFreeSlotGroup = freeSlotGroup
	button._bagsFreeSlotDisplayMode = freeSlotGroup and addon.GetFreeSlotDisplayMode and addon.GetFreeSlotDisplayMode() or nil
	button._bagsFreeSlotColor = button._bagsFreeSlotDisplayMode == "colors" and addon.GetFreeSlotColor and addon.GetFreeSlotColor(freeSlotGroup) or nil

	if tooltipOwner then
		button:CheckUpdateTooltip(tooltipOwner)
	end

	button._bagsHasPendingRenderTexture = true
	button._bagsPendingRenderTexture = texture
	applyItemButtonSkinIfNeeded(button, quality, true)
	if addon.RefreshItemButtonCooldownMask then
		addon.RefreshItemButtonCooldownMask(button)
	end
	updateReagentBagVisuals(button)
	applyConfiguredItemButtonFonts(button, textAppearance, fontSignature)
	applyConfiguredOverlayAnchors(button, overlayRuntime)
	updateItemLevelText(button, itemLink, itemID, quality, overlayRuntime)
	updateItemUpgradeText(button, itemLink, itemID, overlayRuntime)
	storeButtonRenderState(
		button,
		bagID,
		slotID,
		texture,
		displayCount,
		locked,
		quality,
		readable,
		itemLink,
		itemID,
		isFiltered,
		noValue,
		isBound,
		questIsQuestItem,
		questID,
		questIsActive,
		isNewItem,
		overlayVersion,
		fontSignature,
		freeSlotSignature
	)
	button._bagsPendingRenderTexture = nil
	button._bagsHasPendingRenderTexture = nil
	button:Show()
end

local function buildCurrencyEntries()
	local settings = getSettings()
	local currencies = {}
	local seen = {}

	if not settings.showCurrencies then
		return currencies
	end

	if settings.showWatchedCurrencies then
		for index = 1, Core.MAX_WATCHED_CURRENCIES do
			local info = C_CurrencyInfo.GetBackpackCurrencyInfo(index)
			if not info then
				break
			end

			local currencyID = info.currencyTypesID
			if currencyID and not seen[currencyID] then
				seen[currencyID] = true
				currencies[#currencies + 1] = {
					currencyID = currencyID,
					iconFileID = info.iconFileID,
					quantity = info.quantity or 0,
				}
			end
		end
	end

	for _, currencyID in ipairs(addon.GetTrackedCurrencyIDs and addon.GetTrackedCurrencyIDs() or settings.trackedCurrencyIDs or {}) do
		currencyID = tonumber(currencyID)
		if currencyID and currencyID > 0 and not seen[currencyID] then
			local info = addon.GetTrackedCurrencyTrackingInfo and addon.GetTrackedCurrencyTrackingInfo(currencyID)
			if info and info.name then
				seen[currencyID] = true
				currencies[#currencies + 1] = {
					currencyID = currencyID,
					iconFileID = info.iconFileID,
					quantity = tonumber(info.quantity) or 0,
				}
			end
		end
	end

	return currencies
end

local function buildSectionDefinitions()
	local orderedDefinitions = {}
	local definitionMap = {}

	local newItemsDefinition = {
		id = "newItems",
		label = L["categoryNewItems"] or "categoryNewItems",
		color = { 0.48, 0.82, 0.34 },
		collapsible = false,
		forceHeader = true,
	}
	orderedDefinitions[#orderedDefinitions + 1] = newItemsDefinition
	definitionMap[newItemsDefinition.id] = newItemsDefinition

	for _, definition in ipairs(addon.GetCategorySectionDefinitions and addon.GetCategorySectionDefinitions() or {}) do
		local resolvedDefinition = {
			id = definition.id,
			label = definition.label or (definition.labelKey and (L[definition.labelKey] or definition.labelKey)) or definition.id,
			color = definition.color or { 1, 1, 1 },
			sortMode = definition.sortMode,
			isCustom = definition.isCustom,
			groupID = definition.groupID,
			groupLabel = definition.groupLabel,
			groupColor = definition.groupColor,
			groupCollapseID = definition.groupCollapseID,
			collapsible = definition.collapsible ~= false,
			forceHeader = definition.forceHeader == true,
		}
		orderedDefinitions[#orderedDefinitions + 1] = resolvedDefinition
		definitionMap[resolvedDefinition.id] = resolvedDefinition
	end

	local freeSlotsDefinition = {
		id = Core.FREE_SLOTS_DEFINITION.id,
		label = L[Core.FREE_SLOTS_DEFINITION.labelKey] or Core.FREE_SLOTS_DEFINITION.labelKey,
		color = Core.FREE_SLOTS_DEFINITION.color,
	}
	orderedDefinitions[#orderedDefinitions + 1] = freeSlotsDefinition
	definitionMap[freeSlotsDefinition.id] = freeSlotsDefinition

	return orderedDefinitions, definitionMap
end

local function sortLayoutSections(layoutData)
	if not layoutData or not layoutData.sectionDefinitions then
		return
	end

	local builtinSectionSortModes = {
		equipment = "itemLevel",
		consumables = "count",
		tradegoods = "count",
		recipes = "quality",
		quest = "quality",
		misc = "quality",
	}
	local sortCache = {}

	local function getResolvedSectionSortMode(sectionDefinition)
		if not sectionDefinition then
			return nil
		end

		if sectionDefinition.sortMode and sectionDefinition.sortMode ~= "default" then
			return sectionDefinition.sortMode
		end

		if not sectionDefinition.isCustom then
			return builtinSectionSortModes[sectionDefinition.id]
		end

		return nil
	end

	local function getMappingSortData(mapping, sortMode)
		if not mapping then
			return nil
		end

		local cached = sortCache[mapping]
		if cached then
			return cached
		end

		local info = mapping.itemInfo or C_Container.GetContainerItemInfo(mapping.bagID, mapping.slotID)
		local itemRef = info and (info.hyperlink or info.itemID)
		local ruleItemInfo = itemRef and getCachedRuleItemInfo and getCachedRuleItemInfo(itemRef) or nil
		local itemName = (ruleItemInfo and ruleItemInfo.itemName) or (itemRef and GetItemInfo(itemRef)) or ""
		local quality = tonumber(info and info.quality) or tonumber(ruleItemInfo and ruleItemInfo.itemQuality) or -1
		local count = tonumber(mapping.itemCount) or tonumber(info and info.stackCount) or tonumber(mapping.freeSlotCount) or 0
		local sellPrice = tonumber(ruleItemInfo and ruleItemInfo.sellPrice) or 0
		local itemLink = info and info.hyperlink
		local data = {
			bagID = tonumber(mapping.bagID) or 0,
			slotID = tonumber(mapping.slotID) or 0,
			name = string.lower(tostring(itemName or "")),
			quality = quality,
			count = count,
			totalSellPrice = sellPrice * math.max(1, count),
			expansionID = tonumber(ruleItemInfo and ruleItemInfo.expansionID) or -1,
			itemLevel = 0,
			keystoneLevel = 0,
		}

		if sortMode == "itemLevel" then
			local itemLocation = ItemLocation:CreateFromBagAndSlot(mapping.bagID, mapping.slotID)
			if itemLocation and C_Item.DoesItemExist(itemLocation) and C_Item.GetCurrentItemLevel then
				local currentItemLevel = C_Item.GetCurrentItemLevel(itemLocation)
				data.itemLevel = tonumber(currentItemLevel) or 0
			end
			if data.itemLevel <= 0 and itemRef and C_Item.GetDetailedItemLevelInfo then
				local detailedItemLevel = C_Item.GetDetailedItemLevelInfo(itemRef)
				data.itemLevel = tonumber(detailedItemLevel) or 0
			end
		elseif sortMode == "keystoneLevel" then
			data.keystoneLevel = tonumber(getKeystoneLevelFromItemLink(itemLink)) or 0
		end

		sortCache[mapping] = data
		return data
	end

	local function compareSectionMappingIndices(leftIndex, rightIndex, sortMode)
		local leftMapping = state.slotMappings[leftIndex]
		local rightMapping = state.slotMappings[rightIndex]
		if not leftMapping or not rightMapping then
			return (leftIndex or 0) < (rightIndex or 0)
		end

		local leftData = getMappingSortData(leftMapping, sortMode) or {}
		local rightData = getMappingSortData(rightMapping, sortMode) or {}

		if sortMode == "itemLevel" and leftData.itemLevel ~= rightData.itemLevel then
			return leftData.itemLevel > rightData.itemLevel
		end
		if sortMode == "quality" and leftData.quality ~= rightData.quality then
			return leftData.quality > rightData.quality
		end
		if sortMode == "name" and leftData.name ~= rightData.name then
			return leftData.name < rightData.name
		end
		if sortMode == "count" and leftData.count ~= rightData.count then
			return leftData.count > rightData.count
		end
		if sortMode == "sellPrice" and leftData.totalSellPrice ~= rightData.totalSellPrice then
			return leftData.totalSellPrice > rightData.totalSellPrice
		end
		if sortMode == "expansion" and leftData.expansionID ~= rightData.expansionID then
			return leftData.expansionID > rightData.expansionID
		end
		if sortMode == "keystoneLevel" and leftData.keystoneLevel ~= rightData.keystoneLevel then
			return leftData.keystoneLevel > rightData.keystoneLevel
		end

		if leftData.quality ~= rightData.quality then
			return leftData.quality > rightData.quality
		end
		if leftData.name ~= rightData.name then
			return leftData.name < rightData.name
		end
		if leftData.bagID ~= rightData.bagID then
			return leftData.bagID < rightData.bagID
		end
		return leftData.slotID < rightData.slotID
	end

	for _, definition in ipairs(layoutData.sectionDefinitions) do
		local section = layoutData.sectionMap[definition.id]
		local sortMode = getResolvedSectionSortMode(definition)
		if section and sortMode and #section.slotIndices > 1 then
			table.sort(section.slotIndices, function(leftIndex, rightIndex)
				return compareSectionMappingIndices(leftIndex, rightIndex, sortMode)
			end)
		end
	end
end

local function getTrackedCurrencySignature(settings)
	local tracked = addon.GetTrackedCurrencyIDs and addon.GetTrackedCurrencyIDs() or (settings and settings.trackedCurrencyIDs or {})
	local signature = {}
	for _, currencyID in ipairs(tracked or {}) do
		currencyID = tonumber(currencyID)
		if currencyID and currencyID > 0 then
			signature[#signature + 1] = tostring(currencyID)
		end
	end
	return table.concat(signature, ":")
end

local function getFooterLayoutSignature(settings, frameWidth)
	return table.concat({
		tostring(frameWidth or 0),
		settings and settings.showGold ~= false and "1" or "0",
		addon.GetMoneyFormat and addon.GetMoneyFormat() or tostring(settings and settings.moneyFormat or "symbols"),
		settings and settings.showCurrencies ~= false and "1" or "0",
		settings and settings.showWatchedCurrencies ~= false and "1" or "0",
		settings and settings.showFooterSlotSummary ~= false and "1" or "0",
		tostring(getOutsideFooterPadding(settings)),
		getTrackedCurrencySignature(settings),
	}, "|")
end

local function refreshFooterData(layoutData)
	if not layoutData or not layoutData.footer then
		return
	end

	layoutData.footer.money = GetMoney()
	layoutData.footer.currencies = buildCurrencyEntries()
	state.footerDirty = false
end

getCachedRuleItemInfo = function(itemRef)
	if not itemRef then
		return nil
	end

	local cacheKey = itemRef
	local cachedInfo = state.itemRuleDataCache[cacheKey]
	if cachedInfo and cachedInfo.loaded then
		return cachedInfo
	end

	local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType, expansionID, setID, isCraftingReagent, itemDescription
	if C_Item and C_Item.GetItemInfo then
		itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType, expansionID, setID, isCraftingReagent, itemDescription = C_Item.GetItemInfo(itemRef)
	else
		itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType, expansionID, setID, isCraftingReagent, itemDescription = GetItemInfo(itemRef)
	end

	cachedInfo = cachedInfo or {}
	cachedInfo.loaded = itemName ~= nil
	cachedInfo.itemName = itemName
	cachedInfo.itemLink = itemLink
	cachedInfo.itemQuality = itemQuality
	cachedInfo.itemLevel = itemLevel
	cachedInfo.itemMinLevel = itemMinLevel
	cachedInfo.itemType = itemType
	cachedInfo.itemSubType = itemSubType
	cachedInfo.itemStackCount = itemStackCount
	cachedInfo.itemEquipLoc = itemEquipLoc
	cachedInfo.itemTexture = itemTexture
	cachedInfo.sellPrice = sellPrice
	cachedInfo.classID = classID
	cachedInfo.subclassID = subclassID
	cachedInfo.bindType = bindType
	cachedInfo.expansionID = expansionID
	cachedInfo.setID = setID
	cachedInfo.isCraftingReagent = isCraftingReagent
	cachedInfo.itemDescription = itemDescription
	state.itemRuleDataCache[cacheKey] = cachedInfo

	return cachedInfo
end

local function getCurrentCategoryRulesRevision()
	return addon.GetCategoryRulesRevision and addon.GetCategoryRulesRevision() or 0
end

local function doesRuleUsageDependOnPlayerState(usage)
	return usage and (usage.recommendedForClass or usage.recommendedForSpec or usage.isUpgrade) and true or false
end

local function bumpPlayerRuleRevision()
	state.playerRuleRevision = (state.playerRuleRevision or 0) + 1
end

local function getSlotCategoryCacheBucket(bagID, create)
	if bagID == nil then
		return nil
	end

	local bucket = state.slotCategoryCache[bagID]
	if not bucket and create then
		bucket = {}
		state.slotCategoryCache[bagID] = bucket
	end

	return bucket
end

local function getSlotCategoryCacheEntry(bagID, slotID)
	local bucket = getSlotCategoryCacheBucket(bagID, false)
	return bucket and bucket[slotID] or nil
end

local function setSlotCategoryCacheEntry(bagID, slotID, entry)
	local bucket = getSlotCategoryCacheBucket(bagID, true)
	bucket[slotID] = entry
end

local function clearSlotCategoryCacheEntry(bagID, slotID)
	local bucket = getSlotCategoryCacheBucket(bagID, false)
	if bucket then
		bucket[slotID] = nil
	end
end

local function isSlotCategoryCacheEntryValid(entry, bagID, slotID, info, questInfo, settings, ruleRuntimeContext, hasCustomCategories)
	if not entry or not entry.stable then
		return false
	end

	local showCategories = not not (settings and settings.showCategories)
	local combineDuplicates = not not (settings and settings.combineUnstackableItems)
	local itemLink = info and info.hyperlink or false
	local itemID = info and info.itemID or false
	local quality = info and info.quality or false
	local stackCount = info and info.stackCount or false
	local isBound = info and info.isBound or false
	local questID = questInfo and questInfo.questID or false
	local isQuestItem = questInfo and questInfo.isQuestItem or false
	local isNewItem = isOpenSessionNewItem(bagID, slotID, info)
	local categoryRulesRevision = ruleRuntimeContext and ruleRuntimeContext.categoryRulesRevision or 0
	local playerRuleRevision = ruleRuntimeContext and ruleRuntimeContext.playerRuleRevision or 0

	return entry.showCategories == showCategories
		and entry.combineDuplicates == combineDuplicates
		and entry.hasCustomCategories == hasCustomCategories
		and entry.categoryRulesRevision == categoryRulesRevision
		and entry.playerRuleRevision == playerRuleRevision
		and entry.itemLink == itemLink
		and entry.itemID == itemID
		and entry.quality == quality
		and entry.stackCount == stackCount
		and entry.isBound == isBound
		and entry.questID == questID
		and entry.isQuestItem == isQuestItem
		and entry.isNewItem == isNewItem
end

local function getCachedResolvedCategoryData(bagID, slotID, info, questInfo, settings, ruleRuntimeContext, hasCustomCategories)
	local entry = getSlotCategoryCacheEntry(bagID, slotID)
	if not isSlotCategoryCacheEntryValid(entry, bagID, slotID, info, questInfo, settings, ruleRuntimeContext, hasCustomCategories) then
		return nil
	end

	return entry.sectionID, entry.collapseRef ~= false and entry.collapseRef or nil
end

local function updateResolvedCategoryCache(
	bagID,
	slotID,
	info,
	questInfo,
	settings,
	ruleRuntimeContext,
	hasCustomCategories,
	sectionID,
	collapseRef,
	stable
)
	if not stable then
		clearSlotCategoryCacheEntry(bagID, slotID)
		return
	end

	setSlotCategoryCacheEntry(bagID, slotID, {
		stable = true,
		showCategories = not not (settings and settings.showCategories),
		combineDuplicates = not not (settings and settings.combineUnstackableItems),
		hasCustomCategories = hasCustomCategories,
		categoryRulesRevision = ruleRuntimeContext and ruleRuntimeContext.categoryRulesRevision or 0,
		playerRuleRevision = ruleRuntimeContext and ruleRuntimeContext.playerRuleRevision or 0,
		itemLink = info and info.hyperlink or false,
		itemID = info and info.itemID or false,
		quality = info and info.quality or false,
		stackCount = info and info.stackCount or false,
		isBound = info and info.isBound or false,
		questID = questInfo and questInfo.questID or false,
		isQuestItem = questInfo and questInfo.isQuestItem or false,
		isNewItem = isOpenSessionNewItem(bagID, slotID, info),
		sectionID = sectionID,
		collapseRef = collapseRef or false,
	})
end

local function createRuleRuntimeContext(usage)
	local hasPlayerStateUsage = doesRuleUsageDependOnPlayerState(usage)
	local runtimeContext = {
		usage = usage or {},
		hasUsage = usage and next(usage) ~= nil or false,
		hasPlayerStateUsage = hasPlayerStateUsage,
		equippedItemLevels = {},
		equippedItemLevelKnown = {},
		equippedItemExists = {},
		equippedItemEquipLocs = {},
		tooltipBindTypes = {},
		persistentTooltipBindTypes = state.tooltipBindTypeCache,
		recommendationCache = {},
		upgradeTrackCache = {},
		categoryRulesRevision = getCurrentCategoryRulesRevision(),
		playerRuleRevision = hasPlayerStateUsage and (state.playerRuleRevision or 0) or 0,
		itemContext = {},
	}

	if hasPlayerStateUsage then
		local _, _, classID = UnitClass("player")
		runtimeContext.playerClassID = classID

		local specIndex = C_SpecializationInfo and C_SpecializationInfo.GetSpecialization and C_SpecializationInfo.GetSpecialization()
		if specIndex and specIndex > 0 and C_SpecializationInfo and C_SpecializationInfo.GetSpecializationInfo then
			runtimeContext.playerSpecID = C_SpecializationInfo.GetSpecializationInfo(specIndex)
		end
	end

	return runtimeContext
end

local function getEquippedItemLevel(runtimeContext, inventorySlot)
	if not runtimeContext or not inventorySlot then
		return 0, true, false
	end

	local cachedLevel = runtimeContext.equippedItemLevels[inventorySlot]
	if cachedLevel ~= nil then
		return cachedLevel, runtimeContext.equippedItemLevelKnown[inventorySlot] ~= false, runtimeContext.equippedItemExists[inventorySlot] == true
	end

	local equippedLevel = 0
	local hasEquippedItem = false
	local isReliable = false
	local equippedLocation = ItemLocation and ItemLocation:CreateFromEquipmentSlot(inventorySlot) or nil
	if equippedLocation and C_Item and C_Item.DoesItemExist and C_Item.DoesItemExist(equippedLocation) then
		hasEquippedItem = true
		equippedLevel = C_Item.GetCurrentItemLevel and C_Item.GetCurrentItemLevel(equippedLocation) or 0
	end

	if (not equippedLevel or equippedLevel <= 0) then
		local equippedLink = GetInventoryItemLink("player", inventorySlot)
		hasEquippedItem = hasEquippedItem or equippedLink ~= nil or GetInventoryItemID("player", inventorySlot) ~= nil
		equippedLevel = equippedLink and C_Item.GetDetailedItemLevelInfo and C_Item.GetDetailedItemLevelInfo(equippedLink) or equippedLevel
	end

	equippedLevel = tonumber(equippedLevel) or 0
	if not hasEquippedItem and equippedLevel <= 0 then
		isReliable = true
	elseif equippedLevel > 0 then
		isReliable = true
	end

	runtimeContext.equippedItemLevels[inventorySlot] = equippedLevel
	runtimeContext.equippedItemLevelKnown[inventorySlot] = isReliable
	runtimeContext.equippedItemExists[inventorySlot] = hasEquippedItem
	return equippedLevel, isReliable, hasEquippedItem
end

local function getEquippedItemEquipLoc(runtimeContext, inventorySlot)
	if not runtimeContext or not inventorySlot then
		return nil
	end

	local cachedEquipLoc = runtimeContext.equippedItemEquipLocs[inventorySlot]
	if cachedEquipLoc ~= nil then
		return cachedEquipLoc or nil
	end

	local equippedRef = GetInventoryItemLink("player", inventorySlot) or GetInventoryItemID("player", inventorySlot)
	local equipLoc = equippedRef and select(4, GetItemInfoInstant(equippedRef)) or nil
	runtimeContext.equippedItemEquipLocs[inventorySlot] = equipLoc or false
	return equipLoc
end

local function isTwoHandWeaponEquipLoc(equipLoc)
	return equipLoc == "INVTYPE_2HWEAPON" or equipLoc == "INVTYPE_RANGED" or equipLoc == "INVTYPE_RANGEDRIGHT"
end

local function isOneHandWeaponEquipLoc(equipLoc)
	return equipLoc == "INVTYPE_WEAPON" or equipLoc == "INVTYPE_WEAPONOFFHAND" or equipLoc == "INVTYPE_WEAPONMAINHAND"
end

local function getTooltipResolvedBindType(bagID, slotID, info, runtimeContext)
	if not runtimeContext or not Core.GET_BAG_ITEM_TOOLTIP or bagID == nil or slotID == nil then
		return nil
	end

	local cacheKey = tostring(bagID) .. ":" .. tostring(slotID)
	local cachedBindType = runtimeContext.tooltipBindTypes[cacheKey]
	if cachedBindType ~= nil then
		return cachedBindType or nil
	end

	local itemLink = info and info.hyperlink or false
	local itemID = info and info.itemID or false
	local isBound = info and info.isBound or false
	local persistentCache = runtimeContext.persistentTooltipBindTypes
	local persistentEntry = persistentCache and persistentCache[cacheKey]
	if persistentEntry
		and persistentEntry.itemLink == itemLink
		and persistentEntry.itemID == itemID
		and persistentEntry.isBound == isBound
	then
		local persistentBindType = persistentEntry.bindType
		runtimeContext.tooltipBindTypes[cacheKey] = persistentBindType or false
		return persistentBindType or nil
	end

	local resolvedBindType
	local tooltipData = Core.GET_BAG_ITEM_TOOLTIP(bagID, slotID)
	local lines = tooltipData and tooltipData.lines
	if lines then
		for _, line in ipairs(lines) do
			if line.type == 20 then
				local text = line.leftText
				if text == ITEM_BIND_ON_PICKUP then
					resolvedBindType = 1
				elseif text == ITEM_BIND_ON_EQUIP then
					resolvedBindType = 2
				elseif text == ITEM_BIND_ON_USE then
					resolvedBindType = 3
				elseif text == ITEM_BIND_QUEST then
					resolvedBindType = 4
				elseif text == ITEM_ACCOUNTBOUND or text == ITEM_BIND_TO_ACCOUNT then
					resolvedBindType = 7
				elseif text == ITEM_BIND_TO_BNETACCOUNT then
					resolvedBindType = 8
				elseif text == ITEM_ACCOUNTBOUND_UNTIL_EQUIP or text == ITEM_BIND_TO_ACCOUNT_UNTIL_EQUIP then
					resolvedBindType = 9
				end

				if resolvedBindType ~= nil then
					break
				end
			end
		end
	end

	runtimeContext.tooltipBindTypes[cacheKey] = resolvedBindType or false
	if persistentCache then
		persistentCache[cacheKey] = {
			itemLink = itemLink,
			itemID = itemID,
			isBound = isBound,
			bindType = resolvedBindType or false,
		}
	end
	return resolvedBindType
end

local function getUpgradeComparisonSlots(equipLoc, runtimeContext)
	if not equipLoc then
		return nil, nil
	end

	local mainhandSlot = INVSLOT_MAINHAND or 16
	local offhandSlot = INVSLOT_OFFHAND or 17

	if equipLoc == "INVTYPE_2HWEAPON" then
		local mainhandEquipLoc = getEquippedItemEquipLoc(runtimeContext, mainhandSlot)
		local offhandEquipLoc = getEquippedItemEquipLoc(runtimeContext, offhandSlot)
		local offhandOccupied = (offhandEquipLoc and offhandEquipLoc ~= "") or getEquippedItemLevel(runtimeContext, offhandSlot) > 0
		local isDualTwoHandLoadout = isTwoHandWeaponEquipLoc(mainhandEquipLoc)
			and isTwoHandWeaponEquipLoc(offhandEquipLoc)
			and type(IsDualWielding) == "function"
			and IsDualWielding()

		if offhandOccupied and not isDualTwoHandLoadout then
			return { mainhandSlot, offhandSlot }, "all"
		end

		if isDualTwoHandLoadout then
			return { mainhandSlot, offhandSlot }, "any"
		end

		return { mainhandSlot }, "any"
	end

	if equipLoc == "INVTYPE_WEAPON" then
		local comparisonSlots = { mainhandSlot }
		local mainhandEquipLoc = getEquippedItemEquipLoc(runtimeContext, mainhandSlot)
		local canCompareOffhand = type(CanDualWield) == "function" and CanDualWield() and not isTwoHandWeaponEquipLoc(mainhandEquipLoc)
		if canCompareOffhand then
			local offhandEquipLoc = getEquippedItemEquipLoc(runtimeContext, offhandSlot)
			local offhandEmpty = not offhandEquipLoc or offhandEquipLoc == ""
			local offhandHasWeapon = isOneHandWeaponEquipLoc(offhandEquipLoc)
			if offhandEmpty or offhandHasWeapon then
				comparisonSlots[#comparisonSlots + 1] = offhandSlot
			end
		end
		return comparisonSlots, "any"
	end

	if equipLoc == "INVTYPE_SHIELD" or equipLoc == "INVTYPE_WEAPONOFFHAND" or equipLoc == "INVTYPE_HOLDABLE" then
		local mainhandEquipLoc = getEquippedItemEquipLoc(runtimeContext, mainhandSlot)
		if isTwoHandWeaponEquipLoc(mainhandEquipLoc) then
			return nil, nil
		end
	end

	return Core.EQUIP_LOCATION_COMPARISON_SLOTS[equipLoc], "any"
end

local function getRuleUpgradeTrackKey(itemRef, runtimeContext)
	if not itemRef or not runtimeContext then
		return nil
	end

	local cacheKey = itemRef
	if runtimeContext.upgradeTrackCache[cacheKey] ~= nil then
		return runtimeContext.upgradeTrackCache[cacheKey] or nil
	end

	local upgradeInfo = C_Item and C_Item.GetItemUpgradeInfo and C_Item.GetItemUpgradeInfo(itemRef)
	local trackKey = addon.NormalizeUpgradeTrackKey and addon.NormalizeUpgradeTrackKey(upgradeInfo and upgradeInfo.trackStringID, upgradeInfo and upgradeInfo.trackString) or nil
	runtimeContext.upgradeTrackCache[cacheKey] = trackKey or false
	return trackKey
end

local function getRecommendationFlags(itemRef, itemID, runtimeContext)
	if not itemRef or not runtimeContext or not runtimeContext.playerClassID then
		return false, false
	end

	local cacheKey = itemRef
	local cachedFlags = runtimeContext.recommendationCache[cacheKey]
	if cachedFlags then
		return cachedFlags.recommendedForClass, cachedFlags.recommendedForSpec
	end

	local recommendedForClass = false
	local recommendedForSpec = false
	local hasSpecData = false

	if C_Item and C_Item.IsEquippableItem and not C_Item.IsEquippableItem(itemRef) then
		runtimeContext.recommendationCache[cacheKey] = {
			recommendedForClass = false,
			recommendedForSpec = false,
		}
		return false, false
	end

	local specTable = C_Item and C_Item.GetItemSpecInfo and C_Item.GetItemSpecInfo(itemRef)
	hasSpecData = type(specTable) == "table" and next(specTable) ~= nil

	if hasSpecData then
		for _, specID in ipairs(specTable) do
			if runtimeContext.playerSpecID and specID == runtimeContext.playerSpecID then
				recommendedForSpec = true
			end
			if C_SpecializationInfo and C_SpecializationInfo.GetClassIDFromSpecID and C_SpecializationInfo.GetClassIDFromSpecID(specID) == runtimeContext.playerClassID then
				recommendedForClass = true
			end
		end
	else
		if C_Item and C_Item.DoesItemContainSpec then
			recommendedForClass = C_Item.DoesItemContainSpec(itemRef, runtimeContext.playerClassID, 0)
			if runtimeContext.playerSpecID then
				recommendedForSpec = C_Item.DoesItemContainSpec(itemRef, runtimeContext.playerClassID, runtimeContext.playerSpecID)
			end
		end

		if not recommendedForClass and itemID and C_PlayerInfo and C_PlayerInfo.CanUseItem then
			recommendedForClass = C_PlayerInfo.CanUseItem(itemID)
		end

		recommendedForSpec = recommendedForClass
	end

	recommendedForClass = not not recommendedForClass
	recommendedForSpec = not not recommendedForSpec

	runtimeContext.recommendationCache[cacheKey] = {
		recommendedForClass = recommendedForClass,
		recommendedForSpec = recommendedForSpec,
	}

	return recommendedForClass, recommendedForSpec
end

local function isRuleUpgradeItem(equipLoc, itemLevel, recommendedForSpec, runtimeContext)
	if not recommendedForSpec or not equipLoc then
		return false, true
	end

	itemLevel = tonumber(itemLevel)
	if not itemLevel or itemLevel <= 0 then
		return false, true
	end

	local comparisonSlots, comparisonMode = getUpgradeComparisonSlots(equipLoc, runtimeContext)
	if not comparisonSlots or #comparisonSlots == 0 then
		return false, true
	end

	if comparisonMode == "all" then
		local hasComparedSlot = false
		local hasUnknownComparedSlot = false
		for _, inventorySlot in ipairs(comparisonSlots) do
			local equippedLevel, isReliable, hasEquippedItem = getEquippedItemLevel(runtimeContext, inventorySlot)
			if hasEquippedItem then
				if not isReliable then
					hasUnknownComparedSlot = true
				else
					hasComparedSlot = true
					if itemLevel <= equippedLevel then
						return false, true
					end
				end
			end
		end

		if hasUnknownComparedSlot then
			return false, false
		end

		return hasComparedSlot, true
	end

	local baselineLevel
	local hasComparedSlot = false
	local hasUnknownComparedSlot = false
	local hasEmptyComparisonSlot = false
	for _, inventorySlot in ipairs(comparisonSlots) do
		local equippedLevel, isReliable, hasEquippedItem = getEquippedItemLevel(runtimeContext, inventorySlot)
		if hasEquippedItem then
			if not isReliable then
				hasUnknownComparedSlot = true
			else
				hasComparedSlot = true
				if baselineLevel == nil or equippedLevel < baselineLevel then
					baselineLevel = equippedLevel
				end
			end
		else
			hasComparedSlot = true
			hasEmptyComparisonSlot = true
			if baselineLevel == nil or baselineLevel > 0 then
				baselineLevel = 0
			end
		end
	end

	if hasUnknownComparedSlot and not hasEmptyComparisonSlot then
		return false, false
	end

	return hasComparedSlot and baselineLevel ~= nil and itemLevel > baselineLevel, true
end

local function getDefaultCategoryForItem(info, questInfo, equipLoc, classID)
	if questInfo and (questInfo.isQuestItem or questInfo.questID) then
		return "quest"
	end

	local itemRef = info and (info.hyperlink or info.itemID)
	if not itemRef then
		return "misc"
	end

	equipLoc = equipLoc or select(4, GetItemInfoInstant(itemRef))
	classID = classID or select(6, GetItemInfoInstant(itemRef))

	if C_Item and C_Item.IsCosmeticItem then
		local ok, isCosmetic = pcall(C_Item.IsCosmeticItem, itemRef)
		if ok and isCosmetic then
			return "equipment"
		end
	end

	if equipLoc and equipLoc ~= "" and not Core.IGNORED_ITEM_LEVEL_EQUIP_LOCS[equipLoc] then
		return "equipment"
	end

	if classID == Core.ITEM_CLASS.Weapon or classID == Core.ITEM_CLASS.Armor then
		return "equipment"
	elseif classID == Core.ITEM_CLASS.Consumable then
		return "consumables"
	elseif classID == Core.ITEM_CLASS.Tradegoods then
		return "tradegoods"
	elseif classID == Core.ITEM_CLASS.Recipe then
		return "recipes"
	end

	return "misc"
end

local function ensureSection(layoutData, sectionID)
	local section = layoutData.sectionMap[sectionID]
	if section then
		return section
	end

	local definition = layoutData.sectionDefinitionsByID[sectionID] or {}
	section = {
		id = sectionID,
		label = definition.label,
		color = definition.color or { 1, 1, 1 },
		isCustom = definition.isCustom,
		groupID = definition.groupID,
		groupLabel = definition.groupLabel,
		groupColor = definition.groupColor,
		groupCollapseID = definition.groupCollapseID,
		collapsible = definition.collapsible ~= false,
		columnCount = tonumber(definition.columnCount) or nil,
		forceHeader = definition.forceHeader == true,
		slotIndices = {},
	}
	layoutData.sectionMap[sectionID] = section
	return section
end

local function resolveCategoryForItem(bagID, slotID, info, questInfo, settings, ruleRuntimeContext, hasCustomCategories)
	local cachedSectionID, cachedCollapseRef = getCachedResolvedCategoryData(
		bagID,
		slotID,
		info,
		questInfo,
		settings,
		ruleRuntimeContext,
		hasCustomCategories
	)
	if cachedSectionID then
		return cachedSectionID, cachedCollapseRef
	end

	local showCategories = not not (settings and settings.showCategories)
	local combineDuplicates = not not (settings and settings.combineUnstackableItems)
	local itemRef = info and (info.hyperlink or info.itemID)
	local sectionID = "misc"
	local collapseRef = nil
	local stable = true
	local ruleItemInfo

	if showCategories then
		local equipLoc, _, classID, subClassID = nil, nil, nil, nil
		if itemRef then
			_, _, _, equipLoc, _, classID, subClassID = GetItemInfoInstant(itemRef)
		end
		local defaultCategory = getDefaultCategoryForItem(info, questInfo, equipLoc, classID)
		sectionID = addon.NormalizeCategorySectionID and addon.NormalizeCategorySectionID(defaultCategory) or defaultCategory

		if hasCustomCategories and addon.GetMatchingCustomCategoryID then
		local usage = ruleRuntimeContext and ruleRuntimeContext.usage or {}
			ruleItemInfo = ruleRuntimeContext and ruleRuntimeContext.hasUsage and getCachedRuleItemInfo(itemRef) or nil
			if ruleRuntimeContext and ruleRuntimeContext.hasUsage and itemRef and not (ruleItemInfo and ruleItemInfo.loaded) then
				stable = false
				state.awaitingRuleItemData = true
				local itemID = tonumber(info and info.itemID)
				if itemID and itemID > 0 then
					state.pendingRuleItemDataIDs[itemID] = true
					if C_Item and C_Item.RequestLoadItemDataByID then
						C_Item.RequestLoadItemDataByID(itemID)
					end
				end
			end

			local resolvedItemLevel
			local itemLocation
			if usage.itemLevel or usage.isUpgrade or usage.canAuctionHouseSell then
				itemLocation = ItemLocation:CreateFromBagAndSlot(bagID, slotID)
			end
			if usage.itemLevel or usage.isUpgrade then
				resolvedItemLevel = ruleItemInfo and ruleItemInfo.itemLevel or nil

				if itemLocation and C_Item.DoesItemExist(itemLocation) and C_Item.GetCurrentItemLevel then
					resolvedItemLevel = C_Item.GetCurrentItemLevel(itemLocation) or resolvedItemLevel
				end

				if (not resolvedItemLevel or resolvedItemLevel <= 0) and itemRef and C_Item.GetDetailedItemLevelInfo then
					resolvedItemLevel = C_Item.GetDetailedItemLevelInfo(itemRef) or resolvedItemLevel
				end

				if usage.itemLevel or usage.isUpgrade then
					resolvedItemLevel = tonumber(resolvedItemLevel) or nil
					if not resolvedItemLevel or resolvedItemLevel <= 0 then
						stable = false
					end
				end
			end

			classID = (ruleItemInfo and ruleItemInfo.classID) or classID
			subClassID = (ruleItemInfo and ruleItemInfo.subclassID) or subClassID
			equipLoc = (ruleItemInfo and ruleItemInfo.itemEquipLoc) or equipLoc
			local recommendedForClass
			local recommendedForSpec
			if usage.recommendedForClass or usage.recommendedForSpec or usage.isUpgrade then
				recommendedForClass, recommendedForSpec = getRecommendationFlags(itemRef, info and info.itemID, ruleRuntimeContext)
			end

			local upgradeTrackKey
			if usage.upgradeTrackKey then
				upgradeTrackKey = getRuleUpgradeTrackKey(itemRef, ruleRuntimeContext)
			end

			local canAuctionHouseSell
			if usage.canAuctionHouseSell then
				stable = false
				canAuctionHouseSell = itemLocation and itemLocation:IsValid() and C_AuctionHouse and C_AuctionHouse.IsSellItemValid and C_AuctionHouse.IsSellItemValid(itemLocation, false) or false
			end

			local resolvedBindType = ruleItemInfo and ruleItemInfo.bindType or nil
			if usage.bindType then
				local tooltipBindType = getTooltipResolvedBindType(bagID, slotID, info, ruleRuntimeContext)
				if tooltipBindType ~= nil then
					resolvedBindType = tooltipBindType
				end
			end

			local itemContext = ruleRuntimeContext and ruleRuntimeContext.itemContext or {}
			if next(itemContext) ~= nil and wipe then
				wipe(itemContext)
			end
			itemContext.bagID = bagID
			itemContext.slotID = slotID
			itemContext.itemID = info and info.itemID
			itemContext.itemName = ruleItemInfo and ruleItemInfo.itemName or nil
			itemContext.itemLink = (ruleItemInfo and ruleItemInfo.itemLink) or (info and info.hyperlink)
			itemContext.itemDescription = ruleItemInfo and ruleItemInfo.itemDescription or nil
			itemContext.quality = (ruleItemInfo and ruleItemInfo.itemQuality) or (info and info.quality)
			itemContext.itemLevel = resolvedItemLevel
			itemContext.itemMinLevel = ruleItemInfo and ruleItemInfo.itemMinLevel or nil
			itemContext.itemType = ruleItemInfo and ruleItemInfo.itemType or nil
			itemContext.itemSubType = ruleItemInfo and ruleItemInfo.itemSubType or nil
			itemContext.itemStackCount = (ruleItemInfo and ruleItemInfo.itemStackCount) or (info and info.stackCount) or 0
			itemContext.itemTexture = (ruleItemInfo and ruleItemInfo.itemTexture) or (info and info.iconFileID)
			itemContext.sellPrice = (ruleItemInfo and ruleItemInfo.sellPrice) or 0
			itemContext.classID = classID
			itemContext.subClassID = subClassID
			itemContext.subClassKey = classID and subClassID and string.format("%d:%d", classID, subClassID) or nil
			itemContext.professionGroupKey = addon.GetProfessionGroupKeyForItem and addon.GetProfessionGroupKeyForItem(classID, subClassID) or nil
			itemContext.bindType = resolvedBindType
			itemContext.expansionID = ruleItemInfo and ruleItemInfo.expansionID or nil
			itemContext.setID = ruleItemInfo and ruleItemInfo.setID or nil
			itemContext.isCraftingReagent = not not (ruleItemInfo and ruleItemInfo.isCraftingReagent)
			itemContext.isBound = info and info.isBound
			itemContext.recommendedForSpec = not not recommendedForSpec
			itemContext.recommendedForClass = not not recommendedForClass
			if usage.isUpgrade then
				local isUpgrade, upgradeEvaluationStable = isRuleUpgradeItem(equipLoc, resolvedItemLevel, recommendedForSpec, ruleRuntimeContext)
				itemContext.isUpgrade = isUpgrade
				itemContext.upgradeEvaluationStable = upgradeEvaluationStable
				if not upgradeEvaluationStable then
					stable = false
				end
			else
				itemContext.isUpgrade = false
				itemContext.upgradeEvaluationStable = true
			end
			itemContext.upgradeTrackKey = upgradeTrackKey
			itemContext.canVendor = ((ruleItemInfo and ruleItemInfo.sellPrice) or 0) > 0
			itemContext.canAuctionHouseSell = not not canAuctionHouseSell
			itemContext.isHearthstone = usage.isHearthstone and isRuleHearthstoneItem(info and info.itemID) or false
			itemContext.isKeystone = usage.isKeystone and isKeystoneItem(info and info.itemID) or false
			itemContext.equipLoc = equipLoc
			itemContext.defaultCategory = defaultCategory
			itemContext.isQuestItem = questInfo and questInfo.isQuestItem or false
			itemContext.questID = questInfo and questInfo.questID or nil

			local customCategoryID = addon.GetMatchingCustomCategoryID and addon.GetMatchingCustomCategoryID(itemContext)
			if customCategoryID then
				sectionID = addon.NormalizeCategorySectionID and addon.NormalizeCategorySectionID(customCategoryID) or customCategoryID
			end
		end
	end

	if isOpenSessionNewItem(bagID, slotID, info) then
		sectionID = "newItems"
	end

	if combineDuplicates then
		collapseRef = getCollapsedItemRef(info, ruleItemInfo)
	end

	updateResolvedCategoryCache(
		bagID,
		slotID,
		info,
		questInfo,
		settings,
		ruleRuntimeContext,
		hasCustomCategories,
		sectionID,
		collapseRef,
		stable
	)
	return sectionID, collapseRef
end

local function addSlotMapping(layoutData, sectionID, bagID, slotID, extraData)
	local section = ensureSection(layoutData, sectionID)
	local index = layoutData.requiredButtonCount + 1
	local mapping = state.slotMappings[index] or {}
	mapping.bagID = bagID
	mapping.slotID = slotID
	mapping.freeSlotGroup = extraData and extraData.freeSlotGroup or nil
	mapping.freeSlotCount = extraData and extraData.freeSlotCount or nil
	mapping.itemCount = extraData and extraData.itemCount or nil
	mapping.itemInfo = extraData and extraData.itemInfo or nil
	mapping.questInfo = extraData and extraData.questInfo or nil
	state.slotMappings[index] = mapping

	layoutData.requiredButtonCount = index
	section.slotIndices[#section.slotIndices + 1] = index
	return index, mapping
end

local function registerFlatStorageSection(layoutData, sectionID, label, color, columnCount)
	if not layoutData or not sectionID or not label then
		return
	end

	if layoutData.sectionDefinitionsByID[sectionID] then
		return
	end

	layoutData.sectionDefinitionsByID[sectionID] = {
		id = sectionID,
		label = label,
		color = color or { 1, 1, 1 },
		columnCount = tonumber(columnCount) or nil,
		forceHeader = true,
	}
end

local function addFlatStorageContext(layoutData, context)
	if not layoutData or not context or not context.id then
		return
	end

	local sectionID = string.format("storage:%s", tostring(context.id))
	registerFlatStorageSection(layoutData, sectionID, context.label or tostring(context.id), context.color, context.columnCount)

	local hasSlots = false
	for _, bagID in ipairs(context.bagIDs or {}) do
		local slotCount = C_Container.GetContainerNumSlots(bagID) or 0
		layoutData.totalSlotCount = layoutData.totalSlotCount + slotCount

		for slotID = 1, slotCount do
			addSlotMapping(layoutData, sectionID, bagID, slotID)
			hasSlots = true
		end
	end

	if hasSlots then
		layoutData.flatStorageSectionIDs[#layoutData.flatStorageSectionIDs + 1] = sectionID
	end
end

local function buildLayoutData()
	local settings = getSettings()
	local hasCustomCategories = settings.showCategories and addon.HasCustomCategories and addon.HasCustomCategories() or false
	local ruleUsage = hasCustomCategories and addon.GetCategoryRuleContextUsage and addon.GetCategoryRuleContextUsage() or nil
	local ruleRuntimeContext = hasCustomCategories and createRuleRuntimeContext(ruleUsage) or nil
	local layoutData = {
		requiredButtonCount = 0,
		sectionMap = {},
		sections = {},
		sectionDefinitions = {},
		sectionDefinitionsByID = {},
		totalSlotCount = 0,
		footer = {
			normalFree = 0,
			normalTotal = 0,
			reagentFree = 0,
			reagentTotal = 0,
			currencies = {},
			money = GetMoney(),
		},
		combinedFreeSlots = {
			normal = {},
			reagent = {},
		},
		collapsedItems = {},
		flatStorageSectionIDs = {},
	}
	layoutData.sectionDefinitions, layoutData.sectionDefinitionsByID = buildSectionDefinitions()

	for bagID = Core.BACKPACK_ID, Core.LAST_CHARACTER_BAG_ID do
		local slotCount = C_Container.GetContainerNumSlots(bagID) or 0
		local isReagentBag = bagID == Core.REAGENT_BAG_ID

		layoutData.totalSlotCount = layoutData.totalSlotCount + slotCount

		if isReagentBag then
			layoutData.footer.reagentTotal = layoutData.footer.reagentTotal + slotCount
		else
			layoutData.footer.normalTotal = layoutData.footer.normalTotal + slotCount
		end

		for slotID = 1, slotCount do
			local info = C_Container.GetContainerItemInfo(bagID, slotID)
			local hasItem = info and info.iconFileID

			if hasItem then
				local questInfo
				local sectionID = "misc"
				local collapseRef = nil
				if settings.showCategories or settings.combineUnstackableItems or isOpenSessionNewItem(bagID, slotID, info) then
					questInfo = settings.showCategories and C_Container.GetContainerItemQuestInfo(bagID, slotID) or nil
					sectionID, collapseRef = resolveCategoryForItem(
						bagID,
						slotID,
						info,
						questInfo,
						settings,
						ruleRuntimeContext,
						hasCustomCategories
					)
				end
				local itemRef = info and (info.hyperlink or info.itemID)
				if shouldCombineDuplicateItem(itemRef, settings) then
					local collapsedSection = layoutData.collapsedItems[sectionID]
					if not collapsedSection then
						collapsedSection = {}
						layoutData.collapsedItems[sectionID] = collapsedSection
					end
					local collapsedMapping = collapseRef ~= nil and collapsedSection[collapseRef] or nil
					if collapsedMapping then
						collapsedMapping.itemCount = (collapsedMapping.itemCount or 1) + getCollapsedItemCount(info)
					else
						local _, mapping = addSlotMapping(
							layoutData,
							sectionID,
							bagID,
							slotID,
							{
								itemCount = getCollapsedItemCount(info),
								itemInfo = info,
								questInfo = questInfo,
							}
						)
						if collapseRef ~= nil then
							collapsedSection[collapseRef] = mapping
						end
					end
				else
					addSlotMapping(layoutData, sectionID, bagID, slotID, {
						itemInfo = info,
						questInfo = questInfo,
					})
				end
			else
				clearSlotCategoryCacheEntry(bagID, slotID)
				if isReagentBag then
					layoutData.footer.reagentFree = layoutData.footer.reagentFree + 1
					if not layoutData.combinedFreeSlots.reagent.bagID then
						layoutData.combinedFreeSlots.reagent.bagID = bagID
						layoutData.combinedFreeSlots.reagent.slotID = slotID
					end
				else
					layoutData.footer.normalFree = layoutData.footer.normalFree + 1
					if not layoutData.combinedFreeSlots.normal.bagID then
						layoutData.combinedFreeSlots.normal.bagID = bagID
						layoutData.combinedFreeSlots.normal.slotID = slotID
					end
				end

				if settings.showFreeSlots ~= false and not settings.combineFreeSlots then
					local sectionID = settings.showCategories and Core.FREE_SLOTS_SECTION_ID or "misc"
					addSlotMapping(layoutData, sectionID, bagID, slotID)
				end
			end
		end
	end

	if settings.showFreeSlots ~= false and settings.combineFreeSlots then
		local sectionID = settings.showCategories and Core.FREE_SLOTS_SECTION_ID or "misc"

		if layoutData.footer.normalFree > 0 and layoutData.combinedFreeSlots.normal.bagID then
			addSlotMapping(
				layoutData,
				sectionID,
				layoutData.combinedFreeSlots.normal.bagID,
				layoutData.combinedFreeSlots.normal.slotID,
				{
					freeSlotGroup = "normal",
					freeSlotCount = layoutData.footer.normalFree,
				}
			)
		end

		if layoutData.footer.reagentFree > 0 and layoutData.combinedFreeSlots.reagent.bagID then
			addSlotMapping(
				layoutData,
				sectionID,
				layoutData.combinedFreeSlots.reagent.bagID,
				layoutData.combinedFreeSlots.reagent.slotID,
				{
					freeSlotGroup = "reagent",
					freeSlotCount = layoutData.footer.reagentFree,
				}
			)
		end
	end

	sortLayoutSections(layoutData)

	for _, context in ipairs(getVisibleFlatBankContexts()) do
		addFlatStorageContext(layoutData, context)
	end

	if settings.showCategories then
		for _, definition in ipairs(layoutData.sectionDefinitions) do
			local section = layoutData.sectionMap[definition.id]
			if section and #section.slotIndices > 0 then
				layoutData.sections[#layoutData.sections + 1] = section
			end
		end
	else
		local newItemsSection = layoutData.sectionMap.newItems
		if newItemsSection and #newItemsSection.slotIndices > 0 then
			layoutData.sections[#layoutData.sections + 1] = newItemsSection
		end
		local flatSection = layoutData.sectionMap.misc
		if flatSection and #flatSection.slotIndices > 0 then
			layoutData.sections[#layoutData.sections + 1] = flatSection
			flatSection.label = nil
		end
	end

	for _, sectionID in ipairs(layoutData.flatStorageSectionIDs) do
		local section = layoutData.sectionMap[sectionID]
		if section and #section.slotIndices > 0 then
			layoutData.sections[#layoutData.sections + 1] = section
		end
	end

	for cleanupIndex = layoutData.requiredButtonCount + 1, #state.slotMappings do
		state.slotMappings[cleanupIndex] = nil
	end

	refreshFooterData(layoutData)
	state.layoutData = layoutData
	return layoutData
end

local function ensureButtonCapacity(requiredCount)
	if requiredCount <= #state.buttons then
		return true
	end
	if InCombatLockdown and InCombatLockdown() then
		state.pendingRebuild = true
		return false
	end

	for index = #state.buttons + 1, requiredCount do
		local button = state.buttonPool:Acquire()
		button:SetParent(state.content)
		button:EnableMouseWheel(true)
		button:SetScript("OnMouseWheel", function(_, delta)
			handleScrollWheel(delta)
		end)
		button.GetItemContextMatchResult = getCustomItemContextMatchResult
		if button.ItemLevelText then
			button.ItemLevelText:SetText("")
			button.ItemLevelText:Hide()
		end
		if button.ItemUpgradeText then
			button.ItemUpgradeText:SetText("")
			button.ItemUpgradeText:Hide()
		end
		state.buttons[index] = button
	end

	return true
end

local function layoutFooter(layoutData, frameWidth)
	local footer = state.frame.Footer
	local footerData = layoutData.footer
	local settings = getSettings()
	local showFooterSlotSummary = settings.showFooterSlotSummary ~= false
	local footerPadding = getOutsideFooterPadding(settings)
	local minimumFooterHeight = getMinimumFooterHeight(settings)
	local footerWidth = math.max(1, (footer and footer.GetWidth and footer:GetWidth()) or frameWidth or 1)
	local visibleCurrencyCount = 0
	local currencyButtons = {}
	local totalCurrencyWidth = 0
	local maxCurrencyButtonWidth = 0
	local currencyRowCount = 0
	local currencyRowsHeight = 0
	local moneyOnSeparateRow = false

	applyConfiguredFrameFonts()
	applyFramePadding(settings)

	footer.NormalSlotsText:ClearAllPoints()
	footer.ReagentSlotsText:ClearAllPoints()
	footer.CurrencyContainer:ClearAllPoints()
	footer.MoneyButton:ClearAllPoints()

	if showFooterSlotSummary then
		footer.NormalSlotsText:SetText(string.format(
			"%s: %d/%d %s",
			L["footerBagsLabel"] or "Bags",
			footerData.normalFree,
			footerData.normalTotal,
			L["footerFreeLabel"] or "free"
		))
		footer.ReagentSlotsText:SetText(string.format(
			"%s: %d/%d %s",
			L["footerReagentLabel"] or "Reagents",
			footerData.reagentFree,
			footerData.reagentTotal,
			L["footerFreeLabel"] or "free"
		))
		footer.NormalSlotsText:Show()
		footer.ReagentSlotsText:Show()
	else
		footer.NormalSlotsText:Hide()
		footer.ReagentSlotsText:Hide()
	end

	if settings.showGold then
		footer.MoneyText:SetText(formatFooterMoneyString(footerData.money or 0))
		footer.MoneyButton:SetWidth(math.max(120, footer.MoneyText:GetStringWidth() + 24 + Core.FOOTER_MONEY_RIGHT_PADDING))
		footer.MoneyButton:Show()
		footer.MoneyText:Show()
	else
		footer.MoneyButton:Hide()
		footer.MoneyText:Hide()
	end

	local reservedMoneyWidth = settings.showGold and math.max(120, footer.MoneyButton:GetWidth()) or 0
	for index, currencyInfo in ipairs(footerData.currencies or {}) do
		local button = acquireCurrencyButton(index)
		local quantityText = formatFooterCurrencyQuantity(currencyInfo.quantity or 0)

		button.currencyID = currencyInfo.currencyID
		button.Icon:SetTexture(currencyInfo.iconFileID)
		button.Count:SetText(quantityText)
		button:SetWidth(button.Count:GetStringWidth() + 24)
		currencyButtons[index] = button

		maxCurrencyButtonWidth = math.max(maxCurrencyButtonWidth, button:GetWidth())
		totalCurrencyWidth = totalCurrencyWidth + button:GetWidth()
		if index > 1 then
			totalCurrencyWidth = totalCurrencyWidth + 10
		end
		visibleCurrencyCount = index
	end

	local minimumFooterContentWidth = 0
	if showFooterSlotSummary then
		minimumFooterContentWidth = math.max(
			minimumFooterContentWidth,
			math.ceil((footer.NormalSlotsText:GetStringWidth() or 0) + 18 + (footer.ReagentSlotsText:GetStringWidth() or 0))
		)
	end
	if settings.showGold then
		minimumFooterContentWidth = math.max(minimumFooterContentWidth, math.ceil(footer.MoneyButton:GetWidth() or 0))
	end
	if maxCurrencyButtonWidth > 0 then
		minimumFooterContentWidth = math.max(minimumFooterContentWidth, math.ceil(maxCurrencyButtonWidth))
	end
	state.minimumFooterContentWidth = minimumFooterContentWidth

	moneyOnSeparateRow = settings.showGold
		and visibleCurrencyCount > 0
		and totalCurrencyWidth > math.max(1, footerWidth - reservedMoneyWidth)

	local currencyRowWidth = footerWidth
	if not moneyOnSeparateRow and settings.showGold then
		currencyRowWidth = math.max(1, footerWidth - reservedMoneyWidth)
	end

	local rowAssignments = {}
	local currentRowIndex = 1
	local currentRowWidth = 0
	for index = 1, visibleCurrencyCount do
		local button = currencyButtons[index]
		local buttonWidth = button:GetWidth()
		local requiredWidth = buttonWidth
		if currentRowWidth > 0 then
			requiredWidth = requiredWidth + 10
		end

		if currentRowWidth > 0 and (currentRowWidth + requiredWidth) > currencyRowWidth then
			currentRowIndex = currentRowIndex + 1
			currentRowWidth = 0
			requiredWidth = buttonWidth
		end

		if currentRowWidth > 0 then
			currentRowWidth = currentRowWidth + 10
		end

		rowAssignments[index] = {
			row = currentRowIndex,
			x = currentRowWidth,
		}
		currentRowWidth = currentRowWidth + buttonWidth
		currencyRowCount = currentRowIndex
	end

	if currencyRowCount > 0 then
		currencyRowsHeight = (currencyRowCount * Core.FOOTER_ROW_HEIGHT) + ((currencyRowCount - 1) * Core.FOOTER_ROW_SPACING)
	end

	local summaryHeight = 0
	if showFooterSlotSummary then
		summaryHeight = math.max(
			footer.NormalSlotsText:GetStringHeight() or 0,
			footer.ReagentSlotsText:GetStringHeight() or 0,
			12
		)
	end

	local moneyRowHeight = settings.showGold and Core.FOOTER_ROW_HEIGHT or 0
	local bottomBlockHeight
	if moneyOnSeparateRow then
		bottomBlockHeight = currencyRowsHeight
		if currencyRowsHeight > 0 and moneyRowHeight > 0 then
			bottomBlockHeight = bottomBlockHeight + Core.FOOTER_SECTION_SPACING
		end
		bottomBlockHeight = bottomBlockHeight + moneyRowHeight
	else
		bottomBlockHeight = math.max(currencyRowsHeight, moneyRowHeight)
	end

	local desiredFooterHeight = bottomBlockHeight
	if showFooterSlotSummary then
		desiredFooterHeight = footerPadding + summaryHeight + footerPadding
		if bottomBlockHeight > 0 then
			desiredFooterHeight = desiredFooterHeight + Core.FOOTER_SECTION_SPACING + bottomBlockHeight
		end
	else
		desiredFooterHeight = bottomBlockHeight + (footerPadding * 2)
	end
	desiredFooterHeight = math.max(minimumFooterHeight, desiredFooterHeight)

	state.desiredFooterHeight = desiredFooterHeight
	footer:SetHeight(desiredFooterHeight)

	if showFooterSlotSummary then
		footer.NormalSlotsText:SetPoint("TOPLEFT", footer, "TOPLEFT", 0, -footerPadding)
		footer.ReagentSlotsText:SetPoint("LEFT", footer.NormalSlotsText, "RIGHT", 18, 0)
	end

	local currencyBottomOffset = footerPadding
	if moneyOnSeparateRow and moneyRowHeight > 0 then
		currencyBottomOffset = footerPadding + moneyRowHeight
		if currencyRowsHeight > 0 then
			currencyBottomOffset = currencyBottomOffset + Core.FOOTER_SECTION_SPACING
		end
	end

	footer.CurrencyContainer:SetWidth(math.max(1, currencyRowWidth))
	footer.CurrencyContainer:SetHeight(math.max(0, currencyRowsHeight))
	footer.CurrencyContainer:SetPoint("BOTTOMLEFT", footer, "BOTTOMLEFT", 0, currencyBottomOffset)
	footer.CurrencyContainer:SetShown(currencyRowCount > 0)

	if settings.showGold then
		footer.MoneyButton:SetPoint("BOTTOMRIGHT", footer, "BOTTOMRIGHT", 0, footerPadding)
	end

	for index = 1, visibleCurrencyCount do
		local button = currencyButtons[index]
		local assignment = rowAssignments[index]
		local rowBottomOffset = currencyRowsHeight - Core.FOOTER_ROW_HEIGHT - ((assignment.row - 1) * (Core.FOOTER_ROW_HEIGHT + Core.FOOTER_ROW_SPACING))
		button:ClearAllPoints()
		button:SetPoint("BOTTOMLEFT", footer.CurrencyContainer, "BOTTOMLEFT", assignment.x, rowBottomOffset)
		button:Show()
	end

	for index = visibleCurrencyCount + 1, #state.currencyButtons do
		state.currencyButtons[index]:Hide()
	end

	state.footerLayoutSignature = getFooterLayoutSignature(settings, footerWidth)
	state.currentFooterHeight = desiredFooterHeight
	state.currentPaddingSignature = getFramePaddingSignature(settings)
	state.footerDirty = false
	return desiredFooterHeight
end

local function setSectionMappingsCollapsed(section, isCollapsed)
	if not section then
		return
	end

	for _, mappingIndex in ipairs(section.slotIndices or {}) do
		local mapping = state.slotMappings[mappingIndex]
		if mapping then
			mapping.sectionCollapsed = isCollapsed
		end
	end
end

local function getMeasuredSectionHeaderWidth(label, isCustom, textElementID)
	if not label or label == "" then
		return Core.BUTTON_SIZE
	end

	if not state.sectionHeaderMeasure then
		state.sectionHeaderMeasure = (state.content or UIParent):CreateFontString(nil, "OVERLAY", "GameFontNormal")
		state.sectionHeaderMeasure:Hide()
	end

	local measure = state.sectionHeaderMeasure
	applyConfiguredFont(measure, nil, textElementID or "subcategoryHeader")
	measure:SetText(addon.FormatTextElement and addon.FormatTextElement(textElementID or "subcategoryHeader", label) or label)

	local width = math.ceil((measure:GetStringWidth() or 0) + 0.5)
	local totalWidth = width + Core.SECTION_TOGGLE_WIDTH + 12
	if isCustom and isCategoryAssignModeActive() then
		totalWidth = totalWidth + Core.CATEGORY_ASSIGN_BUTTON_SIZE + 6
	end

	return math.max(Core.BUTTON_SIZE, totalWidth)
end

local function getSectionLayoutMetrics(section, showSectionHeader, sectionCollapsed, buttonSize, buttonSpacing, maxColumns, maxColumnsThatFitWidth)
	local itemCount = #section.slotIndices
	local sectionColumnCount = math.max(1, tonumber(section.columnCount) or maxColumns)
	sectionColumnCount = math.min(sectionColumnCount, maxColumns, maxColumnsThatFitWidth)

	local visibleColumns = 1
	local rows = 0
	local sectionWidth = buttonSize
	local headerWidth = buttonSize
	local blockHeight = 0
	local textElementID = section and section.groupID and "subcategoryHeader" or "categoryHeader"

	if showSectionHeader then
		blockHeight = blockHeight + Core.SECTION_HEADER_HEIGHT
		headerWidth = getMeasuredSectionHeaderWidth(section.label, section.isCustom, textElementID)
		sectionWidth = math.max(sectionWidth, headerWidth)
	end

	if itemCount > 0 and not sectionCollapsed then
		visibleColumns = math.max(1, math.min(sectionColumnCount, itemCount))
		rows = math.max(1, math.ceil(itemCount / sectionColumnCount))
		sectionWidth = (visibleColumns * buttonSize) + (math.max(0, visibleColumns - 1) * buttonSpacing)
		if showSectionHeader then
			sectionWidth = math.max(sectionWidth, headerWidth)
			blockHeight = blockHeight + Core.SECTION_CONTENT_TOP_PADDING
		end
		blockHeight = blockHeight + (rows * buttonSize) + (math.max(0, rows - 1) * buttonSpacing)
	end

	return {
		itemCount = itemCount,
		showSectionHeader = showSectionHeader,
		sectionCollapsed = sectionCollapsed,
		sectionColumnCount = sectionColumnCount,
		visibleColumns = visibleColumns,
		rows = rows,
		sectionWidth = sectionWidth,
		blockWidth = sectionWidth,
		blockHeight = math.max(blockHeight, showSectionHeader and Core.SECTION_HEADER_HEIGHT or 1),
	}
end

local function isCompactableSection(section, metrics, settings)
	if not (settings.showCategories and addon.GetCompactCategoryLayout and addon.GetCompactCategoryLayout()) then
		return false
	end

	if not section or section.id == Core.FREE_SLOTS_SECTION_ID then
		return false
	end

	if not metrics or metrics.itemCount <= 0 then
		return false
	end

	return metrics.showSectionHeader
end

local function getSectionGroupHeaderColor(section)
	if section and section.groupColor then
		return section.groupColor
	end

	local skin = getActiveFrameSkin()
	if skin and skin.titleColor then
		return {
			skin.titleColor[1] or 1,
			skin.titleColor[2] or 0.82,
			skin.titleColor[3] or 0,
		}
	end

	return { 1, 0.82, 0 }
end

local function getSectionCollapsedState(section, showSectionHeader)
	if not showSectionHeader or not section then
		return false
	end

	local collapseID = section.groupCollapseID
	if not collapseID and section.collapsible ~= false then
		collapseID = section.id
	end
	if not collapseID then
		return false
	end

	return isSectionCollapsed(collapseID)
end

local function renderSectionGroupHeader(section, currentHeaderCount, yOffset, isCollapsed)
	if not section or not section.groupID or not section.groupLabel or section.groupLabel == "" then
		return currentHeaderCount, yOffset
	end

	currentHeaderCount = currentHeaderCount + 1
	local header = acquireSectionHeader(currentHeaderCount)
	configureSectionHeader(header, {
		sectionID = section.groupCollapseID,
		label = section.groupLabel,
		color = getSectionGroupHeaderColor(section),
		collapsed = isCollapsed,
		collapsible = section.groupCollapseID ~= nil,
		textElementID = "categoryHeader",
	})
	header:ClearAllPoints()
	header:SetPoint("TOPLEFT", state.content, "TOPLEFT", 0, -yOffset)
	header:SetPoint("RIGHT", state.content, "RIGHT", 0, 0)
	header:Show()

	return currentHeaderCount, yOffset + Core.GROUP_HEADER_HEIGHT + Core.GROUP_HEADER_GAP
end

local function layoutFrame(layoutData)
	local settings = getSettings()
	local buttonSize = getButtonSize(settings)
	local buttonSpacing = getButtonSpacing(settings)
	local currentHeaderCount = 0
	local contentWidth = 1
	local yOffset = 0
	local activeGroupID = nil
	local maxColumns = getMaxColumns(settings)
	local compactSectionGap = addon.GetCompactCategoryGap and addon.GetCompactCategoryGap() or Core.SECTION_HORIZONTAL_GAP
	local screenMaxContentWidth = math.max(
		buttonSize,
		getScreenMaxFrameWidth() - (getInsideHorizontalPadding(settings) * 2) - Core.SCROLL_BAR_RESERVED_WIDTH
	)
	local maxColumnsThatFitWidth = math.max(1, math.floor((screenMaxContentWidth + buttonSpacing) / (buttonSize + buttonSpacing)))
	local effectiveMaxColumns = math.max(1, math.min(maxColumns, maxColumnsThatFitWidth))
	local maxContentWidth = (effectiveMaxColumns * buttonSize) + (math.max(0, effectiveMaxColumns - 1) * buttonSpacing)

	applyConfiguredFrameFonts()

	local sectionIndex = 1
	while sectionIndex <= #layoutData.sections do
		local section = layoutData.sections[sectionIndex]
		local showSectionHeader = section.label and (settings.showCategories or section.forceHeader)
		local groupCollapsed = section.groupID and section.groupCollapseID and isSectionCollapsed(section.groupCollapseID) or false

		if section.groupID then
			if activeGroupID ~= section.groupID then
				currentHeaderCount, yOffset = renderSectionGroupHeader(section, currentHeaderCount, yOffset, groupCollapsed)
				activeGroupID = section.groupID
			end
		else
			activeGroupID = nil
		end

		if groupCollapsed then
			local collapsedGroupID = section.groupID
			while sectionIndex <= #layoutData.sections do
				local groupedSection = layoutData.sections[sectionIndex]
				if groupedSection.groupID ~= collapsedGroupID then
					break
				end
				setSectionMappingsCollapsed(groupedSection, true)
				sectionIndex = sectionIndex + 1
			end
			if sectionIndex <= #layoutData.sections then
				yOffset = yOffset + Core.SECTION_GAP
			end
		else
			local sectionCollapsed = getSectionCollapsedState(section, showSectionHeader)
			local metrics = getSectionLayoutMetrics(section, showSectionHeader, sectionCollapsed, buttonSize, buttonSpacing, maxColumns, effectiveMaxColumns)
			setSectionMappingsCollapsed(section, sectionCollapsed)

			if isCompactableSection(section, metrics, settings) then
				local rowSections = {}
				local rowWidth = 0
				local rowHeight = 0
				local rowGroupID = section.groupID

				while sectionIndex <= #layoutData.sections do
					local candidate = layoutData.sections[sectionIndex]
					local candidateShowHeader = candidate.label and (settings.showCategories or candidate.forceHeader)
					local candidateGroupCollapsed = candidate.groupID and candidate.groupCollapseID and isSectionCollapsed(candidate.groupCollapseID) or false
					local candidateCollapsed = candidateGroupCollapsed or getSectionCollapsedState(candidate, candidateShowHeader)
					local candidateMetrics = getSectionLayoutMetrics(candidate, candidateShowHeader, candidateCollapsed, buttonSize, buttonSpacing, maxColumns, effectiveMaxColumns)
					setSectionMappingsCollapsed(candidate, candidateCollapsed)

					if candidateGroupCollapsed or not isCompactableSection(candidate, candidateMetrics, settings) then
						break
					end

					if candidate.groupID ~= rowGroupID then
						break
					end

					local nextWidth = candidateMetrics.blockWidth
					if #rowSections > 0 then
						nextWidth = nextWidth + compactSectionGap
					end

					if #rowSections > 0 and (rowWidth + nextWidth) > maxContentWidth then
						break
					end

					rowSections[#rowSections + 1] = {
						section = candidate,
						metrics = candidateMetrics,
						collapsed = candidateCollapsed,
					}
					rowWidth = rowWidth + nextWidth
					rowHeight = math.max(rowHeight, candidateMetrics.blockHeight)
					sectionIndex = sectionIndex + 1
				end

				local blockX = 0
				for _, entry in ipairs(rowSections) do
					local rowSection = entry.section
					local rowMetrics = entry.metrics

					currentHeaderCount = currentHeaderCount + 1
					local header = acquireSectionHeader(currentHeaderCount)
					configureSectionHeader(header, {
						sectionID = rowSection.id,
						label = rowSection.label,
						color = rowSection.color,
						isCustom = rowSection.isCustom,
						collapsed = entry.collapsed,
						collapsible = rowSection.collapsible,
						textElementID = rowSection.groupID and "subcategoryHeader" or "categoryHeader",
					})
					header:ClearAllPoints()
					header:SetPoint("TOPLEFT", state.content, "TOPLEFT", blockX, -yOffset)
					header:SetWidth(rowMetrics.blockWidth)
					header:Show()

					local buttonYOffset = yOffset + Core.SECTION_HEADER_HEIGHT + Core.SECTION_CONTENT_TOP_PADDING
					for visualIndex, mappingIndex in ipairs(rowSection.slotIndices) do
						local button = state.buttons[mappingIndex]
						local row = math.floor((visualIndex - 1) / rowMetrics.sectionColumnCount)
						local column = (visualIndex - 1) % rowMetrics.sectionColumnCount
						button:SetSize(buttonSize, buttonSize)
						button:ClearAllPoints()
						button:SetPoint(
							"TOPLEFT",
							state.content,
							"TOPLEFT",
							blockX + (column * (buttonSize + buttonSpacing)),
							-(buttonYOffset + (row * (buttonSize + buttonSpacing)))
						)
					end

					contentWidth = math.max(contentWidth, blockX + rowMetrics.blockWidth)
					blockX = blockX + rowMetrics.blockWidth + compactSectionGap
				end

				yOffset = yOffset + rowHeight
				if sectionIndex <= #layoutData.sections then
					yOffset = yOffset + Core.SECTION_GAP
				end
			else
				if showSectionHeader then
					currentHeaderCount = currentHeaderCount + 1
					local header = acquireSectionHeader(currentHeaderCount)
					configureSectionHeader(header, {
						sectionID = section.id,
						label = section.label,
						color = section.color,
						isCustom = section.isCustom,
						collapsed = sectionCollapsed,
						collapsible = section.collapsible,
						textElementID = section.groupID and "subcategoryHeader" or "categoryHeader",
					})
					header:ClearAllPoints()
					header:SetPoint("TOPLEFT", state.content, "TOPLEFT", 0, -yOffset)
					header:SetPoint("RIGHT", state.content, "RIGHT", 0, 0)
					header:Show()
					yOffset = yOffset + Core.SECTION_HEADER_HEIGHT
				end

				if metrics.itemCount > 0 and not sectionCollapsed then
					if showSectionHeader then
						yOffset = yOffset + Core.SECTION_CONTENT_TOP_PADDING
					end
					contentWidth = math.max(contentWidth, metrics.sectionWidth)

					for visualIndex, mappingIndex in ipairs(section.slotIndices) do
						local button = state.buttons[mappingIndex]
						local row = math.floor((visualIndex - 1) / metrics.sectionColumnCount)
						local column = (visualIndex - 1) % metrics.sectionColumnCount
						button:SetSize(buttonSize, buttonSize)
						button:ClearAllPoints()
						button:SetPoint(
							"TOPLEFT",
							state.content,
							"TOPLEFT",
							column * (buttonSize + buttonSpacing),
							-(yOffset + (row * (buttonSize + buttonSpacing)))
						)
					end

					yOffset = yOffset + (metrics.rows * buttonSize) + (math.max(0, metrics.rows - 1) * buttonSpacing)
				end

				if sectionIndex < #layoutData.sections then
					yOffset = yOffset + Core.SECTION_GAP
				end
				sectionIndex = sectionIndex + 1
			end
		end
	end

	for index = currentHeaderCount + 1, #state.sectionHeaders do
		state.sectionHeaders[index]:Hide()
	end

	local contentHeight = getLayoutContentHeight(settings, yOffset)
	state.lastLayoutContentWidth = contentWidth
	state.lastLayoutRawContentHeight = yOffset
	state.lastLayoutContentHeight = contentHeight

	local initialFooterHeight = getFooterHeight(settings)
	local insideHorizontalPadding = getInsideHorizontalPadding(settings)
	local frameWidth = updateScrollFrameLayout(contentWidth, contentHeight)
	local measuredFooterHeight = layoutFooter(layoutData, frameWidth - (insideHorizontalPadding * 2))
	local minimumFooterFrameWidth = (tonumber(state.minimumFooterContentWidth) or 0) + (Core.FRAME_PADDING * 2)
	if measuredFooterHeight ~= initialFooterHeight or minimumFooterFrameWidth > frameWidth then
		frameWidth = updateScrollFrameLayout(contentWidth, contentHeight)
		layoutFooter(layoutData, frameWidth - (insideHorizontalPadding * 2))
	end
	applyActiveSkin()

	for index = layoutData.requiredButtonCount + 1, #state.buttons do
		state.buttons[index]:Hide()
	end
end

local function rebuildLayout()
	if not state.frame then
		createMainFrame()
	end
	if InCombatLockdown and InCombatLockdown() then
		state.pendingRebuild = true
		return false
	end

	state.awaitingRuleItemData = false
	if wipe then
		wipe(state.pendingRuleItemDataIDs)
	else
		state.pendingRuleItemDataIDs = {}
	end
	local layoutData = buildLayoutData()
	if not ensureButtonCapacity(layoutData.requiredButtonCount) then
		return false
	end

	layoutFrame(layoutData)
	local overlayRuntime = getOverlayRuntimeConfig()
	local textAppearance = getResolvedTextAppearance("overlays")
	local fontSignature = getItemButtonTextAppearanceSignature(textAppearance)
	local tooltipOwner = GameTooltip and GameTooltip.GetOwner and GameTooltip:GetOwner() or nil
	local forceDynamicUpdate = state.forceDynamicRefresh

	for index = 1, layoutData.requiredButtonCount do
		local mapping = state.slotMappings[index]
		local button = state.buttons[index]
		if button._bagsBagID ~= mapping.bagID or button._bagsSlotID ~= mapping.slotID then
			button:Initialize(mapping.bagID, mapping.slotID)
			button._bagsBagID = mapping.bagID
			button._bagsSlotID = mapping.slotID
		end
		updateButtonData(button, mapping, overlayRuntime, textAppearance, fontSignature, tooltipOwner, forceDynamicUpdate)
		mapping.itemInfo = nil
		mapping.questInfo = nil
	end

	state.currentLayoutCount = layoutData.requiredButtonCount
	state.currentTotalSlotCount = layoutData.totalSlotCount
	if not state.bagContentSnapshotsInitialized then
		refreshAllManagedBagContentSignatures()
		state.bagContentSnapshotsInitialized = true
	end
	state.pendingRebuild = false
	state.pendingRefresh = false
	state.forceDynamicRefresh = false
	state.currentTextAppearanceSignature = fontSignature
	return true
end

local function refreshButtons()
	if not state.layoutData then
		return rebuildLayout()
	end

	local settings = getSettings()
	local desiredPaddingSignature = getFramePaddingSignature(settings)
	if state.currentPaddingSignature ~= desiredPaddingSignature then
		return rebuildLayout()
	end
	local desiredSkinSignature = addon.GetSkinSignature and addon.GetSkinSignature() or nil
	if state.currentSkinSignature ~= desiredSkinSignature then
		applyActiveSkin()
	end

	local insideHorizontalPadding = getInsideHorizontalPadding(settings)
	local footerWidth = math.max(1, state.frame.Footer and state.frame.Footer:GetWidth() or (state.frame:GetWidth() - (insideHorizontalPadding * 2)))
	local footerLayoutSignature = getFooterLayoutSignature(settings, footerWidth)
	if state.footerDirty or state.footerLayoutSignature ~= footerLayoutSignature then
		local previousFooterHeight = getFooterHeight(settings)
		local previousContentHeight = state.lastLayoutContentHeight
		refreshFooterData(state.layoutData)
		local measuredFooterHeight = layoutFooter(state.layoutData, footerWidth)
		local contentHeight = getLayoutContentHeight(settings, state.lastLayoutRawContentHeight or state.lastLayoutContentHeight)
		if state.lastLayoutRawContentHeight then
			state.lastLayoutContentHeight = contentHeight
		end
		if (measuredFooterHeight ~= previousFooterHeight or contentHeight ~= previousContentHeight) and state.lastLayoutContentWidth and state.lastLayoutContentHeight then
			updateScrollFrameLayout(state.lastLayoutContentWidth, contentHeight)
			layoutFooter(state.layoutData, math.max(1, state.frame.Footer and state.frame.Footer:GetWidth() or footerWidth))
		elseif state.lastLayoutContentWidth and ((tonumber(state.minimumFooterContentWidth) or 0) + (Core.FRAME_PADDING * 2)) > (state.frame:GetWidth() or 0) then
			updateScrollFrameLayout(state.lastLayoutContentWidth, contentHeight)
			layoutFooter(state.layoutData, math.max(1, state.frame.Footer and state.frame.Footer:GetWidth() or footerWidth))
		end
	end

	local overlayRuntime = getOverlayRuntimeConfig()
	local textAppearance = getResolvedTextAppearance("overlays")
	local fontSignature = getItemButtonTextAppearanceSignature(textAppearance)
	if state.currentTextAppearanceSignature ~= nil and state.currentTextAppearanceSignature ~= fontSignature then
		return rebuildLayout()
	end
	local tooltipOwner = GameTooltip and GameTooltip.GetOwner and GameTooltip:GetOwner() or nil
	local forceDynamicUpdate = state.forceDynamicRefresh

	for index = 1, state.currentLayoutCount or 0 do
		updateButtonData(
			state.buttons[index],
			state.slotMappings[index],
			overlayRuntime,
			textAppearance,
			fontSignature,
			tooltipOwner,
			forceDynamicUpdate
		)
	end

	state.pendingRefresh = false
	state.forceDynamicRefresh = false
	state.currentTextAppearanceSignature = fontSignature
	return true
end

function Bags.functions.PositionFrame()
	if not state.frame or state.userMoved then
		return
	end

	local anchor = getAnchorTargetFrame()
	state.frame:ClearAllPoints()
	if anchor then
		state.frame:SetPoint("TOPRIGHT", anchor, "TOPLEFT", -Core.CLUSTER_GAP, 0)
	else
		state.frame:SetPoint(
			Core.DEFAULT_FRAME_POINT.point,
			UIParent,
			Core.DEFAULT_FRAME_POINT.relativePoint,
			Core.DEFAULT_FRAME_POINT.x,
			Core.DEFAULT_FRAME_POINT.y
		)
	end
end

function addon.GetCustomBagsAnchorTargetFrame()
	if not state.frame or not state.initialized then
		return nil
	end
	if state.frame:IsShown() or state.manualVisible or state.explicitToggleVisible or shouldShowManagedContainerFrame() then
		return state.frame
	end
	return nil
end

local function processUpdate()
	if not state.initialized then
		return
	end

	local shouldBeVisible = state.manualVisible or state.explicitToggleVisible or shouldShowManagedContainerFrame()
	local wasVisible = state.frame and state.frame:IsShown()
	local openingFrame = shouldBeVisible and not wasVisible
	setActiveBagEventRegistration(shouldBeVisible)
	if openingFrame then
		state.footerDirty = true
		resetOpenSessionNewItems()
	end
	local settings = getSettings()
	local needsRebuild = state.pendingRebuild
		or state.layoutData == nil
		or state.currentTotalSlotCount ~= getTotalSlotCount()
		or state.currentFooterHeight ~= getFooterHeight(settings)
		or state.currentPaddingSignature ~= getFramePaddingSignature(settings)
	local needsRefresh = openingFrame or state.pendingRefresh or state.forceDynamicRefresh or state.footerDirty

	local updateApplied = true
	if needsRebuild then
		updateApplied = rebuildLayout()
	elseif needsRefresh then
		updateApplied = refreshButtons()
	end

	if shouldBeVisible then
		if updateApplied and not state.userMoved then
			Bags.functions.PositionFrame()
		end
		state.frame:Show()
		if updateApplied and Bags.functions.ApplyVendorMarks then
			Bags.functions.ApplyVendorMarks()
		end
		BagSlotPanel.Refresh()
		if openingFrame and addon.Vendor and addon.Vendor.functions and addon.Vendor.functions.refreshSellMarks then
			addon.Vendor.functions.refreshSellMarks(false)
		end
	else
		state.suppressNativeBagClose = true
		state.frame:Hide()
		state.suppressNativeBagClose = false
		if wasVisible and addon.Vendor and addon.Vendor.functions and addon.Vendor.functions.refreshSellMarks then
			addon.Vendor.functions.refreshSellMarks(false)
		end
	end
end

scheduleUpdate = function(requestRefresh, requestRebuild, forceWhenHidden)
	if requestRebuild then
		state.pendingRebuild = true
	end
	if requestRefresh then
		state.pendingRefresh = true
	end

	if not forceWhenHidden and not shouldProcessVisibleBagUpdates() then
		return
	end

	if state.updateScheduled then
		return
	end
	state.updateScheduled = true
	C_Timer.After(0, function()
		state.updateScheduled = false
		processUpdate()
	end)
end

function Bags.functions.RequestLayoutUpdate(requestRebuild, forceWhenHidden)
	scheduleUpdate(true, requestRebuild, forceWhenHidden)
end

function Bags.functions.IsInventoryOpenForVendor()
	return state.frame and state.frame:IsShown() or false
end

function Bags.functions.GetVendorDestroyButtonAnchor()
	if not (state.frame and state.frame:IsShown()) then
		return nil
	end
	local footer = state.frame.Footer
	if footer and footer.MoneyButton and footer.MoneyButton:IsShown() then
		return footer.MoneyButton
	end
	return footer or state.frame
end

function Bags.functions.ApplyVendorMarks(overlaySell, overlayDestroy)
	local vendorFunctions = addon.Vendor and addon.Vendor.functions or nil
	if not vendorFunctions then
		return
	end

	local applyMark = vendorFunctions.ApplySellDestroyOverlayToItemButton
	local hideMark = vendorFunctions.HideSellDestroyOverlays
	for index, button in ipairs(state.buttons or {}) do
		if button and button:IsShown() and index <= (state.currentLayoutCount or 0) then
			if applyMark then
				applyMark(button, overlaySell, overlayDestroy)
			end
			if applyItemButtonSkinIfNeeded then
				applyItemButtonSkinIfNeeded(button, button._bagsRenderQuality)
			end
		elseif button and hideMark then
			hideMark(button)
		end
	end
end

function Bags.functions.ShowFrame()
	if not (addon.Bags and addon.Bags.IsEnabled and addon.Bags.IsEnabled()) then
		return
	end
	setManualVisibility(true)
	scheduleUpdate(true, false)
end

function Bags.functions.HideFrame()
	setManualVisibility(false)
	state.explicitToggleVisible = false
	if shouldShowSimpleBags() and type(CloseAllBags) == "function" then
		CloseAllBags()
	end
	if state.frame and not shouldShowManagedContainerFrame() then
		state.suppressNativeBagClose = true
		state.frame:Hide()
		state.suppressNativeBagClose = false
	end
	scheduleUpdate(false, false, true)
end

function Bags.functions.ToggleFrame()
	if not (addon.Bags and addon.Bags.IsEnabled and addon.Bags.IsEnabled()) then
		return
	end
	local isVisible = (state.frame and state.frame:IsShown()) or state.manualVisible or state.explicitToggleVisible
	if isVisible and not shouldShowManagedContainerFrame() then
		Bags.functions.HideFrame()
	else
		Bags.functions.ShowFrame()
	end
end

function Bags.functions.ResetFramePosition()
	local frameDB = getFrameDB()
	wipe(frameDB)
	state.userMoved = false

	if state.frame then
		state.frame:ClearAllPoints()
		state.frame:SetPoint(
			Core.DEFAULT_FRAME_POINT.point,
			UIParent,
			Core.DEFAULT_FRAME_POINT.relativePoint,
			Core.DEFAULT_FRAME_POINT.x,
			Core.DEFAULT_FRAME_POINT.y
		)
	end

	scheduleUpdate(false, false)
end

function Bags.functions.EnableMain()
	if state.initialized or not (addon.Bags and addon.Bags.IsEnabled and addon.Bags.IsEnabled()) then
		return
	end

	state.manualVisible = not not getSettings().manualVisible
	createMainFrame()
	detachDefaultBagFrames()
	installVisibilityHooks()
	installTokenWatcherHooks()
	state.initialized = true
	state.pendingRebuild = true
	registerPassiveBagEvents()
	local processNow = shouldProcessVisibleBagUpdates()
	setActiveBagEventRegistration(processNow)
	if processNow then
		scheduleUpdate(true, true, true)
	end
end

local NATIVE_BAG_TOGGLE_FILTERS = {
	ToggleAllBags = {},
	ToggleBackpack = {
		"ToggleAllBags",
	},
	ToggleBag = {
		"OpenBackpack",
		"ToggleBackpack",
	},
}

local function syncFromNativeBagState(requestRefresh, requestRebuild)
	state.nativeBagStateSyncScheduled = false
	if not state.initialized then
		return
	end

	local nativeOpen = isNativeStandardBagOpen()
	if nativeOpen then
		state.explicitToggleVisible = true
	else
		state.explicitToggleVisible = false
		setManualVisibility(false)
	end

	scheduleUpdate(nativeOpen or requestRefresh, requestRebuild, true)
end

local function scheduleNativeBagStateSync(requestRefresh, requestRebuild)
	if state.nativeBagStateSyncScheduled then
		return
	end

	state.nativeBagStateSyncScheduled = true
	C_Timer.After(0, function()
		syncFromNativeBagState(requestRefresh, requestRebuild)
	end)
end

Bags.functions.SynchronizeContextOpenedBagToggleState = function()
	if type(IsBagOpen) ~= "function" or type(OpenBag) ~= "function" then
		return
	end
	if type(ContainerFrame_AllowedToOpenBags) == "function" and not ContainerFrame_AllowedToOpenBags() then
		return
	end

	local hasOpenStandardBag = false
	for bagID = Core.BACKPACK_ID, Core.LAST_CHARACTER_BAG_ID do
		if IsBagOpen(bagID) then
			hasOpenStandardBag = true
			break
		end
	end
	if not hasOpenStandardBag then
		return
	end

	if not IsBagOpen(Core.BACKPACK_ID) and type(OpenBackpack) == "function" then
		OpenBackpack()
	end

	for bagID = 1, Core.LAST_CHARACTER_BAG_ID do
		local slotCount = C_Container and C_Container.GetContainerNumSlots and C_Container.GetContainerNumSlots(bagID) or 0
		if slotCount > 0 and not IsBagOpen(bagID) then
			OpenBag(bagID)
		end
	end
end

local function shouldIgnoreNativeBagToggle(functionName)
	local patterns = NATIVE_BAG_TOGGLE_FILTERS[functionName]
	if not patterns or type(debugstack) ~= "function" then
		return false
	end

	local stack = debugstack() or ""
	for _, pattern in ipairs(patterns) do
		if stack:find(pattern, 1, true) then
			return true
		end
	end

	return false
end

installVisibilityHooks = function()
	if state.hooksInstalled then
		return
	end
	state.hooksInstalled = true

	local openHookTargets = {
		"OpenBag",
		"OpenAllBags",
		"OpenAllBagsMatchingContext",
		"OpenBackpack",
	}

	for _, functionName in ipairs(openHookTargets) do
		local hookName = functionName
		if type(_G[hookName]) == "function" then
			hooksecurefunc(hookName, function()
				scheduleNativeBagStateSync(true, false)
			end)
		end
	end

	local closeHookTargets = {
		"CloseAllBags",
		"CloseBag",
		"CloseBackpack",
	}

	for _, functionName in ipairs(closeHookTargets) do
		local hookName = functionName
		if type(_G[hookName]) == "function" then
			hooksecurefunc(hookName, function()
				scheduleNativeBagStateSync(false, false)
			end)
		end
	end

	for functionName in pairs(NATIVE_BAG_TOGGLE_FILTERS) do
		local hookName = functionName
		if type(_G[hookName]) == "function" then
			hooksecurefunc(hookName, function()
				if shouldIgnoreNativeBagToggle(hookName) then
					scheduleNativeBagStateSync(true, false)
					return
				end

				scheduleNativeBagStateSync(true, false)
			end)
		end
	end

	if EventRegistry and type(EventRegistry.RegisterCallback) == "function" then
		EventRegistry:RegisterCallback("ContainerFrame.OpenAllBags", function()
			scheduleNativeBagStateSync(true, false)
		end, state)
		EventRegistry:RegisterCallback("ContainerFrame.CloseAllBags", function()
			scheduleNativeBagStateSync(false, false)
		end, state)
	end
end

installTokenWatcherHooks = function()
	if state.tokenWatcherHooksInstalled then
		return
	end
	if not EventRegistry or type(EventRegistry.RegisterCallback) ~= "function" then
		return
	end

	state.tokenWatcherHooksInstalled = true
	EventRegistry:RegisterCallback("TokenFrame.OnTokenWatchChanged", function()
		state.footerDirty = true
		scheduleUpdate(true, false)
	end, state)
end

local eventFrame = state.eventFrame or CreateFrame("Frame")
state.eventFrame = eventFrame
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("BANKFRAME_OPENED")
eventFrame:RegisterEvent("BANKFRAME_CLOSED")
eventFrame:SetScript("OnEvent", function(_, event, ...)
	if event == "PLAYER_LOGIN" then
		if addon.Bags and addon.Bags.IsEnabled and addon.Bags.IsEnabled() then
			addon.Bags.functions.Enable()
		end
		eventFrame:UnregisterEvent("PLAYER_LOGIN")
		return
	end

	if not state.initialized or not (addon.Bags and addon.Bags.IsEnabled and addon.Bags.IsEnabled()) then
		return
	end

	if event == "PLAYER_REGEN_ENABLED" then
		scheduleUpdate(state.pendingRefresh, state.pendingRebuild)
	elseif event == "BANKFRAME_OPENED" or event == "BANKFRAME_CLOSED" then
		scheduleUpdate(true, true, true)
	elseif event == "BAG_UPDATE" then
		local bagID = ...
		if isManagedBagUpdateID(bagID) and refreshManagedBagContentSignature(bagID) then
			state.bagContentsDirty = true
			state.footerDirty = true
		end
	elseif event == "BAG_UPDATE_DELAYED" then
		state.footerDirty = true
		if state.bagContentsDirty then
			state.bagContentsDirty = false
			scheduleUpdate(true, true)
		else
			scheduleUpdate(true, false)
		end
	elseif event == "BAG_NEW_ITEMS_UPDATED" then
		state.bagContentsDirty = false
		scheduleUpdate(true, true)
	elseif event == "ITEM_DATA_LOAD_RESULT" then
		local itemID, success = ...
		if success and (state.pendingRuleItemDataIDs[itemID] or state.awaitingRuleItemData) then
			state.pendingRuleItemDataIDs[itemID] = nil
			scheduleUpdate(true, true)
		end
	elseif event == "UNIT_INVENTORY_CHANGED" or event == "PLAYER_SPECIALIZATION_CHANGED" or event == "PLAYER_LEVEL_UP" then
		local usage = addon.GetCategoryRuleContextUsage and addon.GetCategoryRuleContextUsage() or nil
		if doesRuleUsageDependOnPlayerState(usage) then
			bumpPlayerRuleRevision()
			scheduleUpdate(true, true)
		else
			scheduleUpdate(true, false)
		end
	elseif event == "INVENTORY_SEARCH_UPDATE" then
		scheduleUpdate(true, false)
	elseif event == "MODIFIER_STATE_CHANGED" then
		local key = ...
		if key == "LALT" or key == "RALT" then
			scheduleUpdate(true, true)
		end
	elseif event == "ACCOUNT_CHARACTER_CURRENCY_DATA_RECEIVED" then
		refreshVisibleFooterCurrencyTooltip()
	elseif event == "PLAYER_MONEY" or event == "ACCOUNT_MONEY" or event == "CURRENCY_DISPLAY_UPDATE" then
		state.footerDirty = true
		refreshVisibleFooterCurrencyTooltip()
		scheduleUpdate(true, false)
	elseif event == "ITEM_LOCK_CHANGED" or event == "BAG_UPDATE_COOLDOWN" then
		if event == "BAG_UPDATE_COOLDOWN" then
			state.forceDynamicRefresh = true
		end
		scheduleUpdate(true, false)
	end
end)
