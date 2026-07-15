//
//  Placeholders.swift
//  stellar
//
//  Neutral stand-ins for widget / complication previews. These deliberately do
//  NOT reproduce the real widget content — they render a category symbol (and,
//  for wider families, faux text lines) on a muted surface so the gallery
//  layout reads correctly before the real WidgetKit previews exist.
//

import SwiftUI

/// A preview (widget or complication) with a caption below it. Shared by the
/// gallery and category screens, which differ only in caption styling.
struct CaptionedTile<Content: View>: View {
    let caption: String
    var spacing: CGFloat = 8
    var captionSize: CGFloat = 13
    var captionColor: Color = .stellarTextSecondary
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: spacing) {
            content
            Text(caption)
                .font(.system(size: captionSize))
                .foregroundStyle(captionColor)
        }
    }
}

/// Faux redacted text lines used inside medium / rectangular placeholders.
private struct TextLines: View {
    var count: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(0 ..< count, id: \.self) { i in
                Capsule()
                    .fill(Color.stellarRedacted)
                    .frame(width: i == 0 ? 120 : 78, height: 8)
            }
        }
    }
}

/// Accent symbol shared by the small and medium widget placeholder layouts.
private struct PlaceholderSymbol: View {
    let symbol: String
    let size: CGFloat

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: size, weight: .regular))
            .foregroundStyle(Color.stellarAccent.opacity(0.9))
    }
}

/// Square (small) or wide (medium) widget placeholder.
struct WidgetPlaceholder: View {
    let symbol: String
    /// 0 = centered symbol (small). >0 = leading symbol + N faux text rows (medium).
    var textLines: Int = 0
    var cornerRadius: CGFloat = StellarRadius.tile

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Color.stellarSurface)
            .overlay { content }
            .shadow(color: .stellarShadow, radius: 12, x: 0, y: 8)
    }

    @ViewBuilder private var content: some View {
        if textLines == 0 {
            PlaceholderSymbol(symbol: symbol, size: 34)
        } else {
            HStack(spacing: 14) {
                PlaceholderSymbol(symbol: symbol, size: 30)
                TextLines(count: textLines)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 18)
        }
    }
}

/// Round complication placeholder (circular family).
struct ComplicationPlaceholder: View {
    let symbol: String
    var diameter: CGFloat = 64

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: diameter * 0.34, weight: .medium))
            .foregroundStyle(Color.stellarAccent)
            .frame(width: diameter, height: diameter)
            .background(Circle().fill(.black))
            .overlay(Circle().strokeBorder(Color.stellarHairline, lineWidth: 1.5))
    }
}

/// Rectangular complication placeholder (leading glyph + faux text rows).
struct RectComplicationPlaceholder: View {
    let symbol: String

    var body: some View {
        HStack(spacing: 14) {
            ComplicationPlaceholder(symbol: symbol, diameter: 44)
            TextLines(count: 2)
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: StellarRadius.rectRow, style: .continuous)
                .fill(Color.stellarSurfaceComp)
        )
    }
}
