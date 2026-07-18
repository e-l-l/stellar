//
//  ContentView.swift
//  stellar
//
//  Root view: shows the splash while loading, then the current product gallery.
//  Loading remains a fixed delay until integration setup needs real preparation.
//

import SwiftUI

struct ContentView: View {
    @State private var isLoading = true

    var body: some View {
        ZStack {
            if isLoading {
                SplashView()
                    .transition(.opacity)
            } else {
                NavigationStack {
                    GalleryView()
                }
                .transition(.opacity)
            }
        }
        .preferredColorScheme(.dark)
        .task {
            try? await Task.sleep(for: .seconds(2.2))
            withAnimation(.easeInOut(duration: 0.4)) { isLoading = false }
        }
    }
}

#Preview {
    ContentView()
}
