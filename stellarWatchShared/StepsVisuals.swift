//
//  StepsVisuals.swift
//  stellarWatchShared
//
//  Reusable Steps presentation shared by the watch complication and mobile
//  gallery. HealthKit access remains in StepsReader and watch-owned targets.
//

import SwiftUI
import WidgetKit

extension Color {
    static let cometProgress = Color(red: 0.965, green: 0.647, blue: 0.753)
    static let cometOverflow = Color(red: 0.541, green: 0.851, blue: 0.690)
    static let cometCount = Color(red: 0.961, green: 0.961, blue: 0.969)
    static let cometInk = Color(red: 0.922, green: 0.922, blue: 0.961)
}

struct StepsPresentation: Sendable, Equatable {
    enum State: Sendable, Equatable {
        case available
        case pending
        case unavailable
        case failed
    }

    let state: State
    let ratio: Double
    let steps: Int?

    init(reading: StepReadState, goal: StepGoal) {
        switch reading {
        case .available(let count):
            state = .available
            steps = count.steps
            ratio = Double(count.steps) / Double(goal.value)
        case .pending:
            state = .pending
            steps = nil
            ratio = 0
        case .unavailable:
            state = .unavailable
            steps = nil
            ratio = 0
        case .failed:
            state = .failed
            steps = nil
            ratio = 0
        }
    }
}

func stepsLabel(_ steps: Int) -> String {
    steps >= 100_000 ? "\(steps / 1000)K" : steps.formatted(.number)
}

private func overLabel(_ ratio: Double) -> String {
    ratio >= 2 ? String(format: "%.1f×", ratio) : "+\(Int((ratio - 1) * 100))%"
}

struct StepsCircularVisual: View {
    let presentation: StepsPresentation

    var body: some View {
        GeometryReader { geometry in
            let dimension = min(geometry.size.width, geometry.size.height)
            ZStack {
                track(dimension: dimension)
                arcAndHead(dimension: dimension)
                center(dimension: dimension)
            }
            .frame(width: dimension, height: dimension)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @ViewBuilder
    private func track(dimension: CGFloat) -> some View {
        let strokeWidth = dimension * 0.05
        let inset = dimension * 0.09

        switch presentation.state {
        case .unavailable:
            Circle()
                .stroke(
                    Color.white.opacity(0.16),
                    style: StrokeStyle(
                        lineWidth: strokeWidth,
                        dash: [dimension * 0.05, dimension * 0.05]
                    )
                )
                .padding(inset)
        case .failed:
            Circle()
                .stroke(Color.white.opacity(0.12), lineWidth: strokeWidth)
                .padding(inset)
        default:
            Circle()
                .stroke(Color.cometProgress.opacity(0.12), lineWidth: strokeWidth)
                .padding(inset)
        }
    }

    @ViewBuilder
    private func arcAndHead(dimension: CGFloat) -> some View {
        if presentation.state == .available {
            let strokeWidth = dimension * 0.05
            let inset = dimension * 0.09
            let headDiameter = dimension * 0.15
            let radius = dimension / 2 - inset
            let stroke = StrokeStyle(lineWidth: strokeWidth, lineCap: .round)

            if presentation.ratio > 1, presentation.ratio < 2 {
                arc(to: 1, color: .cometProgress, style: stroke, inset: inset)
                    .widgetAccentable()
                arc(
                    to: min(presentation.ratio - 1, 1),
                    color: .cometOverflow,
                    style: stroke,
                    inset: inset
                )
                head(
                    color: .cometOverflow,
                    angle: (presentation.ratio - 1) * 360,
                    radius: radius,
                    diameter: headDiameter,
                    dimension: dimension,
                    accent: false
                )
            } else if presentation.ratio >= 2 {
                Circle()
                    .stroke(Color.cometOverflow, lineWidth: strokeWidth)
                    .padding(inset)
                head(
                    color: .cometOverflow,
                    angle: 0,
                    radius: radius,
                    diameter: headDiameter,
                    dimension: dimension,
                    accent: false
                )
            } else {
                arc(
                    to: presentation.ratio,
                    color: .cometProgress,
                    style: stroke,
                    inset: inset
                )
                .widgetAccentable()
                head(
                    color: .cometProgress,
                    angle: presentation.ratio * 360,
                    radius: radius,
                    diameter: headDiameter,
                    dimension: dimension,
                    accent: true,
                    faint: presentation.ratio == 0
                )
            }
        }
    }

    private func arc(
        to end: Double,
        color: Color,
        style: StrokeStyle,
        inset: CGFloat
    ) -> some View {
        Circle()
            .trim(from: 0, to: end)
            .stroke(color, style: style)
            .rotationEffect(.degrees(-90))
            .padding(inset)
    }

    @ViewBuilder
    private func head(
        color: Color,
        angle: Double,
        radius: CGFloat,
        diameter: CGFloat,
        dimension: CGFloat,
        accent: Bool,
        faint: Bool = false
    ) -> some View {
        let dot = Circle()
            .fill(color)
            .frame(
                width: faint ? diameter * 0.7 : diameter,
                height: faint ? diameter * 0.7 : diameter
            )
            .shadow(color: color.opacity(0.8), radius: dimension * 0.08)
            .opacity(faint ? 0.6 : 1)
            .offset(y: -radius)
            .rotationEffect(.degrees(angle))

        if accent { dot.widgetAccentable() } else { dot }
    }

    @ViewBuilder
    private func center(dimension: CGFloat) -> some View {
        switch presentation.state {
        case .available:
            VStack(spacing: dimension * 0.01) {
                Text(stepsLabel(presentation.steps ?? 0))
                    .font(.system(size: dimension * 0.30, weight: .semibold).monospacedDigit())
                    .tracking(-0.02 * dimension * 0.30)
                    .foregroundStyle(Color.cometCount)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                    .widgetAccentable()
                subLabel(dimension: dimension)
            }
            .padding(.horizontal, dimension * 0.16)

        case .pending:
            Capsule()
                .fill(Color.white.opacity(0.14))
                .frame(width: dimension * 0.4, height: dimension * 0.16)
                .redacted(reason: .placeholder)

        case .unavailable:
            emptyState(
                glyph: Text("—"),
                caption: "STEPS",
                dimension: dimension,
                opacity: 0.4
            )

        case .failed:
            emptyState(
                glyph: Image(systemName: "arrow.clockwise"),
                caption: "RETRY",
                dimension: dimension,
                opacity: 0.55
            )
        }
    }

    @ViewBuilder
    private func subLabel(dimension: CGFloat) -> some View {
        if presentation.ratio > 1 {
            Text(overLabel(presentation.ratio))
                .font(.system(size: dimension * 0.13, weight: .semibold))
                .foregroundStyle(Color.cometOverflow)
        } else {
            Text("STEPS")
                .font(.system(size: dimension * 0.10, weight: .semibold))
                .tracking(dimension * 0.006)
                .textCase(.uppercase)
                .foregroundStyle(Color.cometInk.opacity(0.5))
        }
    }

    private func emptyState(
        glyph: some View,
        caption: String,
        dimension: CGFloat,
        opacity: Double
    ) -> some View {
        VStack(spacing: dimension * 0.02) {
            glyph
                .font(.system(size: dimension * 0.26, weight: .semibold))
                .foregroundStyle(Color.cometInk.opacity(opacity))
            Text(caption)
                .font(.system(size: dimension * 0.10, weight: .semibold))
                .tracking(dimension * 0.006)
                .textCase(.uppercase)
                .foregroundStyle(Color.cometInk.opacity(0.5))
        }
    }
}
