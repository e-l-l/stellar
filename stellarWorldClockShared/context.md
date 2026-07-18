# `stellarWorldClockShared/` — shared World Clock model + renderer

Platform-neutral World Clock code, shared so the iOS **app gallery** and the iOS **widget
extension** render identically. WidgetKit-independent by design: the renderer takes plain
inputs and knows nothing about timelines or environment.

**Target membership (per file):** all three files → `stellar` (app) **and**
`stellarWidgetsExtension`. Not a synced group — membership is explicit (see repo-root
`context.md`).

## Files

| File | Responsibility |
| --- | --- |
| `City.swift` | The `City` enum (14 presets). Owns everything derived from a city + `Date`: time zone, `timeText`/`clockDigits`/`amPMText`, `isDaytime`, `periodWord`, and 12/24-hour locale handling. Pure, `Sendable`. App Intents picker metadata is *not* here — it lives in the extension (`City+AppIntents.swift`) to keep this file platform-neutral. |
| `WorldClockRenderer.swift` | The SwiftUI view. `layout` (small/medium) × `renderingStyle` (fullColor/monochrome) → panels with city name, time, day/night glyph, and a day/night gradient wash. **Every visible value derives from the injected `date`.** |
| `WorldClockPalette.swift` | Shared `wc*` colors (surface, text, day/night washes, sun/moon) so gallery and widget stay visually aligned. |

## Notes

- Monochrome style exists for widget tinted/accented rendering contexts; full-color is the
  default look.
- Because the renderer is pure over `(date, cityA, cityB, layout, style)`, the gallery can
  drive it with a live `TimelineView` and the widget with timeline entries — same output.
