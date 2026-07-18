//
//  ContentView.swift
//  stellarWatch Watch App
//
//  ⚠️ DESIGN HANDOFF STUB — no styling here on purpose.
//
//  The watch app is companion-first: its only job right now is to prompt for
//  HealthKit authorization and keep the complication fed (see WatchStepsModel).
//  This body shows the raw state as plain controls so the flow is verifiable;
//  its appearance is owned by the separate Claude Design handoff.
//

import SwiftUI

struct ContentView: View {
    @State private var model = WatchStepsModel()

    var body: some View {
        VStack {
            Text(stepText)
            Text(String(describing: model.authState))
            Button("Authorize") {
                Task { await model.authorizeAndRefresh() }
            }
        }
        .task { await model.start() }
    }

    private var stepText: String {
        switch model.stepState {
        case .pending:
            "Loading"
        case .available(let count):
            "\(count.steps)"
        case .unavailable:
            "Unavailable"
        case .failed:
            "Error"
        }
    }
}

#Preview {
    ContentView()
}
