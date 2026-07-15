# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Working Style

This is the user's first Swift project. Keep changes small and reviewable. When introducing Swift, SwiftUI, WidgetKit, concurrency, Xcode target, signing, capability, or entitlement concepts, briefly explain what each does, why it is needed, which target owns it, and what project configuration it changes.

Pick sensible defaults for minor code choices. Ask before changing product scope, deployment policy, signing, bundle identifiers, or data-sync architecture. Do not hide broad Xcode changes inside unrelated work.

Use current documentation for version-sensitive Apple APIs. Prefer official Apple documentation when Context7 does not provide authoritative WidgetKit, watchOS, or Xcode guidance.

## Current Repository State

This is currently a minimal SwiftUI iOS application, not yet the planned multi-target widget product.

- Project: `stellar.xcodeproj`, created with Xcode 26.6 project format.
- Existing target and discoverable scheme: `stellar`.
- Product: `stellar.app`; bundle identifier: `com.e-l-l.stellar.stellar`.
- Current deployment setting: iOS 26.5; current device families: iPhone and iPad.
- Intended baseline: iOS 26 and watchOS 26, retaining iPad support. Align targets only as an explicit project change.
- Swift language mode: Swift 5.
- `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` and approachable concurrency are enabled.
- Entry point: `stellar/stellarApp.swift`; current root view: `stellar/ContentView.swift`.
- Info.plist content is generated from build settings; no source `Info.plist` exists.
- No widget, watchOS, test, entitlement, dependency, lint, or formatting target/configuration exists yet.

Architecture below is intended direction, not existing infrastructure.

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
- `xcodebuild` discovers `stellar`, but no explicit shared `.xcscheme` is committed. Add and verify proper shared scheme before CI depends on scheme actions.

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
