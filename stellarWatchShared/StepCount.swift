//
//  StepCount.swift
//  stellarWatchShared
//
//  Pure value models shared by both watch targets via file membership. They stay
//  UI-free and Sendable so they cross concurrency boundaries cleanly.
//

import Foundation

struct StepCount: Sendable, Equatable {
    let steps: Int
    let date: Date
}

enum StepReadState: Sendable, Equatable {
    case pending(asOf: Date)
    case available(StepCount)
    case unavailable(asOf: Date)
    case failed(asOf: Date)

    var date: Date {
        switch self {
        case .pending(let date), .unavailable(let date), .failed(let date):
            date
        case .available(let count):
            count.date
        }
    }
}

struct StepGoal: Sendable, Equatable, Hashable {
    static let validRange = 1...100_000
    static let standard = StepGoal(clamping: 10_000)

    let value: Int

    init(clamping value: Int) {
        self.value = min(max(value, Self.validRange.lowerBound), Self.validRange.upperBound)
    }
}
