//
//  Catalog.swift
//  stellar
//
//  Local sample catalog driving the gallery / category screens. Value types,
//  no UI isolation. Real preview data will later come from TimelineProviders;
//  for now each item only needs a display name and an SF Symbol placeholder.
//

import Foundation

struct CatalogItem: Identifiable {
    let id = UUID()
    let name: String
    let symbol: String
}

struct Category: Identifiable {
    let id = UUID()
    let name: String
    let symbol: String            // header glyph
    let widgetSymbol: String
    let complicationSymbol: String
}

enum CatalogData {
    static let smallWidgets = [
        CatalogItem(name: "Weather", symbol: "sun.max.fill"),
        CatalogItem(name: "Battery", symbol: "battery.75"),
        CatalogItem(name: "Activity", symbol: "figure.run"),
        CatalogItem(name: "World Clock", symbol: "clock.fill"),
    ]

    static let mediumWidgets = [
        CatalogItem(name: "Up Next", symbol: "calendar"),
        CatalogItem(name: "Forecast", symbol: "cloud.sun.fill"),
    ]

    static let circularComplications = [
        CatalogItem(name: "Weather", symbol: "sun.max.fill"),
        CatalogItem(name: "Battery", symbol: "battery.75"),
        CatalogItem(name: "Activity", symbol: "figure.run"),
        CatalogItem(name: "Date", symbol: "calendar"),
    ]

    static let rectangularComplications = [
        CatalogItem(name: "Battery", symbol: "battery.75"),
        CatalogItem(name: "Up Next", symbol: "calendar"),
    ]

    static let categories = [
        Category(name: "Weather", symbol: "sun.max.fill",
                 widgetSymbol: "sun.max.fill", complicationSymbol: "sun.max.fill"),
        Category(name: "Calendar", symbol: "calendar",
                 widgetSymbol: "calendar", complicationSymbol: "calendar"),
        Category(name: "Battery", symbol: "battery.75",
                 widgetSymbol: "battery.75", complicationSymbol: "battery.75"),
        Category(name: "Fitness", symbol: "figure.run",
                 widgetSymbol: "figure.run", complicationSymbol: "figure.run"),
    ]
}
