# `stellar/` — iOS/iPadOS app target

The app (`stellar.app`). Its current job is to **showcase** the widgets and complications
via an in-app gallery; it doesn't yet own persistence, networking, or data sync (per
`CLAUDE.md`'s "start local" rule). It also hosts (embeds) the iOS widget extension and the
watch content.

This directory is a filesystem-synchronized Xcode group: files dropped here join the target
automatically. Shared rendering comes from `stellarWorldClockShared/` and
`stellarWatchShared/` (see repo-root `context.md` for the membership table).

## Files

| File | Responsibility |
| --- | --- |
| `stellarApp.swift` | `@main` entry point. `WindowGroup` → `ContentView`. |
| `ContentView.swift` | Root view. Shows `SplashView` while loading, then the `GalleryView` in a `NavigationStack`. Loading is a fixed 2.2s delay for now; forces dark mode. |
| `Screens/` | Splash + gallery screens. See `Screens/context.md`. |
| `DesignSystem/` | Design tokens and reusable controls. See `DesignSystem/context.md`. |

## Notes

- **Dark mode only** — `ContentView` sets `.preferredColorScheme(.dark)`; all tokens assume
  a dark background.
- The gallery renders both feature domains with the *same* shared renderers used by the real
  extensions, so previews stay faithful. World Clock previews are live (`TimelineView`);
  Steps previews use sample data (`6,000 / 10,000`).
