//
//  GalleryView.swift
//  stellar
//
//  Current product gallery. Every preview uses rendering shared with its real
//  WidgetKit extension; only Steps data is representative rather than live.
//

import SwiftUI

private enum GalleryTab: String, CaseIterable, Identifiable {
    case widgets = "Widgets"
    case complications = "Complications"

    var id: Self { self }
}

struct GalleryView: View {
    @State private var tab: GalleryTab = .widgets

    var body: some View {
        ScrollView {
            VStack(spacing: 26) {
                SegmentedControl(
                    options: GalleryTab.allCases,
                    title: { $0.rawValue },
                    selection: $tab
                )

                switch tab {
                case .widgets:
                    widgetsTab
                case .complications:
                    complicationsTab
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(Color.stellarBackground.ignoresSafeArea())
        .navigationTitle("Gallery")
    }

    // MARK: - Widgets

    private var widgetsTab: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            VStack(alignment: .leading, spacing: 28) {
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Small")
                    HStack {
                        CaptionedTile(caption: "World Clock") {
                            worldClockPreview(
                                date: context.date,
                                layout: .small,
                                aspectRatio: 1
                            )
                        }
                        .frame(maxWidth: 220)
                        Spacer(minLength: 0)
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Medium")
                    CaptionedTile(caption: "World Clock") {
                        worldClockPreview(
                            date: context.date,
                            layout: .medium,
                            aspectRatio: 2
                        )
                    }
                    .frame(maxWidth: 560)
                }
            }
        }
    }

    private func worldClockPreview(
        date: Date,
        layout: WorldClockLayout,
        aspectRatio: CGFloat
    ) -> some View {
        ZStack {
            Color.wcSurface
            WorldClockRenderer(
                date: date,
                cityA: .newYork,
                cityB: .tokyo,
                layout: layout,
                renderingStyle: .fullColor
            )
        }
        .aspectRatio(aspectRatio, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: StellarRadius.tile, style: .continuous))
        .shadow(color: .stellarShadow, radius: 12, x: 0, y: 8)
    }

    // MARK: - Complications

    private var complicationsTab: some View {
        let presentation = StepsPresentation(
            reading: .available(StepCount(steps: 6_000, date: .now)),
            goal: .standard
        )

        return VStack(alignment: .leading, spacing: 28) {
            Label {
                Text("Preview uses 6,000 of 10,000 steps. Live data comes from Apple Watch.")
            } icon: {
                Image(systemName: "applewatch")
                    .foregroundStyle(Color.stellarAccent)
            }
            .font(.system(size: 13))
            .foregroundStyle(Color.stellarTextSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Circular")
                HStack {
                    CaptionedTile(caption: "Steps", spacing: 10) {
                        complicationCard {
                            StepsCircularVisual(presentation: presentation)
                                .frame(width: 112, height: 112)
                                .background(Circle().fill(.black))
                        }
                    }
                    .frame(maxWidth: 220)
                    Spacer(minLength: 0)
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Corner")
                HStack {
                    CaptionedTile(caption: "6,000 · 60%", spacing: 12) {
                        StepsCornerGalleryPreview(presentation: presentation)
                    }
                    .frame(maxWidth: 220)
                    Spacer(minLength: 0)
                }
            }
        }
    }

    private func complicationCard<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: StellarRadius.tile, style: .continuous)
                .fill(Color.stellarSurfaceComp)
            content()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 156)
        .overlay {
            RoundedRectangle(cornerRadius: StellarRadius.tile, style: .continuous)
                .strokeBorder(Color.stellarHairline, lineWidth: 1)
        }
    }
}

/// iPhone-only visual approximation. WidgetKit owns actual accessory-corner
/// geometry on watch faces, so this deliberately does not share its layout.
private struct StepsCornerGalleryPreview: View {
    let presentation: StepsPresentation

    private static let size: CGFloat = 220
    private static let scale: CGFloat = 220 / 132

    private var progress: CGFloat {
        CGFloat(min(max(presentation.ratio, 0), 1))
    }

    private var stepText: String {
        guard let steps = presentation.steps else { return "—" }
        return steps.formatted(.number)
    }

    private var progressText: String {
        if presentation.ratio > 1 {
            return "+\(Int((presentation.ratio - 1) * 100))%"
        }
        return "\(Int((presentation.ratio * 100).rounded()))%"
    }

    var body: some View {
        let displayedStepText = stepText
        let displayedProgressText = progressText

        ZStack(alignment: .bottomTrailing) {
            RoundedRectangle(cornerRadius: 30 * Self.scale, style: .continuous)
                .fill(.black)

            CornerGaugeArc()
                .stroke(
                    Color.stellarAccent.opacity(0.14),
                    style: StrokeStyle(lineWidth: 5 * Self.scale, lineCap: .round)
                )
                .padding(8 * Self.scale)

            CornerGaugeArc()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.stellarAccent,
                    style: StrokeStyle(lineWidth: 5 * Self.scale, lineCap: .round)
                )
                .padding(8 * Self.scale)

            VStack(alignment: .trailing, spacing: Self.scale) {
                Text(displayedStepText)
                    .font(.system(size: 24 * Self.scale, weight: .semibold).monospacedDigit())
                    .foregroundStyle(Color.stellarTextPrimary)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)

                Text("STEPS · \(displayedProgressText)")
                    .font(.system(size: 9 * Self.scale, weight: .semibold))
                    .tracking(0.6 * Self.scale)
                    .foregroundStyle(Color.stellarTextTertiary)
            }
            .padding(.trailing, 14 * Self.scale)
            .padding(.bottom, 14 * Self.scale)
        }
        .frame(width: Self.size, height: Self.size)
        .clipShape(RoundedRectangle(cornerRadius: 30 * Self.scale, style: .continuous))
        .shadow(color: .stellarShadow, radius: 10 * Self.scale, x: 0, y: 7 * Self.scale)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Steps: \(displayedStepText), \(displayedProgressText) of goal")
    }
}

private struct CornerGaugeArc: Shape {
    func path(in rect: CGRect) -> Path {
        let radius = min(rect.width, rect.height) * 0.88
        var path = Path()
        path.addArc(
            center: CGPoint(x: rect.minX, y: rect.minY),
            radius: radius,
            startAngle: .zero,
            endAngle: .degrees(90),
            clockwise: false
        )
        return path
    }
}

#Preview {
    NavigationStack { GalleryView() }
        .preferredColorScheme(.dark)
}
