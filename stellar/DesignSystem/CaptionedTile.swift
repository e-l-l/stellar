//
//  CaptionedTile.swift
//  stellar
//
//  Shared preview tile with a caption below its rendered content.
//

import SwiftUI

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
