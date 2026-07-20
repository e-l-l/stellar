//
//  ConfigureView.swift
//  stellarWatch Watch App
//
//  Screen 1b — the Steps configuration surface: set the daily goal (→ 1c), review
//  HealthKit step access, and see the complication style. Reads the goal from the
//  shared `StepGoalStore` (App Group) and the authorization state from the
//  app-owned `WatchStepsModel` in the environment.
//

import SwiftUI

struct ConfigureView: View {
    @Environment(WatchStepsModel.self) private var model
    @State private var goal = StepGoalStore().goal.value

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Configure")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.stellarText)
                    .padding(.bottom, 16)

                sectionHeader("Goal")
                goalRow
                    .padding(.bottom, 18)

                sectionHeader("Health")
                stepAccessRow
                    .padding(.bottom, 8)
                infoCard
                    .padding(.bottom, 18)

                sectionHeader("Complication")
                styleRow

                Text(StepGoalStore.appGroupID)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(Color.stellarInk.opacity(0.35))
                    .frame(maxWidth: .infinity)
                    .padding(.top, 16)
            }
            .padding(.horizontal, 6)
        }
        .navigationTitle("Configure")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { goal = StepGoalStore().goal.value }
    }

    // MARK: Goal

    private var goalRow: some View {
        NavigationLink {
            GoalPickerView()
        } label: {
            HStack(spacing: 11) {
                IconTile(colors: [.stellarFillTop, .stellarFillBottom]) {
                    Circle().fill(.white).frame(width: 9, height: 9)
                }
                Text("Daily Goal")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.stellarText)
                Spacer(minLength: 0)
                Text(goal.formatted(.number))
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color.stellarPink)
                Chevron()
            }
            .rowCard()
        }
        .buttonStyle(.plain)
    }

    // MARK: Health

    @ViewBuilder
    private var stepAccessRow: some View {
        if model.authState == .unknown {
            Button { Task { await model.authorizeAndRefresh() } } label: {
                stepAccessContent
            }
            .buttonStyle(.plain)
        } else {
            stepAccessContent
        }
    }

    private var stepAccessContent: some View {
        HStack(spacing: 11) {
            IconTile(colors: [.stellarHealthTop, .stellarHealthBottom]) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(.white)
            }
            Text("Step Access")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.stellarText)
            Spacer(minLength: 0)
            statusView
        }
        .rowCard()
    }

    @ViewBuilder
    private var statusView: some View {
        switch model.authState {
        case .authorized:
            HStack(spacing: 6) {
                Circle().fill(Color.stellarGreen).frame(width: 7, height: 7)
                Text("On")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.stellarGreen)
            }
        case .unknown:
            Text("Allow")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.stellarPink)
        case .denied:
            Text("Off")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.stellarInk.opacity(0.5))
        case .unavailable:
            Text("Unavailable")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.stellarInk.opacity(0.5))
        }
    }

    private var infoCard: some View {
        Text("Stellar reads today's step count to fill your goal. Manage in Watch → Privacy → Health.")
            .font(.system(size: 12))
            .lineSpacing(3)
            .foregroundStyle(Color.stellarInk.opacity(0.65))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
            .padding(.horizontal, 15)
            .background(Color.stellarPink.opacity(0.10), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color.stellarPink.opacity(0.22), lineWidth: 1)
            )
    }

    // MARK: Complication

    private var styleRow: some View {
        HStack(spacing: 11) {
            IconTile(colors: [.stellarSlateTop, .stellarSlateBottom]) {
                Circle().strokeBorder(Color.stellarPink, lineWidth: 2).frame(width: 11, height: 11)
            }
            Text("Style")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.stellarText)
            Spacer(minLength: 0)
            Text("Progress arc")
                .font(.system(size: 13))
                .foregroundStyle(Color.stellarInk.opacity(0.55))
            Chevron()
        }
        .rowCard()
    }

    // MARK: Section header

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .bold))
            .tracking(0.6)
            .textCase(.uppercase)
            .foregroundStyle(Color.stellarInk.opacity(0.4))
            .padding(.leading, 4)
            .padding(.bottom, 8)
    }
}

// MARK: - Shared row chrome

/// A 26pt rounded gradient tile holding a small glyph — the leading icon on
/// each Configure row.
struct IconTile<Content: View>: View {
    let colors: [Color]
    @ViewBuilder let content: Content

    var body: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(width: 26, height: 26)
            .overlay { content }
    }
}

struct Chevron: View {
    var body: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(Color.stellarInk.opacity(0.3))
    }
}

private extension View {
    /// The standard Configure row background: filled, rounded 16.
    func rowCard() -> some View {
        padding(.vertical, 13)
            .padding(.horizontal, 15)
            .background(Color.stellarRowFill.opacity(0.20), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        ConfigureView()
            .environment(WatchStepsModel())
    }
}
