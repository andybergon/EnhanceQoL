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

```
git fetch upstream
git rebase upstream/main
git push origin main
```

## Dev Setup

- NTFS junction: `AddOns/EnhanceQoL` → `C:\Users\andyb\repos\EnhanceQoL\EnhanceQoL`
- Code changes → `/reload` in-game to test
- Use `/wow-addon-dev` skill for linking guidance

## Key Files

- `EnhanceQoL/Locales/enUS.lua` — English locale strings
- `EnhanceQoL/Modules/Aura/ResourceBars.lua` — Resource bar rendering (health, power, stagger, stacks)
- `EnhanceQoL/Modules/Aura/Settings_Ressourcebars.lua` — Resource bar settings/dropdowns

## PR Conventions

This is an external repo — always preview PR title/body for user review before submitting. Keep tone casual and human.
