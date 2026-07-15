//
//  SplashView.swift
//  stellar
//
//  Launch screen shown while content loads. Pure decoration + looping
//  animations; it holds no data and dismisses when `ContentView` flips state.
//

import SwiftUI

struct SplashView: View {
    @State private var pulse = false
    @State private var glow = false

    var body: some View {
        ZStack {
            RadialGradient(
                colors: [.stellarSplashTop, .stellarSplashBottom],
                center: UnitPoint(x: 0.5, y: 0.38),
                startRadius: 0,
                endRadius: 460
            )
            .ignoresSafeArea()

            // Blurred pink glow behind the mark.
            Circle()
                .fill(Color.stellarAccent.opacity(0.4))
                .frame(width: 340, height: 340)
                .blur(radius: 30)
                .opacity(glow ? 0.7 : 0.35)

            VStack(spacing: 22) {
                Image(systemName: "sparkle")
                    .font(.system(size: 84))
                    .foregroundStyle(Color.stellarAccent)
                    .shadow(color: Color.stellarAccent.opacity(0.5), radius: 20, y: 6)
                    .scaleEffect(pulse ? 1.07 : 1.0)
                    .opacity(pulse ? 0.82 : 1.0)

                VStack(spacing: 8) {
                    Text("Stellar")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(Color.stellarTextPrimary)
                    Text("Widgets & Complications")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.stellarTextSecondary)
                }
            }

            VStack {
                Spacer()
                LoaderDots()
                    .padding(.bottom, 96)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                pulse = true
            }
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                glow = true
            }
        }
    }
}

/// Three pink dots blinking in sequence.
private struct LoaderDots: View {
    @State private var active = false

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0 ..< 3, id: \.self) { i in
                Circle()
                    .fill(Color.stellarAccent)
                    .frame(width: 7, height: 7)
                    .opacity(active ? 1 : 0.25)
                    .animation(
                        .easeInOut(duration: 0.7)
                            .repeatForever(autoreverses: true)
                            .delay(Double(i) * 0.2),
                        value: active
                    )
            }
        }
        .onAppear { active = true }
    }
}

#Preview {
    SplashView()
}
