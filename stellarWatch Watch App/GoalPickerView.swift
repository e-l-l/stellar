//
//  GoalPickerView.swift
//  stellarWatch Watch App
//
//  Screen 1c — the Digital-Crown daily-goal picker opened from Configure. The
//  crown drives a draft value (100–50,000 by 100, default 10,000); Save commits
//  it to the shared `StepGoalStore` (App Group) and reloads the complication,
//  Cancel dismisses without persisting. Replaces the earlier unstyled
//  GoalSettingView (which auto-saved on every detent).
//

import SwiftUI
import WidgetKit

struct GoalPickerView: View {
    private static let step = 100
    private static let lower = 100
    private static let upper = 50_000
    /// Crown positions in units of `step` (1…500 == 100…50,000).
    private static let range = (lower / step)...(upper / step)

    @Environment(\.dismiss) private var dismiss
    @State private var position: Int
    @FocusState private var isCrownFocused: Bool
    private let store: StepGoalStore

    init(store: StepGoalStore = StepGoalStore()) {
        self.store = store
        let saved = store.goal.value
        let rounded = Int((Double(saved) / Double(Self.step)).rounded())
        _position = State(initialValue: min(max(rounded, Self.range.lowerBound), Self.range.upperBound))
    }

    private var steps: Int { position * Self.step }

    var body: some View {
        VStack(spacing: 0) {
            Text("Daily Goal")
                .font(.system(size: 13, weight: .semibold))
                .tracking(0.6)
                .textCase(.uppercase)
                .foregroundStyle(Color.stellarInk.opacity(0.5))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity)

            Spacer(minLength: 0)

            HStack(spacing: 10) {
                VStack(spacing: 2) {
                    Text(steps.formatted(.number))
                        .font(.system(size: 46, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.stellarPink)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    Text("steps")
                        .font(.system(size: 13, weight: .semibold))
                        .tracking(0.7)
                        .textCase(.uppercase)
                        .foregroundStyle(Color.stellarInk.opacity(0.5))
                }
                .frame(maxWidth: .infinity)
                .focusable(interactions: .edit)
                .focused($isCrownFocused)
                .digitalCrownRotation(
                    detent: $position,
                    from: Self.range.lowerBound,
                    through: Self.range.upperBound,
                    by: 1,
                    sensitivity: .medium
                )

                tickScale
            }

            Spacer(minLength: 0)

            Text("Turn crown · 100–50,000")
                .font(.system(size: 11))
                .foregroundStyle(Color.stellarInk.opacity(0.4))
                .padding(.bottom, 8)

            HStack(spacing: 8) {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.stellarInk.opacity(0.7))
                        .frame(width: 46)
                        .padding(.vertical, 11)
                        .background(Color.stellarRowFill.opacity(0.24), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)

                Button { save() } label: {
                    Text("Save")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.stellarOnPink)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background(Color.stellarPink, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .navigationBarBackButtonHidden(true)
        .onAppear { isCrownFocused = true }
    }

    /// A five-tick crown-position affordance; the centre tick is the widest and
    /// accented.
    private var tickScale: some View {
        VStack(alignment: .trailing, spacing: 5) {
            tick(width: 10, height: 2, color: .stellarInk.opacity(0.25))
            tick(width: 16, height: 2, color: .stellarInk.opacity(0.35))
            tick(width: 22, height: 3, color: .stellarPink)
            tick(width: 16, height: 2, color: .stellarInk.opacity(0.35))
            tick(width: 10, height: 2, color: .stellarInk.opacity(0.25))
        }
    }

    private func tick(width: CGFloat, height: CGFloat, color: Color) -> some View {
        Capsule().fill(color).frame(width: width, height: height)
    }

    private func save() {
        store.setGoal(StepGoal(clamping: steps))
        WidgetCenter.shared.reloadAllTimelines()
        dismiss()
    }
}

#Preview {
    NavigationStack {
        GoalPickerView()
    }
}
