//
//  WorldClockProvider.swift
//  stellarWidgets
//
//  Supplies the placeholder, snapshot, and timeline. The timeline strategy is
//  the important bit: we emit ONE ENTRY PER MINUTE for the next hour in a single
//  timeline, then ask the system to reload at the end (.atEnd). WidgetKit's
//  reload budget limits how often `timeline(...)` is *called* — not how many
//  entries one call returns — so this gives minute-granular updates at roughly
//  24 reloads/day, well under budget. No per-minute wakeup from the app needed.
//

import WidgetKit

struct WorldClockProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> WorldClockEntry {
        WorldClockEntry(date: Date(), cityA: .newYork, cityB: .tokyo)
    }

    func snapshot(for configuration: WorldClockConfigIntent, in context: Context) async -> WorldClockEntry {
        WorldClockEntry(date: Date(), cityA: configuration.cityA, cityB: configuration.cityB)
    }

    func timeline(for configuration: WorldClockConfigIntent, in context: Context) async -> Timeline<WorldClockEntry> {
        let calendar = Calendar.current
        let now = Date()

        // Truncate to the start of the current minute so every entry lands on a
        // clean HH:mm boundary and the displayed digits flip exactly on the minute.
        let minuteComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: now)
        let start = calendar.date(from: minuteComponents) ?? now

        var entries: [WorldClockEntry] = []
        for minuteOffset in 0..<60 {
            guard let date = calendar.date(byAdding: .minute, value: minuteOffset, to: start) else { continue }
            entries.append(WorldClockEntry(date: date, cityA: configuration.cityA, cityB: configuration.cityB))
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
}
