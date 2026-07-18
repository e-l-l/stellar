# `stellarWidgets/` — iOS WidgetKit extension (`stellarWidgetsExtension`)

The iOS home-screen widget extension. Vends the **World Clock** widget (small + medium).
A widget extension is a separate, short-lived, system-scheduled process — its view `body`
must never fetch data or start long work; everything needed to render lives in the timeline
entry (see `CLAUDE.md` → Widget and Complication Runtime).

Rendering itself lives in `stellarWorldClockShared/`; this directory is the WidgetKit
plumbing that adapts it. World Clock has **no external data source** — every value derives
from the entry `date`.

## Files

| File | Responsibility |
| --- | --- |
| `StellarWidgetsBundle.swift` | `@main` `WidgetBundle`. Lists the widgets the extension vends (just `WorldClockWidget` today). |
| `WorldClockWidget.swift` | The `Widget` declaration. Ties intent + provider + view; declares `.systemSmall`/`.systemMedium`; sets `containerBackground`; disables default content margins for a near-full-bleed layout (9pt inset applied in the renderer). |
| `WorldClockProvider.swift` | `AppIntentTimelineProvider`. Placeholder/snapshot/timeline. **Timeline strategy:** one entry per minute for the next hour, `.atEnd` reload — minute-granular display at ~24 reloads/day, well under budget, with no per-minute app wakeup. |
| `WorldClockEntry.swift` | `TimelineEntry`: `date` + the two chosen `City` values. Render-complete `Sendable` value. |
| `WorldClockView.swift` | Thin WidgetKit adapter. Maps `widgetFamily` → layout and `widgetRenderingMode` → rendering style, then hands off to `WorldClockRenderer`. Also holds the `#Preview`s. |
| `WorldClockConfigIntent.swift` | `WidgetConfigurationIntent` — the "Edit Widget" sheet. Two `@Parameter` city pickers (default New York / Tokyo). |
| `City+AppIntents.swift` | Makes the shared `City` an `AppEnum` so it appears in the picker. `caseDisplayRepresentations` must stay an exhaustive literal — App Intents extracts it statically at build time. |

## Notes

- The config-intent city choices arrive back in the provider's `snapshot`/`timeline` calls
  and get copied into each entry.
- Adding a new widget = new `Widget` type + add it to `StellarWidgetsBundle.body`.
