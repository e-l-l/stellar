//
//  WorldClockView.swift
//  stellarWidgets
//
//  WidgetKit adapter for the shared World Clock renderer. Provider entries stay
//  render-complete; this view only maps widget environment values to layout and
//  rendering style.
//

import SwiftUI
import WidgetKit

struct WorldClockView: View {
    @Environment(\.widgetFamily) private var family
    @Environment(\.widgetRenderingMode) private var renderingMode
    let entry: WorldClockEntry

    var body: some View {
        WorldClockRenderer(
            date: entry.date,
            cityA: entry.cityA,
            cityB: entry.cityB,
            layout: family == .systemMedium ? .medium : .small,
            renderingStyle: renderingMode == .fullColor ? .fullColor : .monochrome
        )
    }
}

// MARK: - Previews

#Preview("Small", as: .systemSmall) {
    WorldClockWidget()
} timeline: {
    WorldClockEntry(date: .now, cityA: .newYork, cityB: .tokyo)
}

#Preview("Medium", as: .systemMedium) {
    WorldClockWidget()
} timeline: {
    WorldClockEntry(date: .now, cityA: .london, cityB: .singapore)
}

#Preview("Medium · long names", as: .systemMedium) {
    WorldClockWidget()
} timeline: {
    WorldClockEntry(date: .now, cityA: .losAngeles, cityB: .saoPaulo)
}
