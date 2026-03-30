# EnhanceQoL - WoW Addon

External repo owned by R41z0r. We contribute via fork.

## Git Workflow (Fork + PR)

- `origin` = `andybergon/EnhanceQoL` (our fork, full push access)
- `upstream` = `R41z0r/EnhanceQoL` (upstream, read-only)

**Development happens on `main`.** Push freely to `origin/main` — it's our fork.

### Opening a PR to upstream

Each PR branch must contain **only the commits for that feature** — never include unrelated commits from our `main` (like CLAUDE.md or other features).

1. Fetch upstream: `git fetch upstream`
2. Create a branch off **upstream's** main: `git checkout -b feat/my-feature upstream/main`
3. Cherry-pick only the relevant commit(s) from main: `git cherry-pick <hash>`
4. Push the branch to our fork: `git push -u origin feat/my-feature`
5. Open PR: `gh pr create --repo R41z0r/EnhanceQoL --head andybergon:feat/my-feature --base main`

**Never push `main` directly to a PR branch** — `main` has fork-only commits (CLAUDE.md, etc.) that shouldn't go upstream.

### Syncing with upstream

Use `/fork-sync` skill. Rebase rewrites fork commit hashes, so push requires `--force-with-lease`.

## Dev Setup

- NTFS junction: `AddOns/EnhanceQoL` → `C:\Users\andyb\repos\EnhanceQoL\EnhanceQoL`
- Code changes → `/reload` in-game to test
- Use `/wow-addon-dev` skill for linking guidance
- **Error logs (BugGrabber):** `/mnt/c/Program Files (x86)/World of Warcraft/_retail_/WTF/Account/ANDYBERGON/SavedVariables/!BugGrabber.lua` — Lua table (`BugGrabberDB.errors`), each entry has `message`, `stack`, `locals`, `time`, `session`, `counter`

## Parallel Feature Development (Worktrees)

Multiple features can be developed in parallel using `claude -w <branch>`. Each session gets its own worktree and works independently without interfering with other sessions.

**Am I on `main` or in a worktree?** Check the current working directory — worktrees live under `.claude/worktrees/` inside the repo. If you're in the primary repo root (`repos/EnhanceQoL/`), you're on `main`.

**WoW can only test one branch at a time** — the NTFS junction points to the primary repo by default. To test a worktree's code in WoW, re-point the junction:

```powershell
# PowerShell (admin) — swap junction to a worktree
cmd /c rmdir "C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns\EnhanceQoL"
cmd /c mklink /J "C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns\EnhanceQoL" "C:\Users\andyb\repos\EnhanceQoL\.claude\worktrees\<my-feature>\EnhanceQoL"
```

Then `/reload` in WoW. When done testing, point it back to the primary repo.

**Workflow summary:**
1. `claude -w feat/A` — start a session on a feature branch (creates worktree automatically)
2. Develop independently in each session
3. Re-point NTFS junction to whichever worktree you want to test in WoW
4. When done, merge to `main` and clean up the worktree

## Testing Against Upstream

The WoW addon symlink points to `repos/EnhanceQoL/EnhanceQoL/`, so switching branches in git changes what WoW loads on `/reload`.

To test upstream code (e.g. verify a bug exists there before opening a PR):
1. `git stash` (save current changes)
2. `git checkout -b test/upstream upstream/main` (temp branch from upstream)
3. `/reload` in WoW — now running upstream code
4. Test the bug
5. `git checkout main && git stash pop` (restore our code)
6. `git branch -D test/upstream` (cleanup)

## Key Files

- `EnhanceQoL/Locales/enUS.lua` — English locale strings
- `EnhanceQoL/Modules/Aura/ResourceBars.lua` — Resource bar rendering (health, power, stagger, stacks)
- `EnhanceQoL/Modules/Aura/Settings_Ressourcebars.lua` — Resource bar settings/dropdowns

## Fork Changes Tracking

All fork changes are tracked in [`FORK_CHANGES.md`](FORK_CHANGES.md). **CRITICAL: Always update FORK_CHANGES.md as part of every commit — not after. Include it in the same commit.** Also update when syncing with upstream (features brought upstream, status changes, etc.).

Non-trivial features get a **detail section** below the table (linked via anchor in the Feature column). Each section covers: Problem, Root cause (if a bug fix), Fix/How it works, Key gotchas, Files changed. Simple/self-explanatory features stay as table-only entries.

## Cooldown Panels Gotchas

- **Don't add new fields to `PANEL_LAYOUT_DEFAULTS` or `ENTRY_DEFAULTS`** in `CooldownPanels_Helper.lua`. `NormalizePanel` iterates over these defaults and sets them on every panel layout during initialization, which can interfere with panel rendering and the `enabledPanels` rebuild timing. Instead, let new boolean fields default to `nil` (which evaluates as `false` via `field == true` checks).
- **Don't add settings to `RegisterEditModePanel`** settings list without careful testing. The Edit Mode save/restore cycle can cause panels to get disabled. Prefer adding settings only to the standalone EQoL editor (`OpenLayoutPanelStandaloneMenu` / `OpenLayoutEntryStandaloneMenu`).
- **Edit Mode inspector uses `getEditor()` not `editor` directly.** The `editor` variable is local to `ensureEditor()`. Use `getEditor()` to access `selectedPanelId`/`selectedEntryId` from button handlers.
- **Standalone entry editor (`OpenLayoutEntryStandaloneMenu`)** opens when clicking icons directly on-screen during layout edit, not from the Cooldown Panel Editor window. The editor window uses `RegisterEditModePanel` settings.

## Taint / Secret Number Gotchas

Blizzard's taint system marks certain API return values as "secret" when addon code runs inside secure callback chains (e.g. `GameTooltip:HookScript("OnHide")` triggered from `LFGList.lua`). Arithmetic on these values errors with "attempt to perform arithmetic on a secret number value". Affected APIs include `GetStringWidth()`, `GetPoint()`, `GetHeight()`, `GetSize()`.

**Fix pattern:** Wrap the call or the arithmetic in `pcall` with a fallback, and check `issecretvalue` on return values before using them. See `SafeGetStringWidth()` / `SafeGetStringHeight()` / `SafeSetSize()` in `DungeonPortal.lua` and `getHeightOffset()` in `functions.lua` for examples. Upstream has dozens of similar fixes throughout the codebase (search git history for "secret", "taint", "pcall").

**Taint propagates through module-level variables.** If a tainted value is stored in a module-scope `local` (e.g. `minFrameSize = max(title:GetStringWidth(), 205)`), ALL subsequent uses of that variable are tainted for the rest of the session. Always use safe wrappers even for "one-time" initialization code at module scope.

**Never call WoW APIs inside `table.sort` comparators.** If an API returns tainted data mid-sort, the comparator becomes non-transitive (returns `false` for both `a<b` and `b<a`), corrupting Lua's sort. Cache all values *before* sorting, resolving taint once per element, then sort using the cache.

**BackdropTemplate taint:** `SafeSetSize` alone doesn't prevent backdrop errors. Blizzard's `SetupTextureCoordinates`/`SetupPieceVisuals` call `self:GetSize()` which returns secret values in tainted *execution contexts* — even if stored dimensions are clean. Fix: wrap these methods with `pcall` on the frame instance. See `ensureRioScoreFrame()` in `DungeonPortal.lua`.

**Never insert addon frames into Blizzard's internal tables** (e.g. `QuestMapFrame.ContentFrames`, `QuestMapFrame.TabButtons`). When Blizzard iterates these tables, tainted entries propagate taint to the loop variable, and any `GetHeight()`/`GetWidth()` calls on it return tainted values — corrupting ALL subsequent layout calculations in that pass. Similarly, never call Blizzard layout methods like `ValidateTabs()` directly from addon code — use `hooksecurefunc` to run after Blizzard's own secure calls instead. See the comment block in `WorldMapDungeonPortals.lua:TryInit()` for the full rationale.

**LFG search DataProvider sort:** Don't use `DataProvider:SetSortComparator()` for the search panel — it reorders data internally but frames don't re-bind their `resultID`, breaking click targeting (signs up for wrong group). Instead, sort `panel.results` directly (flat array of result IDs) and re-call `LFGListSearchPanel_UpdateResults(self)` with a recursion guard. The applicant viewer's `SetSortComparator` works because its data elements use `{id=X}` tables, but search result elements may differ.

**Tooltip widget set taint:** `TooltipDataProcessor.AddTooltipPostCall(AllTypes)` runs addon code for every tooltip type. For types the addon doesn't handle (AreaPOI, etc.), this taints the execution context without doing useful work. Blizzard's `GameTooltip_ClearWidgetSet` then fails comparing tainted widget frame dimensions in `LayoutFrame.lua` during `OnHide`. Fix: (1) early-return from the post-call handler when `kind` is nil (unhandled type), and (2) wrap `GameTooltip_ClearWidgetSet` with `pcall` to suppress taint comparison errors during cleanup. See `registerTooltipHooks()` in `EnhanceQoLTooltip.lua`.

**Aura taint in M+ and combat:** `C_UnitAuras.GetUnitAuraBySpellID` returns `nil` for valid buffs when aura data is tainted (active M+ via `ForceTaint_Strong`, and during combat). `GetAuraDataByIndex` still shows the aura, but slot-scan and spell-ID-lookup APIs fail silently. For long-duration buffs like Emerald Coach's Whistle (spell 389581 "Coaching"), assume buff is active when in combat or M+ rather than showing a false "missing" state. Check `C_ChallengeMode.IsChallengeModeActive()` and `InCombatLockdown()` as guards.

**Emerald Coach's Whistle (item 193718):** Caster gets spell 389581 "Coaching", target gets spell 386578 "Coached". Check the caster buff (389581) on the player, not the target buff. `GetAuraDataByIndex` reports overridden spell ID 386581, but `GetUnitAuraBySpellID` needs the base ID 389581.

## Lua Local Variable Limit

`ResourceBars.lua` is at the 200 local variable limit for Lua's main chunk. **Do NOT add new `local` forward declarations at the top level.** Instead, put new functions on the `ResourceBars` table (e.g. `ResourceBars.myFunction = function(...)` instead of `local myFunction`). This applies to any large file that's near the limit.

## PR Conventions

This is an external repo — always preview PR title/body for user review before submitting. Keep tone casual and human.
