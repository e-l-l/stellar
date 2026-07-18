//
//  StepsProvider.swift
//  stellarWatchWidgets
//
//  Supplies the placeholder, snapshot, and timeline. Future steps can't be
//  predicted, so each timeline is a SINGLE current entry with a `.after` reload
//  ~15 minutes out. The watch app additionally reloads us via WidgetCenter when
//  HealthKit reports new samples (see WatchStepsModel), so fresh counts appear
//  sooner than the 15-minute floor while the app is active.
//
//  The provider queries HealthKit directly here — the extension reads the
//  authorization the watch app already obtained. Shared reader policy preserves
//  legitimate zero, unavailable, failed, and cancelled outcomes distinctly.
//
//  The goal is read from the shared App Group (StepGoalStore), written by the
//  watch app. A plain TimelineProvider (not AppIntentTimelineProvider) uses
//  completion handlers and has no recommendations(); the async HealthKit read
//  runs inside a Task before the completion fires.
//

import WidgetKit

struct StepsProvider: TimelineProvider {
    private static let reloadInterval: TimeInterval = 15 * 60

    func placeholder(in context: Context) -> StepsEntry {
        sampleEntry(goal: .standard, asOf: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (StepsEntry) -> Void) {
        let now = Date()
        let goal = StepGoalStore().goal
        guard !context.isPreview else {
            completion(sampleEntry(goal: goal, asOf: now))
            return
        }
        Task { completion(await entry(goal: goal, asOf: now)) }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StepsEntry>) -> Void) {
        let now = Date()
        let goal = StepGoalStore().goal
        Task {
            let entry = await entry(goal: goal, asOf: now)
            let reload = now.addingTimeInterval(Self.reloadInterval)
            completion(Timeline(entries: [entry], policy: .after(reload)))
        }
    }

    private func entry(goal: StepGoal, asOf date: Date) async -> StepsEntry {
        let reading = await StepsReader().readTodaySteps(asOf: date) ?? .unavailable(asOf: date)
        return StepsEntry(reading: reading, goal: goal)
    }

    private func sampleEntry(goal: StepGoal, asOf date: Date) -> StepsEntry {
        StepsEntry(reading: .available(StepCount(steps: 6000, date: date)), goal: goal)
    }
}
