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
ChannelHistory.EVENT_FILTER_KEY = ChannelHistory.EVENT_FILTER_KEY
	or {
		CHAT_MSG_SAY = "SAY",
		CHAT_MSG_YELL = "YELL",
		CHAT_MSG_WHISPER = "WHISPER",
		CHAT_MSG_WHISPER_INFORM = "WHISPER",
		CHAT_MSG_BN_WHISPER = "BN_WHISPER",
		CHAT_MSG_BN_WHISPER_INFORM = "BN_WHISPER",
		CHAT_MSG_PARTY = "PARTY",
		CHAT_MSG_INSTANCE_CHAT = "INSTANCE",
		CHAT_MSG_INSTANCE_CHAT_LEADER = "INSTANCE",
		CHAT_MSG_RAID = "RAID",
		CHAT_MSG_RAID_LEADER = "RAID",
		CHAT_MSG_GUILD = "GUILD",
		CHAT_MSG_OFFICER = "OFFICER",
		CHAT_MSG_CHANNEL = "GENERAL",
		CHAT_MSG_COMMUNITIES_CHANNEL = "GENERAL",
		CHAT_MSG_LOOT = "LOOT",
		CHAT_MSG_MONEY = "LOOT",
		CHAT_MSG_CURRENCY = "LOOT",
		CHAT_MSG_SYSTEM = "SYSTEM",
		CHAT_MSG_OPENING = "OPENING",
	}
ChannelHistory.loggedIn = ChannelHistory.loggedIn or (IsLoggedIn and IsLoggedIn()) or false
ChannelHistory.defaultFilters = {
	SAY = true,
	GUILD = true,
	PARTY = true,
	INSTANCE = true,
	OFFICER = true,
	RAID = true,
	YELL = true,
	WHISPER = true,
	BN_WHISPER = true,
	GENERAL = true,
	SYSTEM = true,
	OPENING = true,
}
ChannelHistory.ui = ChannelHistory.ui or {}
local splitSender, getSenderClass, toColorCode, getChatColor, formatLine, deriveScope, resolveClassFromGUID

local function getClassStyle(classFile)
	if not classFile then return nil end
	local color = RAID_CLASS_COLORS and RAID_CLASS_COLORS[classFile]
	return color
end

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
	if ChannelHistory.EVENT_FILTER_KEY then
		for event in pairs(ChannelHistory.EVENT_FILTER_KEY) do
			if not IGNORED_EVENTS[event] then events[event] = true end
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
		local descriptor = channelBaseName or channelName or base
		local keyPart = descriptor
		if channelIndex then keyPart = tostring(channelIndex) .. ":" .. descriptor end
		local label = channelIndex and (tostring(channelIndex) .. ": " .. descriptor) or descriptor
		return base .. ":" .. keyPart, label
	end

	if event == "CHAT_MSG_COMMUNITIES_CHANNEL" then
		local communityID = safeSelect(18, ...)
		local streamID = safeSelect(19, ...)
		local channelName = safeSelect(4, ...) or base
		local descriptor
		if communityID or streamID then descriptor = string.format("%s:%s", communityID or "COMMUNITY", streamID or "STREAM") end
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
	-- respect filters
	local filterKey = self.EVENT_FILTER_KEY and self.EVENT_FILTER_KEY[event]
	if filterKey and self.IsFilterEnabled then
		if not self:IsFilterEnabled(filterKey) then return end
	end
	if self.maxLines == 0 then return end
	if not self.history or not self.keys then self:InitStorage() end
	local charBucket = getCharacterBucket(true)
	if not charBucket then return end
	local currentCharKey = self.keys and self.keys.charKey

	local msg, sender, _, _, _, _, _, _, _, _, lineID, guid, bnetIDAccount = ...
	-- Skip channel notices and trivial change messages
	if event == "CHAT_MSG_CHANNEL_NOTICE" or event == "CHAT_MSG_CHANNEL_NOTICE_USER" then return end
	if msg == "YOU_CHANGED" then return end
	local channelKey, channelLabel = buildChannelKey(event, ...)
	channelKey = channelKey or event
	local senderName, senderRealmKey = splitSender(sender)
	if (not senderRealmKey or senderRealmKey == "") and self.keys and self.keys.realmKey then senderRealmKey = self.keys.realmKey end
	local className, classFile = getSenderClass(guid)
	if not classFile then
		local token = resolveClassFromGUID(guid)
		if token then
			classFile = token
			className = (LOCALIZED_CLASS_NAMES_MALE and LOCALIZED_CLASS_NAMES_MALE[token]) or (LOCALIZED_CLASS_NAMES_FEMALE and LOCALIZED_CLASS_NAMES_FEMALE[token]) or token
		end
	end
	local classColor = classFile and getClassStyle(classFile)
	local chatColor = getChatColor(filterKey) or { r = 1, g = 0.82, b = 0 }
	local displayName = senderName or sender or ""
	if displayName ~= "" then
		local playerRealm = self.keys and self.keys.realmKey
		local sameRealm = senderRealmKey and playerRealm and senderRealmKey == playerRealm
		if senderRealmKey and senderRealmKey ~= "" and not sameRealm then displayName = displayName .. "-" .. senderRealmKey end
	end
	local stamp = now()

	charBucket.channels = charBucket.channels or {}
	local channelBucket = charBucket.channels[channelKey] or { label = channelLabel or channelKey, lines = {} }
	channelBucket.label = channelLabel or channelBucket.label or channelKey

	local line = {
		time = stamp,
		event = event,
		filterKey = filterKey,
		channel = channelKey,
		label = channelBucket.label,
		message = msg or "",
		sender = sender or "",
		ownerCharKey = self.keys.charKey,
		ownerRealmKey = self.keys.realmKey,
		ownerFaction = self.keys.faction,
		senderName = senderName or sender or "",
		senderRealmKey = senderRealmKey,
		senderClassName = className,
		senderClassFile = classFile,
		classColor = classColor,
		chatColor = chatColor,
		displayName = displayName,
		lineID = lineID,
		guid = guid,
		bnetIDAccount = bnetIDAccount,
	}
	line.formatted = formatLine(self, line)

	appendLine(channelBucket, line)

	charBucket.channels[channelKey] = channelBucket
	charBucket.lastUpdated = line.time
	if not charBucket.classFile then
		local className, classFile, classID = UnitClass("player")
		charBucket.className = className
		charBucket.classFile = classFile
		charBucket.classID = classID
	end
	if self.debugFrame and self.debugFrame:IsShown() then
		if self:ShouldDisplayLive(line, currentCharKey) then self:AppendLineToLog(line) end
	end
end

local function iterCharacters(scope, realmKey, charKey, factionKey)
	if not ChannelHistory.history or not ChannelHistory.keys then return function() end end

	local function yieldFromRealm(realm)
		if not realm or not realm.characters then return function() end end
		local keyList = {}
		for charKeyInner in pairs(realm.characters) do table.insert(keyList, charKeyInner) end
		table.sort(keyList)
		local i = 0
		return function()
			i = i + 1
			local key = keyList[i]
			if not key then return end
			return key, realm.characters[key]
		end
	end

	local function yieldFromFaction(factionBucket)
		if not factionBucket then return function() end end
		local realmKeys = {}
		for rKey in pairs(factionBucket) do table.insert(realmKeys, rKey) end
		table.sort(realmKeys)
		local realmIndex = 0
		local charIter = nil
		return function()
			while true do
				if not charIter then
					realmIndex = realmIndex + 1
					local rKey = realmKeys[realmIndex]
					if not rKey then return end
					charIter = yieldFromRealm(factionBucket[rKey])
				end
				local ck, data = charIter()
				if ck then return ck, data end
				charIter = nil
			end
		end
	end

	if scope == nil or scope == "character" then
		local targetChar = charKey or ChannelHistory.keys.charKey
		local inferredRealm = targetChar and targetChar:match("%-([^-]+)$")
		local targetRealm = realmKey or inferredRealm or ChannelHistory.keys.realmKey
		local targetFaction = factionKey or ChannelHistory.keys.faction
		local factionBucket = ChannelHistory.history[targetFaction]
		local realmBucket = factionBucket and factionBucket[targetRealm]
		local bucket = realmBucket and realmBucket.characters and realmBucket.characters[targetChar]
		local returned = false
		return function()
			if returned or not bucket then return end
			returned = true
			return targetChar, bucket
		end
	end

	if scope == "realm" then
		local targetFaction = factionKey or ChannelHistory.keys.faction
		local factionBucket = ChannelHistory.history[targetFaction]
		local targetRealm = realmKey or ChannelHistory.keys.realmKey
		return yieldFromRealm(factionBucket and factionBucket[targetRealm])
	end

	if scope == "faction" and factionKey then
		return yieldFromFaction(ChannelHistory.history[factionKey])
	end

	if scope == "faction" then
		local factionKeys = {}
		for fKey in pairs(ChannelHistory.history) do table.insert(factionKeys, fKey) end
		table.sort(factionKeys)
		local fIndex = 0
		local charIter = nil
		return function()
			while true do
				if not charIter then
					fIndex = fIndex + 1
					local fKey = factionKeys[fIndex]
					if not fKey then return end
					charIter = yieldFromFaction(ChannelHistory.history[fKey])
				end
				local ck, data = charIter()
				if ck then return ck, data end
				charIter = nil
			end
		end
	end

	return function() end
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

local function setButtonClassVisual(btn, classFile)
	local color = getClassStyle(classFile)
	if color and btn.nameText then btn.nameText:SetTextColor(color.r, color.g, color.b) end
end

local function setClassIcon(btn, classFile)
	if not btn or not btn.icon then return end
	if CLASS_ICON_TCOORDS and classFile and CLASS_ICON_TCOORDS[classFile] then
		local coords = CLASS_ICON_TCOORDS[classFile]
		btn.icon:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")
		btn.icon:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
		btn.icon:Show()
	else
		btn.icon:SetTexture(nil)
		btn.icon:Hide()
	end
end

local CHAT_COLOR_KEYS = {
	SAY = "SAY",
	YELL = "YELL",
	WHISPER = "WHISPER",
	BN_WHISPER = "BN_WHISPER",
	PARTY = "PARTY",
	INSTANCE = "INSTANCE_CHAT",
	RAID = "RAID",
	GUILD = "GUILD",
	OFFICER = "OFFICER",
	GENERAL = "CHANNEL", -- fallback to channel1 if CHANNEL missing
	LOOT = "LOOT",
	SYSTEM = "SYSTEM",
	OPENING = "OPENING",
}

local CHAT_COLOR_FALLBACK = {
	SAY = { r = 1, g = 1, b = 1 },
	YELL = { r = 1, g = 0.25, b = 0.25 },
	WHISPER = { r = 1, g = 0.5, b = 1 },
	BN_WHISPER = { r = 0, g = 1, b = 0.96 },
	PARTY = { r = 170 / 255, g = 170 / 255, b = 1 },
	INSTANCE = { r = 170 / 255, g = 170 / 255, b = 1 },
	RAID = { r = 1, g = 127 / 255, b = 0 },
	GUILD = { r = 0.25, g = 1, b = 0.25 },
	OFFICER = { r = 0.25, g = 0.75, b = 0.25 },
	GENERAL = { r = 192 / 255, g = 128 / 255, b = 128 / 255 },
	LOOT = { r = 0, g = 170 / 255, b = 0 },
	SYSTEM = { r = 1, g = 1, b = 0 },
	OPENING = { r = 128 / 255, g = 128 / 255, b = 1 },
}

function splitSender(sender)
	if not sender or sender == "" then return nil, nil end
	local name, realm = sender:match("^(.-)%-(.+)$")
	if not name or name == "" then name = sender end
	if realm and realm ~= "" then realm = sanitizeRealm(realm) end
	return name, realm
end

local CLASS_NAME_TO_FILE = nil

local function buildClassLookup()
	if CLASS_NAME_TO_FILE then return end
	CLASS_NAME_TO_FILE = {}
	if LOCALIZED_CLASS_NAMES_MALE then
		for token, loc in pairs(LOCALIZED_CLASS_NAMES_MALE) do
			CLASS_NAME_TO_FILE[loc] = token
		end
	end
	if LOCALIZED_CLASS_NAMES_FEMALE then
		for token, loc in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
			CLASS_NAME_TO_FILE[loc] = token
		end
	end
end

local function resolveClassTokenFromValues(values)
	buildClassLookup()
	for _, val in ipairs(values) do
		if type(val) == "string" then
			local upper = string.upper(val)
			if RAID_CLASS_COLORS and RAID_CLASS_COLORS[upper] then return upper end
			if CLASS_NAME_TO_FILE and CLASS_NAME_TO_FILE[val] then return CLASS_NAME_TO_FILE[val] end
		end
	end
	return nil
end

function resolveClassFromGUID(guid)
	if not guid or not GetPlayerInfoByGUID then return nil end
	local info = { GetPlayerInfoByGUID(guid) }
	if #info == 0 then return nil end
	return resolveClassTokenFromValues(info)
end

function getSenderClass(guid)
	local token = resolveClassFromGUID(guid)
	if not token then return nil, nil end
	local locName = (LOCALIZED_CLASS_NAMES_MALE and LOCALIZED_CLASS_NAMES_MALE[token]) or (LOCALIZED_CLASS_NAMES_FEMALE and LOCALIZED_CLASS_NAMES_FEMALE[token]) or token
	return locName, token
end

function toColorCode(color)
	if not color then return "|r" end
	local r = math.floor((color.r or 1) * 255 + 0.5)
	local g = math.floor((color.g or 1) * 255 + 0.5)
	local b = math.floor((color.b or 1) * 255 + 0.5)
	return string.format("|cff%02x%02x%02x", r, g, b)
end

function getChatColor(key)
	if not key then return nil end
	local chatKey = CHAT_COLOR_KEYS[key] or key
	local info = ChatTypeInfo and ChatTypeInfo[chatKey]
	if (not info or not info.r) and chatKey == "CHANNEL" then info = ChatTypeInfo and ChatTypeInfo["CHANNEL1"] end
	if info and info.r and info.g and info.b then return info end
	return CHAT_COLOR_FALLBACK[key]
end

function formatLine(self, line)
	if not line then return "" end

	-- Enrich sender info if it was not stored yet (old lines)
	if (not line.senderName) or (line.senderRealmKey == nil) then
		local senderName, senderRealmKey = splitSender(line.sender)
		line.senderName = line.senderName or senderName or line.sender or ""
		line.senderRealmKey = line.senderRealmKey or senderRealmKey
	end
	if (not line.senderClassFile) and line.guid then
		local _, classFile = getSenderClass(line.guid)
		line.senderClassFile = classFile
	end
	if (not line.classColor) and line.senderClassFile then line.classColor = getClassStyle(line.senderClassFile) end
	if (not line.classColor) and line.guid then
		local token = resolveClassFromGUID(line.guid)
		if token then
			line.senderClassFile = token
			line.classColor = getClassStyle(token)
		end
	end
	local playerRealmKey = self.keys and self.keys.realmKey
	local senderRealmKey = line.senderRealmKey or playerRealmKey
	local sameRealm = senderRealmKey and playerRealmKey and senderRealmKey == playerRealmKey
	if not line.displayName then
		local display = line.senderName or ""
		if display ~= "" and not sameRealm and senderRealmKey and senderRealmKey ~= "" then display = display .. "-" .. senderRealmKey end
		line.displayName = display
	end

	local timeText = date("%H:%M:%S", line.time or now())
	timeText = string.format("|cff888888%s|r", timeText)

	local chatColor = line.chatColor or line.color or getChatColor(line.filterKey) or { r = 1, g = 0.82, b = 0 }
	local chatColorCode = toColorCode(chatColor)
	line.chatColor = chatColor

	local nameColor = line.classColor or chatColor
	local nameColorCode = toColorCode(nameColor)
	local nameText = ""
	if line.displayName and line.displayName ~= "" then
		local linkTarget = line.sender and line.sender ~= "" and line.sender or line.displayName
		nameText = string.format("|Hplayer:%s|h%s[%s]|r|h", linkTarget, nameColorCode, line.displayName)
	end

	local body = line.message or ""
	body = body:gsub("|r", "|r" .. chatColorCode)

	local parts = { timeText, " ", chatColorCode }
	if nameText ~= "" then
		table.insert(parts, nameText)
		table.insert(parts, "|r")
		table.insert(parts, chatColorCode)
		table.insert(parts, ": ")
	end
	table.insert(parts, body)
	table.insert(parts, "|r")

	local text = table.concat(parts)
	line.formatted = text
	return text
end

local function matchesSearch(searchText, message, sender)
	if not searchText or searchText == "" then return true end
	local needle = searchText:lower()
	if message and message:lower():find(needle, 1, true) then return true end
	if sender and sender:lower():find(needle, 1, true) then return true end
	return false
end

function ChannelHistory:ShouldDisplayLive(line, currentCharKey)
	if not self.debugFrame or not self.debugFrame:IsShown() then return false end
	if not self.ui or not self.ui.logFrame then return false end
	if not line.filterKey and line.event and self.EVENT_FILTER_KEY then
		line.filterKey = self.EVENT_FILTER_KEY[line.event]
	end
	if not self:IsFilterEnabled(line.filterKey) then return false end
	local scope, realmKey, charKey, factionKey = deriveScope(self.ui.selection, self.keys)
	if scope == "character" then
		if charKey and line.ownerCharKey and charKey ~= line.ownerCharKey then return false end
	elseif scope == "realm" then
		local lineRealm = line.ownerRealmKey or (line.ownerCharKey and line.ownerCharKey:match("%-([^-]+)$")) or self.keys.realmKey
		if realmKey and lineRealm and realmKey ~= lineRealm then return false end
	elseif scope == "faction" and factionKey then
		local lineFaction = line.ownerFaction or self.keys.faction
		if lineFaction and factionKey ~= lineFaction then return false end
	end
	local search = self.ui.rightSearch and self.ui.rightSearch:GetText()
	if not matchesSearch(search, line.message, line.sender) then return false end
	return true
end

function ChannelHistory:AppendLineToLog(line)
	if not self.ui or not self.ui.logFrame then return end
	local text = formatLine(self, line)
	self.ui.logFrame:AddMessage(text, 1, 1, 1)
	if self.ui.logFrame.ScrollToBottom then self.ui.logFrame:ScrollToBottom() end
end

function ChannelHistory:IsFilterEnabled(filterKey)
	if not filterKey then return true end
	self.ui = self.ui or {}
	self.ui.filters = self.ui.filters or {}
	local stored = self.ui.filters[filterKey]
	if stored ~= nil then return stored end
	return self.defaultFilters[filterKey] ~= false
end

function ChannelHistory:LoadFiltersFromDB()
	self.ui = self.ui or {}
	self.ui.filters = self.ui.filters or {}
	if addon.db and addon.db.chatChannelFilters then
		for k, v in pairs(addon.db.chatChannelFilters) do
			self.ui.filters[k] = v and true or false
		end
	end
end

function deriveScope(selection, keys)
	if not selection then return "character", keys and keys.charKey, nil, keys and keys.faction end
	if selection.type == "header" then return "faction", nil, nil, nil end
	if selection.type == "faction" then
		local factionKey = selection.key and selection.key:match("^faction:(.+)$") or selection.key
		return "faction", nil, nil, factionKey
	end
	if selection.type == "realm" then
		local factionKey, realmKey = (selection.key or ""):match("^realm:([^:]+):(.+)$")
		if not realmKey then realmKey = selection.key and selection.key:match("^realm:(.+)$") or selection.key end
		if not factionKey then factionKey = keys and keys.faction end
		return "realm", realmKey, nil, factionKey
	end
	if selection.type == "character" then
		local factionKey, charKey = (selection.key or ""):match("^char:([^:]+):(.+)$")
		if not charKey then charKey = selection.key and selection.key:match("^char:(.+)$") or selection.key end
		if not factionKey then factionKey = keys and keys.faction end
		return "character", nil, charKey, factionKey
	end
	return "character", nil, keys and keys.charKey, keys and keys.faction
end

local function collectLines(self, scope, realmKey, charKey, factionKey, searchText)
	local results = {}
	if not self.history or not self.keys then self:InitStorage() end
	local search = searchText and searchText:lower()

	local function addFromChar(charData, charKeyInner)
		if not charData or not charData.channels then return end
		for _, channelData in pairs(charData.channels) do
			for _, line in ipairs(channelData.lines or {}) do
				if not line.filterKey and line.event and self.EVENT_FILTER_KEY then
					line.filterKey = self.EVENT_FILTER_KEY[line.event]
				end
				if matchesSearch(search, line.message, line.sender) and self:IsFilterEnabled(line.filterKey) then
					table.insert(results, {
						charKey = charKeyInner,
						line = line,
					})
				end
			end
		end
	end

	for ck, cd in iterCharacters(scope, realmKey, charKey, factionKey) do
		addFromChar(cd, ck)
	end

	table.sort(results, function(a, b) return (a.line.time or 0) < (b.line.time or 0) end)
	return results
end

local function setLabelText(label, text)
	if label then label:SetText(text) end
end

-- UI helpers: left tree
function ChannelHistory:BuildLeftEntries(filterText)
	if not self.history or not self.keys then self:InitStorage() end
	local entries = {}
	local state = self.ui and self.ui.leftState or { realms = {}, factions = {}, accountExpanded = true }
	state.realms = state.realms or {}
	state.factions = state.factions or {}
	self.ui = self.ui or {}
	local playerCharKey = "char:" .. (self.keys.faction or "") .. ":" .. (self.keys.charKey or "")
	if not self.ui.selection then self.ui.selection = { type = "character", key = playerCharKey, faction = self.keys.faction } end
	filterText = filterText and filterText:lower()

	local function matchesFilter(name, realm)
		if not filterText or filterText == "" then return true end
		if name and name:lower():find(filterText, 1, true) then return true end
		if realm and realm:lower():find(filterText, 1, true) then return true end
		return false
	end

	-- Account node
	table.insert(entries, { kind = "header", label = "All", level = 0, key = "account", expanded = state.accountExpanded ~= false })

	local history = self.history or {}
	local factionKeys = {}
	for fKey in pairs(history) do table.insert(factionKeys, fKey) end
	table.sort(factionKeys)

	for _, fKey in ipairs(factionKeys) do
		local factionBucket = history[fKey]
		local factionEntry = {
			kind = "faction",
			label = fKey,
			level = 1,
			key = "faction:" .. fKey,
			factionKey = fKey,
			expanded = state.factions[fKey] ~= false,
		}
		table.insert(entries, factionEntry)

		if factionEntry.expanded and factionBucket and type(factionBucket) == "table" then
			local realmKeys = {}
			for realmKey in pairs(factionBucket) do table.insert(realmKeys, realmKey) end
			table.sort(realmKeys)

			state.realms[fKey] = state.realms[fKey] or {}

			for _, realmKey in ipairs(realmKeys) do
				local realmData = factionBucket[realmKey]
				local realmLabel = realmData and realmData.realmName or realmKey
				local realmEntry = {
					kind = "realm",
					label = realmLabel,
					level = 2,
					key = string.format("realm:%s:%s", fKey, realmKey),
					expanded = state.realms[fKey][realmKey] ~= false,
					factionKey = fKey,
					realmKey = realmKey,
				}
				table.insert(entries, realmEntry)

				if realmEntry.expanded and realmData and realmData.characters then
					local charKeys = {}
					for charKey in pairs(realmData.characters) do table.insert(charKeys, charKey) end
					table.sort(charKeys)
					for _, charKey in ipairs(charKeys) do
						local charData = realmData.characters[charKey]
						if charData then
							if matchesFilter(charData.name, realmLabel) then
								table.insert(entries, {
									kind = "character",
									label = charData.name or charKey,
									level = 3,
									key = string.format("char:%s:%s", fKey, charKey),
									realm = realmLabel,
									factionKey = fKey,
									realmKey = realmKey,
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
		btn.hl:Hide()

		btn.icon = btn:CreateTexture(nil, "ARTWORK")
		btn.icon:SetSize(16, 16)
		btn.icon:SetPoint("LEFT", btn, "LEFT", 4, 0)

		btn.toggle = btn:CreateTexture(nil, "ARTWORK")
		btn.toggle:SetSize(12, 12)
		btn.toggle:SetPoint("LEFT", btn, "LEFT", 2, 0)
		btn.toggle:Hide()
		btn.toggleFrame = CreateFrame("Button", nil, btn)
		btn.toggleFrame:SetSize(18, 18)
		btn.toggleFrame:SetPoint("LEFT", btn, "LEFT", 0, 0)
		btn.toggleFrame:Hide()

		btn.nameText = btn:CreateFontString(nil, "OVERLAY")
		btn.nameText:SetFontObject("GameFontNormal")
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

		local sel = self.ui.selection or { type = "character", key = self.keys.charKey and ("char:" .. self.keys.charKey) or nil }
		local selected = sel and sel.key == entry.key and sel.type == entry.kind
		btn.bg:SetVertexColor(1, 1, 1, selected and 0.35 or 0)
		btn.icon:Hide()
		btn.toggle:Hide()
		btn.toggleFrame:Hide()

		local indent = (entry.level or 0) * 14
		local baseX = 10 + indent

		btn.icon:ClearAllPoints()
		btn.nameText:ClearAllPoints()
		btn.toggleFrame:ClearAllPoints()
		btn.toggle:ClearAllPoints()
		btn.toggleFrame:SetPoint("LEFT", btn, "LEFT", baseX - 10, 0)
		btn.toggle:SetPoint("CENTER", btn.toggleFrame, "CENTER", 0, 0)

		if entry.kind == "header" then
			btn.toggle:Hide()
			btn.toggleFrame:Hide()
			btn.icon:Hide()
			btn.nameText:SetPoint("LEFT", btn, "LEFT", baseX, 0)
			setLabelText(btn.nameText, entry.label)
			btn.nameText:SetTextColor(1, 0.9, 0.6)
		elseif entry.kind == "faction" then
			btn.toggle:Show()
			btn.toggle:SetAtlas(entry.expanded and "NPE_ArrowDown" or "NPE_ArrowRight")
			btn.toggleFrame:Show()
			btn.icon:SetTexture("Interface\\FriendsFrame\\PlusManz-Highlight")
			btn.icon:SetPoint("LEFT", btn, "LEFT", baseX - 10, 0)
			btn.icon:Show()
			btn.nameText:SetPoint("LEFT", btn.icon, "RIGHT", 4, 0)
			setLabelText(btn.nameText, entry.label or entry.key)
			btn.nameText:SetTextColor(0.9, 0.9, 0.9)
		elseif entry.kind == "realm" then
			btn.toggle:Show()
			btn.toggle:SetAtlas(entry.expanded and "NPE_ArrowDown" or "NPE_ArrowRight")
			btn.toggleFrame:Show()
			btn.icon:SetTexture("Interface\\FriendsFrame\\PlusManz-Highlight")
			btn.icon:SetPoint("LEFT", btn, "LEFT", baseX - 10, 0)
			btn.icon:Show()
			btn.nameText:SetPoint("LEFT", btn.icon, "RIGHT", 4, 0)
			setLabelText(btn.nameText, entry.label or entry.key)
			btn.nameText:SetTextColor(0.85, 0.85, 0.85)
		elseif entry.kind == "character" then
			local classFile = entry.classFile or (entry.charKey == (self.keys.charKey or "") and select(2, UnitClass("player")))
			setClassIcon(btn, classFile)
			btn.icon:SetPoint("LEFT", btn, "LEFT", baseX + 12, 0)
			btn.nameText:SetPoint("LEFT", btn.icon, "RIGHT", 8, 0)
			setLabelText(btn.nameText, entry.label or entry.charKey or "")
			local color = getClassStyle(classFile)
			if color then
				btn.nameText:SetTextColor(color.r, color.g, color.b)
			else
				btn.nameText:SetTextColor(0.9, 0.9, 0.9)
			end
		else
			setLabelText(btn.nameText, entry.label or entry.key)
		end

		btn:SetScript("OnMouseUp", function(selfBtn, button)
			if button ~= "LeftButton" then return end
			local data = selfBtn.entry
			if not data then return end
			if data.kind == "character" then
				self.ui.selection = { type = "character", key = data.key, faction = data.factionKey }
				print("|cff99e599[EQOL] Selected:|r", data.key or "nil")
				self:RefreshLeftList()
				self:RefreshLogView()
			elseif data.kind == "realm" then
				local realmKey = data.realmKey or data.key:match("^realm:(.+)$") or data.key
				self.ui.selection = { type = "realm", key = data.key, faction = data.factionKey }
				print("|cff99e599[EQOL] Realm selected:|r", realmKey or "nil")
				self:RefreshLeftList()
				self:RefreshLogView()
			elseif data.kind == "faction" then
				self.ui.selection = { type = "faction", key = data.key, faction = data.factionKey }
				print("|cff99e599[EQOL] Faction selected:|r", data.factionKey or "nil")
				self:RefreshLeftList()
				self:RefreshLogView()
			elseif data.kind == "header" then
				self.ui.selection = { type = "header", key = data.key }
				print("|cff99e599[EQOL] Scope: All|r")
				self:RefreshLeftList()
				self:RefreshLogView()
			end
		end)

		btn.toggleFrame:SetScript("OnMouseUp", function(_, button)
			if button ~= "LeftButton" then return end
			local data = btn.entry
			if not data then return end
			if data.kind == "realm" then
				local realmKey = data.realmKey or data.key:match("^realm:(.+)$") or data.key
				local fKey = data.factionKey or self.keys.faction
				self.ui.leftState.realms[fKey] = self.ui.leftState.realms[fKey] or {}
				local newState = not data.expanded
				self.ui.leftState.realms[fKey][realmKey] = newState
			elseif data.kind == "faction" then
				local fKey = data.factionKey or data.key:match("^faction:(.+)$") or data.key
				local newState = not data.expanded
				self.ui.leftState.factions[fKey] = newState
			else
				return
			end
			self:RefreshLeftList()
		end)

		btn.toggleFrame:SetScript("OnEnter", function()
			if btn.hl then btn.hl:Show() end
		end)
		btn.toggleFrame:SetScript("OnLeave", function()
			if btn.hl then btn.hl:Hide() end
		end)
	end

	for j = #entries + 1, #buttons do
		buttons[j]:Hide()
	end

	local totalHeight = #entries * buttonHeight
	self.ui.leftContent:SetHeight(totalHeight)
	if self.ui.leftScroll then self.ui.leftScroll:UpdateScrollChildRect() end
end

function ChannelHistory:OnEvent(event, ...)
	if not self.enabled then return end
	if not self.loggedIn then return end
	if not self.events or not self.events[event] then return end
	self:Store(event, ...)
end

ChannelHistory.frame:SetScript("OnEvent", function(_, event, ...)
	if event == "PLAYER_LOGIN" then
		ChannelHistory.loggedIn = true
		ChannelHistory:InitStorage()
		ChannelHistory:SetMaxLines(addon.db and addon.db["chatChannelHistoryMaxLines"])
		if ChannelHistory.enabled then
			ChannelHistory:RegisterEvents()
			ChannelHistory:CreateDebugFrame()
			ChannelHistory:RefreshLogView()
		end
		return
	end
	ChannelHistory:OnEvent(event, ...)
end)

function ChannelHistory:RegisterEvents()
	if not self.frame then return end
	self.frame:UnregisterAllEvents()
	self.frame:RegisterEvent("PLAYER_LOGIN")
	if not self.loggedIn then return end
	self.events = self.events or buildEventSet()
	for event in pairs(self.events or {}) do
		self.frame:RegisterEvent(event)
	end
end

function ChannelHistory:SetEnabled(enabled)
	self.enabled = enabled and true or false
	self:LoadFiltersFromDB()
	if self.enabled then
		if self.loggedIn then
			self:InitStorage()
			self.events = self.events or buildEventSet()
			self:SetMaxLines(addon.db and addon.db["chatChannelHistoryMaxLines"])
		end
		self:RegisterEvents()
		if self.loggedIn then
			self:CreateDebugFrame()
			if self.debugFrame then self.debugFrame:Show() end
			if self.ui and self.ui.leftSearch then
				self.ui.leftSearch:SetText("")
				SearchBoxTemplate_OnTextChanged(self.ui.leftSearch)
			end
			self:RefreshLeftList()
			self:RefreshLogView()
		end
	else
		if self.frame then self.frame:UnregisterAllEvents() end
		if self.debugFrame then self.debugFrame:Hide() end
	end
end

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

function ChannelHistory:CreateFilterUI()
	if not self.debugFrame or not self.middle then return end
	self.ui.filters = self.ui.filters or {}
	local container = self.ui.filterContainer
	if not container then
		container = CreateFrame("Frame", nil, self.middle)
		self.ui.filterContainer = container
	end

	container:ClearAllPoints()
	container:SetPoint("TOPLEFT", self.middle, "TOPLEFT", 12, -36)
	container:SetPoint("TOPRIGHT", self.middle, "TOPRIGHT", -12, -36)

	local filters = {
		{ key = "SAY", label = "|T2056011:16:16:0:0|t Say" },
		{ key = "YELL", label = "|T892447:16:16:0:0|t Yell" },
		{ key = "WHISPER", label = "|T133458:16:16:0:0|t Whisper" },
		{ key = "BN_WHISPER", label = "|TInterface\\FriendsFrame\\UI-Toast-ChatInviteIcon:16:16:0:0|t BN Whisper" },
		{ key = "PARTY", label = "|T134149:16:16:0:0|t Party" },
		{ key = "INSTANCE", label = "|TInterface\\AddOns\\EnhanceQoL\\Icons\\Dungeon.tga:16:16:0:0|t Instance" },
		{ key = "RAID", label = "|TInterface\\AddOns\\EnhanceQoL\\Icons\\Raid.tga:16:16:0:0|t Raid" },
		{ key = "GUILD", label = "|T514261:16:16:0:0|t Guild" },
		{ key = "OFFICER", label = "|T133071:16:16:0:0|t Officer" },
		{ key = "GENERAL", label = "General" },
		{ key = "LOOT", label = "|T133639:16:16:0:0|t Loot" },
		{ key = "SYSTEM", label = "System" },
		{ key = "OPENING", label = "Opening" },
	}

	local checkHeight = 22
	local spacing = 4

	self.ui.filterChecks = self.ui.filterChecks or {}
	self.ui.filterRows = self.ui.filterRows or {}
	self:LoadFiltersFromDB()

	for i, info in ipairs(filters) do
		local row = self.ui.filterRows[i]
		if not row then
			row = CreateFrame("Button", nil, container)
			row:SetHeight(checkHeight)
			row.bg = row:CreateTexture(nil, "BACKGROUND")
			row.bg:SetAllPoints()
			row.bg:SetColorTexture(1, 1, 1, 0)
			row.hl = row:CreateTexture(nil, "HIGHLIGHT")
			row.hl:SetAllPoints()
			row.hl:SetColorTexture(1, 1, 1, 0.08)
			row.hl:Hide()
			self.ui.filterRows[i] = row
		end
		row:SetPoint("TOPLEFT", container, "TOPLEFT", 0, -((i - 1) * (checkHeight + spacing)))
		row:SetPoint("TOPRIGHT", container, "TOPRIGHT", 0, -((i - 1) * (checkHeight + spacing)))

		local cb = self.ui.filterChecks[i]
		if not cb then
			cb = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
			self.ui.filterChecks[i] = cb
		end
		cb:ClearAllPoints()
		cb:SetPoint("LEFT", row, "LEFT", 4, 0)
		local stored = self.ui.filters[info.key]
		local defaultOn = self.defaultFilters[info.key] ~= false
		cb:SetChecked(stored == nil and defaultOn or stored)

		local label = cb.Text or cb.text
		if not label then
			label = cb:CreateFontString(nil, "OVERLAY")
			cb.Text = label
		end

		label:ClearAllPoints()
		label:SetPoint("LEFT", cb, "RIGHT", 6, 0)
		label:SetPoint("RIGHT", row, "RIGHT", -6, 0)
		label:SetJustifyH("LEFT")
		label:SetWordWrap(false)
		label:SetFontObject("GameFontNormalLarge")
		setLabelText(label, info.label)
		label:Show()
		local c = info.color or getChatColor(info.key)
		if c then
			label:SetTextColor(c.r, c.g, c.b)
		else
			label:SetTextColor(1, 0.82, 0)
		end

		local function applyValue(val)
			local newVal = val and true or false
			self.ui.filters[info.key] = newVal
			if addon.db then
				addon.db.chatChannelFilters = addon.db.chatChannelFilters or {}
				addon.db.chatChannelFilters[info.key] = newVal
			end
			self:RefreshLogView()
		end

		cb:SetScript("OnClick", function(btn) applyValue(btn:GetChecked()) end)
		row:SetScript("OnClick", function() cb:Click() end)
		row:SetScript("OnEnter", function() row.hl:Show() end)
		row:SetScript("OnLeave", function() row.hl:Hide() end)
	end

	local totalHeight = #filters * (checkHeight + spacing)
	container:SetHeight(totalHeight)
	container:Show()
end

function ChannelHistory:EnsureLogFrame()
	if self.ui.logFrame then return end
	local frame = CreateFrame("ScrollingMessageFrame", nil, self.right)
	frame:SetPoint("TOPLEFT", self.right, "TOPLEFT", 10, -40)
	frame:SetPoint("BOTTOMRIGHT", self.right, "BOTTOMRIGHT", -10, 10)
	self.ui.logFont = self.ui.logFont or CreateFont("EnhanceQoLChannelHistoryLogFont")
	local fontSource = ChatFontNormal or GameFontNormal or NumberFontNormal
	local fontFile, fontHeight, fontFlags = fontSource:GetFont()
	self.ui.logFont:SetFont(fontFile, 14, (fontFlags and (fontFlags .. ",MONOCHROME")) or "MONOCHROME")
	frame:SetFontObject(self.ui.logFont)
	frame:SetJustifyH("LEFT")
	frame:SetFading(false)
	frame:SetMaxLines(1000)
	frame:SetHyperlinksEnabled(true)
	frame:EnableMouseWheel(true)
	frame:SetScript("OnMouseWheel", function(f, delta)
		if delta > 0 then
			f:ScrollUp()
		else
			f:ScrollDown()
		end
	end)
	frame:SetScript("OnHyperlinkClick", function(_, link, text, button)
		if SetItemRef then SetItemRef(link, text, button, frame) end
	end)
	self.ui.logFrame = frame
end

function ChannelHistory:RefreshLogView()
	if not self.history or not self.keys then self:InitStorage() end
	if not self.debugFrame or not self.ui or not self.ui.logFrame then return end
	local scope, realmKey, charKey, factionKey = deriveScope(self.ui.selection, self.keys)
	local search = self.ui.rightSearch and self.ui.rightSearch:GetText()
	local lines = collectLines(self, scope, realmKey, charKey, factionKey, search)

	local log = self.ui.logFrame
	log:Clear()
	for _, entry in ipairs(lines) do
		local line = entry.line
		local text = formatLine(self, line)
		log:AddMessage(text, 1, 1, 1)
	end
	if self.ui.logInfo then
		local count = #lines
		local max = self.maxLines or 0
		self.ui.logInfo:SetText(string.format("Lines: %d / %d", count, max))
	end
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
	if self.ui and self.ui.filterContainer then
		self.ui.filterContainer:SetPoint("TOPLEFT", f.middle, "TOPLEFT", 12, -36)
		self.ui.filterContainer:SetPoint("TOPRIGHT", f.middle, "TOPRIGHT", -12, -36)
	end

	-- Right panel
	f.right:SetPoint("TOPLEFT", f.middle, "TOPRIGHT", spacing, 0)
	f.right:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -padding, padding)
	f.right:SetWidth(rightWidth)
end

function ChannelHistory:CreateDebugFrame()
	if self.debugFrame then return end
	self:InitStorage()

	local f = CreateFrame("Frame", "EnhanceQoLChannelHistoryFrame", UIParent, "BackdropTemplate")
	self.debugFrame = f
	self.ui = self.ui or {}
	self.ui.leftButtons = self.ui.leftButtons or {}
	self.ui.leftEntries = self.ui.leftEntries or {}
	self.ui.leftState = self.ui.leftState or { realms = {}, factions = {}, accountExpanded = true }
	self.ui.filters = self.ui.filters or {}

	f:SetSize(950, 500)
	f:SetPoint("CENTER")
	f:SetClampedToScreen(true)
	f:SetMovable(true)
	f:EnableMouse(true)
	f:RegisterForDrag("LeftButton")
	f:SetResizable(false)
	f:SetBackdrop(WINDOW_BACKDROP)
	f:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
	f.bg = f:CreateTexture(nil, "BACKGROUND")
	f.bg:SetAllPoints()
	f.bg:SetAtlas("character-panel-background")
	f.bg:SetAlpha(0.9)
	f:SetFrameStrata("HIGH")

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
	self.left = f.left

	f.middle = CreateFrame("Frame", nil, f, "BackdropTemplate")
	applyPanelBackdrop(f.middle)
	f.middle.bg = f.middle:CreateTexture(nil, "BACKGROUND", nil, -7)
	f.middle.bg:SetAllPoints()
	f.middle.bg:SetAtlas("QuestLog-empty-quest-background")
	f.middle.bg:SetAlpha(0.75)
	self.middle = f.middle

	f.right = CreateFrame("Frame", nil, f, "BackdropTemplate")
	applyPanelBackdrop(f.right)
	f.right.bg = f.right:CreateTexture(nil, "BACKGROUND", nil, -7)
	f.right.bg:SetAllPoints()
	f.right.bg:SetAtlas("communities-widebackground")
	f.right.bg:SetAlpha(0.35)
	self.right = f.right

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
	self.ui.rightSearch = rightSearch
	rightSearch:SetScript("OnTextChanged", function(box)
		SearchBoxTemplate_OnTextChanged(box)
		ChannelHistory:RefreshLogView()
	end)
	self.ui.logInfo = f.right:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	self.ui.logInfo:SetPoint("TOPRIGHT", rightSearch, "BOTTOMRIGHT", 0, -2)
	self.ui.logInfo:SetText("")

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
			-- sizing disabled
		end
	end)
	grip:SetScript("OnMouseUp", function() end)
	grip:Hide()

	f:SetScript("OnSizeChanged", function(frame, w, h) ChannelHistory:LayoutDebugFrame(w, h) end)

	self:LayoutDebugFrame(950, 500)
	self:RefreshLeftList()
	self:CreateFilterUI()
	self:EnsureLogFrame()
	self:RefreshLogView()
	f:Show()
end
