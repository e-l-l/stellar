# `stellar/DesignSystem/` — tokens & reusable controls

Design-handoff tokens (colors, radii, fonts) and the shared UI controls built from them.
Value-type helpers with no UI/actor isolation, so any view in the app target can read them.
These are **app-target only** — the widget/watch renderers carry their own palettes
(`WorldClockPalette`, the `comet*` colors in `StepsVisuals`) so they stay self-contained.

## Files

| File | Responsibility |
| --- | --- |
| `Theme.swift` | The token source. `Color(hex:)` initializer; `stellar*` color tokens (backgrounds, surfaces, pastel-pink accent, text tiers, hairlines, splash gradient); `StellarRadius` corner radii; `SectionHeader` view. |
| `SegmentedControl.swift` | Custom generic segmented control. Hand-drawn because the native iOS 26 control forces a pill/liquid-glass radius the handoff doesn't want (track radius 9 + 2px pad, selection radius 7, pink fill, `matchedGeometryEffect` slide). |
| `CaptionedTile.swift` | Generic wrapper: renders content with a caption label below it. Used for every gallery tile. |

## Notes

- Colors come from the handoff as `0xRRGGBB` literals via `Color(hex:)`; keep new values in
  that form for consistency.
- Radii are intentionally *not* collapsed into one constant — different families use
  different radii by design (`tile` 22, `segmentTrack` 9, `segmentPill` 7).
