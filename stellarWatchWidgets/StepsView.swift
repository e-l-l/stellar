//
//  StepsView.swift
//  stellarWatchWidgets
//
//  WidgetKit adapter for shared Steps visuals. Family placement and container
//  behavior remain watch-owned; HealthKit data arrives through StepsEntry.
//

import SwiftUI
import WidgetKit

struct StepsView: View {
    @Environment(\.widgetFamily) private var family
    let entry: StepsEntry

    private var presentation: StepsPresentation {
        StepsPresentation(reading: entry.reading, goal: entry.goal)
    }

    var body: some View {
        switch family {
        case .accessoryCorner:
            StepsCornerValueVisual(presentation: presentation)
                .widgetLabel {
                    StepsCornerGaugeVisual(presentation: presentation)
                }
        default:
            StepsCircularVisual(presentation: presentation)
        }
    }
}

private struct StepsCornerValueVisual: View {
    let presentation: StepsPresentation

    @ViewBuilder
    var body: some View {
        switch presentation.state {
        case .available:
            Text(stepsLabel(presentation.steps ?? 0))
                .font(.system(.title3, weight: .semibold).monospacedDigit())
                .minimumScaleFactor(0.7)
                .lineLimit(1)
                .foregroundStyle(Color.cometCount)
                .widgetAccentable()
        case .pending:
            Text("0,000")
                .font(.system(.title3, weight: .semibold).monospacedDigit())
                .redacted(reason: .placeholder)
        case .unavailable:
            Text("—")
                .font(.system(.title3, weight: .semibold))
                .foregroundStyle(Color.cometInk.opacity(0.4))
        case .failed:
            Image(systemName: "arrow.clockwise")
                .font(.system(.title3, weight: .semibold))
                .foregroundStyle(Color.cometInk.opacity(0.55))
        }
    }
}

private struct StepsCornerGaugeVisual: View {
    let presentation: StepsPresentation

    @ViewBuilder
    var body: some View {
        switch presentation.state {
        case .available:
            Gauge(value: min(presentation.ratio, 1)) { Text("") }
                .tint(presentation.ratio > 1 ? Color.cometOverflow : Color.cometProgress)
                .widgetAccentable(presentation.ratio <= 1)
        default:
            Gauge(value: 0) { Text("") }
                .tint(Color.white.opacity(0.16))
        }
    }
}

// MARK: - Container background

/// Paints a black well only in full-color contexts; stays clear when the system
/// removes the widget container so background-removed faces render clean.
struct WellBackground: View {
    @Environment(\.showsWidgetContainerBackground) private var showsBackground

    var body: some View {
        if showsBackground { Color.black } else { Color.clear }
    }
}

// MARK: - Previews

#Preview("Circular", as: .accessoryCircular) {
    StepsWidget()
} timeline: {
    StepsEntry(reading: .available(StepCount(steps: 6000, date: .now)), goal: .standard)
    StepsEntry(reading: .available(StepCount(steps: 0, date: .now)), goal: .standard)
    StepsEntry(reading: .available(StepCount(steps: 12345, date: .now)), goal: .standard)
    StepsEntry(reading: .available(StepCount(steps: 128000, date: .now)), goal: .standard)
    StepsEntry(reading: .pending(asOf: .now), goal: .standard)
    StepsEntry(reading: .unavailable(asOf: .now), goal: .standard)
    StepsEntry(reading: .failed(asOf: .now), goal: .standard)
}

#Preview("Corner", as: .accessoryCorner) {
    StepsWidget()
} timeline: {
    StepsEntry(reading: .available(StepCount(steps: 6000, date: .now)), goal: .standard)
    StepsEntry(reading: .available(StepCount(steps: 0, date: .now)), goal: .standard)
    StepsEntry(reading: .available(StepCount(steps: 12345, date: .now)), goal: .standard)
    StepsEntry(reading: .available(StepCount(steps: 128000, date: .now)), goal: .standard)
    StepsEntry(reading: .pending(asOf: .now), goal: .standard)
    StepsEntry(reading: .unavailable(asOf: .now), goal: .standard)
    StepsEntry(reading: .failed(asOf: .now), goal: .standard)
}
