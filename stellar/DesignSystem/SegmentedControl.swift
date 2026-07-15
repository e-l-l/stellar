//
//  SegmentedControl.swift
//  stellar
//
//  Custom segmented control matching the handoff tokens exactly. The native
//  iOS 26 control forces a pill/liquid-glass corner radius, so we draw our own:
//  track radius 9 with 2px padding, selected segment radius 7, pink fill.
//

import SwiftUI

struct SegmentedControl<T: Hashable & Identifiable>: View {
    let options: [T]
    let title: (T) -> String
    @Binding var selection: T

    @Namespace private var pill

    var body: some View {
        HStack(spacing: 2) {
            ForEach(options) { option in
                let isOn = option == selection
                Text(title(option))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(isOn ? .black : Color.stellarTextSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 7)
                    .background {
                        if isOn {
                            RoundedRectangle(cornerRadius: StellarRadius.segmentPill, style: .continuous)
                                .fill(Color.stellarAccent)
                                .matchedGeometryEffect(id: "pill", in: pill)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.15)) { selection = option }
                    }
            }
        }
        .padding(2)
        .background(
            RoundedRectangle(cornerRadius: StellarRadius.segmentTrack, style: .continuous)
                .fill(Color.stellarSegmentTrack)
        )
    }
}
