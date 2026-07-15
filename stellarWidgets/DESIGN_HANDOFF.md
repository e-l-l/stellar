# World Clock Widget — Design Handoff

The **functional layer is built and compiling**. Your job is the visual layer:
replace `stellarWidgets/WorldClockView.swift` with the real, designed layouts.
Do **not** touch the provider, intent, entry, or bundle — those are the data plumbing.

## What this widget is

A digital world clock showing the current time in **two user-chosen cities**,
side by side. The user picks the cities via long-press → **Edit Widget** (already wired).

## Families to design (v1)

| Family | Intent |
| --- | --- |
| `.systemSmall` | Two cities **stacked** vertically. |
| `.systemMedium` | Two cities **side by side**. |

Build a genuine layout for **each** — do not scale one into the other
(project rule). Read `@Environment(\.widgetFamily)` to branch.

## Data contract — this is all you get per render

The view receives one `WorldClockEntry`:

```swift
entry.date            // the instant this frame represents (already minute-aligned)
entry.cityA           // City   (first city)
entry.cityB           // City   (second city)
```

Per `City`, use these helpers (already implemented in `City.swift`):

```swift
city.title                    // "New York", "Tokyo", "São Paulo", …
city.timeText(at: entry.date) // zone-correct wall-clock string, e.g. "9:41 AM" / "21:41"
city.timeZone                 // TimeZone, if you want to format differently yourself
```

⚠️ **Do NOT** use `Text(entry.date, style: .time)` — that always renders the
*device's* timezone, which is wrong for a second city. Always go through
`city.timeText(at:)` (or format `entry.date` yourself with `city.timeZone`).
The time is correct *because* it's driven by `entry.date`, which the system
advances minute-by-minute — never call `Date()` in the view.

## Design tokens

The app has a design system in `stellar/DesignSystem/Theme.swift` (colors like
`Color.stellarSurface`, `.stellarAccent`, `.stellarTextPrimary`, radii in
`StellarRadius`). **Reuse it** for visual consistency.

- `Theme.swift` must be a **member of the `stellarWidgetsExtension` target** for
  the widget to see it. If `Color.stellarAccent` won't resolve, select
  `Theme.swift` in Xcode → File Inspector → Target Membership → check
  `stellarWidgetsExtension`. (The current placeholder avoids Theme so it builds
  either way — you'll be adding the dependency.)
- The handoff palette skews dark; `stellarSurface` (`#1c1c1e`) is the tile color.

## Rendering-context requirements (WidgetKit)

- Keep `.containerBackground(for: .widget)` (already on the widget in
  `WorldClockWidget.swift`) — style its content, but the modifier stays.
- Test and make legible in: full-color, **accented**, **tinted**, vibrant, and
  background-removed contexts. Tinted/accented strip your colors — rely on
  shape and hierarchy, not hue alone.
- The `body` must not fetch or compute anything heavy — layout only.

## States to cover in `#Preview`

Expand the two starter previews to include:

- Normal (done)
- Placeholder / redacted
- **Long / localized names** — "Los Angeles", "São Paulo", "Singapore" — must
  not truncate badly or clip the time.
- Both 12-hour (AM/PM) and 24-hour locales.

## Out of scope (do not add)

- More families (Large, accessory/lock-screen) — v1 is Small + Medium only.
- Control widgets, Live Activities.
- A third city, per-city labels beyond name, seconds, or date. Keep it to
  **name + HH:mm** unless we explicitly expand scope.

## How to preview

Open `WorldClockView.swift` in Xcode and use the canvas, or run the
`stellarWidgetsExtension` scheme. Verified build command:

```bash
xcodebuild -project stellar.xcodeproj -scheme stellarWidgetsExtension \
  -configuration Debug -destination 'generic/platform=iOS Simulator' build
```
