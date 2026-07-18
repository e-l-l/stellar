//
//  WatchStepsModel.swift
//  stellarWatch Watch App
//
//  The watch app's step state and the HealthKit lifecycle the complication
//  can't run itself: only an app can PROMPT for authorization, and the app hosts
//  the long-lived observer. When HealthKit reports new samples we reload the
//  complication's timelines via WidgetCenter and refresh our own displayed count.
//
//  MainActor-isolated (it drives UI state); the observation loop is structured
//  concurrency driven by the view's `.task`, so it's cancelled automatically
//  when the view goes away — no `Task.detached`.
//

import Foundation
import Observation
import WidgetKit

@MainActor
@Observable
final class WatchStepsModel {
    enum AuthState: Sendable {
        case unknown, authorized, denied, unavailable
    }

    private(set) var stepState = StepReadState.pending(asOf: .distantPast)
    private(set) var authState: AuthState = .unknown

    private let reader = StepsReader()

    /// Called from the root view's `.task`. Requests authorization, loads the
    /// current count, then runs the observation loop until the task is cancelled.
    func start() async {
        await authorizeAndRefresh()
        guard authState != .unavailable else { return }

        for await _ in reader.observationUpdates() {
            WidgetCenter.shared.reloadAllTimelines()
            await refresh()
        }
    }

    func authorizeAndRefresh() async {
        guard StepsReader.isAvailable else {
            authState = .unavailable
            await refresh()
            return
        }
        await requestAuthorization()
        await refresh()
    }

    private func requestAuthorization() async {
        do {
            try await reader.requestAuthorization()
            authState = .authorized
        } catch is CancellationError {
            return
        } catch {
            authState = .denied
        }
    }

    private func refresh() async {
        guard let state = await reader.readTodaySteps() else { return }
        stepState = state
    }
}
