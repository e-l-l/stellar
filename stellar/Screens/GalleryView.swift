//
//  GalleryView.swift
//  stellar
//
//  Primary gallery treatment: large title + segmented Widgets/Complications
//  control, with items grouped by size. Previews are placeholders.
//

import SwiftUI

private enum GalleryTab: String, CaseIterable, Identifiable {
    case widgets = "Widgets"
    case complications = "Complications"
    var id: Self { self }
}

struct GalleryView: View {
    @State private var tab: GalleryTab = .widgets

    private let columns = [GridItem(.flexible(), spacing: 16),
                           GridItem(.flexible(), spacing: 16)]

    var body: some View {
        ScrollView {
            VStack(spacing: 26) {
                SegmentedControl(
                    options: GalleryTab.allCases,
                    title: { $0.rawValue },
                    selection: $tab
                )

                switch tab {
                case .widgets: widgetsTab
                case .complications: complicationsTab
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(Color.stellarBackground.ignoresSafeArea())
        .navigationTitle("Gallery")
    }

    // MARK: Widgets

    private var widgetsTab: some View {
        VStack(alignment: .leading, spacing: 28) {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Small")
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(CatalogData.smallWidgets) { item in
                        CaptionedTile(caption: item.name) {
                            WidgetPlaceholder(symbol: item.symbol)
                                .aspectRatio(1, contentMode: .fit)
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Medium")
                VStack(spacing: 16) {
                    ForEach(CatalogData.mediumWidgets) { item in
                        CaptionedTile(caption: item.name) {
                            WidgetPlaceholder(symbol: item.symbol, textLines: 2)
                                .frame(height: 110)
                        }
                    }
                }
            }
        }
    }

    // MARK: Complications

    private var complicationsTab: some View {
        VStack(alignment: .leading, spacing: 28) {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Circular")
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(CatalogData.circularComplications) { item in
                        CaptionedTile(caption: item.name, spacing: 10) {
                            ComplicationPlaceholder(symbol: item.symbol)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: StellarRadius.tile, style: .continuous)
                                .fill(Color.stellarSurfaceComp)
                        )
                    }
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Rectangular")
                VStack(spacing: 14) {
                    ForEach(CatalogData.rectangularComplications) { item in
                        RectComplicationPlaceholder(symbol: item.symbol)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack { GalleryView() }
        .preferredColorScheme(.dark)
}
