# Fork Changes

[Compare upstream and fork](https://github.com/R41z0r/EnhanceQoL/compare/main...andybergon:EnhanceQoL:main)

All changes made in this fork (`andybergon/EnhanceQoL`) relative to upstream (`R41z0r/EnhanceQoL`).

| Feature | Status | Upstream | Fork | Notes |
|---------|--------|----------|------|-------|
| Clickcast slash commands (`/ccb`, `/clickcast`) | Brought upstream | PR #981, [`478b62ac`](https://github.com/R41z0r/EnhanceQoL/commit/478b62ac) (2026-03-17) | [`c241e899`](https://github.com/andybergon/EnhanceQoL/commit/c241e899) (2026-03-07) | Implemented independently upstream; functionally identical |
| CreateMacro limit fix | Brought upstream | PR #983 (closed), [`9814ce8d`](https://github.com/R41z0r/EnhanceQoL/commit/9814ce8d) (2026-03-09) | [`7325f136`](https://github.com/andybergon/EnhanceQoL/commit/7325f136) (2026-03-07) | Our fix was per-call-site guards; upstream extracted a shared `EnsureGlobalMacro()` helper across all macro types |
| Resource bar text options | Brought upstream (partially) | PR [#980](https://github.com/R41z0r/EnhanceQoL/pull/980), [`7ce6ade2`](https://github.com/R41z0r/EnhanceQoL/commit/7ce6ade2) (2026-03-07) | [`5d90073f`](https://github.com/andybergon/EnhanceQoL/commit/5d90073f) (2026-03-07) | Upstream added `CURPERCENT` ("Current - Percentage") only; `CURMAXPERCENT` ("Current/Max - Percentage") still fork-only |
| Cooldown panel "Only glow in combat" | Brought upstream | [`23ec74ce`](https://github.com/R41z0r/EnhanceQoL/commit/23ec74ce) (2026-03-17) | [`b4cea68b`](https://github.com/andybergon/EnhanceQoL/commit/b4cea68b) (2026-03-20) | Implemented independently upstream as `hideGlowOutOfCombat`; our `readyGlowOnlyInCombat` dropped in favor of upstream's version |
| Lightfused Mana Potion rank group | Brought upstream | [`8f8daa3c`](https://github.com/R41z0r/EnhanceQoL/commit/8f8daa3c) (2026-03-17) | [`ee3c3921`](https://github.com/andybergon/EnhanceQoL/commit/ee3c3921) (2026-03-20) | 241300/241301 grouped for "use highest rank" |
| Cooldown panel item init fix | Brought upstream | [`478b62ac`](https://github.com/R41z0r/EnhanceQoL/commit/478b62ac) (2026-03-17) | [`42c82243`](https://github.com/andybergon/EnhanceQoL/commit/42c82243) (2026-03-20) | Upstream added `GetItemUseSpellID` with proper caching + `RebuildSpellIndex` in Init |
| Right-click targeting blocker | Pending upstream | PR [#982](https://github.com/R41z0r/EnhanceQoL/pull/982) (open) | [`d07d6834`](https://github.com/andybergon/EnhanceQoL/commit/d07d6834) (2026-03-07) | Includes double-click support |
| Absorb fill dropdown | Pending upstream | PR [#984](https://github.com/R41z0r/EnhanceQoL/pull/984) (open) | [`170238ba`](https://github.com/andybergon/EnhanceQoL/commit/170238ba) (2026-03-07) | Replaces mutually-exclusive checkboxes with a dropdown |
| `/vault`, `/greatvault`, `/weeklyvault` slash commands | Fork-only | — | [`581af1cc`](https://github.com/andybergon/EnhanceQoL/commit/581af1cc) (2026-03-08) | Blocked on collaborator access to open PR upstream |
| Out-of-combat-only class buff reminder | Brought upstream | [`f2fbdcaf`](https://github.com/R41z0r/EnhanceQoL/commit/f2fbdcaf) (2026-03-20) | [`ef73fb86`](https://github.com/andybergon/EnhanceQoL/commit/ef73fb86) (2026-03-20) | Implemented independently upstream as `DB_ONLY_OUT_OF_COMBAT` with `IsRuntimeEvaluationBlockedByCombat()`; fork commit skipped during rebase |
| Gossip skip behavior setting | Fork-only | — | [`a6f08f68`](https://github.com/andybergon/EnhanceQoL/commit/a6f08f68) (2026-03-20) | Dropdown for gossip "Skip" options: pause / auto-skip / accept normally |
| `CURMAXPERCENT` resource bar text | Fork-only | — | [`f90cfc8c`](https://github.com/andybergon/EnhanceQoL/commit/f90cfc8c) (2026-03-07) | "Current/Max - Percentage" text option; upstream only has `CURPERCENT` |
| Rank display mode dropdown | Fork-only (WIP) | — | branch `feat/rank-display-mode` | Replace "use highest rank" checkbox with Single/Highest/Lowest/Both dropdown |

This file and `CLAUDE.md` are also fork-only (project docs for Claude Code).
