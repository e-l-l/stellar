//
//  WorldClockRenderer.swift
//  stellarWorldClockShared
//
//  WidgetKit-independent World Clock presentation shared by the real widget and
//  the mobile gallery. All visible values derive from the injected date.
//

import SwiftUI

enum WorldClockLayout: Sendable {
    case small
    case medium
}

enum WorldClockRenderingStyle: Sendable {
    case fullColor
    case monochrome
}

struct WorldClockRenderer: View {
    let date: Date
    let cityA: City
    let cityB: City
    let layout: WorldClockLayout
    let renderingStyle: WorldClockRenderingStyle

    private var isFullColor: Bool { renderingStyle == .fullColor }

    var body: some View {
        Group {
            switch layout {
            case .small:
                VStack(spacing: 8) {
                    smallCell(cityA)
                    smallCell(cityB)
                }
            case .medium:
                HStack(spacing: 9) {
                    mediumPanel(cityA)
                    mediumPanel(cityB)
                }
            }
        }
        .padding(9)
    }

    private func smallCell(_ city: City) -> some View {
        let day = city.isDaytime(at: date)
        return VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 4) {
                cityName(city, size: 12, opacity: 0.6)
                Spacer(minLength: 0)
                glyph(day: day, size: 16)
            }
            Spacer(minLength: 0)
            timeView(city, digitsSize: 28, meridiemSize: 14, showMeridiem: true)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 15)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(panelBackground(day: day, radius: 18, glowRadius: 105))
    }

    private func mediumPanel(_ city: City) -> some View {
        let day = city.isDaytime(at: date)
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

    private func cityName(_ city: City, size: CGFloat, opacity: Double) -> some View {
        Text(city.title)
            .font(.system(size: size, weight: .semibold))
            .foregroundStyle(Color.wcTextPrimary.opacity(opacity))
            .lineLimit(1)
            .minimumScaleFactor(0.85)
    }

    private func timeView(
        _ city: City,
        digitsSize: CGFloat,
        meridiemSize: CGFloat,
        showMeridiem: Bool
    ) -> some View {
        HStack(alignment: .lastTextBaseline, spacing: 3) {
            Text(city.clockDigits(at: date))
                .font(.system(size: digitsSize, weight: .semibold))
                .monospacedDigit()
                .foregroundStyle(Color.wcTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.85)

            if showMeridiem, let meridiem = city.amPMText(at: date) {
                Text(meridiem)
                    .font(.system(size: meridiemSize, weight: .semibold))
                    .foregroundStyle(Color.wcTextPrimary.opacity(0.5))
            }
        }
    }

    private func caption(_ city: City) -> some View {
        let period = city.periodWord(at: date).uppercased()
        let text = city.amPMText(at: date).map { "\($0.uppercased()) · \(period)" } ?? period

        return Text(text)
            .font(.system(size: 12, weight: .semibold))
            .tracking(0.96)
            .foregroundStyle(Color.wcTextPrimary.opacity(0.5))
            .lineLimit(1)
            .minimumScaleFactor(0.8)
    }

    private func glyph(day: Bool, size: CGFloat) -> some View {
        let tint = isFullColor
            ? (day ? Color.wcSun : Color.wcMoon)
            : Color.wcTextPrimary.opacity(0.75)

        return Image(systemName: day ? "sun.max.fill" : "moon.fill")
            .font(.system(size: size, weight: .medium))
            .symbolRenderingMode(isFullColor ? .multicolor : .monochrome)
            .foregroundStyle(tint)
            .shadow(color: isFullColor ? tint.opacity(0.55) : .clear, radius: 6)
    }

    @ViewBuilder
    private func panelBackground(day: Bool, radius: CGFloat, glowRadius: CGFloat) -> some View {
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)

        if isFullColor {
            let wash = day ? Color.wcDayWash : Color.wcNightWash
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
            shape.fill(Color.white.opacity(0.035))
        }
    }
}
