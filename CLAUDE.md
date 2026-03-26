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

## Cooldown Panels Gotchas

- **Don't add new fields to `PANEL_LAYOUT_DEFAULTS` or `ENTRY_DEFAULTS`** in `CooldownPanels_Helper.lua`. `NormalizePanel` iterates over these defaults and sets them on every panel layout during initialization, which can interfere with panel rendering and the `enabledPanels` rebuild timing. Instead, let new boolean fields default to `nil` (which evaluates as `false` via `field == true` checks).
- **Don't add settings to `RegisterEditModePanel`** settings list without careful testing. The Edit Mode save/restore cycle can cause panels to get disabled. Prefer adding settings only to the standalone EQoL editor (`OpenLayoutPanelStandaloneMenu` / `OpenLayoutEntryStandaloneMenu`).
- **Edit Mode inspector uses `getEditor()` not `editor` directly.** The `editor` variable is local to `ensureEditor()`. Use `getEditor()` to access `selectedPanelId`/`selectedEntryId` from button handlers.
- **Standalone entry editor (`OpenLayoutEntryStandaloneMenu`)** opens when clicking icons directly on-screen during layout edit, not from the Cooldown Panel Editor window. The editor window uses `RegisterEditModePanel` settings.

## PR Conventions

This is an external repo — always preview PR title/body for user review before submitting. Keep tone casual and human.
