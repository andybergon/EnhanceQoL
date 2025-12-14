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
		local className, classFile, classID = UnitClass("player")
		charBucket = {
			name = keys.player,
			realm = keys.realmName,
			faction = keys.faction,
			className = className,
			classFile = classFile,
			classID = classID,
			channels = {},
		}
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
	if not charBucket.classFile then
		local className, classFile, classID = UnitClass("player")
		charBucket.className = className
		charBucket.classFile = classFile
		charBucket.classID = classID
	end
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

local function getClassStyle(classFile)
	if not classFile then return nil end
	local color = RAID_CLASS_COLORS and RAID_CLASS_COLORS[classFile]
	return color
end

local function setButtonClassVisual(btn, classFile)
	local color = getClassStyle(classFile)
	if color and btn.nameText then btn.nameText:SetTextColor(color.r, color.g, color.b) end
	if btn.icon and CLASS_ICON_TCOORDS and classFile and CLASS_ICON_TCOORDS[classFile] then
		btn.icon:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")
		btn.icon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[classFile]))
		btn.icon:Show()
	elseif btn.icon then
		btn.icon:SetTexture(nil)
		btn.icon:Hide()
	end
end

-- UI helpers: left tree
function ChannelHistory:BuildLeftEntries(filterText)
	if not self.history or not self.keys then self:InitStorage() end
	local entries = {}
	local factionBucket = self.history and self.history[self.keys.faction]
	local state = self.ui and self.ui.leftState or { realms = {}, accountExpanded = true }
	self.ui = self.ui or {}
	local playerCharKey = "char:" .. (self.keys.charKey or "")
	if not self.ui.leftSelected then self.ui.leftSelected = playerCharKey end
	filterText = filterText and filterText:lower()

	local function matchesFilter(name, realm)
		if not filterText or filterText == "" then return true end
		if name and name:lower():find(filterText, 1, true) then return true end
		if realm and realm:lower():find(filterText, 1, true) then return true end
		return false
	end

	-- Account node
	table.insert(entries, { kind = "header", label = "All", level = 0, key = "account", expanded = state.accountExpanded ~= false })

	if factionBucket and type(factionBucket) == "table" then
		local realmKeys = {}
		for realmKey in pairs(factionBucket) do
			table.insert(realmKeys, realmKey)
		end
		table.sort(realmKeys)

		for _, realmKey in ipairs(realmKeys) do
			local realmData = factionBucket[realmKey]
			local realmLabel = realmData and realmData.realmName or realmKey
			local realmEntry = {
				kind = "realm",
				label = realmLabel,
				level = 1,
				key = "realm:" .. realmKey,
				expanded = state.realms[realmKey] ~= false,
			}
			table.insert(entries, realmEntry)

			if realmEntry.expanded and realmData and realmData.characters then
				local charKeys = {}
				for charKey in pairs(realmData.characters) do
					table.insert(charKeys, charKey)
				end
				table.sort(charKeys)
				for _, charKey in ipairs(charKeys) do
					local charData = realmData.characters[charKey]
					if charData then
						if matchesFilter(charData.name, realmLabel) then
							table.insert(entries, {
								kind = "character",
								label = charData.name or charKey,
								level = 2,
								key = "char:" .. charKey,
								realm = realmLabel,
								classFile = charData.classFile,
								className = charData.className,
								charKey = charKey,
							})
						end
					end
				end
			end
		end
	end

	self.ui = self.ui or {}
	self.ui.leftEntries = entries
	return entries
end

local function ensureLeftButtons(self, count)
	self.ui.leftButtons = self.ui.leftButtons or {}
	local buttons = self.ui.leftButtons
	local content = self.ui.leftContent
	local buttonHeight = 22

	for i = #buttons + 1, count do
		local btn = CreateFrame("Button", nil, content)
		btn:EnableMouse(true)
		btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		btn:SetHeight(buttonHeight)
		btn:SetPoint("TOPLEFT", content, "TOPLEFT", 4, -((i - 1) * buttonHeight))
		btn:SetPoint("TOPRIGHT", content, "TOPRIGHT", -4, -((i - 1) * buttonHeight))

		btn.bg = btn:CreateTexture(nil, "BACKGROUND")
		btn.bg:SetAllPoints()
		btn.bg:SetTexture("Interface\\AuctionFrame\\AuctionHouse-UI-Row-Select")
		btn.bg:SetTexCoord(0, 1, 0, 1)
		btn.bg:SetVertexColor(1, 1, 1, 0)

		btn.hl = btn:CreateTexture(nil, "HIGHLIGHT")
		btn.hl:SetAllPoints()
		btn.hl:SetColorTexture(1, 1, 1, 0.08)

		btn.icon = btn:CreateTexture(nil, "ARTWORK")
		btn.icon:SetSize(16, 16)
		btn.icon:SetPoint("LEFT", btn, "LEFT", 4, 0)

		btn.toggle = btn:CreateTexture(nil, "ARTWORK")
		btn.toggle:SetSize(12, 12)
		btn.toggle:SetPoint("LEFT", btn, "LEFT", 2, 0)
		btn.toggle:Hide()
		btn.toggleFrame = CreateFrame("Button", nil, btn)
		btn.toggleFrame:SetSize(16, 16)
		btn.toggleFrame:SetPoint("LEFT", btn, "LEFT", 0, 0)
		btn.toggleFrame:Hide()

		btn.nameText = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		btn.nameText:SetPoint("LEFT", btn.icon, "RIGHT", 6, 0)

		btn:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")

		btn:SetScript("OnEnter", function(selfBtn)
			if selfBtn.hl then selfBtn.hl:Show() end
		end)
		btn:SetScript("OnLeave", function(selfBtn)
			if selfBtn.hl then selfBtn.hl:Hide() end
		end)

		buttons[i] = btn
	end

	return buttonHeight, buttons
end

function ChannelHistory:RefreshLeftList()
	if not self.debugFrame or not self.ui or not self.ui.leftContent then return end
	local filter = self.ui.leftSearch and self.ui.leftSearch:GetText()
	local entries = self:BuildLeftEntries(filter)
	local buttonHeight, buttons = ensureLeftButtons(self, #entries)
	if self.ui.leftScroll and self.ui.leftContent then
		local width = math.max(1, (self.ui.leftScroll:GetWidth() or 0) - 16)
		self.ui.leftContent:SetWidth(width)
	end

	for i, entry in ipairs(entries) do
		local btn = buttons[i]
		btn.entry = entry
		btn:Show()

		if self.ui.leftSelected == entry.key then
			btn.bg:SetVertexColor(1, 1, 1, 1)
		else
			btn.bg:SetVertexColor(1, 1, 1, 0)
		end
		btn.icon:Hide()
		btn.toggle:Hide()
		btn.toggleFrame:Hide()

		local indent = (entry.level or 0) * 14
		btn.nameText:SetPoint("LEFT", btn.icon, "RIGHT", 6 + indent, 0)

		if entry.kind == "header" then
			btn.toggle:Hide()
			btn.toggleFrame:Hide()
			btn.nameText:SetText(entry.label)
			btn.nameText:SetTextColor(1, 0.9, 0.6)
			btn.icon:Hide()
		elseif entry.kind == "realm" then
			btn.toggle:Show()
			btn.toggle:SetAtlas(entry.expanded and "NPE_ArrowDown" or "NPE_ArrowRight")
			btn.toggleFrame:Show()
			btn.icon:SetTexture("Interface\\FriendsFrame\\PlusManz-Highlight")
			btn.icon:Show()
			btn.nameText:SetText(entry.label or entry.key)
			btn.nameText:SetTextColor(0.85, 0.85, 0.85)
		elseif entry.kind == "character" then
			setButtonClassVisual(btn, entry.classFile)
			btn.nameText:SetText(entry.label)
			local color = getClassStyle(entry.classFile)
			if color then
				btn.nameText:SetTextColor(color.r, color.g, color.b)
			else
				btn.nameText:SetTextColor(0.9, 0.9, 0.9)
			end
		else
			btn.nameText:SetText(entry.label or entry.key)
		end

		btn:SetScript("OnMouseUp", function(selfBtn, button)
			if button ~= "LeftButton" then return end
			local data = selfBtn.entry
			if not data then return end
			if data.kind == "character" then
				self.ui.leftSelected = data.key
				self:RefreshLeftList()
			end
		end)

		btn.toggleFrame:SetScript("OnMouseUp", function(_, button)
			if button ~= "LeftButton" then return end
			local data = btn.entry
			if not data or data.kind ~= "realm" then return end
			local realmKey = data.key:match("^realm:(.+)$") or data.key
			local newState = not data.expanded
			self.ui.leftState.realms[realmKey] = newState
			self:RefreshLeftList()
		end)
	end

	for j = #entries + 1, #buttons do
		buttons[j]:Hide()
	end

	local totalHeight = #entries * buttonHeight
	self.ui.leftContent:SetHeight(totalHeight)
	if self.ui.leftScroll then
		self.ui.leftScroll:UpdateScrollChildRect()
	end
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
		if self.ui and self.ui.leftSearch then
			self.ui.leftSearch:SetText("")
			SearchBoxTemplate_OnTextChanged(self.ui.leftSearch)
		end
		self:RefreshLeftList()
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
	self.ui = self.ui or {}
	self.ui.leftButtons = self.ui.leftButtons or {}
	self.ui.leftEntries = self.ui.leftEntries or {}
	self.ui.leftState = self.ui.leftState or { realms = {}, accountExpanded = true }

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
	self.ui.leftSearch = leftSearch
	leftSearch:SetScript("OnTextChanged", function(box)
		SearchBoxTemplate_OnTextChanged(box)
		ChannelHistory:RefreshLeftList()
	end)

	local rightSearch = createSearchBox(f.right, "Search logs...")
	rightSearch:SetPoint("TOPLEFT", f.right, "TOPLEFT", 10, -12)
	rightSearch:SetPoint("TOPRIGHT", f.right, "TOPRIGHT", -10, -12)

	-- Left list scroll
	local listTopOffset = -40
	local leftScroll = CreateFrame("ScrollFrame", nil, f.left, "UIPanelScrollFrameTemplate")
	leftScroll:SetPoint("TOPLEFT", f.left, "TOPLEFT", 8, listTopOffset)
	leftScroll:SetPoint("BOTTOMRIGHT", f.left, "BOTTOMRIGHT", -28, 12)
	local sb = leftScroll.ScrollBar or leftScroll.scrollBar
	if sb then
		sb:ClearAllPoints()
		sb:SetPoint("TOPLEFT", leftScroll, "TOPRIGHT", 2, -16)
		sb:SetPoint("BOTTOMLEFT", leftScroll, "BOTTOMRIGHT", 2, 16)
	end

	local leftContent = CreateFrame("Frame", nil, leftScroll)
	leftContent:SetSize(1, 1)
	leftScroll:SetScrollChild(leftContent)

	self.ui.leftScroll = leftScroll
	self.ui.leftContent = leftContent

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
	self:RefreshLeftList()
	f:Show()
end
