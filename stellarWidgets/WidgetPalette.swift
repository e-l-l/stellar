//
//  WidgetPalette.swift
//  stellarWidgets
//
//  Colors for the World Clock widget's "Day / Night" design. Kept widget-local
//  rather than pulled from the app's Theme.swift because:
//    • the day/night washes + glyph colors don't exist in Theme anyway, and
//    • sharing Theme across targets isn't worth a project.pbxproj edit for two
//      shared hex values (see architecture notes in CLAUDE.md).
//  `wcSurface` / `wcTextPrimary` mirror Theme's `stellarSurface` /
//  `stellarTextPrimary` exactly — if Theme is later added to this target's
//  membership, swap these for the shared tokens.
//

import SwiftUI

extension Color {
    /// Tile background — mirrors Theme.stellarSurface (#1c1c1e).
    static let wcSurface = Color(.sRGB, red: 28 / 255, green: 28 / 255, blue: 30 / 255, opacity: 1)
    /// Primary text — mirrors Theme.stellarTextPrimary (#f5f5f7).
    static let wcTextPrimary = Color(.sRGB, red: 245 / 255, green: 245 / 255, blue: 247 / 255, opacity: 1)

    /// Day wash — warm amber, rgba(255,196,120).
    static let wcDayWash = Color(.sRGB, red: 255 / 255, green: 196 / 255, blue: 120 / 255, opacity: 1)
    /// Night wash — cool indigo, rgba(120,150,235).
    static let wcNightWash = Color(.sRGB, red: 120 / 255, green: 150 / 255, blue: 235 / 255, opacity: 1)

    /// Sun glyph tint (#ffb52e).
    static let wcSun = Color(.sRGB, red: 255 / 255, green: 181 / 255, blue: 46 / 255, opacity: 1)
    /// Moon glyph tint (#c9d3ef).
    static let wcMoon = Color(.sRGB, red: 201 / 255, green: 211 / 255, blue: 239 / 255, opacity: 1)
}
