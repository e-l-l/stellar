//
//  WorldClockPalette.swift
//  stellarWorldClockShared
//
//  Shared colors keep gallery previews and WidgetKit rendering visually aligned.
//

import SwiftUI

extension Color {
    static let wcSurface = Color(.sRGB, red: 28 / 255, green: 28 / 255, blue: 30 / 255, opacity: 1)
    static let wcTextPrimary = Color(.sRGB, red: 245 / 255, green: 245 / 255, blue: 247 / 255, opacity: 1)

    static let wcDayWash = Color(.sRGB, red: 255 / 255, green: 196 / 255, blue: 120 / 255, opacity: 1)
    static let wcNightWash = Color(.sRGB, red: 120 / 255, green: 150 / 255, blue: 235 / 255, opacity: 1)

    static let wcSun = Color(.sRGB, red: 255 / 255, green: 181 / 255, blue: 46 / 255, opacity: 1)
    static let wcMoon = Color(.sRGB, red: 201 / 255, green: 211 / 255, blue: 239 / 255, opacity: 1)
}
