# `stellarWatch Watch App/` — watchOS app target

The watchOS companion app. It does the things the complication extension *can't* do
itself — prompt for HealthKit authorization (only an app can present that prompt) and host
the long-lived observer that keeps the complication fed — and it now carries the styled UI
from the design handoff: a complications gallery, a Steps configure surface, and a
Digital-Crown goal picker.

Filesystem-synchronized Xcode group — new `.swift` files here auto-join the watch app target
(no `project.pbxproj` edits). HealthKit reading logic + the goal store are shared from
`stellarWatchShared/` (`StepsReader`, `StepCount`, `StepGoalStore`).

## Files

| File | Responsibility |
| --- | --- |
| `stellarWatchApp.swift` | `@main` entry point. `WindowGroup` → `ContentView`. |
| `ContentView.swift` | App shell. Owns the app-wide `WatchStepsModel`, injects it into the environment, and hosts the `NavigationStack` rooted at `GalleryView`. Starts the observer via `.task`. |
| `WatchStepsModel.swift` | `@MainActor @Observable` model. Requests authorization, reads the current count, then loops over `StepsReader.observationUpdates()`. On each HealthKit update it reloads complication timelines (`WidgetCenter.reloadAllTimelines()`) and refreshes its own count. Exposes `authState` (unknown/authorized/denied/unavailable) read by Configure. |
| `GalleryView.swift` | **Screen 1a** — the complications gallery. Stellar vends one complication (Steps) in two families, so this is a single **Steps card**: it shows a 48pt thumbnail per family (Circular + Corner), and the **whole card is a `NavigationLink` to `ConfigureView`** (with a "Configure" chevron affordance). A separate full-width "Add to Watch Face" button opens the add-to-face instructions sheet. |
| `ConfigureView.swift` | **Screen 1b** — Steps config surface. Grouped sections: Goal (row → `GoalPickerView`, shows the stored goal), Health (Step Access row keyed off `WatchStepsModel.authState` + info card; the row is a tap-to-authorize button while auth is undetermined), Complication (Style = "Progress arc"), and the App Group footer. Reads the goal fresh from `StepGoalStore` on appear. Also holds shared row chrome: `IconTile`, `Chevron`, `rowCard()`. |
| `GoalPickerView.swift` | **Screen 1c** — Digital-Crown goal picker. Crown drives a draft (100–50,000 by 100, default 10,000); **Save** commits to `StepGoalStore` + reloads the complication, **Cancel (✕)** dismisses without persisting. Replaced the earlier auto-saving `GoalSettingView`. |
| `GalleryComplicationPreviews.swift` | The gallery's family thumbnails + the shared `galleryStepsSample` (fixed 6,000 / 10,000). `StepsCircularThumbnail` reuses the **real** `StepsCircularVisual` on a black well — the browse preview matches the shipping complication exactly. `StepsCornerThumbnail` is a static **representation** of `.accessoryCorner` (corner gauge + value); the true curved gauge is system-rendered and can't be reproduced in a plain view. |
| `WatchPalette.swift` | `Color` design tokens (`stellar*`) for the gallery/configure chrome (text, ink, row fill, goal-tile + health/slate gradients). The complication art itself uses the `comet*` palette from `StepsVisuals` (now a watch-app member). |

## Notes

- **Why the app owns HealthKit:** the complication extension is a separate process that can
  read granted access but cannot *prompt* for it, and cannot host a persistent observer. The
  app fills both gaps; the complication benefits via `WidgetCenter` reloads. The observation
  loop is structured concurrency tied to `ContentView`'s `.task` — no `Task.detached`.
- **App Group (`group.com.e-l-l.stellar`)** carries the daily step goal: `GoalPickerView`
  writes it (`StepGoalStore`), the complication extension reads it. Same-device only — it does
  **not** sync iPhone↔Watch. The extension still queries HealthKit directly using the
  authorization this app obtained.
- **Gallery → Configure navigation** was a spec gap (the handoff draws the three screens but no
  gallery→configure link). Resolution: the **whole Steps card** is a `NavigationLink` to
  Configure, with a visible "Configure" chevron; "Add to Watch Face" is a separate button.
- **Gallery is Steps-only.** The handoff mocked Weather/Battery/Activity/Date/World Clock rows,
  but none are real complications in this product, so they were cut. World Clock is real but
  iOS-widget-only — there is no watch World Clock complication. Add a card here only when a real
  complication backs it.
- **Gallery previews use the real renderer.** `StepsCircularThumbnail` reuses the shipping
  `StepsCircularVisual` (arc/comet) so the circular preview matches the face exactly — the old
  `LiquidFillOrb` liquid-fill mock is gone. The corner thumbnail is a static representation
  (`.accessoryCorner`'s curved gauge is system-rendered). Configure's "Style" row reads
  "Progress arc" to match; there is a single style, so its chevron doesn't navigate.
