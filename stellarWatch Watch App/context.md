# `stellarWatch Watch App/` — watchOS app target

The watchOS companion app. It is **companion-first**: its whole job right now is to do the
things the complication extension *can't* do itself — prompt for HealthKit authorization
(only an app can present that prompt) and host the long-lived observer that keeps the
complication fed. It has no styled UI yet.

Filesystem-synchronized Xcode group. HealthKit reading logic is shared from
`stellarWatchShared/` (`StepsReader`, `StepCount`).

## Files

| File | Responsibility |
| --- | --- |
| `stellarWatchApp.swift` | `@main` entry point. `WindowGroup` → `ContentView`. |
| `ContentView.swift` | **Deliberate unstyled stub** (design owned by a separate handoff). Shows raw step/auth state as plain controls + an Authorize button so the flow is verifiable, inside a `NavigationStack` with a link to `GoalSettingView`. Drives `WatchStepsModel` via `.task`. |
| `WatchStepsModel.swift` | `@MainActor @Observable` model. Requests authorization, reads the current count, then loops over `StepsReader.observationUpdates()`. On each HealthKit update it reloads complication timelines (`WidgetCenter.reloadAllTimelines()`) and refreshes its own count. |
| `GoalSettingView.swift` | Digital-Crown editor for the daily step goal. Writes each change to the shared `StepGoalStore` (App Group) and reloads the complication on `onDisappear` only when the goal changed. Unstyled stub — styling owned by the design handoff. |

## Notes

- **Why the app owns this:** the complication extension is a separate process that can read
  granted HealthKit access but cannot *prompt* for it, and cannot host a persistent observer.
  The app fills both gaps; the complication benefits via `WidgetCenter` reloads.
- The observation loop is structured concurrency tied to the view's `.task`, so it cancels
  automatically when the view goes away — no `Task.detached` (per `CLAUDE.md`).
- **App Group (`group.com.e-l-l.stellar`)** now carries the daily step goal: this app writes
  it (`GoalSettingView` → `StepGoalStore`), the complication extension reads it. Same-device
  only — it does **not** sync iPhone↔Watch. No Watch Connectivity yet; the extension still
  queries HealthKit directly using the authorization this app obtained. Add cross-device
  transport only when a feature needs it.
