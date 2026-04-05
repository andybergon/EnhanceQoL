local parentAddonName = "EnhanceQoL"
local addonName, addon = ...

if _G[parentAddonName] then
	addon = _G[parentAddonName]
else
	error(parentAddonName .. " is not loaded")
end

addon.Aura = addon.Aura or {}
addon.Aura.UF = addon.Aura.UF or {}
local UF = addon.Aura.UF

UF.AuraUtil = UF.AuraUtil or {}
local AuraUtil = UF.AuraUtil

local L = LibStub("AceLocale-3.0"):GetLocale("EnhanceQoL")
local Masque

function AuraUtil.getMasqueGroup()
	if not Masque and LibStub then Masque = LibStub("Masque", true) end
	if not Masque then return nil end
	UF.runtime = UF.runtime or {}
	if not UF.runtime.masqueGroup then
		UF.runtime.masqueGroup = Masque:Group(parentAddonName, L["Unit Frame Buffs/Debuffs"] or "Unit Frame Buffs/Debuffs")
	end
	return UF.runtime.masqueGroup
end

function AuraUtil.reskinMasqueButton(btn)
	if not btn then return false end
	local group = AuraUtil.getMasqueGroup()
	if group and btn._eqolMasqueType and group.ReSkin then
		group:ReSkin(btn)
		return true
	end
	return false
end

function AuraUtil.setAuraButtonSize(btn, size, force)
	size = tonumber(size)
	if not (btn and size and btn.SetSize) then return false end
	if force ~= true and btn._eqolAuraButtonSize == size then return false end
	btn:SetSize(size, size)
	btn._eqolAuraButtonSize = size
	AuraUtil.reskinMasqueButton(btn)
	return true
end

function AuraUtil.syncMasqueButton(btn, isDebuff)
	local group = AuraUtil.getMasqueGroup()
	if not (group and btn) then return end
	btn._eqolMasqueRegions = btn._eqolMasqueRegions or {
		Icon = btn.icon,
		Cooldown = btn.cd,
		Border = btn.border,
	}
	local desiredType = (isDebuff == true) and "Debuff" or "Buff"
	if btn._eqolMasqueType ~= desiredType then
		group:AddButton(btn, btn._eqolMasqueRegions, desiredType, true)
		btn._eqolMasqueType = desiredType
		if group.ReSkin then group:ReSkin(btn) end
	end
end

function UF.RegisterMasqueButtons()
	local group = AuraUtil.getMasqueGroup()
	if not group then return end

	local function syncMasqueButtonsInList(buttons, forcedIsDebuff)
		if not buttons then return end
		for i = 1, #buttons do
			local btn = buttons[i]
			if btn then
				local isDebuff = forcedIsDebuff
				if isDebuff == nil then isDebuff = btn.isDebuff == true end
				AuraUtil.syncMasqueButton(btn, isDebuff)
			end
		end
	end

	local states = addon.variables and addon.variables.states or nil
	if states then
		for _, st in pairs(states) do
			if st then
				syncMasqueButtonsInList(st.auraButtons, nil)
				syncMasqueButtonsInList(st.debuffButtons, true)
			end
		end
	end

	local GF = UF.GroupFrames
	if not GF then return end

	local function syncStateButtons(st)
		if not st then return end
		syncMasqueButtonsInList(st.buffButtons, false)
		syncMasqueButtonsInList(st.debuffButtons, true)
		syncMasqueButtonsInList(st.externalButtons, false)
		if st.groupButtons then
			for _, buttons in pairs(st.groupButtons) do
				syncMasqueButtonsInList(buttons, false)
			end
		end
	end

	local function eachChild(header, fn)
		if not (header and fn and header.GetAttribute) then return end
		local index = 1
		local child = header:GetAttribute("child" .. index)
		while child do
			fn(child, index)
			index = index + 1
			child = header:GetAttribute("child" .. index)
		end
	end

	for _, header in pairs(GF.headers or {}) do
		eachChild(header, function(child) syncStateButtons(child and child._eqolUFState) end)
	end

	for _, header in ipairs(GF._raidGroupHeaders or {}) do
		if header and not header._eqolSpecialHide then eachChild(header, function(child) syncStateButtons(child and child._eqolUFState) end) end
	end

	for _, frames in pairs(GF._previewFrames or {}) do
		for i = 1, #frames do
			local frame = frames[i]
			if frame then syncStateButtons(frame._eqolUFState) end
		end
	end
end

function UF.ReskinMasque()
	local group = AuraUtil.getMasqueGroup()
	if group and group.ReSkin then group:ReSkin() end
end

UF._masqueLoader = UF._masqueLoader or CreateFrame("Frame")
UF._masqueLoader:RegisterEvent("ADDON_LOADED")
UF._masqueLoader:SetScript("OnEvent", function(_, event, name)
	if event == "ADDON_LOADED" and name == "Masque" then
		UF.RegisterMasqueButtons()
		UF.ReskinMasque()
	end
end)
