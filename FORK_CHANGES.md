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
| [LFG ApplicationViewer sort + score display](#lfg-applicationviewer-sort--score-display) | Fork-only (partial) | — | `main` | Upstream has its own applicant RIO sort via `table.sort`; fork adds score prepend to applicant names with RaiderIO main/alt detection |
| [Trinket buff tracking + CPE glow suppression](#trinket-buff-tracking--cpe-glow-suppression) | Fork-only | — | `main` | Reimplemented on upstream's refactored ClassBuffReminder; tracks trinket buff durations; CPE glow suppression; combat/M+ taint guards; instance-only and nearby-only settings |
| [DungeonPortal RIO score frame taint fix](#dungeonportal-rio-score-frame-taint-fix) | Brought upstream | Independently fixed via `MeasureTextWidth`/`MeasureTextHeight` helpers (2026-03-25) | Skipped during rebase (2026-03-28) | Our `SafeGetStringWidth`/`SafeGetStringHeight` approach superseded by upstream's pre-measurement approach |
| [Sort M+ search results by leader score](#sort-m-search-results-by-leader-score) | Fork-only | — | [`53fa4695`](https://github.com/andybergon/EnhanceQoL/commit/53fa4695) (2026-03-26) | Sorts Dungeon Finder search results by leader's overall M+ score; shows score in color-coded brackets on each listing; applied-first option; debounced async re-sort; shows leader's main M+ score via RaiderIO when the leader is an alt |
| [Heal absorb bar for resource bars](#heal-absorb-bar-for-resource-bars) | Fork-only | — | [`ef6405f9`](https://github.com/andybergon/EnhanceQoL/commit/ef6405f9) (2026-03-26) | Adds heal absorb overlay to health bar with custom texture, color, fill mode (normal/reverse/opposite side), and sample preview |
| Cooldown panel passive trinket glow fix | Fork-only | — | `main` | `GetItemUseSpellID` checked `C_Item.GetItemSpell` which returns spells for "Equip:" effects too; now verifies "Use:" via tooltip |
| Class buff reminder "nearby only" filter | Fork-only | — | `main` | Only count group members in buff cast range (`IsSpellInRange`) for missing buff counts; falls back to visibility (~100yd) for AoE buffs like Battle Shout |
| Absorb text on health bar | Likely overlaps upstream | Upstream added `absorbText` (2026-04) | `main` | Shows absorb/heal-absorb amounts as text suffix on health bar; dropdown with None/Absorb/Heal Absorb/Both; taint-safe via `issecretvalue` guard. **Post-2026-04-22 merge:** upstream independently added `absorbText` setting — both implementations coexist in the merged tree; needs in-game audit to decide whether to keep fork or adopt upstream's. |
| [Tooltip widget taint fixes](#tooltip-widget-taint-fixes) | Fork-only | — | `main` | Replaced GameTooltip OnShow hooks + conditional SetDefaultAnchor to reduce AreaPOI widget taint from 1382→~100 |
| [LFG persistSignUpNote taint fix](#lfg-persistsignupnote-taint-fix) | Fork-only | — | `main` | Replaced `LFGListApplicationDialog_Show` global function replacement with `hooksecurefunc` + `OnTextChanged` HookScript; eliminates `LFGList.lua:1614` (and 1571/3187/4002) cascade |
| UIWidget TextWithState taint fix | Fork-only | — | `main` | pcall wrapper on `UIWidgetTemplateTextWithStateMixin:Setup` to suppress `GetStringHeight` secret number errors |
| LFG search auto-refresh | Fork-only | — | `main` | Auto-refresh toggle + interval selector (5–60s) in filter dropdown; only runs while search panel is open |
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

### LFG ApplicationViewer sort + score display

**Problem:** Sorting LFG applicants by RIO score using `table.sort()` directly on the `self.applicants` array taints the secure frame. Calling `GetApplicantMemberInfo` inside the sort comparator returns tainted values, making the comparator non-transitive and corrupting sort order.

**Fix:** Uses `DataProvider:SetSortComparator()` with pre-cached scores. All scores are fetched via `GetApplicantMemberInfo` BEFORE sorting, with `issecretvalue` guards. The comparator only does table lookups — no API calls.

**Score display:** Hooks `LFGListApplicationViewer_UpdateApplicantMember` to prepend M+ score to each applicant's name. If RaiderIO addon is present and the character is an alt (main score > character score), shows `[mainScore]` instead. Falls back to character's own `[score]` when RaiderIO is absent or when the character IS the main. RaiderIO data accessed via `RaiderIO.GetProfile(name, realm).mythicKeystoneProfile.mplusMainCurrent.score`.

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
1. `LFGListSearchPanel_UpdateResults` — sorts both `self.results` (for Blizzard's rendering) and the DataProvider (for immediate visual update) using pre-cached scores. Does NOT recursively call `UpdateResults` — that tainted the search panel and broke the Sign Up button.
2. `LFGListSearchEntry_Update` — prepends each entry's name with the leader's score in color-coded brackets using `C_ChallengeMode.GetDungeonScoreRarityColor()`.

**11.1.5+ format change:** `panel.results` elements changed from plain numeric IDs to `{resultID=N}` tables. The `searchResultID(elem)` helper extracts the numeric ID from either format. DungeonFilter also updated with same helper.

**Taint-safe cached comparator:** Scores and applied status are cached *before* sorting to avoid calling `GetSearchResultInfo()` inside the comparator. Tainted API calls mid-sort can make the comparator non-transitive (`false` for both `a<b` and `b<a`), corrupting Lua's sort. The cache resolves taint once per result, then the comparator uses only clean cached values.

**Applied-first option:** New `lfgSortSearchAppliedFirst` setting floats groups the player has applied to above unapplied groups. Uses `C_LFGList.GetApplicationInfo()` to detect applied/pending status. Works independently of score sorting.

**Leader main score display:** When RaiderIO is loaded, splits `info.leaderName` into char/realm, calls `RaiderIO.GetProfile(name, realm).mythicKeystoneProfile.mplusMainCurrent.score`, and if the main's score is higher than the character's shows both in color-coded brackets (`[mainScore/charScore] Leader Name`). Mirrors the applicant-viewer pattern from "LFG ApplicationViewer sort + score display" but applied to the search-results entry hook. Falls back to single-score bracket when RaiderIO is absent or the leader IS the main.

**Debounced async re-sort:** Scores load asynchronously — the first `UpdateResults` fires before `leaderOverallDungeonScore` is populated. A hidden frame listens for `LFG_LIST_SEARCH_RESULT_UPDATED` events and debounces (0.3s via `C_Timer.NewTimer`) a re-call to `LFGListSearchPanel_UpdateResultList`, ensuring the list re-sorts once scores arrive.

**Files changed:** `EnhanceQoL.lua`, `Modules/MythicPlus/DungeonFilter.lua`, `Settings/CombatDungeon.lua`, `Locales/enUS.lua`.

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

---

### Tooltip widget taint fixes

**Problem:** `GameTooltip:HookScript("OnShow")` runs addon code for ALL tooltip types — including AreaPOI, world map pins, and event tooltips. This taints the execution context, causing `DefaultWidgetLayout`, `GetUnscaledFrameRect`, and `GetStringHeight` to error on secret number values during widget set processing. Observed 1382 errors per session.

**Fix:** Three changes:
1. **DungeonPortal.lua:** Replaced `GameTooltip:HookScript("OnShow/OnHide")` with per-entry `OnEnter/OnLeave` hooks via `hooksecurefunc("LFGListSearchEntry_Update")`. The RIO score frame positioning now only fires when hovering LFG search entries, never for unrelated tooltips.
2. **Ignore.lua:** Replaced `GameTooltip:HookScript("OnShow")` with `TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit)`. The ignore note only fires for unit tooltips.
3. **EnhanceQoLTooltip.lua:** Made `hooksecurefunc("GameTooltip_SetDefaultAnchor")` conditional — only registered when custom tooltip anchoring is active (`TooltipAnchorType ~= 1`). Changing the setting requires `/reload`.

**Result:** 1382 → ~100 errors per session. Remaining errors are from `TooltipDataProcessor` internal table taint (unavoidable without removing tooltip features).

**Files changed:** `Modules/MythicPlus/DungeonPortal.lua`, `Submodules/Ignore/Ignore.lua`, `Modules/Tooltip/EnhanceQoLTooltip.lua`.

---

### LFG persistSignUpNote taint fix

**Problem:** When `persistSignUpNote` was enabled, the LFG ApplicationViewer threw hundreds of "secret value tainted by 'EnhanceQoL'" errors per session — `LFGList.lua:1614` (`self.EntryName:GetWidth() > 290`), `1571` (`activeEntryInfo.comment`), `3187` (`activityIDs`), `4002` (`isNew`). All triggered on every `GROUP_ROSTER_UPDATE` while the application viewer was open.

**Root cause:** The original implementation replaced the global `LFGListApplicationDialog_Show` with an addon function that skipped `C_LFGList.ClearApplicationTextFields()`. Replacing a global Blizzard function makes the function itself addon-defined code, which taints **every caller** in the `Blizzard_GroupFinder/LFGList.lua` namespace. Once tainted, `C_LFGList.GetActiveEntryInfo()` returned tainted tables and `self.EntryName:GetWidth()` returned secret numbers, breaking `LFGListApplicationViewer_UpdateInfo`. This is the exact anti-pattern called out in `CLAUDE.md` "Taint / Secret Number Gotchas".

**Fix:** Track the user's note via `EditBox:HookScript("OnTextChanged", ...)` (only saves when `userInput` is true so Blizzard's clears don't overwrite the saved value), then restore it in a `hooksecurefunc("LFGListApplicationDialog_Show", ...)` post-hook. Both `HookScript` and `hooksecurefunc` are taint-safe additive hooks; neither replaces a global. The hook is idempotent and gates on `addon.db.persistSignUpNote` at call time, so toggling the setting at runtime works without re-installing anything.

**Files changed:** `EnhanceQoL.lua`.
