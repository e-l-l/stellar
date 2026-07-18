//
//  StepsConfigIntent.swift
//  stellarWatchWidgets
//
//  The complication's configuration intent. WidgetKit presents this @Parameter
//  in the system "Edit" sheet so the user picks their daily step goal. The
//  chosen value arrives back in the provider's snapshot/timeline calls.
//
//  HealthKit has no notion of a step goal, so it must come from configuration
//  (or a hardcoded default) rather than being read from Health.
//

import AppIntents
import WidgetKit

struct StepsConfigIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Step Goal" }
    static var description: IntentDescription { "Set your daily step goal." }

    @Parameter(
        title: "Daily Goal",
        default: 10_000,
        inclusiveRange: (lowerBound: 1, upperBound: 100_000)
    )
    var goal: Int
}
