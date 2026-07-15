//
//  CategoryView.swift
//  stellar
//
//  "By Category" screen: every widget + complication grouped by its source
//  category. Previews are placeholders.
//

import SwiftUI

struct CategoryView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                Text("Widgets & complications, grouped")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.stellarTextSecondary)

                ForEach(CatalogData.categories) { category in
                    CategoryBlock(category: category)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(Color.stellarBackground.ignoresSafeArea())
        .navigationTitle("By Category")
    }
}

private struct CategoryBlock: View {
    let category: Category

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: category.symbol)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.stellarAccent)
                    .frame(width: 26, height: 26)
                    .background(
                        RoundedRectangle(cornerRadius: StellarRadius.glyph, style: .continuous)
                            .fill(Color.stellarSurface)
                    )
                Text(category.name)
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(Color.stellarTextPrimary)
                Spacer()
                Text("1 widget · 1 complication")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.stellarTextQuaternary)
            }

            HStack(spacing: 14) {
                categoryTile(caption: "Widget · S") {
                    WidgetPlaceholder(symbol: category.widgetSymbol,
                                      cornerRadius: StellarRadius.categoryTile)
                        .frame(width: 110, height: 110)
                }
                categoryTile(caption: "Complication") {
                    ZStack {
                        RoundedRectangle(cornerRadius: StellarRadius.categoryTile, style: .continuous)
                            .fill(Color.stellarSurfaceComp)
                        ComplicationPlaceholder(symbol: category.complicationSymbol, diameter: 60)
                    }
                    .frame(width: 110, height: 110)
                }
            }
        }
    }

    private func categoryTile<Content: View>(
        caption: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        CaptionedTile(caption: caption, spacing: 7, captionSize: 12,
                      captionColor: .stellarTextTertiary, content: content)
    }
}

#Preview {
    NavigationStack { CategoryView() }
        .preferredColorScheme(.dark)
}
