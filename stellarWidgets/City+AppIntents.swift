//
//  City+AppIntents.swift
//  stellarWidgets
//
//  Widget configuration metadata for the shared City model.
//

import AppIntents

extension City: AppEnum {
    static var typeDisplayRepresentation: TypeDisplayRepresentation { "City" }

    // Must stay an exhaustive dictionary literal. App Intents extracts this
    // metadata statically when building the widget configuration UI.
    static var caseDisplayRepresentations: [City: DisplayRepresentation] {
        [
            .losAngeles: "Los Angeles",
            .denver: "Denver",
            .chicago: "Chicago",
            .newYork: "New York",
            .saoPaulo: "São Paulo",
            .london: "London",
            .paris: "Paris",
            .berlin: "Berlin",
            .dubai: "Dubai",
            .mumbai: "Mumbai",
            .singapore: "Singapore",
            .hongKong: "Hong Kong",
            .tokyo: "Tokyo",
            .sydney: "Sydney",
        ]
    }
}
