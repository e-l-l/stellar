# `stellarWatchWidgets/` — watchOS WidgetKit extension (`stellarWatchWidgetsExtension`)

The watchOS complication extension. Vends the **Steps** complication in the accessory
circular and corner families (watch face + Smart Stack). Like any widget extension it is a
short-lived, system-scheduled process; entries must be render-complete (see `CLAUDE.md` →
Widget and Complication Runtime).

Step models + HealthKit reader + the circular visual are shared from `stellarWatchShared/`;
this directory is the WidgetKit plumbing plus the corner-family visuals.

## Files

| File | Responsibility |
| --- | --- |
| `stellarWatchWidgetsBundle.swift` | `@main` `WidgetBundle`. Lists complications vended (just `StepsWidget`). Xcode's sample + control widgets were removed — controls are out of scope. |
| `StepsWidget.swift` | The `Widget` declaration. Ties intent + provider + view; declares `.accessoryCircular` + `.accessoryCorner`; sets the container background via `WellBackground`. |
| `StepsProvider.swift` | `AppIntentTimelineProvider`. Future steps can't be predicted, so each timeline is a **single current entry** with a `.after(~15min)` reload. Queries HealthKit directly (reads the app-granted authorization). Supplies `recommendations()` (required on watchOS). Preserves the zero / unavailable / failed / cancelled distinction from the shared reader. |
| `StepsEntry.swift` | `TimelineEntry`: the `StepReadState` + validated `StepGoal`. `date` derives from the reading. |
| `StepsConfigIntent.swift` | `WidgetConfigurationIntent` — the "Edit" sheet. One `@Parameter` for the daily goal (default 10k, clamped 1…100k). HealthKit has no goal concept, so it must come from config. |
| `StepsView.swift` | WidgetKit adapter. `accessoryCircular` → shared `StepsCircularVisual`; `accessoryCorner` → local `StepsCornerValueVisual` + `widgetLabel` gauge. Also defines `WellBackground` (black well in full-color contexts, clear when the system removes the container) and holds the `#Preview`s covering every state. |

## Notes

- **Freshness path:** the 15-minute reload is the floor. While the watch app is active it
  reloads this extension via `WidgetCenter` on each new HealthKit sample, so counts update
  sooner (see `stellarWatch Watch App/context.md`).
- Corner geometry is owned here (not shared) because accessory-corner layout is WidgetKit-
  specific; the app gallery only *approximates* it.
