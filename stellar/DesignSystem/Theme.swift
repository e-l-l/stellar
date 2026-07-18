//
//  Theme.swift
//  stellar
//
//  Design tokens from the handoff (colors, fonts). Kept as value-type helpers
//  with no UI isolation so any view/target can read them.
//

import SwiftUI

extension Color {
    /// Build a Color from a 0xRRGGBB literal, matching the handoff hex values.
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 8) & 0xff) / 255,
            blue: Double(hex & 0xff) / 255,
            opacity: alpha
        )
    }

    // Backgrounds & surfaces
    static let stellarBackground = Color(hex: 0x0b0b0d)
    static let stellarSurface = Color(hex: 0x1c1c1e)      // widget tiles
    static let stellarSurfaceCard = Color(hex: 0x141416)  // feed cards
    static let stellarSurfaceComp = Color(hex: 0x111114)  // complication tiles

    // Accent (pastel pink)
    static let stellarAccent = Color(hex: 0xf6a5c0)

    // Text — base color is rgba(235,235,245,x) per the tokens
    static let stellarTextPrimary = Color(hex: 0xf5f5f7)
    static let stellarTextSecondary = Color(hex: 0xebebf5, alpha: 0.6)
    static let stellarTextTertiary = Color(hex: 0xebebf5, alpha: 0.45)
    static let stellarTextQuaternary = Color(hex: 0xebebf5, alpha: 0.4)

    // Controls
    static let stellarSegmentTrack = Color(hex: 0x767680, alpha: 0.24)

    // Decorative — reusable one-off values kept out of the views
    static let stellarShadow = Color.black.opacity(0.4)   // tile / card drop shadow
    static let stellarHairline = Color(hex: 0xffffff, alpha: 0.08)  // 1px borders
    static let stellarSplashTop = Color(hex: 0x1a1114)    // splash gradient center
    static let stellarSplashBottom = Color(hex: 0x0a0a0b) // splash gradient edge
}

/// Corner radii from the handoff. Different families use different radii by
/// design, so each is named rather than collapsed into one value.
enum StellarRadius {
    static let tile: CGFloat = 22          // widget and complication tiles
    static let segmentTrack: CGFloat = 9   // segmented control track
    static let segmentPill: CGFloat = 7    // segmented control selection
}

/// Uppercase grouped-list section header ("SMALL", "CIRCULAR", …).
struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title.uppercased())
            .font(.system(size: 13, weight: .semibold))
            .tracking(0.8)
            .foregroundStyle(Color.stellarTextTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
    }
}
