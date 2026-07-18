//
//  StepsReader.swift
//  stellarWatchShared
//
//  All HealthKit access and read-result policy lives here, with no UI. Shared by
//  both watch targets: the widget extension reads timeline data, while the watch
//  app requests authorization (only an app can prompt) and observes updates.
//
//  HealthKit's query APIs are callback-based; we bridge them to async/await with
//  continuations and an AsyncStream rather than `Task.detached`, per CLAUDE.md's
//  structured-concurrency rule. HKHealthStore is thread-safe.
//

import Foundation
import HealthKit

private final class StatisticsQueryOperation: @unchecked Sendable {
    private let store: HKHealthStore
    private let lock = NSLock()
    private var query: HKStatisticsQuery?
    private var continuation: CheckedContinuation<StepCount, any Error>?
    private var isFinished = false

    init(store: HKHealthStore) {
        self.store = store
    }

    func start(
        query: HKStatisticsQuery,
        continuation: CheckedContinuation<StepCount, any Error>
    ) {
        lock.lock()
        guard !isFinished else {
            lock.unlock()
            continuation.resume(throwing: CancellationError())
            return
        }
        self.query = query
        self.continuation = continuation
        store.execute(query)
        lock.unlock()
    }

    func finish(with result: Result<StepCount, any Error>) {
        lock.lock()
        guard !isFinished, let continuation else {
            lock.unlock()
            return
        }
        isFinished = true
        self.continuation = nil
        query = nil
        lock.unlock()
        continuation.resume(with: result)
    }

    func cancel() {
        lock.lock()
        guard !isFinished else {
            lock.unlock()
            return
        }
        isFinished = true
        let query = query
        let continuation = continuation
        self.query = nil
        self.continuation = nil
        lock.unlock()

        if let query {
            store.stop(query)
        }
        continuation?.resume(throwing: CancellationError())
    }
}

struct StepsReader {
    private let store = HKHealthStore()
    private let stepType = HKQuantityType(.stepCount)

    /// HealthKit isn't present on every device/configuration; callers should
    /// check this before prompting or querying.
    static var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    /// Prompt for read access to step count. Only an app (not an extension) can
    /// present this; the widget extension inherits the granted status.
    func requestAuthorization() async throws {
        try await store.requestAuthorization(toShare: [], read: [stepType])
    }

    /// Reads today's cumulative steps and preserves the difference between a
    /// legitimate zero, unavailable HealthKit, and a failed query. A nil result
    /// means the task was cancelled, so callers should not publish new state.
    func readTodaySteps(asOf now: Date = Date()) async -> StepReadState? {
        guard Self.isAvailable else { return .unavailable(asOf: now) }

        do {
            return .available(try await queryTodaySteps(asOf: now))
        } catch is CancellationError {
            return nil
        } catch {
            return .failed(asOf: now)
        }
    }

    /// Today's cumulative step count from local midnight to `now`. A successful
    /// query with no samples is a real zero-step reading, not a failure.
    private func queryTodaySteps(asOf now: Date) async throws -> StepCount {
        let start = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: start, end: now)

        let operation = StatisticsQueryOperation(store: store)
        return try await withTaskCancellationHandler {
            try Task.checkCancellation()
            return try await withCheckedThrowingContinuation { continuation in
                let query = HKStatisticsQuery(
                    quantityType: stepType,
                    quantitySamplePredicate: predicate,
                    options: .cumulativeSum
                ) { _, statistics, error in
                    if let error {
                        operation.finish(with: .failure(error))
                        return
                    }
                    let count = statistics?.sumQuantity()?.doubleValue(for: .count()) ?? 0
                    operation.finish(with: .success(StepCount(steps: Int(count), date: now)))
                }
                operation.start(query: query, continuation: continuation)
            }
        } onCancel: {
            operation.cancel()
        }
    }

    /// Emits `()` whenever HealthKit reports new step samples. Backed by an
    /// `HKObserverQuery` plus background delivery, so it fires even when the app
    /// is backgrounded. The query is stopped when the stream's consuming task is
    /// cancelled (e.g. the view disappears).
    func observationUpdates() -> AsyncStream<Void> {
        AsyncStream { continuation in
            let query = HKObserverQuery(sampleType: stepType, predicate: nil) { _, completionHandler, error in
                if error == nil { continuation.yield(()) }
                completionHandler()
            }
            store.execute(query)
            store.enableBackgroundDelivery(for: stepType, frequency: .immediate) { _, _ in }
            continuation.onTermination = { _ in store.stop(query) }
        }
    }
}
