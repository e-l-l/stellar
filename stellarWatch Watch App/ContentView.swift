//
//  ContentView.swift
//  stellarWatch Watch App
//
//  App shell. Owns the app-wide `WatchStepsModel` (HealthKit authorization + the
//  long-lived step observer), injects it into the environment for the gallery /
//  configure screens, and hosts the navigation stack rooted at the complications
//  gallery (1a → Configure 1b → Goal picker 1c).
//

import SwiftUI

struct ContentView: View {
    @State private var model = WatchStepsModel()

    var body: some View {
        NavigationStack {
            GalleryView()
        }
        .environment(model)
        .task { await model.start() }
    }
}

#Preview {
    ContentView()
}
