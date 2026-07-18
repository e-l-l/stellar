//
//  StepsView.swift
//  stellarWatchWidgets
//
//  Concept C — "Comet": a hairline progress track with a single glowing head
//  that travels to the progress angle. Renders the same StepsEntry in two
//  accessory families (circular + corner). No data access here — every value is
//  derived once from the immutable entry (see CLAUDE.md widget runtime rules).
//

import SwiftUI
import WidgetKit

// MARK: - Design tokens

private extension Color {
    /// Accent / progress pink (#F6A5C0). Accentable so it picks up face tint.
    static let cometProgress = Color(red: 0.965, green: 0.647, blue: 0.753)
    /// Over-goal mint (#8AD9B0). Kept literal so the over-goal signal survives `.accented`.
    static let cometOverflow = Color(red: 0.541, green: 0.851, blue: 0.690)
    /// Primary count ink (#F5F5F7).
    static let cometCount = Color(red: 0.961, green: 0.961, blue: 0.969)
    /// Muted label ink (rgb 235,235,245) — used at low opacity for sub-labels and empty states.
    static let cometInk = Color(red: 0.922, green: 0.922, blue: 0.961)
}

// MARK: - Derived state

/// The four reading cases, flattened for the meter. All display values are
/// derived from `entry`; the view holds no state of its own.
private enum MeterState: Equatable {
    case available
    case pending
    case unavailable
    case failed
}

/// Grouped up to 4 digits (`6,000`, `12,345`); abbreviated ≥ 100,000 as `128K`
/// so the number never clips the well.
private func stepsLabel(_ steps: Int) -> String {
    steps >= 100_000 ? "\(steps / 1000)K" : steps.formatted(.number)
}

/// Over-goal caption: `+23%` for a partial extra lap, `12.8×` for large multiples.
private func overLabel(_ ratio: Double) -> String {
    ratio >= 2 ? String(format: "%.1f×", ratio) : "+\(Int((ratio - 1) * 100))%"
}

// MARK: - Entry point

struct StepsView: View {
    @Environment(\.widgetFamily) private var family
    let entry: StepsEntry

    var body: some View {
        switch family {
        case .accessoryCorner:
            CornerMeter(state: state, ratio: ratio, steps: steps)
        default:
            CircularMeter(state: state, ratio: ratio, steps: steps)
        }
    }

    private var state: MeterState {
        switch entry.reading {
        case .available: .available
        case .pending: .pending
        case .unavailable: .unavailable
        case .failed: .failed
        }
    }

    private var steps: Int? {
        if case .available(let count) = entry.reading { count.steps } else { nil }
    }

    /// May exceed 1.0 (over-goal). `0` when there is no reading yet.
    private var ratio: Double {
        guard let steps else { return 0 }
        return Double(steps) / Double(entry.goal.value)
    }
}

// MARK: - Circular meter

private struct CircularMeter: View {
    let state: MeterState
    let ratio: Double
    let steps: Int?

    var body: some View {
        GeometryReader { geo in
            let dim = min(geo.size.width, geo.size.height)
            ZStack {
                track(dim: dim)
                arcAndHead(dim: dim)
                center(dim: dim)
            }
            .frame(width: dim, height: dim)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // Full-circle track. Never accented — stays a dim divider.
    @ViewBuilder private func track(dim: CGFloat) -> some View {
        let s = dim * 0.05
        let inset = dim * 0.09
        switch state {
        case .unavailable:
            Circle()
                .stroke(Color.white.opacity(0.16),
                        style: StrokeStyle(lineWidth: s, dash: [dim * 0.05, dim * 0.05]))
                .padding(inset)
        case .failed:
            Circle().stroke(Color.white.opacity(0.12), lineWidth: s).padding(inset)
        default:
            Circle().stroke(Color.cometProgress.opacity(0.12), lineWidth: s).padding(inset)
        }
    }

    // Progress arc + comet head. Only drawn for a real reading.
    @ViewBuilder private func arcAndHead(dim: CGFloat) -> some View {
        if state == .available {
            let s = dim * 0.05
            let inset = dim * 0.09
            let headD = dim * 0.15
            let radius = dim / 2 - inset
            let stroke = StrokeStyle(lineWidth: s, lineCap: .round)

            if ratio > 1, ratio < 2 {
                // Base ring completes in pink, a second lap draws in mint.
                arc(to: 1, color: .cometProgress, style: stroke, inset: inset).widgetAccentable()
                arc(to: min(ratio - 1, 1), color: .cometOverflow, style: stroke, inset: inset)
                head(color: .cometOverflow, angle: (ratio - 1) * 360,
                     radius: radius, d: headD, dim: dim, accent: false)
            } else if ratio >= 2 {
                // Huge: whole ring reads as overflow, head parked at top.
                Circle().stroke(Color.cometOverflow, lineWidth: s).padding(inset)
                head(color: .cometOverflow, angle: 0,
                     radius: radius, d: headD, dim: dim, accent: false)
            } else {
                arc(to: ratio, color: .cometProgress, style: stroke, inset: inset).widgetAccentable()
                head(color: .cometProgress, angle: ratio * 360,
                     radius: radius, d: headD, dim: dim, accent: true, faint: ratio == 0)
            }
        }
    }

    // A trimmed ring starting at 12 o'clock, sweeping clockwise.
    private func arc(to end: Double, color: Color, style: StrokeStyle, inset: CGFloat) -> some View {
        Circle()
            .trim(from: 0, to: end)
            .stroke(color, style: style)
            .rotationEffect(.degrees(-90))
            .padding(inset)
    }

    // A glowing dot on the ring at `angle` degrees clockwise from 12 o'clock.
    @ViewBuilder private func head(color: Color, angle: Double, radius: CGFloat,
                                   d: CGFloat, dim: CGFloat,
                                   accent: Bool, faint: Bool = false) -> some View {
        let dot = Circle()
            .fill(color)
            .frame(width: faint ? d * 0.7 : d, height: faint ? d * 0.7 : d)
            .shadow(color: color.opacity(0.8), radius: dim * 0.08)
            .opacity(faint ? 0.6 : 1)
            .offset(y: -radius)
            .rotationEffect(.degrees(angle))
        if accent { dot.widgetAccentable() } else { dot }
    }

    // Centered number / state glyph plus sub-label.
    @ViewBuilder private func center(dim: CGFloat) -> some View {
        switch state {
        case .available:
            VStack(spacing: dim * 0.01) {
                Text(stepsLabel(steps ?? 0))
                    .font(.system(size: dim * 0.30, weight: .semibold).monospacedDigit())
                    .tracking(-0.02 * dim * 0.30)
                    .foregroundStyle(Color.cometCount)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                    .widgetAccentable()
                subLabel(dim: dim)
            }
            .padding(.horizontal, dim * 0.16)

        case .pending:
            Capsule()
                .fill(Color.white.opacity(0.14))
                .frame(width: dim * 0.4, height: dim * 0.16)
                .redacted(reason: .placeholder)

        case .unavailable:
            emptyState(glyph: Text("—"), caption: "STEPS", dim: dim, opacity: 0.4)

        case .failed:
            emptyState(glyph: Image(systemName: "arrow.clockwise"),
                       caption: "RETRY", dim: dim, opacity: 0.55)
        }
    }

    @ViewBuilder private func subLabel(dim: CGFloat) -> some View {
        if ratio > 1 {
            Text(overLabel(ratio))
                .font(.system(size: dim * 0.13, weight: .semibold))
                .foregroundStyle(Color.cometOverflow)
        } else {
            Text("STEPS")
                .font(.system(size: dim * 0.10, weight: .semibold))
                .tracking(dim * 0.006)
                .textCase(.uppercase)
                .foregroundStyle(Color.cometInk.opacity(0.5))
        }
    }

    private func emptyState(glyph: some View, caption: String,
                            dim: CGFloat, opacity: Double) -> some View {
        VStack(spacing: dim * 0.02) {
            glyph
                .font(.system(size: dim * 0.26, weight: .semibold))
                .foregroundStyle(Color.cometInk.opacity(opacity))
            Text(caption)
                .font(.system(size: dim * 0.10, weight: .semibold))
                .tracking(dim * 0.006)
                .textCase(.uppercase)
                .foregroundStyle(Color.cometInk.opacity(0.5))
        }
    }
}

// MARK: - Corner meter

private struct CornerMeter: View {
    let state: MeterState
    let ratio: Double
    let steps: Int?

    var body: some View {
        content
            .widgetLabel { gauge }
    }

    // Inner-corner content: the number (or state glyph).
    @ViewBuilder private var content: some View {
        switch state {
        case .available:
            Text(stepsLabel(steps ?? 0))
                .font(.system(.title3, weight: .semibold).monospacedDigit())
                .minimumScaleFactor(0.7)
                .lineLimit(1)
                .foregroundStyle(Color.cometCount)
                .widgetAccentable()
        case .pending:
            Text("0,000")
                .font(.system(.title3, weight: .semibold).monospacedDigit())
                .redacted(reason: .placeholder)
        case .unavailable:
            Text("—").font(.system(.title3, weight: .semibold))
                .foregroundStyle(Color.cometInk.opacity(0.4))
        case .failed:
            Image(systemName: "arrow.clockwise")
                .font(.system(.title3, weight: .semibold))
                .foregroundStyle(Color.cometInk.opacity(0.55))
        }
    }

    // System-curved bezel gauge — the lit leading end reads as the comet head.
    @ViewBuilder private var gauge: some View {
        switch state {
        case .available:
            Gauge(value: min(ratio, 1)) { Text("") }
                .tint(ratio > 1 ? Color.cometOverflow : Color.cometProgress)
                .widgetAccentable(ratio <= 1)
        default:
            Gauge(value: 0) { Text("") }
                .tint(Color.white.opacity(0.16))
        }
    }
}

// MARK: - Container background

/// Paints a black well only in full-color contexts; stays clear when the system
/// removes the widget container so background-removed faces render clean.
struct WellBackground: View {
    @Environment(\.showsWidgetContainerBackground) private var showsBackground
    var body: some View {
        if showsBackground { Color.black } else { Color.clear }
    }
}

// MARK: - Previews

#Preview("Circular", as: .accessoryCircular) {
    StepsWidget()
} timeline: {
    StepsEntry(reading: .available(StepCount(steps: 6000, date: .now)), goal: .standard)
    StepsEntry(reading: .available(StepCount(steps: 0, date: .now)), goal: .standard)
    StepsEntry(reading: .available(StepCount(steps: 12345, date: .now)), goal: .standard)
    StepsEntry(reading: .available(StepCount(steps: 128000, date: .now)), goal: .standard)
    StepsEntry(reading: .pending(asOf: .now), goal: .standard)
    StepsEntry(reading: .unavailable(asOf: .now), goal: .standard)
    StepsEntry(reading: .failed(asOf: .now), goal: .standard)
}

#Preview("Corner", as: .accessoryCorner) {
    StepsWidget()
} timeline: {
    StepsEntry(reading: .available(StepCount(steps: 6000, date: .now)), goal: .standard)
    StepsEntry(reading: .available(StepCount(steps: 0, date: .now)), goal: .standard)
    StepsEntry(reading: .available(StepCount(steps: 12345, date: .now)), goal: .standard)
    StepsEntry(reading: .available(StepCount(steps: 128000, date: .now)), goal: .standard)
    StepsEntry(reading: .pending(asOf: .now), goal: .standard)
    StepsEntry(reading: .unavailable(asOf: .now), goal: .standard)
    StepsEntry(reading: .failed(asOf: .now), goal: .standard)
}
