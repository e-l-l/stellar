//
//  StepsEntry.swift
//  stellarWatchWidgets
//
//  One rendered moment in the complication's timeline. Carries the read state
//  and validated goal so the view never queries HealthKit or invents fallback
//  data (see CLAUDE.md widget runtime rules).
//

import WidgetKit

struct StepsEntry: TimelineEntry {
    let reading: StepReadState
    let goal: StepGoal

    var date: Date { reading.date }
}
