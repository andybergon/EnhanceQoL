# Fork Changes

[Compare upstream and fork](https://github.com/R41z0r/EnhanceQoL/compare/main...andybergon:EnhanceQoL:main)

All changes made in this fork (`andybergon/EnhanceQoL`) relative to upstream (`R41z0r/EnhanceQoL`).

| Feature | Status | Upstream | Fork | Notes |
|---------|--------|----------|------|-------|
| Clickcast slash commands (`/ccb`, `/clickcast`) | Brought upstream | PR #981, [`478b62ac`](https://github.com/R41z0r/EnhanceQoL/commit/478b62ac) (2026-03-17) | [`c241e899`](https://github.com/andybergon/EnhanceQoL/commit/c241e899) (2026-03-07) | Implemented independently upstream; functionally identical |
| CreateMacro limit fix | Brought upstream | PR #983 (closed), [`9814ce8d`](https://github.com/R41z0r/EnhanceQoL/commit/9814ce8d) (2026-03-09) | [`7325f136`](https://github.com/andybergon/EnhanceQoL/commit/7325f136) (2026-03-07) | Our fix was per-call-site guards; upstream extracted a shared `EnsureGlobalMacro()` helper across all macro types |
| Resource bar text options | Brought upstream (partially) | PR [#980](https://github.com/R41z0r/EnhanceQoL/pull/980), [`7ce6ade2`](https://github.com/R41z0r/EnhanceQoL/commit/7ce6ade2) (2026-03-07) | [`b2967d14`](https://github.com/andybergon/EnhanceQoL/commit/b2967d14) (2026-03-07) | Upstream added `CURPERCENT` ("Current - Percentage") only; `CURMAXPERCENT` ("Current/Max - Percentage") still fork-only |
| Cooldown panel "Only glow in combat" | Brought upstream | [`23ec74ce`](https://github.com/R41z0r/EnhanceQoL/commit/23ec74ce) (2026-03-17) | [`b4cea68b`](https://github.com/andybergon/EnhanceQoL/commit/b4cea68b) (2026-03-20) | Implemented independently upstream as `hideGlowOutOfCombat`; our `readyGlowOnlyInCombat` dropped in favor of upstream's version |
| Lightfused Mana Potion rank group | Brought upstream | [`8f8daa3c`](https://github.com/R41z0r/EnhanceQoL/commit/8f8daa3c) (2026-03-17) | [`ee3c3921`](https://github.com/andybergon/EnhanceQoL/commit/ee3c3921) (2026-03-20) | 241300/241301 grouped for "use highest rank" |
| Cooldown panel item init fix | Brought upstream | [`478b62ac`](https://github.com/R41z0r/EnhanceQoL/commit/478b62ac) (2026-03-17) | [`42c82243`](https://github.com/andybergon/EnhanceQoL/commit/42c82243) (2026-03-20) | Upstream added `GetItemUseSpellID` with proper caching + `RebuildSpellIndex` in Init |
| Out-of-combat-only class buff reminder | Brought upstream | [`f2fbdcaf`](https://github.com/R41z0r/EnhanceQoL/commit/f2fbdcaf) (2026-03-20) | [`ef73fb86`](https://github.com/andybergon/EnhanceQoL/commit/ef73fb86) (2026-03-20) | Implemented independently upstream as `DB_ONLY_OUT_OF_COMBAT` with `IsRuntimeEvaluationBlockedByCombat()`; fork commit skipped during rebase |
| [Right-click targeting blocker](#right-click-targeting-blocker) | Pending upstream | PR [#982](https://github.com/R41z0r/EnhanceQoL/pull/982) (open) | [`1b83d28d`](https://github.com/andybergon/EnhanceQoL/commit/1b83d28d) (2026-03-07) | Includes double-click support |
| [Absorb fill dropdown](#absorb-fill-dropdown) | Pending upstream | PR [#984](https://github.com/R41z0r/EnhanceQoL/pull/984) (open) | [`fb01a164`](https://github.com/andybergon/EnhanceQoL/commit/fb01a164) (2026-03-07) | Replaces mutually-exclusive checkboxes with a dropdown |
| `/vault`, `/greatvault`, `/weeklyvault` slash commands | Fork-only | — | [`2cb733fa`](https://github.com/andybergon/EnhanceQoL/commit/2cb733fa) (2026-03-08) | Blocked on collaborator access to open PR upstream |
| [Gossip skip behavior setting](#gossip-skip-behavior-setting) | Fork-only | — | [`a12bf33f`](https://github.com/andybergon/EnhanceQoL/commit/a12bf33f) (2026-03-20) | Dropdown for gossip "Skip" options: pause / auto-skip / accept normally |
| `CURMAXPERCENT` resource bar text | Fork-only | — | [`b2967d14`](https://github.com/andybergon/EnhanceQoL/commit/b2967d14) (2026-03-07) | "Current/Max - Percentage" text option; upstream only has `CURPERCENT` |
| [Health bar white after reload fix](#health-bar-white-after-reload-fix) | Fork-only | — | [`cc943b54`](https://github.com/andybergon/EnhanceQoL/commit/cc943b54) (2026-03-21) | Forces color update when `_lastColor` uninitialized (Midnight color curve) |
| [LFG ApplicationViewer taint fix](#lfg-applicationviewer-taint-fix) | Fork-only | — | [`fe800f94`](https://github.com/andybergon/EnhanceQoL/commit/fe800f94) (2026-03-23) | Moves RIO sort from `table.sort` on applicants array to `DataProvider:SetSortComparator` to prevent taint |
| [Trinket buff tracking + CPE glow suppression](#trinket-buff-tracking--cpe-glow-suppression) | Fork-only | — | [`bcc905cb`](https://github.com/andybergon/EnhanceQoL/commit/bcc905cb), [`819657ea`](https://github.com/andybergon/EnhanceQoL/commit/819657ea), [`28e065aa`](https://github.com/andybergon/EnhanceQoL/commit/28e065aa) (2026-03-23 → 2026-03-26) | ClassBuffReminder tracks trinket buff durations; suppresses "missing buff" while active; CPE glow suppression; combat/M+ taint guards; instance-only setting |
| [DungeonPortal RIO score frame taint fix](#dungeonportal-rio-score-frame-taint-fix) | Brought upstream | Independently fixed via `MeasureTextWidth`/`MeasureTextHeight` helpers (2026-03-25) | Skipped during rebase (2026-03-28) | Our `SafeGetStringWidth`/`SafeGetStringHeight` approach superseded by upstream's pre-measurement approach |
| [Sort M+ search results by leader score](#sort-m-search-results-by-leader-score) | Fork-only | — | [`53fa4695`](https://github.com/andybergon/EnhanceQoL/commit/53fa4695) (2026-03-26) | Sorts Dungeon Finder search results by leader's overall M+ score; shows score in color-coded brackets on each listing; applied-first option; debounced async re-sort |
| [Heal absorb bar for resource bars](#heal-absorb-bar-for-resource-bars) | Fork-only | — | [`ef6405f9`](https://github.com/andybergon/EnhanceQoL/commit/ef6405f9) (2026-03-26) | Adds heal absorb overlay to health bar with custom texture, color, fill mode (normal/reverse/opposite side), and sample preview |
| Cooldown panel passive trinket glow fix | Fork-only | — | `main` | `GetItemUseSpellID` checked `C_Item.GetItemSpell` which returns spells for "Equip:" effects too; now verifies "Use:" via tooltip |
| Class buff reminder "nearby only" filter | Fork-only | — | `main` | Only count group members in buff cast range (`IsSpellInRange`) for missing buff counts; falls back to visibility (~100yd) for AoE buffs like Battle Shout |
| Rank display mode dropdown | Fork-only (WIP) | — | branch `feat/rank-display-mode` | Replace "use highest rank" checkbox with Single/Highest/Lowest/Both dropdown |

This file and `CLAUDE.md` are also fork-only (project docs for Claude Code).

---

### Right-click targeting blocker

**Problem:** Right-clicking in the game world targets units/objects, which interferes with gameplay. Players needed a way to block this without losing camera rotation (which also uses right-click). Replaces the standalone "Right Click Modifier" addon by Zevade.

**Fix:** Hooks `WorldFrame:OnMouseUp` and calls `MouselookStop()` on right-click. This cancels the targeting action without affecting camera rotation — the same technique used by the Zevade addon. Separate in-combat and out-of-combat toggles let players configure behavior per context.

**Double-click support:** Two modes: (1) block all right-clicks entirely, or (2) block only single clicks while allowing double-click targeting. The second mode tracks `lastStopTime` and compares against a configurable threshold (default 0.2s, range 0.1–0.5s) — if a second click arrives within the threshold, it's allowed through.

**Files changed:** `Submodules/RightClickTargeting.lua` (new), `Modules/Mouse/Settings_Mouse.lua`, `EnhanceQoL.lua`, `EnhanceQoL.toc`, `Locales/enUS.lua`.

---

### Absorb fill dropdown

**Problem:** The absorb bar had two checkboxes — "Reverse absorb fill" and "Absorb overfill" — that were mutually exclusive. Checking one silently unchecked the other, which was confusing and easy to miss.

**Fix:** Replaces both checkboxes with a single dropdown offering three options: Normal / Reverse fill / Overfill. The getter/setter translates between the dropdown value and the two underlying boolean flags (`absorbReverseFill`, `absorbOverfill`), maintaining backward compatibility with existing saved variables.

**Files changed:** `Modules/Aura/Settings_Ressourcebars.lua`.

---

### Gossip skip behavior setting

**Problem:** The auto-quest system relies on Blizzard's gossip flags (`flags=1`) to detect which options to auto-accept, but this is unreliable on the Midnight client. There are known cases where flag-based detection picks the wrong option and skips story content the player wanted to see.

**Fix:** Adds a `findGossipSkipOption()` helper that strictly detects skip options by requiring both red color code (`|cFFFF0000`) and `<Skip` text — avoiding false positives from other red text like locked profession requirements. A dropdown in Quest settings offers three behaviors:
- **Pause** (default): Halts auto-accept when a skip option is detected, requiring manual input
- **Skip**: Automatically clicks the skip option via `C_GossipInfo.SelectOption()`
- **Accept**: Uses the old flag-based behavior (current upstream behavior)

**Files changed:** `EnhanceQoL.lua`, `Settings/Quest.lua`, `Locales/enUS.lua`.

---

### Health bar white after reload fix

**Problem:** On the Midnight client (12.x), health bars appeared white after `/reload` when using non-default textures (e.g., SharedMedia textures) without custom or class colors.

**Root cause:** When no custom color is set, `baseR/G/B/A` are all `nil`. On reload, `_lastColor` is also `nil` (fresh frame). The color comparison `nil ~= nil` evaluates to `false` in Lua, so the color update block was entirely skipped and the Midnight color curve (`UnitHealthPercent`) never got applied.

**Fix:** Forces `colorChanged = true` when `_lastColor` is uninitialized, ensuring the Midnight color curve is applied on first render regardless of whether base colors are set.

**Files changed:** `Modules/Aura/ResourceBars.lua`.

---

### LFG ApplicationViewer taint fix

**Problem:** Sorting LFG applicants by RIO score using `table.sort()` directly on the `self.applicants` array taints the secure frame. This causes `LFGListApplicationViewer_UpdateInfo` to fail when comparing secret values like `requiredItemLevel` and `comment` from `C_LFGList.GetActiveEntryInfo()`.

**Fix:** Moves sorting from the data layer to the display layer. Instead of mutating the applicants array, hooks `LFGListApplicationViewer_UpdateResults` and installs a comparator on the ScrollBox's `DataProvider` via `SetSortComparator()`. The comparator extracts dungeon scores from `C_LFGList.GetApplicantMemberInfo()` and sorts descending. The underlying array stays untouched and untainted.

**Key gotcha:** The comparator checks `issecretvalue()` on scores before comparing — if either score is secret, it returns `false` (no reorder) rather than erroring.

**Files changed:** `EnhanceQoL.lua`.

---

### Trinket buff tracking + CPE glow suppression

Three commits that build on each other to add trinket buff awareness to ClassBuffReminder and CooldownPanels.

**Problem:** Long-duration trinkets like Emerald Coach's Whistle (item 193718) give a 1-hour buff that players often forget to apply. Meanwhile, the cooldown panel shows a misleading "ready" glow when the trinket's cooldown finishes but the buff is still active (meaning it can't be used yet).

**Trinket tracking** (`bcc905cb`): Adds a `TRINKET_BUFF_ITEMS` table mapping item IDs to buff spell IDs. `GetTrinketMissingEntries()` scans both trinket slots for equipped trinkets, checks if the player has the corresponding buff aura, and shows a reminder if missing. Includes `HasRealPlayerInGroup()` to filter out AI followers in Delves/follower dungeons. Also adds Druid-specific Symbiotic Relationship tracking (combined MOTW + Symbiotic status in one consolidated check).

**CPE glow suppression** (`819657ea`): `IsLongBuffTrinketWithActiveBuff()` checks if a trinket's buff is currently active. CooldownPanels calls this for both ITEM-type and SLOT-type entries — if the buff is active, `canTriggerReadyGlow` is set to false, suppressing the misleading "ready" glow.

**Combat/taint robustness** (`28e065aa`): Three problems addressed:
1. **M+ aura taint:** `C_UnitAuras.GetUnitAuraBySpellID()` returns `nil` for valid buffs during M+ (Blizzard's `ForceTaint_Strong`). Fix: assume trinket buff is active when `C_ChallengeMode.IsChallengeModeActive()` rather than showing a false "missing" state.
2. **Battle-res flicker:** `InCombatLockdown()` briefly returns `false` during battle-res animations. Fix: track combat state via a `combatActive` flag set on `PLAYER_REGEN_DISABLED/ENABLED`, checked before the API call.
3. **Instance-only setting:** New `instanceOnly` option suppresses all reminders outside dungeons/raids, where buffs are less critical.

**Key gotcha (Emerald Coach's Whistle):** Caster gets spell 389581 "Coaching", target gets spell 386578 "Coached". Check the caster buff (389581) on the player. `GetAuraDataByIndex` may report overridden spell ID 386581, but `GetUnitAuraBySpellID` needs the base ID 389581.

**Files changed:** `Submodules/ClassBuffReminder.lua`, `Modules/Aura/CooldownPanels.lua`, `Locales/enUS.lua`.

---

### DungeonPortal RIO score frame taint fix

**Problem:** When the DungeonPortal RIO score frame is rendered inside a tainted callback chain (e.g., `GameTooltip:HookScript("OnHide")` triggered from `LFGList.lua`), APIs like `GetStringWidth()`, `GetStringHeight()`, `GetPoint()`, and `GetHeight()` return secret values. Any arithmetic on these values (e.g., `title:GetStringWidth() + 20`) errors with "attempt to perform arithmetic on a secret number value". Worse, if a tainted value is stored in a module-level variable, ALL subsequent uses of that variable are tainted for the rest of the session.

**Fix:** Three safe wrapper functions:
- `SafeGetStringWidth(fontString)` / `SafeGetStringHeight(fontString)` — wrap the call in `pcall`, check `issecretvalue()` on the result, return 0 on any failure.
- `SafeSetSize(frame, width, height)` — bail entirely if either dimension is a secret value; also defers to after-combat if `InCombatLockdown()`.

Additionally, `getHeightOffset()` in `functions.lua` wraps the entire `GetPoint()` + `GetHeight()` arithmetic in a single `pcall` block.

**Key pattern:** Two levels of protection — `pcall` catches errors from using secret values, then `issecretvalue()` prevents secret values from being stored and propagating.

**Backdrop taint:** Blizzard's `BackdropTemplate` calls `SetupTextureCoordinates()` on `OnSizeChanged`, which does `self:GetSize()`. In a tainted execution context, `GetSize()` returns secret values and the arithmetic in `SetupTextureCoordinates` errors. The `SafeSetSize` guards can't prevent this because the taint comes from `GetSize()` returning secret values in the tainted *context*, not from stored tainted dimensions. Fix: wrap `SetupTextureCoordinates` and `SetupPieceVisuals` on the `EQOLDungeonScoreFrame` instance with `pcall`.

**Files changed:** `Modules/MythicPlus/DungeonPortal.lua`, `General/functions.lua`.

---

### Sort M+ search results by leader score

**Problem:** When browsing the Dungeon Finder search results for M+ groups, there was no way to quickly identify groups led by experienced players. Results appeared in arbitrary order.

**Fix:** Two hooks working together:
1. `LFGListSearchPanel_UpdateResults` — sorts `self.results` by `leaderOverallDungeonScore` (descending) via `C_LFGList.GetSearchResultInfo()`. Uses a `isSortingSearch` flag to prevent infinite recursion: the hook sorts the array, sets the flag, re-calls the original function (which re-fires the hook but bails on the flag), then clears the flag.
2. `LFGListSearchEntry_Update` — prepends each entry's name with the leader's score in color-coded brackets using `C_ChallengeMode.GetDungeonScoreRarityColor()`.

**Why not `SetSortComparator`?** The ApplicationViewer's DataProvider elements are `{id=X}` tables — each element carries its own ID, so reordering the DataProvider correctly re-binds frames. Search results (`self.results`) are a flat array of raw result IDs (just numbers). `SetSortComparator` reorders data internally but search frames bind `resultID` by position, not element identity — clicking a row would sign up for the wrong group. Instead, we sort the array directly and re-call the update function with a recursion guard.

**Taint-safe cached comparator:** Scores and applied status are cached *before* `table.sort` to avoid calling `GetSearchResultInfo()` inside the comparator. Tainted API calls mid-sort can make the comparator non-transitive (`false` for both `a<b` and `b<a`), corrupting Lua's sort. The cache resolves taint once per result, then the comparator uses only clean cached values.

**Applied-first option:** New `lfgSortSearchAppliedFirst` setting floats groups the player has applied to above unapplied groups. Uses `C_LFGList.GetApplicationInfo()` to detect applied/pending status. Works independently of score sorting.

**Debounced async re-sort:** Scores load asynchronously — the first `UpdateResults` fires before `leaderOverallDungeonScore` is populated. A hidden frame listens for `LFG_LIST_SEARCH_RESULT_UPDATED` events and debounces (0.3s via `C_Timer.NewTimer`) a re-call to `LFGListSearchPanel_UpdateResults`, ensuring the list re-sorts once scores arrive.

**Files changed:** `EnhanceQoL.lua`, `Settings/CombatDungeon.lua`, `Locales/enUS.lua`.

---

### Heal absorb bar for resource bars

**Problem:** Resource bars had no visual feedback for heal absorb effects. Unlike regular absorb shields (which show on the missing-health side), heal absorbs "eat into" existing health and need different visual treatment.

**Fix:** Adds a new StatusBar ("EQOLHealAbsorbBar") as a child of the health bar, mirroring the existing absorb bar pattern. Updates on `UNIT_HEAL_ABSORB_AMOUNT_CHANGED` via `UnitGetTotalHealAbsorbs()`. Default color is red-tinted (1.0, 0.3, 0.3, 0.7) to distinguish from regular absorb.

**Fill modes:** Three options via `applyHealAbsorbLayout()`:
- **Normal** — standard bar fill direction
- **Reverse** — reversed direction
- **Opposite side** — anchors to the trailing edge of the health fill, visually representing how heal absorb reduces existing health. When health fills left-to-right, the heal absorb bar anchors right and grows inward.

Settings include enable toggle, custom color with opacity, texture selection, fill mode dropdown, and a sample preview mode (shows 30% of max health).

**Key gotcha:** New functions use `ResourceBars.applyHealAbsorbLayout` (on the module table) instead of `local` forward declarations to stay within Lua's 200 local variable limit in `ResourceBars.lua`.

**Files changed:** `Modules/Aura/ResourceBars.lua`, `Modules/Aura/Settings_Ressourcebars.lua`, `Locales/enUS.lua`.
