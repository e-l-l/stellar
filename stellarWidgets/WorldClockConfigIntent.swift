//
//  WorldClockConfigIntent.swift
//  stellarWidgets
//
//  The widget's configuration intent. WidgetKit presents these @Parameters in
//  the system "Edit Widget" sheet, letting the user pick the two cities. The
//  chosen values arrive back in the provider's snapshot/timeline calls.
//

import AppIntents
import WidgetKit

struct WorldClockConfigIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Select Cities" }
    static var description: IntentDescription { "Choose two cities to show the time for." }

    @Parameter(title: "First City", default: .newYork)
    var cityA: City

    @Parameter(title: "Second City", default: .tokyo)
    var cityB: City
}
