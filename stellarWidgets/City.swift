//
//  City.swift
//  stellarWidgets
//
//  Preset cities the world-clock widget can display. Modeled as an `AppEnum`
//  so it appears as a picker in the widget's edit UI (long-press → Edit Widget).
//
//  This is deliberately a fixed preset list for v1 (no dynamic search). Each
//  case carries an IANA time-zone identifier; time formatting is pure and
//  deterministic given an entry's `date`, matching the deterministic-timeline
//  approach in CLAUDE.md.
//

import AppIntents
import Foundation

enum City: String, AppEnum, CaseIterable {
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

    /// Human-facing city name, used both in the picker and by the widget view.
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

    /// IANA time-zone identifier backing this city.
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

    /// Falls back to GMT if the identifier is somehow unavailable on-device.
    var timeZone: TimeZone { TimeZone(identifier: timeZoneIdentifier) ?? .gmt }

    /// Locale-aware, zone-specific wall-clock string (e.g. "9:41 AM" / "21:41").
    /// Pure: same `date` + same city always yields the same string.
    func timeText(at date: Date) -> String {
        var style = Date.FormatStyle(date: .omitted, time: .shortened)
        style.timeZone = timeZone
        return date.formatted(style)
    }

    // MARK: Display helpers (pure, deterministic given `date`)

    /// True when it's roughly daytime in this city (06:00–18:00 local).
    /// Drives the day/night wash + sun/moon glyph.
    func isDaytime(at date: Date) -> Bool {
        (6..<18).contains(localHour(at: date))
    }

    /// Numeric clock string only — no AM/PM — rendered in this city's zone and
    /// the device's 12h/24h preference. e.g. "6:41" (12h) or "21:41" (24h).
    func clockDigits(at date: Date) -> String {
        let comps = calendar.dateComponents([.hour, .minute], from: date)
        let hour24 = comps.hour ?? 0
        let minute = comps.minute ?? 0
        if City.uses24HourClock {
            return String(format: "%02d:%02d", hour24, minute)
        }
        let hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12
        return String(format: "%d:%02d", hour12, minute)
    }

    /// Localized "AM"/"PM" for this city's time, or `nil` in 24-hour locales
    /// (where the caller should omit the token entirely).
    func amPMText(at date: Date) -> String? {
        guard !City.uses24HourClock else { return nil }
        let formatter = DateFormatter()
        formatter.locale = .current
        return localHour(at: date) < 12 ? formatter.amSymbol : formatter.pmSymbol
    }

    /// Coarse period-of-day word for the medium caption (uppercased by the view).
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

    /// Whether the device locale prefers a 24-hour clock.
    static var uses24HourClock: Bool {
        switch Locale.current.hourCycle {
        case .zeroToTwentyThree, .oneToTwentyFour: true
        case .oneToTwelve, .zeroToEleven: false
        @unknown default: false
        }
    }

    // MARK: AppEnum

    static var typeDisplayRepresentation: TypeDisplayRepresentation { "City" }

    // Must be an exhaustive dictionary literal — the AppIntents metadata
    // extractor reads this statically and rejects computed/derived values.
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
