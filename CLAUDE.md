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

Use `/sync-fork` skill. Rebase rewrites fork commit hashes, so push requires `--force-with-lease`.

## Dev Setup

- NTFS junction: `AddOns/EnhanceQoL` → `C:\Users\andyb\repos\EnhanceQoL\EnhanceQoL`
- Code changes → `/reload` in-game to test
- Use `/wow-addon-dev` skill for linking guidance
- **Error logs (BugGrabber):** `/mnt/c/Program Files (x86)/World of Warcraft/_retail_/WTF/Account/ANDYBERGON/SavedVariables/!BugGrabber.lua` — Lua table (`BugGrabberDB.errors`), each entry has `message`, `stack`, `locals`, `time`, `session`, `counter`

## Key Files

- `EnhanceQoL/Locales/enUS.lua` — English locale strings
- `EnhanceQoL/Modules/Aura/ResourceBars.lua` — Resource bar rendering (health, power, stagger, stacks)
- `EnhanceQoL/Modules/Aura/Settings_Ressourcebars.lua` — Resource bar settings/dropdowns

## Fork Changes Tracking

All fork changes are tracked in [`FORK_CHANGES.md`](FORK_CHANGES.md). Update it after committing new features or when syncing with upstream (features brought upstream, status changes, etc.).

## Cooldown Panels Gotchas

- **Don't add new fields to `PANEL_LAYOUT_DEFAULTS` or `ENTRY_DEFAULTS`** in `CooldownPanels_Helper.lua`. `NormalizePanel` iterates over these defaults and sets them on every panel layout during initialization, which can interfere with panel rendering and the `enabledPanels` rebuild timing. Instead, let new boolean fields default to `nil` (which evaluates as `false` via `field == true` checks).
- **Don't add settings to `RegisterEditModePanel`** settings list without careful testing. The Edit Mode save/restore cycle can cause panels to get disabled. Prefer adding settings only to the standalone EQoL editor (`OpenLayoutPanelStandaloneMenu` / `OpenLayoutEntryStandaloneMenu`).
- **Edit Mode inspector uses `getEditor()` not `editor` directly.** The `editor` variable is local to `ensureEditor()`. Use `getEditor()` to access `selectedPanelId`/`selectedEntryId` from button handlers.
- **Standalone entry editor (`OpenLayoutEntryStandaloneMenu`)** opens when clicking icons directly on-screen during layout edit, not from the Cooldown Panel Editor window. The editor window uses `RegisterEditModePanel` settings.

## PR Conventions

This is an external repo — always preview PR title/body for user review before submitting. Keep tone casual and human.
