# TODO

- [ ] Verify AreaPOI tooltip widget taint after `/reload`.
  - Fix committed as `fdd058dc fix(tooltip): guard status bar widget rect taint`.
  - Repro was `Blizzard_SharedXMLBase/FrameUtil.lua:211` from `DefaultWidgetLayout -> GetUnscaledFrameRect` on AreaPOI tooltip status-bar widgets (`widgetType=2`, widget set `2042`).
  - Expected result: hovering the same AreaPOI/event tooltip no longer logs `attempt to perform arithmetic on local 'frameLeft' (a secret number value, while execution tainted by 'EnhanceQoL')`.
  - Local Lua tooling was unavailable (`luac`, `luacheck`, `busted` not installed); validation needs in-game BugSack/BugGrabber.

- [ ] Existing stashes intentionally left untouched:
  - `stash@{0}`: `craft-shopper-auto-untrack`
  - `stash@{1}`: `feat/gossip-skip-behavior`
