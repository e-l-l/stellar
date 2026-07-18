# `stellarWatchShared/` — shared step models, reader, and visuals

Platform-neutral Steps code. Split so the parts each target actually needs are shared
without dragging HealthKit or UI where they don't belong. Not a synced group — membership is
explicit per file:

| File | app | watch app | watch widget ext |
| --- | :-: | :-: | :-: |
| `StepCount.swift` | ✓ | ✓ | ✓ |
| `StepsReader.swift` | | ✓ | ✓ |
| `StepsVisuals.swift` | ✓ | | ✓ |
| `StepGoalStore.swift` | | ✓ | ✓ |

(`StepCount` + `StepsVisuals` reach the app so the gallery can preview Steps; `StepsReader`
and `StepGoalStore` stay off the app — HealthKit reading is watch-only, and the App Group
`StepGoalStore` uses is a watch-local suite the iOS app can't reach.)

## Files

| File | Responsibility |
| --- | --- |
| `StepCount.swift` | Pure value models, UI-free and `Sendable`: `StepCount` (steps + date), `StepReadState` (`pending`/`available`/`unavailable`/`failed` — keeps a real zero distinct from failure/absence), and `StepGoal` (validated, clamped 1…100k). |
| `StepsReader.swift` | **All** HealthKit access and read policy, no UI. Bridges HealthKit's callback APIs to async/await via continuations + an `AsyncStream` (no `Task.detached`). `requestAuthorization` (app-only prompt), `readTodaySteps` (nil = cancelled → don't publish), `observationUpdates` (observer query + background delivery). Counts only this watch's own samples via `todayStepPredicate` (device-model filter). |
| `StepsVisuals.swift` | Reusable Steps SwiftUI shared by the watch complication and the iOS gallery: the `comet*` palette, `StepsPresentation` (maps a read state + goal to a render model), `StepsCircularVisual`, and label helpers. HealthKit access stays out of this file. |
| `StepGoalStore.swift` | Reads/writes the daily `StepGoal` in the watch App Group (`group.com.e-l-l.stellar`). The watch app writes it; the complication extension reads it. Same-device only — App Groups don't bridge iPhone↔Watch. Not `Sendable` (holds `UserDefaults`); instantiate locally. |

## Notes

- **The state distinction matters:** a successful query with no samples is a legitimate
  zero, not a failure; a nil `readTodaySteps` means cancelled, not empty. Views render each
  case differently — don't collapse them.
- `StepsPresentation` handles the over-goal cases (1×–2× shows an overflow arc; ≥2× shows a
  full overflow ring), which is why the visual and the gallery corner preview both branch on
  `ratio`.
- **Watch-only count:** `todayStepPredicate` filters the step query to samples recorded by
  this Apple Watch's device model. The watch's local store *also* holds the paired iPhone's
  step samples (they sync in), and an unfiltered `cumulativeSum` over both inflates the total
  — the iPhone overcounts from in-pocket/in-hand motion. Apple's own Fitness figure trusts the
  on-wrist watch, so filtering to this device tracks that number. Falls back to the time range
  alone if the local model is unknown, so the filter is never empty.
- Keep this platform-neutral: no per-target `#if os(...)`, no App Intents metadata.
