//
//  WorldClockView.swift
//  stellarWidgets
//
//  "Day / Night" world clock. Each city sits in its own washed panel — warm
//  amber when it's daytime there, cool indigo at night — with a sun/moon glyph,
//  so the awake city reads at a glance. Content is name + HH:mm only.
//
//  Pure function of the injected `WorldClockEntry`: no @State, no fetching, no
//  Date() — all times derive from `entry.date`, which the system advances each
//  minute via WorldClockProvider. Design spec: stellarWidgets/DESIGN_HANDOFF.md
//  and the Day/Night handoff README.
//

import SwiftUI
import WidgetKit

struct WorldClockView: View {
    @Environment(\.widgetFamily) private var family
    @Environment(\.widgetRenderingMode) private var renderingMode
    let entry: WorldClockEntry

    /// Full-color contexts keep the amber/indigo washes and multicolor glyphs;
    /// tinted/accented/vibrant strip color, so we fall back to a white wash and
    /// let shape + weight carry the hierarchy.
    private var isFullColor: Bool { renderingMode == .fullColor }

    var body: some View {
        Group {
            switch family {
            case .systemMedium:
                HStack(spacing: 9) {
                    mediumPanel(entry.cityA)
                    mediumPanel(entry.cityB)
                }
            default: // .systemSmall
                VStack(spacing: 8) {
                    smallCell(entry.cityA)
                    smallCell(entry.cityB)
                }
            }
        }
        .padding(9) // inset the panels from the tile edge
    }

    // MARK: - systemSmall: cities stacked

    private func smallCell(_ city: City) -> some View {
        let day = city.isDaytime(at: entry.date)
        return VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 4) {
                cityName(city, size: 12, opacity: 0.6)
                Spacer(minLength: 0)
                glyph(day: day, size: 16)
            }
            Spacer(minLength: 0)
            timeView(city, digitsSize: 28, meridiemSize: 14, showMeridiem: true)
        }
        // Small widgets leave only 66pt per cell on compact devices. Larger
        // vertical padding makes both cells overflow and SwiftUI compresses the
        // outer 9pt top/bottom inset instead. Six points keeps the rows fitting
        // while preserving the intended full-tile margin on physical devices.
        .padding(.vertical, 6)
        .padding(.horizontal, 15)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(panelBackground(day: day, radius: 18, glowRadius: 105))
    }

    // MARK: - systemMedium: cities side by side

    private func mediumPanel(_ city: City) -> some View {
        let day = city.isDaytime(at: entry.date)
        return VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 4) {
                cityName(city, size: 14, opacity: 0.62)
                Spacer(minLength: 0)
                glyph(day: day, size: 18)
            }
            Spacer(minLength: 0)
            VStack(alignment: .leading, spacing: 2) {
                timeView(city, digitsSize: 42, meridiemSize: 0, showMeridiem: false)
                caption(city)
            }
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(panelBackground(day: day, radius: 20, glowRadius: 150))
    }

    // MARK: - Shared pieces

    private func cityName(_ city: City, size: CGFloat, opacity: Double) -> some View {
        Text(city.title)
            .font(.system(size: size, weight: .semibold))
            .foregroundStyle(Color.wcTextPrimary.opacity(opacity))
            .lineLimit(1)
            .minimumScaleFactor(0.85)
    }

    /// Numeric time, with an optional smaller trailing AM/PM span (small family).
    private func timeView(_ city: City, digitsSize: CGFloat, meridiemSize: CGFloat, showMeridiem: Bool) -> some View {
        HStack(alignment: .lastTextBaseline, spacing: 3) {
            Text(city.clockDigits(at: entry.date))
                .font(.system(size: digitsSize, weight: .semibold))
                .monospacedDigit()
                .foregroundStyle(Color.wcTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
            if showMeridiem, let meridiem = city.amPMText(at: entry.date) {
                Text(meridiem)
                    .font(.system(size: meridiemSize, weight: .semibold))
                    .foregroundStyle(Color.wcTextPrimary.opacity(0.5))
            }
        }
    }

    /// Medium-only caption, e.g. "AM · MORNING" (or just "MORNING" in 24h locales).
    private func caption(_ city: City) -> some View {
        let period = city.periodWord(at: entry.date).uppercased()
        let text = city.amPMText(at: entry.date).map { "\($0.uppercased()) · \(period)" } ?? period
        return Text(text)
            .font(.system(size: 12, weight: .semibold))
            .tracking(0.96) // ~.08em at 12pt
            .foregroundStyle(Color.wcTextPrimary.opacity(0.5))
            .lineLimit(1)
            .minimumScaleFactor(0.8)
    }

    private func glyph(day: Bool, size: CGFloat) -> some View {
        let tint = isFullColor ? (day ? Color.wcSun : Color.wcMoon) : Color.wcTextPrimary.opacity(0.75)
        return Image(systemName: day ? "sun.max.fill" : "moon.fill")
            .font(.system(size: size, weight: .medium))
            .symbolRenderingMode(isFullColor ? .multicolor : .monochrome)
            .foregroundStyle(tint)
            // Soft halo so the glyph reads as a light source in the corner.
            .shadow(color: isFullColor ? tint.opacity(0.55) : .clear, radius: 6)
    }

    @ViewBuilder
    private func panelBackground(day: Bool, radius: CGFloat, glowRadius: CGFloat) -> some View {
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)
        ZStack {
            if isFullColor {
                let wash = day ? Color.wcDayWash : Color.wcNightWash
                // Concentrated top-trailing glow radiating from behind the glyph,
                // rather than a flat wash across the whole panel.
                shape.fill(
                    RadialGradient(
                        gradient: Gradient(stops: [
                            .init(color: wash.opacity(0.38), location: 0),
                            .init(color: wash.opacity(0.14), location: 0.45),
                            .init(color: wash.opacity(0), location: 1),
                        ]),
                        center: .topTrailing,
                        startRadius: 0,
                        endRadius: glowRadius
                    )
                )
            } else {
                // Tinted/accented rendering strips the wash. Keep a subtle shape
                // fill there so panel grouping remains visible without color.
                shape.fill(Color.white.opacity(0.035))
            }
        }
    }
}

// MARK: - Previews

#Preview("Small", as: .systemSmall) {
    WorldClockWidget()
} timeline: {
    WorldClockEntry(date: .now, cityA: .newYork, cityB: .tokyo)
}

#Preview("Medium", as: .systemMedium) {
    WorldClockWidget()
} timeline: {
    WorldClockEntry(date: .now, cityA: .london, cityB: .singapore)
}

#Preview("Medium · long names", as: .systemMedium) {
    WorldClockWidget()
} timeline: {
    WorldClockEntry(date: .now, cityA: .losAngeles, cityB: .saoPaulo)
}
