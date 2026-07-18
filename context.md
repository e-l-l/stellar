# Stellar — repository map

Stellar is a multi-target Apple project: an iOS/iPadOS app that showcases home-screen
**widgets** and watch **complications**, plus the watchOS app and both WidgetKit
extensions that make them real.

This file is the orientation map. It complements — does not replace — `CLAUDE.md`, which
holds the working conventions, runtime rules, and product roadmap. Each code directory has
its own `context.md` with file-level detail; this one explains how the pieces fit.

> Note: `CLAUDE.md`'s "Current Repository State" section predates these targets and
> describes the repo as a single minimal app. The target graph below is the current truth.

## Targets

| Target (Xcode name) | Directory | Product | Role |
| --- | --- | --- | --- |
| `stellar` | `stellar/` | `stellar.app` | iOS/iPadOS app. Gallery UI + splash. Hosts the widget extension and watch content. |
| `stellarWidgetsExtension` | `stellarWidgets/` | `.appex` | iOS WidgetKit extension. Vends the **World Clock** widget. |
| `stellarWatch Watch App` | `stellarWatch Watch App/` | watch `.app` | watchOS companion app. Owns HealthKit authorization + the long-lived step observer. |
| `stellarWatchWidgetsExtension` | `stellarWatchWidgets/` | `.appex` | watchOS WidgetKit extension. Vends the **Steps** complication. |
| _(shared, no target)_ | `stellarWorldClockShared/` | — | Platform-neutral World Clock model + renderer + palette. |
| _(shared, no target)_ | `stellarWatchShared/` | — | Platform-neutral step models, HealthKit reader, and Steps visuals. |

**Embedding:** `stellar` embeds `stellarWidgetsExtension` and the watch content; the watch
app embeds `stellarWatchWidgetsExtension`.

## Two feature domains

- **World Clock** — an iOS widget showing the time in two user-chosen cities. Fully
  deterministic from the entry `date`; no external data source. Lives in `stellarWidgets/`
  (WidgetKit plumbing) + `stellarWorldClockShared/` (model + renderer).
- **Steps** — a watch complication showing today's step count vs. a goal. Data comes from
  HealthKit on the watch. Lives in `stellarWatchWidgets/` (WidgetKit plumbing) +
  `stellarWatchShared/` (models + reader + visuals). The watch app drives authorization
  and refreshes.

The iOS app's **Gallery** previews *both* domains using the same shared renderers the real
extensions use — World Clock ticks live via `TimelineView`, Steps uses representative
sample data (live Steps only exists on the watch).

## Shared-code membership (per file, not per directory)

The two shared directories are **not** filesystem-synchronized groups. Each file is added
to specific targets by explicit membership, so adding a file there does *not* auto-compile
it everywhere — you wire it into the targets that need it.

| File | app | iOS widget ext | watch app | watch widget ext |
| --- | :-: | :-: | :-: | :-: |
| `stellarWorldClockShared/*` (City, Palette, Renderer) | ✓ | ✓ | | |
| `stellarWatchShared/StepCount.swift` | ✓ | | ✓ | ✓ |
| `stellarWatchShared/StepsReader.swift` | | | ✓ | ✓ |
| `stellarWatchShared/StepsVisuals.swift` | ✓ | | | ✓ |

(App membership on `StepCount`/`StepsVisuals` is what lets the Gallery preview Steps.)

## Build & run

See `CLAUDE.md` → Commands. Quick reference:

```bash
open stellar.xcodeproj
xcodebuild -project stellar.xcodeproj -list
```

No test/lint/format targets exist yet.
