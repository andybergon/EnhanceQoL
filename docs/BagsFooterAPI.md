# Bags Footer API

EnhanceQoL exposes a small footer docking API for addons that want to display their own compact frame inside the EnhanceQoL bags footer.

The API only manages docking, visibility, and layout refreshes. Your addon owns the frame contents, sizing, tooltip behavior, click handlers, and updates.

## Availability

Always check whether the API is available before registering a frame:

```lua
local eqol = _G.EnhanceQoL
local api = eqol and eqol.Bags and eqol.Bags.API

if api and api.IsAvailable and api.IsAvailable() then
	-- Safe to use the footer API.
end
```

`IsAvailable()` only returns `true` when the EnhanceQoL bags module is enabled.

## Registering A Region

Create your own frame, give it a stable size, then register it:

```lua
local holder = CreateFrame("Frame")
holder:SetSize(120, 18)

local text = holder:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
text:SetPoint("LEFT", holder, "LEFT", 0, 0)
text:SetText("123")

local ok = api.RegisterFooterRegion("my-addon-footer-widget", holder, {
	priority = 50,
})
```

If registration succeeds, EnhanceQoL will parent and position the frame in the bags footer.

`RegisterFooterRegion` returns `true` on success and `false` when the API is unavailable or the arguments are invalid.

## Refreshing Layout

Call `RequestLayoutRefresh()` after changing the registered frame's width or height:

```lua
holder:SetWidth(160)
api.RequestLayoutRefresh()
```

This asks EnhanceQoL to recalculate the footer layout so your frame does not overlap gold, currencies, or other registered footer regions.

## Unregistering

Unregister your frame when your feature is disabled:

```lua
api.UnregisterFooterRegion("my-addon-footer-widget")
```

The ID must match the ID used during registration.

## Options

`RegisterFooterRegion(id, region, options)` currently supports:

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| `priority` | number | `100` | Lower values are placed earlier in the footer row. |

The footer currently docks regions on the left side. Keep frames compact and set an explicit width and height before registering.

## Notes

- Use a stable, addon-prefixed ID to avoid collisions.
- Do not depend on EnhanceQoL internal frame names.
- Do not let your frame resize every frame; update its size only when its displayed content changes.
- EnhanceQoL does not alter icon sizes, font strings, scripts, or tooltips inside registered frames.
