//
//  StepsWidget.swift
//  stellarWatchWidgets
//
//  The complication declaration: ties the provider and the view together and
//  declares the supported accessory families (circular + corner on the watch
//  face and in the Smart Stack).
//
//  Static, not intent-configured: watchOS has no on-device editor for widget
//  intent parameters, so the goal is owned by the watch app and read from the
//  shared App Group (StepGoalStore) instead of a per-complication "Edit" sheet.
//
//  The container background is required by WidgetKit. WellBackground supplies
//  the black full-color well and stays clear when watchOS removes backgrounds.
//

import SwiftUI
import WidgetKit

struct StepsWidget: Widget {
    let kind = "StepsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: StepsProvider()
        ) { entry in
            StepsView(entry: entry)
                .containerBackground(for: .widget) { WellBackground() }
        }
        .configurationDisplayName("Steps")
        .description("Show today's step count and progress toward your daily goal.")
        .supportedFamilies([.accessoryCircular, .accessoryCorner])
    }
}
