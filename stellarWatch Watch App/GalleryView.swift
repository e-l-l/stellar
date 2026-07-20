//
//  GalleryView.swift
//  stellarWatch Watch App
//
//  Screen 1a — the complications gallery. Stellar vends one complication, Steps,
//  in two families (circular + corner), so the gallery is a single Steps card:
//  it previews both families with the real renderer, taps through to Configure
//  (1b), and offers an "Add to Watch Face" action (watchOS can't place a
//  complication programmatically — the user adds it from the face editor).
//

import SwiftUI

struct GalleryView: View {
    @State private var showingAdd = false

    private let sample = galleryStepsSample

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                header
                stepsCard
                addButton
            }
            .padding(.horizontal, 6)
            .padding(.top, 2)
        }
        .sheet(isPresented: $showingAdd) { AddComplicationSheet(sample: sample) }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Complications")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.stellarText)
            Text("Add Steps to your watch face")
                .font(.system(size: 12))
                .foregroundStyle(Color.stellarInk.opacity(0.5))
        }
        .padding(.bottom, 2)
    }

    /// The whole card navigates to Configure (chevron affordance). Tapping
    /// anywhere on it opens the Steps configuration surface.
    private var stepsCard: some View {
        NavigationLink { ConfigureView() } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 14) {
                    familyThumbnail(StepsCircularThumbnail(presentation: sample), caption: "Circular")
                    familyThumbnail(StepsCornerThumbnail(presentation: sample), caption: "Corner")
                    Spacer(minLength: 0)
                }
                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Steps")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.stellarText)
                        Text("Circular · Corner")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.stellarInk.opacity(0.5))
                    }
                    Spacer(minLength: 0)
                    Text("Configure")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.stellarInk.opacity(0.5))
                    Chevron()
                }
            }
            .padding(.vertical, 13)
            .padding(.horizontal, 14)
            .background(Color.stellarRowFill.opacity(0.20), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func familyThumbnail(_ thumbnail: some View, caption: String) -> some View {
        VStack(spacing: 5) {
            thumbnail
                .frame(width: 48, height: 48)
            Text(caption)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(Color.stellarInk.opacity(0.4))
        }
    }

    private var addButton: some View {
        Button { showingAdd = true } label: {
            Text("Add to Watch Face")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.stellarPink)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(Color.stellarPink.opacity(0.18), in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

/// The add-to-face instructions surfaced by "Add to Watch Face". watchOS has no
/// API to place a complication for the user, so this is instructional.
private struct AddComplicationSheet: View {
    let sample: StepsPresentation
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                StepsCircularThumbnail(presentation: sample)
                    .frame(width: 56, height: 56)
                Text("Add Steps")
                    .font(.headline)
                Text("Touch and hold your watch face, tap Edit, swipe to Complications, tap a slot, then choose Stellar.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Button("Done") { dismiss() }
                    .tint(Color.stellarPink)
                    .padding(.top, 4)
            }
            .padding()
        }
    }
}

#Preview {
    NavigationStack {
        GalleryView()
            .environment(WatchStepsModel())
    }
}
