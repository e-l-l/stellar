//
//  WorldClockEntry.swift
//  stellarWidgets
//
//  One rendered moment in the widget's timeline. It carries everything the view
//  needs to render — the instant plus the two chosen cities — so the view never
//  fetches or computes anything expensive itself (see CLAUDE.md runtime rules).
//
//  Value type of Sendable members, so it crosses the provider's async boundary
//  cleanly regardless of the target's actor-isolation defaults.
//

import WidgetKit

struct WorldClockEntry: TimelineEntry {
    let date: Date
    let cityA: City
    let cityB: City
}
