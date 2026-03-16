local addonName, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local SettingsLib = LibStub("LibEQOLSettingsMode-1.0")

local rootCategories = {
	{ id = "UI", label = _G["INTERFACE_LABEL"] },
	{ id = "GENERAL", label = _G["GENERAL"] },
	{ id = "GAMEPLAY", label = _G["SETTING_GROUP_GAMEPLAY"] },
	{ id = "SOCIAL", label = _G["SOCIAL_LABEL"] },
	{ id = "ECONOMY", label = L["Economy"] or "Economy" },
	{ id = "SOUND", label = _G["SOUND"] },
	{ id = "PROFILES", label = L["Profiles"] },
}

local function isSettingEnabled(key) return addon.db and addon.db[key] == true end

local function buildSlashCommandHint(commands, desc, usage)
	local commandText = table.concat(commands, ", ")
	if usage and usage ~= "" then commandText = commandText .. usage end
	return ("|cff00ff98%s|r %s"):format(commandText, desc)
end

local function createRootSlashCommandHints(category)
	addon.functions.SettingsCreateHeadline(category, L["rootSlashCommandsHeader"] or "Slash Commands")
	addon.functions.SettingsCreateText(category, L["rootSlashCommandsDesc"] or "Type these commands in chat. Feature-specific commands only appear here when their setting is enabled.")
	addon.functions.SettingsCreateText(category, L["rootSlashCommandsConflictDesc"] or "Some aliases may be unavailable if another add-on already uses them.")

	local entries = {
		{
			commands = { "/eqol" },
			desc = L["rootSlashCommandSettingsDesc"] or "Open the EnhanceQoL settings.",
		},
		{
			commands = { "/ecd", "/cpe" },
			desc = L["rootSlashCommandCooldownPanelsDesc"] or "Open the Cooldown Panels editor.",
			show = function() return SlashCmdList and SlashCmdList["EQOLCP"] ~= nil end,
		},
		{
			commands = { "/eim" },
			desc = L["rootSlashCommandInstantMessengerDesc"] or "Open the Instant Messenger window.",
			show = function() return isSettingEnabled("enableChatIM") end,
		},
		{
			commands = { "/eil" },
			desc = L["rootSlashCommandIgnoreDesc"] or "Open the enhanced ignore list.",
			show = function() return isSettingEnabled("enableIgnore") end,
		},
		{
			commands = { "/way" },
			usage = " [mapID] 37.8 61.2",
			desc = L["rootSlashCommandWayDesc"] or "Set a waypoint on the world map.",
			show = function() return isSettingEnabled("enableWayCommand") end,
		},
		{
			commands = { "/cdm", "/wa" },
			desc = L["rootSlashCommandCooldownViewerDesc"] or "Open the Blizzard Cooldown Viewer settings.",
			show = function() return isSettingEnabled("enableCooldownManagerSlashCommand") end,
		},
		{
			commands = { "/pull" },
			usage = " [seconds]",
			desc = L["rootSlashCommandPullTimerDesc"] or "Start the Blizzard pull countdown.",
			show = function() return isSettingEnabled("enablePullTimerSlashCommand") end,
		},
		{
			commands = { "/em", "/edit", "/editmode" },
			desc = L["rootSlashCommandEditModeDesc"] or "Open Edit Mode.",
			show = function() return isSettingEnabled("enableEditModeSlashCommand") end,
		},
		{
			commands = { "/kb" },
			desc = L["rootSlashCommandQuickKeybindDesc"] or "Open Quick Keybind Mode.",
			show = function() return isSettingEnabled("enableQuickKeybindSlashCommand") end,
		},
		{
			commands = { "/rl" },
			desc = L["rootSlashCommandReloadUIDesc"] or "Reload UI.",
			show = function() return isSettingEnabled("enableReloadUISlashCommand") end,
		},
	}

	for _, entry in ipairs(entries) do
		addon.functions.SettingsCreateText(category, buildSlashCommandHint(entry.commands, entry.desc, entry.usage), {
			parentSection = entry.show,
		})
	end
end

createRootSlashCommandHints(addon.SettingsLayout.rootCategory)

for _, entry in ipairs(rootCategories) do
	addon.SettingsLayout["root" .. entry.id] = addon.functions.SettingsCreateCategory(nil, entry.label, nil, entry.id)
end
