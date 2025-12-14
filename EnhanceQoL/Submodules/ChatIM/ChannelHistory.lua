local parentAddonName = "EnhanceQoL"
local addonName, addon = ...
if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

addon.ChatIM = addon.ChatIM or {}
local ChatIM = addon.ChatIM

ChatIM.ChannelHistory = ChatIM.ChannelHistory or {}
local ChannelHistory = ChatIM.ChannelHistory

ChannelHistory.version = 1
ChannelHistory.maxLines = ChannelHistory.maxLines or 500
ChannelHistory.enabled = ChannelHistory.enabled or false
ChannelHistory.frame = ChannelHistory.frame or CreateFrame("Frame")
ChannelHistory.events = ChannelHistory.events or nil
ChannelHistory.debugFrame = ChannelHistory.debugFrame or nil

local IGNORED_EVENTS = {
	CHAT_MSG_ADDON = true,
	CHAT_MSG_BN_INLINE_TOAST_ALERT = true,
	CHAT_MSG_BN_INLINE_TOAST_BROADCAST = true,
	CHAT_MSG_BN_INLINE_TOAST_BROADCAST_INFORM = true,
	CHAT_MSG_BN_INLINE_TOAST_CONVERSATION = true,
}

local ADDITIONAL_EVENTS = {
	"CHAT_MSG_COMMUNITIES_CHANNEL",
}

local function now() return (GetServerTime and GetServerTime()) or time() end

local function sanitizeRealm(realm)
	if not realm or realm == "" then realm = GetRealmName() or "Unknown" end
	realm = realm:gsub("%s+", "")
	return realm
end

local function buildKeys()
	local name = UnitName("player") or "Unknown"
	local realmName = GetRealmName() or "Unknown"
	local faction = UnitFactionGroup("player") or "Neutral"
	local realmKey = sanitizeRealm(realmName)

	return {
		player = name,
		realmName = realmName,
		realmKey = realmKey,
		faction = faction,
		charKey = name .. "-" .. realmKey,
	}
end

local function buildEventSet()
	local events = {}
	if ChatTypeGroup then
		for _, list in pairs(ChatTypeGroup) do
			if type(list) == "table" then
				for _, event in ipairs(list) do
					if type(event) == "string" and event:find("^CHAT_MSG") and not IGNORED_EVENTS[event] then
						events[event] = true
					end
				end
			end
		end
	end
	for _, event in ipairs(ADDITIONAL_EVENTS) do
		if not IGNORED_EVENTS[event] then events[event] = true end
	end

	return events
end

local function safeSelect(index, ...)
	local value = select(index, ...)
	if value == "" then return nil end
	return value
end

function ChannelHistory:InitStorage()
	EnhanceQoL_ChannelHistory = EnhanceQoL_ChannelHistory or { _version = self.version }
	if not EnhanceQoL_ChannelHistory._version then EnhanceQoL_ChannelHistory._version = self.version end
	self.history = EnhanceQoL_ChannelHistory
	self.keys = buildKeys()
end

function ChannelHistory:SetMaxLines(value)
	self.maxLines = value or self.maxLines or 500
	if not self.history then return end

	for _, realms in pairs(self.history) do
		if type(realms) == "table" then
			for _, realmData in pairs(realms) do
				local chars = type(realmData) == "table" and realmData.characters
				if type(chars) == "table" then
					for _, charData in pairs(chars) do
						if charData.channels then
							for _, channel in pairs(charData.channels) do
								if channel.lines then
									while #channel.lines > self.maxLines do
										table.remove(channel.lines, 1)
									end
								end
							end
						end
					end
				end
			end
		end
	end
end

local function getCharacterBucket(create)
	if not ChannelHistory.keys then ChannelHistory:InitStorage() end
	local storage = ChannelHistory.history
	if not storage then return end

	local keys = ChannelHistory.keys
	local faction = storage[keys.faction]
	if not faction and create then
		faction = {}
		storage[keys.faction] = faction
	end
	if not faction then return end

	local realm = faction[keys.realmKey]
	if not realm and create then
		realm = { realmName = keys.realmName, characters = {} }
		faction[keys.realmKey] = realm
	end
	if not realm or not realm.characters then return end

	local characters = realm.characters
	local charBucket = characters[keys.charKey]
	if not charBucket and create then
		charBucket = { name = keys.player, realm = keys.realmName, faction = keys.faction, channels = {} }
		characters[keys.charKey] = charBucket
	end

	return charBucket, characters, realm, faction
end

local function buildChannelKey(event, ...)
	local base = event:gsub("^CHAT_MSG_", "")

	if event == "CHAT_MSG_CHANNEL" then
		local channelName = safeSelect(4, ...)
		local channelIndex = safeSelect(8, ...)
		local channelBaseName = safeSelect(9, ...)
		local descriptor = channelName or channelBaseName or base
		if channelIndex then descriptor = tostring(channelIndex) .. ":" .. descriptor end
		return base .. ":" .. descriptor, descriptor
	end

	if event == "CHAT_MSG_COMMUNITIES_CHANNEL" then
		local communityID = safeSelect(18, ...)
		local streamID = safeSelect(19, ...)
		local channelName = safeSelect(4, ...) or base
		local descriptor
		if communityID or streamID then
			descriptor = string.format("%s:%s", communityID or "COMMUNITY", streamID or "STREAM")
		end
		local label = descriptor and (descriptor .. ":" .. channelName) or channelName
		return base .. ":" .. (descriptor or channelName), label
	end

	local channelName = safeSelect(4, ...)
	if channelName then return base .. ":" .. channelName, channelName end

	return base, base
end

local function appendLine(channelBucket, line)
	channelBucket.lines = channelBucket.lines or {}
	table.insert(channelBucket.lines, line)
	while #channelBucket.lines > ChannelHistory.maxLines do
		table.remove(channelBucket.lines, 1)
	end
	channelBucket.lastUpdated = line.time
end

function ChannelHistory:Store(event, ...)
	if self.maxLines == 0 then return end
	local charBucket = getCharacterBucket(true)
	if not charBucket then return end

	local msg, sender = ...
	local channelKey, channelLabel = buildChannelKey(event, ...)
	channelKey = channelKey or event

	charBucket.channels = charBucket.channels or {}
	local channelBucket = charBucket.channels[channelKey] or { label = channelLabel or channelKey, lines = {} }
	channelBucket.label = channelLabel or channelBucket.label or channelKey

	local line = {
		time = now(),
		event = event,
		channel = channelKey,
		label = channelBucket.label,
		message = msg or "",
		sender = sender or "",
		lineID = safeSelect(11, ...),
		guid = safeSelect(12, ...),
		bnetIDAccount = safeSelect(13, ...),
	}

	appendLine(channelBucket, line)

	charBucket.channels[channelKey] = channelBucket
	charBucket.lastUpdated = line.time
end

local function iterCharacters(scope)
	if not ChannelHistory.history or not ChannelHistory.keys then return function() end end

	local factionBucket = ChannelHistory.history[ChannelHistory.keys.faction]
	if not factionBucket then return function() end end

	local realmBucket = factionBucket[ChannelHistory.keys.realmKey]

	if scope == nil or scope == "character" then
		local bucket = realmBucket and realmBucket.characters and realmBucket.characters[ChannelHistory.keys.charKey]
		local returned = false
		return function()
			if returned or not bucket then return end
			returned = true
			return ChannelHistory.keys.charKey, bucket
		end
	end

	local function yieldFromRealm(realm)
		if not realm or not realm.characters then return function() end end
		local keyList = {}
		for charKey in pairs(realm.characters) do
			table.insert(keyList, charKey)
		end
		local i = 0
		return function()
			i = i + 1
			local key = keyList[i]
			if not key then return end
			return key, realm.characters[key]
		end
	end

	if scope == "realm" then return yieldFromRealm(realmBucket) end
	if scope == "faction" then
		local realmKeys = {}
		for realmKey in pairs(factionBucket) do
			table.insert(realmKeys, realmKey)
		end
		local realmIndex = 0
		local charIter = nil
		return function()
			while true do
				if not charIter then
					realmIndex = realmIndex + 1
					local realmKey = realmKeys[realmIndex]
					if not realmKey then return end
					charIter = yieldFromRealm(factionBucket[realmKey])
				end
				local charKey, data = charIter()
				if charKey then return charKey, data end
				charIter = nil
			end
		end
	end

	return yieldFromRealm(realmBucket)
end

function ChannelHistory:GetChannels(scope)
	if not self.history or not self.keys then self:InitStorage() end
	scope = scope or "character"
	local channels = {}
	for _, charData in iterCharacters(scope) do
		if charData and charData.channels then
			for channelKey, channelData in pairs(charData.channels) do
				channels[channelKey] = channels[channelKey] or { label = channelData.label or channelKey, count = 0 }
				if channelData.lines then channels[channelKey].count = channels[channelKey].count + #channelData.lines end
			end
		end
	end
	return channels
end

function ChannelHistory:GetHistory(scope, channelKey)
	if not self.history or not self.keys then self:InitStorage() end
	scope = scope or "character"
	local result = {}
	if not channelKey or channelKey == "" then return result end

	for charKey, charData in iterCharacters(scope) do
		if charData and charData.channels and charData.channels[channelKey] and charData.channels[channelKey].lines then
			for _, line in ipairs(charData.channels[channelKey].lines) do
				table.insert(result, {
					character = charKey,
					faction = charData.faction or self.keys and self.keys.faction,
					realm = charData.realm,
					channel = channelKey,
					label = charData.channels[channelKey].label or channelKey,
					data = line,
				})
			end
		end
	end

	table.sort(result, function(a, b) return (a.data.time or 0) < (b.data.time or 0) end)
	return result
end

function ChannelHistory:OnEvent(event, ...)
	if not self.enabled then return end
	if not self.events or not self.events[event] then return end
	self:Store(event, ...)
end

function ChannelHistory:RegisterEvents()
	if not self.frame then return end
	self.frame:UnregisterAllEvents()
	if not self.events then self.events = buildEventSet() end
	for event in pairs(self.events or {}) do
		self.frame:RegisterEvent(event)
	end
end

function ChannelHistory:SetEnabled(enabled)
	self.enabled = enabled and true or false
	self:InitStorage()
	self.events = self.events or buildEventSet()
	self:SetMaxLines(addon.db and addon.db["chatChannelHistoryMaxLines"])
	if self.enabled then
		self:RegisterEvents()
		self:CreateDebugFrame()
		if self.debugFrame then self.debugFrame:Show() end
	else
		if self.frame then self.frame:UnregisterAllEvents() end
		if self.debugFrame then self.debugFrame:Hide() end
	end
end

ChannelHistory.frame:SetScript("OnEvent", function(_, event, ...) ChannelHistory:OnEvent(event, ...) end)

-- Simple debug frame (no AceGUI) to iterate on layout
local WINDOW_BACKDROP = {
	bgFile = nil,
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = true,
	tileSize = 32,
	edgeSize = 16,
	insets = { left = 5, right = 5, top = 5, bottom = 5 },
}

local PANEL_BACKDROP = {
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = true,
	tileSize = 32,
	edgeSize = 16,
	insets = { left = 5, right = 5, top = 5, bottom = 5 },
}

local function applyPanelBackdrop(panel)
	panel:SetBackdrop(PANEL_BACKDROP)
	panel:SetBackdropColor(0, 0, 0, 0.4)
	panel:SetBackdropBorderColor(0.2, 0.2, 0.2, 0.9)
end

local function createSearchBox(parent, placeholder)
	local box = CreateFrame("EditBox", nil, parent, "SearchBoxTemplate")
	box:SetHeight(22)
	box:SetAutoFocus(false)
	box:SetMaxLetters(128)
	if box.Instructions and placeholder then box.Instructions:SetText(placeholder) end
	return box
end

function ChannelHistory:LayoutDebugFrame(width, height)
	if not self.debugFrame then return end
	local f = self.debugFrame
	width = width or f:GetWidth()
	height = height or f:GetHeight()

	local padding = 12
	local spacing = 10
	local headerOffset = 40

	local availableWidth = width - (padding * 2) - (spacing * 2)
	local availableHeight = height - padding - headerOffset

	local leftWidth = math.max(220, math.floor(availableWidth * 0.28))
	local midWidth = math.max(200, math.floor(availableWidth * 0.22))
	local rightWidth = availableWidth - leftWidth - midWidth
	if rightWidth < 280 then
		local deficit = 280 - rightWidth
		rightWidth = 280
		leftWidth = math.max(180, leftWidth - math.floor(deficit * 0.5))
		midWidth = math.max(160, midWidth - math.ceil(deficit * 0.5))
	end

	-- Left panel
	f.left:SetPoint("TOPLEFT", f, "TOPLEFT", padding, -headerOffset)
	f.left:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", padding, padding)
	f.left:SetWidth(leftWidth)

	-- Middle panel
	f.middle:SetPoint("TOPLEFT", f.left, "TOPRIGHT", spacing, 0)
	f.middle:SetPoint("BOTTOMLEFT", f.left, "BOTTOMRIGHT", spacing, 0)
	f.middle:SetWidth(midWidth)

	-- Right panel
	f.right:SetPoint("TOPLEFT", f.middle, "TOPRIGHT", spacing, 0)
	f.right:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -padding, padding)
	f.right:SetWidth(rightWidth)
end

function ChannelHistory:CreateDebugFrame()
	if self.debugFrame then return end

	local f = CreateFrame("Frame", "EnhanceQoLChannelHistoryFrame", UIParent, "BackdropTemplate")
	self.debugFrame = f

	f:SetSize(1100, 640)
	f:SetPoint("CENTER")
	f:SetClampedToScreen(true)
	f:SetMovable(true)
	f:EnableMouse(true)
	f:RegisterForDrag("LeftButton")
	f:SetResizable(true)
	f:SetResizeBounds(840, 420, 1600, 1100)
	f:SetBackdrop(WINDOW_BACKDROP)
	f:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
	f.bg = f:CreateTexture(nil, "BACKGROUND")
	f.bg:SetAllPoints()
	f.bg:SetAtlas("character-panel-background")
	f.bg:SetAlpha(0.9)
	f:SetFrameStrata("DIALOG")

	f:SetScript("OnDragStart", function(frame) frame:StartMoving() end)
	f:SetScript("OnDragStop", function(frame) frame:StopMovingOrSizing() end)
	f:SetScript("OnMouseDown", function(frame, button)
		if button == "LeftButton" and not frame.isSizing then frame:StartMoving() end
	end)
	f:SetScript("OnMouseUp", function(frame) frame:StopMovingOrSizing() end)

	local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", f, "TOPRIGHT", 4, 4)

	-- Panels
	f.left = CreateFrame("Frame", nil, f, "BackdropTemplate")
	applyPanelBackdrop(f.left)
	f.left.bg = f.left:CreateTexture(nil, "BACKGROUND", nil, -7)
	f.left.bg:SetAllPoints()
	f.left.bg:SetAtlas("QuestLog-main-background")
	f.left.bg:SetAlpha(0.85)

	f.middle = CreateFrame("Frame", nil, f, "BackdropTemplate")
	applyPanelBackdrop(f.middle)
	f.middle.bg = f.middle:CreateTexture(nil, "BACKGROUND", nil, -7)
	f.middle.bg:SetAllPoints()
	f.middle.bg:SetAtlas("QuestLog-empty-quest-background")
	f.middle.bg:SetAlpha(0.75)

	f.right = CreateFrame("Frame", nil, f, "BackdropTemplate")
	applyPanelBackdrop(f.right)
	f.right.bg = f.right:CreateTexture(nil, "BACKGROUND", nil, -7)
	f.right.bg:SetAllPoints()
	f.right.bg:SetAtlas("communities-widebackground")
	f.right.bg:SetAlpha(0.78)

	-- Placeholder labels
	local leftTitle = CreateFrame("Frame", nil, f)
	leftTitle:SetPoint("BOTTOMLEFT", f.left, "TOPLEFT", 0, 4)
	leftTitle:SetPoint("BOTTOMRIGHT", f.left, "TOPRIGHT", 0, 4)
	leftTitle:SetHeight(42)
	local leftTitleText = leftTitle:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	leftTitleText:SetPoint("CENTER")
	leftTitleText:SetText("Scope / Characters")
	local leftLine = leftTitle:CreateTexture(nil, "BACKGROUND")
	leftLine:SetPoint("BOTTOMLEFT", leftTitle, "BOTTOMLEFT", 12, 4)
	leftLine:SetPoint("BOTTOMRIGHT", leftTitle, "BOTTOMRIGHT", -12, 4)
	leftLine:SetHeight(14)
	leftLine:SetAtlas("AftLevelup-GlowLine")
	leftLine:SetAlpha(0.9)

	local midTitle = CreateFrame("Frame", nil, f)
	midTitle:SetPoint("BOTTOMLEFT", f.middle, "TOPLEFT", 0, 4)
	midTitle:SetPoint("BOTTOMRIGHT", f.middle, "TOPRIGHT", 0, 4)
	midTitle:SetHeight(42)
	local midTitleText = midTitle:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	midTitleText:SetPoint("CENTER")
	midTitleText:SetText("Channel Filters")
	local midLine = midTitle:CreateTexture(nil, "BACKGROUND")
	midLine:SetPoint("BOTTOMLEFT", midTitle, "BOTTOMLEFT", 12, 4)
	midLine:SetPoint("BOTTOMRIGHT", midTitle, "BOTTOMRIGHT", -12, 4)
	midLine:SetHeight(14)
	midLine:SetAtlas("AftLevelup-GlowLine")
	midLine:SetAlpha(0.9)

	local rightTitle = CreateFrame("Frame", nil, f)
	rightTitle:SetPoint("BOTTOMLEFT", f.right, "TOPLEFT", 0, 4)
	rightTitle:SetPoint("BOTTOMRIGHT", f.right, "TOPRIGHT", 0, 4)
	rightTitle:SetHeight(42)
	local rightTitleText = rightTitle:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	rightTitleText:SetPoint("CENTER")
	rightTitleText:SetText("Chat History")
	local rightLine = rightTitle:CreateTexture(nil, "BACKGROUND")
	rightLine:SetPoint("BOTTOMLEFT", rightTitle, "BOTTOMLEFT", 12, 4)
	rightLine:SetPoint("BOTTOMRIGHT", rightTitle, "BOTTOMRIGHT", -12, 4)
	rightLine:SetHeight(14)
	rightLine:SetAtlas("AftLevelup-GlowLine")
	rightLine:SetAlpha(0.9)

	-- Search bars (debug placeholders)
	local leftSearch = createSearchBox(f.left, "Search character / realm...")
	leftSearch:SetPoint("TOPLEFT", f.left, "TOPLEFT", 10, -12)
	leftSearch:SetPoint("TOPRIGHT", f.left, "TOPRIGHT", -10, -12)

	local rightSearch = createSearchBox(f.right, "Search logs...")
	rightSearch:SetPoint("TOPLEFT", f.right, "TOPLEFT", 10, -12)
	rightSearch:SetPoint("TOPRIGHT", f.right, "TOPRIGHT", -10, -12)

	-- Resize grip
	local grip = CreateFrame("Button", nil, f)
	grip:SetSize(16, 16)
	grip:SetPoint("BOTTOMRIGHT", -6, 6)
	grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
	grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
	grip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
	grip:SetScript("OnMouseDown", function(frame, button)
		if button == "LeftButton" then
			f.isSizing = true
			f:StartSizing("BOTTOMRIGHT")
		end
	end)
	grip:SetScript("OnMouseUp", function()
		f:StopMovingOrSizing()
		f.isSizing = false
	end)

	f:SetScript("OnSizeChanged", function(frame, w, h) ChannelHistory:LayoutDebugFrame(w, h) end)

	self:LayoutDebugFrame()
	f:Show()
end
