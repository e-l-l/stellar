//
//  WorldClockWidget.swift
//  stellarWidgets
//
//  The widget declaration: ties the configuration intent to the provider and
//  the view, and declares the supported families. Small + Medium only for v1.
//

import SwiftUI
import WidgetKit

struct WorldClockWidget: Widget {
    let kind = "WorldClockWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: WorldClockConfigIntent.self,
            provider: WorldClockProvider()
        ) { entry in
            WorldClockView(entry: entry)
                // Required container background. The design uses the surface
                // color as the full-bleed tile; panels inset 9px on top of it.
                .containerBackground(Color.wcSurface, for: .widget)
        }
        .configurationDisplayName("World Clock")
        .description("Show the time in two cities.")
        .supportedFamilies([.systemSmall, .systemMedium])
        // The system adds ~16pt default content margins; the design wants a
        // near-full-bleed layout with only a 9pt inset (applied in the view),
        // so we opt out of the default margins here.
        .contentMarginsDisabled()
    }
}
