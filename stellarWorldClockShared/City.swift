//
//  City.swift
//  stellarWorldClockShared
//
//  Platform-neutral preset cities used by both the iOS gallery and WidgetKit
//  extension. App Intents picker metadata stays in the extension target.
//

import Foundation

enum City: String, CaseIterable, Sendable, Equatable, Hashable {
    case losAngeles
    case denver
    case chicago
    case newYork
    case saoPaulo
    case london
    case paris
    case berlin
    case dubai
    case mumbai
    case singapore
    case hongKong
    case tokyo
    case sydney

    var title: String {
        switch self {
        case .losAngeles: "Los Angeles"
        case .denver: "Denver"
        case .chicago: "Chicago"
        case .newYork: "New York"
        case .saoPaulo: "São Paulo"
        case .london: "London"
        case .paris: "Paris"
        case .berlin: "Berlin"
        case .dubai: "Dubai"
        case .mumbai: "Mumbai"
        case .singapore: "Singapore"
        case .hongKong: "Hong Kong"
        case .tokyo: "Tokyo"
        case .sydney: "Sydney"
        }
    }

    var timeZoneIdentifier: String {
        switch self {
        case .losAngeles: "America/Los_Angeles"
        case .denver: "America/Denver"
        case .chicago: "America/Chicago"
        case .newYork: "America/New_York"
        case .saoPaulo: "America/Sao_Paulo"
        case .london: "Europe/London"
        case .paris: "Europe/Paris"
        case .berlin: "Europe/Berlin"
        case .dubai: "Asia/Dubai"
        case .mumbai: "Asia/Kolkata"
        case .singapore: "Asia/Singapore"
        case .hongKong: "Asia/Hong_Kong"
        case .tokyo: "Asia/Tokyo"
        case .sydney: "Australia/Sydney"
        }
    }

    var timeZone: TimeZone { TimeZone(identifier: timeZoneIdentifier) ?? .gmt }

    func timeText(at date: Date) -> String {
        var style = Date.FormatStyle(date: .omitted, time: .shortened)
        style.timeZone = timeZone
        return date.formatted(style)
    }

    func isDaytime(at date: Date) -> Bool {
        (6..<18).contains(localHour(at: date))
    }

    func clockDigits(at date: Date) -> String {
        let components = calendar.dateComponents([.hour, .minute], from: date)
        let hour24 = components.hour ?? 0
        let minute = components.minute ?? 0

        if City.uses24HourClock {
            return String(format: "%02d:%02d", hour24, minute)
        }

        let hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12
        return String(format: "%d:%02d", hour12, minute)
    }

    func amPMText(at date: Date) -> String? {
        guard !City.uses24HourClock else { return nil }
        let formatter = DateFormatter()
        formatter.locale = .current
        return localHour(at: date) < 12 ? formatter.amSymbol : formatter.pmSymbol
    }

    func periodWord(at date: Date) -> String {
        switch localHour(at: date) {
        case 5..<12: "Morning"
        case 12..<17: "Afternoon"
        case 17..<21: "Evening"
        default: "Night"
        }
    }

    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        return calendar
    }

    private func localHour(at date: Date) -> Int {
        calendar.component(.hour, from: date)
    }

    static var uses24HourClock: Bool {
        switch Locale.current.hourCycle {
        case .zeroToTwentyThree, .oneToTwentyFour: true
        case .oneToTwelve, .zeroToEleven: false
        @unknown default: false
        }
    }
}
