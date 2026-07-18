# `stellar/Screens/` — app screens

The two full-screen views of the iOS app, both driven by `ContentView`.

## Files

| File | Responsibility |
| --- | --- |
| `SplashView.swift` | Launch screen shown while `ContentView.isLoading` is true. Pure decoration — radial gradient, blurred pink glow, pulsing `sparkle` mark, looping `LoaderDots`. Holds no data; dismissed when `ContentView` flips state. |
| `GalleryView.swift` | The product gallery. A `SegmentedControl` switches between **Widgets** (World Clock small + medium) and **Complications** (Steps circular + corner). |

## Notes

- **Faithful previews:** the Widgets tab uses `WorldClockRenderer` (from
  `stellarWorldClockShared/`) inside a `TimelineView(.periodic … by: 60)` so the clock ticks
  live, exactly like the real widget. The Complications tab uses `StepsCircularVisual` (from
  `stellarWatchShared/`) with sample data.
- **Deliberate non-sharing:** `StepsCornerGalleryPreview` and `CornerGaugeArc` (private to
  `GalleryView`) are an iPhone-only *approximation* of the watch corner complication.
  WidgetKit owns real accessory-corner geometry on the watch face, so this layout is
  intentionally not shared with the extension.
