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

import SwiftUI
import WidgetKit

struct StepsProvider: AppIntentTimelineProvider {
    private static let reloadInterval: TimeInterval = 15 * 60

    // watchOS requires recommendations: the pre-configured options the system
    // offers in the complication picker. We surface one with the default goal.
    func recommendations() -> [AppIntentRecommendation<StepsConfigIntent>] {
        [AppIntentRecommendation(intent: StepsConfigIntent(), description: Text("Steps"))]
    }

    func placeholder(in context: Context) -> StepsEntry {
        sampleEntry(goal: .standard, asOf: Date())
    }

    func snapshot(for configuration: StepsConfigIntent, in context: Context) async -> StepsEntry {
        let now = Date()
        let goal = StepGoal(clamping: configuration.goal)
        guard !context.isPreview else { return sampleEntry(goal: goal, asOf: now) }
        return await entry(goal: goal, asOf: now)
    }

    func timeline(for configuration: StepsConfigIntent, in context: Context) async -> Timeline<StepsEntry> {
        let now = Date()
        let goal = StepGoal(clamping: configuration.goal)
        let entry = await entry(goal: goal, asOf: now)
        let reload = now.addingTimeInterval(Self.reloadInterval)
        return Timeline(entries: [entry], policy: .after(reload))
    }

    private func entry(goal: StepGoal, asOf date: Date) async -> StepsEntry {
        let reading = await StepsReader().readTodaySteps(asOf: date) ?? .unavailable(asOf: date)
        return StepsEntry(reading: reading, goal: goal)
    }

    private func sampleEntry(goal: StepGoal, asOf date: Date) -> StepsEntry {
        StepsEntry(reading: .available(StepCount(steps: 6000, date: date)), goal: goal)
    }
}
