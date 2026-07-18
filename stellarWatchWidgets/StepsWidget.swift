//
//  StepsWidget.swift
//  stellarWatchWidgets
//
//  The complication declaration: ties the configuration intent to the provider
//  and the view, and declares the supported accessory families (circular +
//  corner on the watch face and in the Smart Stack).
//
//  The container background is required by WidgetKit; its appearance is a design
//  concern, so the closure is intentionally left as a neutral placeholder for
//  the design handoff to fill in.
//

import SwiftUI
import WidgetKit

struct StepsWidget: Widget {
    let kind = "StepsWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: StepsConfigIntent.self,
            provider: StepsProvider()
        ) { entry in
            StepsView(entry: entry)
                .containerBackground(for: .widget) { Color.clear }  // design handoff
        }
        .configurationDisplayName("Steps")
        .description("Show today's step count and progress toward your daily goal.")
        .supportedFamilies([.accessoryCircular, .accessoryCorner])
    }
}
