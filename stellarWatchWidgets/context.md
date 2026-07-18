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
| `StepsWidget.swift` | The `Widget` declaration. **`StaticConfiguration`** (no intent — watchOS has no on-device parameter editor). Ties provider + view; declares `.accessoryCircular` + `.accessoryCorner`; sets the container background via `WellBackground`. |
| `StepsProvider.swift` | Plain `TimelineProvider` (completion-handler `getSnapshot`/`getTimeline`, no `recommendations()`). Future steps can't be predicted, so each timeline is a **single current entry** with a `.after(~15min)` reload. Uses the standard goal for placeholders; snapshots and timelines read the shared `StepGoalStore` (App Group) before querying HealthKit directly (app-granted authorization). Preserves the zero / unavailable / failed / cancelled distinction from the shared reader. |
| `StepsEntry.swift` | `TimelineEntry`: the `StepReadState` + validated `StepGoal`. `date` derives from the reading. |
| `StepsView.swift` | WidgetKit adapter. `accessoryCircular` → shared `StepsCircularVisual`; `accessoryCorner` → local `StepsCornerValueVisual` + `widgetLabel` gauge. Also defines `WellBackground` (black well in full-color contexts, clear when the system removes the container) and holds the `#Preview`s covering every state. |

## Notes

- **Freshness path:** the 15-minute reload is the floor. While the watch app is active it
  reloads this extension via `WidgetCenter` on each new HealthKit sample, so counts update
  sooner (see `stellarWatch Watch App/context.md`).
- **Displayed count is watch-only:** the shared reader counts only this Apple Watch's own
  samples (see `stellarWatchShared/context.md`), so the complication tracks Apple's Fitness
  figure rather than the inflated unfiltered store total (which also includes iPhone steps).
- Corner geometry is owned here (not shared) because accessory-corner layout is WidgetKit-
  specific; the app gallery only *approximates* it.
