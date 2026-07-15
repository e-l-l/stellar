//
//  ContentView.swift
//  stellar
//
//  Root view: shows the splash while "loading", then the main tabbed UI.
//  Loading here is a fixed delay standing in for real content preparation.
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
                MainTabView()
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

/// Hosts the two gallery screens. A tab bar isn't in the mock, but it keeps
/// both screens reachable until navigation is designed.
private struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack { GalleryView() }
                .tabItem { Label("Gallery", systemImage: "square.grid.2x2") }
            NavigationStack { CategoryView() }
                .tabItem { Label("Categories", systemImage: "square.stack.3d.up") }
        }
        .tint(Color.stellarAccent)
    }
}

#Preview {
    ContentView()
}
