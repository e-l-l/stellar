//
//  stellarWatchWidgetsBundle.swift
//  stellarWatchWidgets
//
//  Lists every complication the extension vends. For now just Steps; future
//  watch widgets get added to `body`. (The Xcode sample widget and control
//  widget were removed — controls are out of scope per CLAUDE.md.)
//

import WidgetKit
import SwiftUI

@main
struct stellarWatchWidgetsBundle: WidgetBundle {
    var body: some Widget {
        StepsWidget()
    }
}
