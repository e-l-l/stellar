//
//  StepsView.swift
//  stellarWatchWidgets
//
//  ⚠️ DESIGN HANDOFF STUB — no styling here on purpose.
//
//  This renders each read state as plain text, just enough to compile and prove
//  the data path end-to-end. Final layouts for both accessory families remain
//  owned by the separate Claude Design handoff.
//

import SwiftUI
import WidgetKit

struct StepsView: View {
    let entry: StepsEntry

    var body: some View {
        switch entry.reading {
        case .pending:
            Text("--")
                .redacted(reason: .placeholder)
        case .available(let count):
            Text("\(count.steps)")
        case .unavailable:
            Text("Unavailable")
        case .failed:
            Text("Error")
        }
    }
}

// Preview states only. Visual design remains owned by the design handoff.
#Preview("Circular", as: .accessoryCircular) {
    StepsWidget()
} timeline: {
    StepsEntry(reading: .available(StepCount(steps: 6000, date: .now)), goal: .standard)
    StepsEntry(reading: .available(StepCount(steps: 0, date: .now)), goal: .standard)
    StepsEntry(reading: .available(StepCount(steps: 12345, date: .now)), goal: .standard)
    StepsEntry(reading: .available(StepCount(steps: 128000, date: .now)), goal: .standard)
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
    StepsEntry(reading: .unavailable(asOf: .now), goal: .standard)
    StepsEntry(reading: .failed(asOf: .now), goal: .standard)
}
