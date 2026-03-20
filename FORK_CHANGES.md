# Fork Changes

All changes made in this fork (`andybergon/EnhanceQoL`) relative to upstream (`R41z0r/EnhanceQoL`).

| Feature | Status | Upstream | Fork | Notes |
|---------|--------|----------|------|-------|
| Clickcast slash commands (`/ccb`, `/clickcast`) | Brought upstream | PR #981, [`478b62ac`](https://github.com/R41z0r/EnhanceQoL/commit/478b62ac) | [`c241e899`](https://github.com/andybergon/EnhanceQoL/commit/c241e899) | Implemented independently upstream; functionally identical |
| CreateMacro limit fix | Brought upstream | PR #983 (closed), [`9814ce8d`](https://github.com/R41z0r/EnhanceQoL/commit/9814ce8d) | [`7325f136`](https://github.com/andybergon/EnhanceQoL/commit/7325f136) | Our fix was per-call-site guards; upstream extracted a shared `EnsureGlobalMacro()` helper across all macro types |
| Resource bar text options | Brought upstream (partially) | PR [#980](https://github.com/R41z0r/EnhanceQoL/pull/980), [`7ce6ade2`](https://github.com/R41z0r/EnhanceQoL/commit/7ce6ade2) | [`5d90073f`](https://github.com/andybergon/EnhanceQoL/commit/5d90073f) | Upstream added `CURPERCENT` ("Current - Percentage") only; `CURMAXPERCENT` ("Current/Max - Percentage") still fork-only |
| Right-click targeting blocker | Pending upstream | PR [#982](https://github.com/R41z0r/EnhanceQoL/pull/982) (open) | [`d07d6834`](https://github.com/andybergon/EnhanceQoL/commit/d07d6834) | Includes double-click support |
| Absorb fill dropdown | Pending upstream | PR [#984](https://github.com/R41z0r/EnhanceQoL/pull/984) (open) | [`170238ba`](https://github.com/andybergon/EnhanceQoL/commit/170238ba) | Replaces mutually-exclusive checkboxes with a dropdown |
| `/vault`, `/greatvault`, `/weeklyvault` slash commands | Fork-only | — | [`581af1cc`](https://github.com/andybergon/EnhanceQoL/commit/581af1cc) | Blocked on collaborator access to open PR upstream |
| Out-of-combat-only class buff reminder | Fork-only | — | [`ef73fb86`](https://github.com/andybergon/EnhanceQoL/commit/ef73fb86) | Hides reminder during combat |
| Cooldown panel "Only glow in combat" | Fork-only | — | — | Sub-option under Glow; suppresses ready glow out of combat |
| Lightfused Mana Potion rank group | Fork-only | — | — | 241300/241301 grouped for "use highest rank" |
| Cooldown panel item init fix | Fork-only | — | — | Fix `itemUseSpellCache` caching nil as false + `RebuildSpellIndex` in Init |
| Rank display mode dropdown | Fork-only (WIP) | — | branch `feat/rank-display-mode` | Replace "use highest rank" checkbox with Single/Highest/Lowest/Both dropdown |

This file and `CLAUDE.md` are also fork-only (project docs for Claude Code).
