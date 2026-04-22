# Changelog

## [10.6.0-beta2] - 2026-04-22

### 🐛 Fixed

- Cooldown Panels: Polished the Original Blizzard icon border so the frame, icon, and cooldown swipe line up more cleanly.

---

## [10.6.0] - 2026-04-22

### ✨ Added

- Cooldown Panels: Added an Original Blizzard icon border option, matching the rounded Cooldown Manager look for panel icons.

### 🐛 Fixed

- Cooldown Panels: Fixed panels for other specializations sometimes staying visible after switching specs.

---

## [10.5.2] - 2026-04-22

### 🐛 Fixed

- Action Bars: Ignored stale or invalid custom border texture paths from SavedVariables so old profile data can no longer render action buttons as solid black blocks.
- Profiles / Fonts: Guarded remaining tracker and bar font applications so global font-style SavedVariables are resolved before calling `SetFont`.

---

## [10.5.1] - 2026-04-22

### 🐛 Fixed

- Cooldown Panels / Bars: Added a duration toggle for Charge bars. Active Charge timers now render through Blizzard's native cooldown text and segmented Charge handoffs use native cooldown completion callbacks instead of spellcast polling.
- Minimap / Instance Difficulty: Read Delve tier text from Scenario Header widgets when Blizzard's Gossip tier API is absent, restoring normal Delve tiers and Nemesis Delve `?` / `??` labels.
- Mythic Plus / BR & Bloodlust Tracker: Clamped the live tracker buttons to the screen and immediately reset offsets when users change external anchor targets, so Party/Raid anchored trackers land on the intended frame.
- Unit Frames: Raised the default render strata for detached Power and Secondary Power bars so the health-frame border no longer overlaps them.

---

## [10.5.0] - 2026-04-22

### ✨ Added

- Group Frames / Externals: External cooldown icons can now show a glow, with color, style, and offset controls to make important external defensives easier to spot.

### 🐛 Fixed

- Profiles / Fonts / SharedMedia: Fixed invalid or missing LibSharedMedia font assets causing `FontString:SetFont(): Invalid font file asset` errors when profiles reference fonts that are not installed locally.
- Resource Bars / Essence: Temporarily disabled use of Blizzard's `GetPowerRegenForPowerType` for Essence prediction while the API is secret-only in current Retail builds.
- Tooltips: Added secret-value guards for unit identity lookups to avoid `UnitName(unit)` errors on secret tooltip units.
- Minimap / Instance Difficulty: Guarded the removed `C_GossipInfo.GetActiveDelveGossip` Delve tier API so Delves fall back to `D` instead of throwing an error.

---

## [10.4.0] - 2026-04-21

### ✨ Added

- Mythic Plus / BR & Bloodlust Tracker: Added tracker icon choices and grouped Bloodlust Edit Mode options into collapsible sections.
- Cooldown Panels: Added direct panel settings inside the panel dialog, including panel name, enabled state, spec filters, and quick role-group choices.

### 🔄 Changed

- Cooldown Panels: Reworked Layout Edit so panel controls open directly next to the editor, selected entries show their settings immediately, and panel layout editing no longer needs the normal Edit Mode button.
- Cooldown Panels: Simplified the editor layout with a compact drop area, smaller manual add row, and cleaner entries list without repeated fixed subgroup labels.

### 🐛 Fixed

- Unit Frames: Fixed boss-frame Edit Mode previews after reloads, restored frame highlights after dungeon or raid transitions, and restored the target-frame combat icon.
- Cooldown Panels: Fixed Blizzard Cooldown Manager aura icons not always resyncing after cooldown viewer frame reassignments, which could hide tracked panel icons until a later refresh.
- Cooldown Panels / Bars: Fixed separated stack bars so separated offset creates real bordered segments, matching Resource Bars segment rendering.
- Cooldown Panels: Fixed new panels and bar entries defaulting to an explicit `Outline` font style instead of the global font-outline setting.
- Cooldown Panels: Fixed cursor-anchored panels being difficult to configure from Layout Edit.
- Mythic Plus / Teleport Compendium: Fixed the World Map Teleport Compendium tab sometimes disappearing after finishing a dungeon or raid until the UI was reloaded.
- Minimap / Instance Difficulty: Fixed the instance difficulty indicator not always updating its displayed group size after raid members left a flex instance.

---

## [10.3.2] - 2026-04-20

### 🐛 Fixed

- Cooldown Panels / Performance: Reduced addon memory usage and improved overall performance by cleaning up oversized stored panel data.
- Unit Frames / Incoming Heals: Fixed overlay layering so incoming-heal prediction now renders above absorbs again.
- Nameplates / Default Nameplate Coloring: Fixed rare, rare elite, and world boss enemies not always using the configured nameplate colors.
- Cooldown Panels / Strata: Fixed panel handle strata handling.
- Mythic Plus / BR & Bloodlust Tracker: Fixed buggy tracker positions when anchored to Cooldown Panels by reapplying the tracker anchor after the target panel finishes positioning.
- Unit Frames / Follower Dungeons: Fixed spec-based Unit Frames profile switching not always updating when queueing as a different role/spec than the current one.
- Cooldown Panels / Borders / SharedMedia: Fixed a regression where icon borders were not re-applied after `/reload` when using externally registered SharedMedia borders.

---

## [10.3.1] - 2026-04-19

### 🐛 Fixed

- Unit Frames / Status Text: Fixed `Ghost` showing twice on unit frames when both health text and status text were enabled.
- Cooldown Panels / Edit Mode: Reduced lag when opening Edit Mode and `/ecd`. Cooldown Panels now stay almost completely outside of Blizzard Edit Mode and only use it where cursor-based placement still needs it.

---

## [10.3.0] - 2026-04-19

### ✨ Added

- Profiles / Fonts: Added global font and font-style controls, including mass-apply actions for full profiles, and added support for the new font-style system in Data Panels / Combat Text.
- UI / Frames: Added `Hide Event Toasts`.
- Unit Frames: Added absorb-based health-text formats, raised the configurable aura-icon size cap to `120`, and added the missing `Hide in pet battles` Edit Mode option to the Player Frame.
- Resource Bars / Shared Mode: Added optional `Classic` / `Shared` modes per specialization with shared slot layouts, shared anchoring, Edit Mode support, export/import support, and per-power styling overrides.
- Data Panels: Added a per-panel tooltip direction setting.
- Nameplates / Default Nameplate Coloring: Added customizable `Neutral`, `Threat warning`, and `Threat lost` health-bar colors.
- Cooldown Panels / Stances: Added `Shadowform` for Priest stance tracking.

### 🔄 Changed

- Mouse / Ring: Enabled opacity control across the mouse ring color settings.

### 🐛 Fixed

- Data Panels / Stats: Adapted the stats stream for WoW `12.0.5` secret-value restrictions and restored the primary stat display through Blizzard's specialization-based lookup.
- Unit Frames / Cast Bar: Fixed cast-icon border taint and layering issues, and fixed castbar gradients being tinted by the base castbar color while gradients are enabled.
- Group Frames: Fixed stale disconnected indicators after reconnects or reloads, and fixed party-frame names still shaking on the initial login when using non-top/non-bottom name anchors.
- Party/Raid Frames / Status text: Fixed the font outline setting getting stuck on `Outline`.
- Party Frames / Externals: Fixed `outside` anchoring and center alignment when portraits extend the visual frame width.
- Vendor / Baganator: Fixed missing sell and destroy markers, restored the destroy button, and reduced lag spikes when opening the bank from the inventory button.
- Pet Frame: Fixed the pet frame sometimes staying visible without an active pet when a visibility condition was configured.
- Combat Resurrection / Bloodlust Tracker: Fixed Edit Mode anchor restoration, text layering, and anchored positions after login or reload.
- Resource Bars / External Backdrop: Fixed preview and Edit Mode desync issues.
- Focus Interrupt Tracker: Fixed missing Warlock interrupt entries and erratic Edit Mode positioning.
- Group Frames / Healer Buffs: Added the missing `Ebon Might` aura ID `395296` so the buff is tracked correctly.
- Cooldown Panels / Proc Glow: Fixed action-button overlay glows getting stuck after spell-override swaps such as Demon Hunter `Metamorphosis`.

### ❌ Removed

- Data Panels / Stats: Removed `Versatility` from the stats stream for WoW `12.0.5`, because the updated stat APIs now require secret-protected arithmetic that addons can no longer safely perform.
- Character Frame / Stats: Temporarily removed the custom `Movement Speed` stat and custom stat-row formatting on the character stats pane for WoW `12.0.5`, because Blizzard now treats parts of the PaperDoll stats flow as secret-value protected.

---

## [10.2.0] - 2026-04-13

### ✨ Added

- Edit Mode / Anchoring: Combat Resurrection Tracker, Bloodlust Tracker, Standalone Private Auras, Combat Text, and Total Absorb Tracker can now be anchored to the same supported UI elements as Cooldown Panels.
- Group Frames / Party & Raid: Added an `Anchor to` option in Edit Mode so party and raid frames can be attached to other supported UI elements instead of only the screen.
- Unit Frames / Cooldown Viewer Anchoring: Player, party, and raid frames can now be anchored directly to the original Blizzard Cooldown Manager viewers, including `EssentialCooldownViewer`, `UtilityCooldownViewer`, and `BuffIconCooldownViewer`.
- UI / Bars & Resources: Added `Frame strata` and `Frame level offset` settings for resource bars, with the same layering applied consistently to borders, absorb overlays, and segmented resource elements.
- Unit Frames / Player Highlight: Added a separate `Highlight in combat` toggle with its own combat highlight color.
- Action Bars: Added anchor and X/Y offset controls for `Charges/Stacks` and `Keybinds` when their text override settings are enabled.
- Data Panels / Coordinates: Added a precision setting for the coordinates stream, so displayed coordinates can use `0`, `1`, or `2` decimal places.
- Map Navigation / Instance Difficulty: Added an `Anchor` setting for the Minimap difficulty text, so it can align to Minimap points like `TOPLEFT`, `TOP`, or `TOPRIGHT` and be adjusted with `x/y` offsets.
- UI / Interface: Added a `Custom` UI-scale option with a numeric input, so any value between `0.1` and `2` can be entered instead of only using fixed presets.
- Health Macro: Added `Refreshing Serum` to the combat potion pool so the macro can use it on the shared combat potion cooldown.
- Sound: Added a mute toggle for the `Gaze of the Alnseer` trinket under `Trinkets`.

### 🐛 Fixed

- Group Frames / Party & Raid: Fixed `Frame texture` selections using `Use health/power textures` resetting to `SOLID` after reload.
- Pet Frame: Fixed the pet frame sometimes staying visible even without an active pet when a visibility condition was configured.
- Group Frames / Auras: Fixed aura stack counts rendering behind custom aura borders, aura tooltips blocking clicks on party and raid frames, and debuff sub-filters hiding too many harmful auras.
- Group Frames / Auras: Restored the previous layering so party and raid buffs and debuffs stay above role icons and raid markers again.
- Group Frames: Reduced pixel-snapping jitter on party frame text, including player names and centered health or level text.
- Group Frames / Party: Fixed switching UF profiles in Delves and similar party-instance content with `Show Player` enabled sometimes throwing Lua errors and stretching the party frame to full screen height.
- Group Frames / Health: Fixed `Smooth fill` not animating party and raid health bars, so the setting works again instead of behaving the same in both states.
- Group Frames / Healer Buffs: Added the missing `Ebon Might` aura ID `395296` so the buff is tracked correctly.
- Unit Frames / Cast Bar: Fixed cast icon borders sometimes triggering a `Backdrop.lua` secret-number taint error and restored proper rendering for non-`SOLID` SharedMedia borders.
- Unit Frames / Visibility: Fixed `Show when Skyriding` and `Show when Flying` sometimes keeping unit frames visible while dead or flying as a ghost.
- Unit Frames / Status Text: Fixed `Group number font` on player and target frames using the regular status text font instead of its own dedicated font setting.
- Combat Resurrection Tracker / Bloodlust Tracker: Fixed anchored positions and anchor restoration after login or reload so the frames no longer fall back to the top-left corner.
- Focus Interrupt Tracker: Fixed missing Warlock interrupt entries so `Spell Lock` and `Axe Toss` are tracked correctly.
- Cooldown Panels: Fixed some spells occasionally showing a global cooldown swipe or timer when they should not.
- Cooldown Panels: Fixed talent-choice spell variants collapsing too aggressively onto their base spell, so legitimate combinations such as `Wild Charge` with `Dash` can be tracked together while mutually exclusive variants still deduplicate correctly.
