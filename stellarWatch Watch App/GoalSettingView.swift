//
//  GoalSettingView.swift
//  stellarWatch Watch App
//
//  Lets the user set the daily step goal with the Digital Crown. The value is
//  written to the shared App Group (StepGoalStore) so the Steps complication
//  reads it; the complication's timelines are reloaded once on the way out to
//  avoid spamming WidgetCenter on every crown detent.
//
//  ⚠️ Minimal styling on purpose — appearance is owned by the design handoff
//  (see ContentView).
//

import SwiftUI
import WidgetKit

struct GoalSettingView: View {
    private static let stepSize = 500
    private static let crownRange = ((StepGoal.validRange.lowerBound + stepSize - 1) / stepSize)...(StepGoal.validRange.upperBound / stepSize)

    @State private var crownPosition: Int
    @State private var hasChanges = false
    @FocusState private var isCrownFocused: Bool
    private let store: StepGoalStore

    init(store: StepGoalStore = StepGoalStore()) {
        self.store = store
        let savedGoal = store.goal.value
        let roundedPosition = (savedGoal + Self.stepSize / 2) / Self.stepSize
        _crownPosition = State(
            initialValue: min(
                max(roundedPosition, Self.crownRange.lowerBound),
                Self.crownRange.upperBound
            )
        )
    }

    private var steps: Int {
        crownPosition * Self.stepSize
    }

    var body: some View {
        VStack {
            Text("Daily Goal")
            Text("\(steps) steps")
                .font(.title3)
                .focusable(interactions: .edit)
                .focused($isCrownFocused)
                .digitalCrownRotation(
                    detent: $crownPosition,
                    from: Self.crownRange.lowerBound,
                    through: Self.crownRange.upperBound,
                    by: 1,
                    sensitivity: .medium
                )
        }
        .onAppear {
            isCrownFocused = true
        }
        .onChange(of: crownPosition) { _, _ in
            hasChanges = true
            store.setGoal(StepGoal(clamping: steps))
        }
        .onDisappear {
            guard hasChanges else { return }
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}

#Preview {
    GoalSettingView()
}
