//
//  GalleryComplicationPreviews.swift
//  stellarWatch Watch App
//
//  The gallery's family thumbnails for the Steps complication. The **circular**
//  thumbnail reuses the real shipping renderer (`StepsCircularVisual` from
//  `stellarWatchShared/StepsVisuals.swift`) so the browse preview matches the
//  complication on the face exactly. The **corner** thumbnail is a static
//  representation of the `.accessoryCorner` style — the true curved gauge is
//  rendered by the system widget host and can't be reproduced in a plain view,
//  so this evokes it (corner gauge + value) using the same comet palette.
//

import SwiftUI

/// Representative sample used by every gallery thumbnail. The real complication
/// renders live HealthKit data on the face; here we show a fixed 6,000 / 10,000.
let galleryStepsSample = StepsPresentation(
    reading: .available(StepCount(steps: 6000, date: .distantPast)),
    goal: .standard
)

/// The circular complication on a black well, matching `WellBackground`.
struct StepsCircularThumbnail: View {
    let presentation: StepsPresentation

    var body: some View {
        ZStack {
            Circle().fill(.black)
            StepsCircularVisual(presentation: presentation)
        }
        .clipShape(Circle())
    }
}

/// A representation of the `.accessoryCorner` complication: a quarter-circle
/// gauge hugging the bottom-leading corner with the step value in the opposite
/// corner. Static — the shipping corner gauge is system-rendered on the face.
struct StepsCornerThumbnail: View {
    let presentation: StepsPresentation

    var body: some View {
        GeometryReader { geo in
            let d = min(geo.size.width, geo.size.height)
            let lw = d * 0.09
            let over = presentation.ratio > 1
            let level = min(max(presentation.ratio, 0), 1)

            ZStack {
                RoundedRectangle(cornerRadius: d * 0.28, style: .continuous).fill(.black)

                // Bottom-leading quarter-arc gauge (t: 0.25 = 6 o'clock → 0.5 = 9 o'clock).
                Circle()
                    .trim(from: 0.25, to: 0.5)
                    .stroke(Color.cometProgress.opacity(0.15), style: StrokeStyle(lineWidth: lw, lineCap: .round))
                    .padding(lw)
                if presentation.state == .available {
                    Circle()
                        .trim(from: 0.25, to: 0.25 + 0.25 * level)
                        .stroke(over ? Color.cometOverflow : Color.cometProgress, style: StrokeStyle(lineWidth: lw, lineCap: .round))
                        .padding(lw)
                }

                Text(presentation.state == .available ? stepsLabel(presentation.steps ?? 0) : "—")
                    .font(.system(size: d * 0.24, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color.cometCount)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(d * 0.16)
            }
            .frame(width: d, height: d)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    HStack(spacing: 12) {
        StepsCircularThumbnail(presentation: galleryStepsSample)
        StepsCornerThumbnail(presentation: galleryStepsSample)
    }
    .frame(height: 48)
    .padding()
    .background(.black)
}
