# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Working Style

This is the user's first Swift project. Keep changes small and reviewable. When introducing Swift, SwiftUI, WidgetKit, concurrency, Xcode target, signing, capability, or entitlement concepts, briefly explain what each does, why it is needed, which target owns it, and what project configuration it changes.

Pick sensible defaults for minor code choices. Ask before changing product scope, deployment policy, signing, bundle identifiers, or data-sync architecture. Do not hide broad Xcode changes inside unrelated work.

Use current documentation for version-sensitive Apple APIs. Prefer official Apple documentation when Context7 does not provide authoritative WidgetKit, watchOS, or Xcode guidance.

## Context files

Every important directory carries a `context.md`: the repo root holds the target graph,
feature domains, and per-file shared-code membership; each code directory documents its
files and gotchas. **Before exploring or changing a directory, read its `context.md` first**
(and the root one to orient) — it is faster and more reliable than re-deriving structure
from the sources. When a change adds, removes, moves, or repurposes files, or alters a
directory's role or a target's shared-file membership, **update the affected `context.md`
(and the root map if the target graph or membership changes) in the same change.** Keep them
consistent with this file's "Current Repository State".

## Current Repository State

Stellar is now a multi-target widget/complication product (no longer the single minimal app
this section once described). See `context.md` (repo root) for the target graph, feature
domains, and per-file shared-code membership; each code directory has its own `context.md`.

Four targets, each with a committed shared scheme:

| Target | Directory | Platform · family | Deployment | Bundle identifier |
| --- | --- | --- | --- | --- |
| `stellar` | `stellar/` | iOS · iPhone+iPad | iOS 26.5 | `com.e-l-l.stellar.stellar` |
| `stellarWidgetsExtension` | `stellarWidgets/` | iOS · iPhone+iPad | iOS 26.5 | `…stellar.stellarWidgets` |
| `stellarWatch Watch App` | `stellarWatch Watch App/` | watchOS · watch | watchOS 26.5 | `…stellar.watchkitapp` |
| `stellarWatchWidgetsExtension` | `stellarWatchWidgets/` | watchOS · watch | watchOS 26.5 | `…stellar.watchkitapp.stellarWatchWidgets` |

The `stellar` app embeds the iOS widget extension and the watch app; the watch app embeds the
watch widget extension. Two shared source directories (`stellarWorldClockShared/`,
`stellarWatchShared/`) are compiled into targets by explicit per-file membership, not as
synchronized groups.

- Project: `stellar.xcodeproj`, created with Xcode 26.6 project format.
- Product of the app target: `stellar.app`.
- Swift language mode: Swift 5.
- `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` and approachable concurrency are enabled on the
  app and watch app. The two WidgetKit extensions do **not** set it — review concurrency
  isolation per target rather than assuming inheritance.
- App entry point: `stellar/stellarApp.swift`; app root view: `stellar/ContentView.swift`.
- Info.plist content is generated from build settings; no source `Info.plist` exists.
- Intended baseline: iOS 26 and watchOS 26, retaining iPad support.
- Still absent: test, entitlement, dependency, lint, and formatting targets/configuration;
  App Groups, Watch Connectivity, CloudKit, persistence, and networking (see roadmap below).

## Commands

```bash
# Open project
open stellar.xcodeproj

# Inspect targets, configurations, and schemes
xcodebuild -project stellar.xcodeproj -list

# Inspect locally available destinations
xcodebuild -project stellar.xcodeproj -scheme stellar -showdestinations

# Build current app for generic iOS Simulator
xcodebuild \
  -project stellar.xcodeproj \
  -scheme stellar \
  -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  build
```

Generic simulator build is verified in this checkout. Run and interact with app through Xcode until stable scripted launch workflow exists.

No valid repository test, lint, or format command exists. Do not claim `xcodebuild test` passed while no test target exists. After tests are added, document real scheme/test-plan setup. Expected shapes:

```bash
# Full suite after tests exist
xcodebuild -project stellar.xcodeproj -scheme stellar \
  -destination 'platform=iOS Simulator,name=<available simulator>' test

# One test after tests exist
xcodebuild -project stellar.xcodeproj -scheme stellar \
  -destination 'platform=iOS Simulator,name=<available simulator>' \
  -only-testing:<TestTarget>/<Suite>/<testName> test
```

Never commit machine-specific simulator UDIDs.

## Xcode Project Mechanics

- `stellar/` is a filesystem-synchronized group attached to current iOS app target. Ordinary files added there appear automatically; do not edit `project.pbxproj` merely to register them.
- New targets, top-level groups, packages, capabilities, entitlements, build settings, and embedding relationships still require deliberate project changes.
- Give future iOS widget, watch app, watch widget, tests, and shared code separate top-level directories. Do not place all target code under app-owned `stellar/`.
- Treat `stellar.xcodeproj/project.pbxproj` as Xcode-managed. Edit it only for intentional project configuration.
- Do not modify `stellar.xcodeproj/**/xcuserdata/**` as incidental churn. Preserve tracked `stellar.xcodeproj/xcuserdata/ell.xcuserdatad/xcschemes/xcschememanagement.plist` unless scheme management is task.
- All four targets have committed shared schemes under `stellar.xcodeproj/xcshareddata/xcschemes/` (`stellar`, `stellarWidgetsExtension`, `stellarWatch Watch App`, `stellarWatchWidgetsExtension`); `xcodebuild -list` discovers all four. Verify a scheme's actions before CI depends on it.

## Planned Product Architecture

Start with local sample data and deterministic timelines. Do not add persistence, networking, App Groups, CloudKit, or Watch Connectivity until feature needs them.

| Area | Responsibility |
| --- | --- |
| iOS/iPadOS app | Own configuration and primary data preparation. Later own durable storage, networking, expensive transformation, and render-ready snapshots. |
| iOS/iPadOS WidgetKit extension | Supply placeholder, snapshot, and timeline entries. Render extension-safe data without app process memory. |
| watchOS app | Companion-first. Later receive iPhone-originated data through Watch Connectivity and persist it locally. |
| watchOS WidgetKit extension | Implement complications and Smart Stack widgets with WidgetKit/SwiftUI; read watch-local snapshots. Never add ClockKit for new work. |
| Shared logic | Keep snapshot schemas, codecs, formatting, and deterministic timeline calculations platform-neutral where practical. |

Keep SwiftUI and platform lifecycle code in owning targets. Prefer target boundaries over broad `#if os(...)` blocks. Do not extract local Swift package before at least two targets have meaningful shared behavior.

## Widget and Complication Runtime

Widgets and complications are separate, short-lived, system-scheduled processes.

- Timeline entries contain all data needed to render.
- Widget view `body` must not fetch data or start long work.
- Providers handle placeholder, snapshot, and timeline paths.
- Reload dates and `WidgetCenter` reload calls are scheduling requests, not exact timers.
- Prefer future entries for predictable changes.
- Provider work stays bounded, cancellation-aware, and tolerant of missing or stale data.
- Build intentional layouts for each declared family; do not merely scale one layout.
- Use `containerBackground(for: .widget)` and test relevant full-color, accented, tinted, vibrant, and background-removed contexts.
- Control widgets and Live Activities are outside initial scope. Add them only for concrete product requirements; their update models differ from timelines.

## Future Data Flow

```text
iOS app -> iOS App Group snapshot -> iOS/iPadOS widget extension

iOS app -> Watch Connectivity -> watchOS app
         -> watch-local App Group snapshot -> watchOS WidgetKit extension
```

App Groups share data only between entitled targets on same physical device. They do not synchronize iPhone and Apple Watch.

When persistence is added, prefer small read-optimized, versioned `Codable` snapshots with generation timestamp and atomic writes. Readers need safe fallback for missing, corrupt, stale, or schema-incompatible snapshots. Shared `UserDefaults` fits small values, not unstructured database use.

If independent Watch operation becomes requirement, revisit architecture and use CloudKit or appropriate backend; Watch Connectivity does not guarantee independence.

## Swift and Concurrency

Preserve current Swift language and concurrency settings unless task explicitly changes them.

- Keep UI-owned state on main actor.
- Keep immutable snapshot payloads and pure formatting/timeline logic as value types without unnecessary UI isolation.
- Use structured concurrency; do not use `Task.detached` to silence isolation errors.
- Make cross-target/device payloads explicit, versioned, and `Sendable` where they cross concurrency boundaries.
- Review concurrency settings for each new target instead of assuming app settings are inherited.

## Tests and Previews

When test targets exist, use Swift Testing for new unit/integration tests and XCTest for UI automation/performance. Test snapshot encoding/version handling, stale-data policy, timeline generation, formatting, and transport payload interpretation.

Add `#Preview` coverage for every declared family and meaningful states: placeholder, normal, empty, stale, missing/corrupt data, and long/localized values. Previews validate layout, not scheduling, App Group access, Watch Connectivity, or production refresh budgets. Verify those in simulators and physical devices, including runs without attached debugger.

## Apple Documentation Baseline

- [WidgetKit](https://developer.apple.com/documentation/widgetkit/)
- [Developing a WidgetKit strategy](https://developer.apple.com/documentation/widgetkit/developing-a-widgetkit-strategy)
- [Creating accessory widgets and watch complications](https://developer.apple.com/documentation/widgetkit/creating-accessory-widgets-and-watch-complications)
- [Keeping a widget up to date](https://developer.apple.com/documentation/widgetkit/keeping-a-widget-up-to-date)
- [Transferring data with Watch Connectivity](https://developer.apple.com/documentation/watchconnectivity/transferring-data-with-watch-connectivity)
- [Configuring App Groups](https://developer.apple.com/documentation/xcode/configuring-app-groups)
- [Adding tests to an Xcode project](https://developer.apple.com/documentation/xcode/adding-tests-to-your-xcode-project)

Recheck current Apple documentation before selecting new APIs, changing deployment assumptions, or adding capabilities. Keep project conventions distinct from Apple requirements.
