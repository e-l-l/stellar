//
//  StellarWidgetsBundle.swift
//  stellarWidgets
//
//  Extension entry point. Lists every widget the extension vends. For now just
//  the world clock; future widgets get added to `body`.
//

import SwiftUI
import WidgetKit

@main
struct StellarWidgetsBundle: WidgetBundle {
    var body: some Widget {
        WorldClockWidget()
    }
}
