//
//  StepGoalStore.swift
//  stellarWatchShared
//
//  The user's daily step goal, shared between the watch app (writer) and the
//  complication extension (reader) via a watch-local App Group `UserDefaults`.
//  Same device only — App Groups do NOT bridge iPhone↔Watch (see CLAUDE.md).
//
//  Member of the watch app + watch widget extension only (not the iOS app, which
//  can't reach the watch App Group). Not `Sendable` — it holds `UserDefaults`;
//  instantiate it locally where used and don't pass it across a concurrency
//  boundary.
//

import Foundation

struct StepGoalStore {
    static let appGroupID = "group.com.e-l-l.stellar"
    private static let key = "dailyStepGoal"

    private let defaults: UserDefaults

    init(defaults: UserDefaults? = UserDefaults(suiteName: appGroupID)) {
        self.defaults = defaults ?? .standard
    }

    /// The stored goal, or `.standard` when nothing has been set yet. Reading
    /// the object directly distinguishes an absent key from a stored zero.
    var goal: StepGoal {
        guard let value = defaults.object(forKey: Self.key) as? NSNumber else {
            return .standard
        }
        return StepGoal(clamping: value.intValue)
    }

    func setGoal(_ goal: StepGoal) {
        defaults.set(goal.value, forKey: Self.key)
    }
}
