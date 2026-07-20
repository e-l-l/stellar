//
//  WatchPalette.swift
//  stellarWatch Watch App
//
//  Design tokens for the watch app's gallery / configure UI, taken from the
//  design handoff. Defined here (not reused from `StepsVisuals`' comet palette)
//  because that shared file is NOT a member of the watch app target — only the
//  complication extension and the iOS gallery compile it.
//

import SwiftUI

extension Color {
    /// Progress accent (#f6a5c0) — the app's pink.
    static let stellarPink = Color(red: 0.965, green: 0.647, blue: 0.753)
    /// Text/ink on top of a pink fill (#3a1420).
    static let stellarOnPink = Color(red: 0.227, green: 0.078, blue: 0.125)
    /// Goal-tile gradient, top (#f7b1c8) and bottom (#ef82a9).
    static let stellarFillTop = Color(red: 0.969, green: 0.694, blue: 0.784)
    static let stellarFillBottom = Color(red: 0.937, green: 0.510, blue: 0.663)
    /// Authorized green (oklch(0.83 0.13 150)).
    static let stellarGreen = Color(red: 0.52, green: 0.87, blue: 0.60)

    /// Primary text (#f5f5f7).
    static let stellarText = Color(red: 0.961, green: 0.961, blue: 0.969)
    /// Ink base (#ebebf5); use `.opacity(…)` for the secondary/tertiary tiers.
    static let stellarInk = Color(red: 0.922, green: 0.922, blue: 0.961)
    /// Row/control fill base (#767680); use `.opacity(0.20)` for cards.
    static let stellarRowFill = Color(red: 0.463, green: 0.463, blue: 0.502)

    // Configure icon-tile gradients.
    static let stellarHealthTop = Color(red: 1.0, green: 0.369, blue: 0.478)     // #ff5e7a
    static let stellarHealthBottom = Color(red: 0.878, green: 0.137, blue: 0.290) // #e0234a
    static let stellarSlateTop = Color(red: 0.290, green: 0.290, blue: 0.302)     // #4a4a4d
    static let stellarSlateBottom = Color(red: 0.141, green: 0.141, blue: 0.149)  // #242426
}
