//
//  AyahCard.swift
//  Tasbee7
//
//  One ayah a day, in the reading font, with its surah and number and a share button.
//

import SwiftUI

struct AyahCard: View {
    let ayah: Ayah

    @Environment(ReadingPreferences.self) private var reading
    @ScaledMetric(relativeTo: .body) private var scale: CGFloat = 1

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("آية اليوم")
                .textRole(.eyebrow)
                .foregroundStyle(.accent)
                .accessibilityAddTraits(.isHeader)

            Text(verbatim: "﴿\(ayah.text)﴾")
                .font(reading.font.font(size: (reading.size.baseSize + 2) * scale))
                .lineSpacing(reading.font.lineSpacing * scale)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)

            HStack(spacing: Spacing.grid) {
                Text(ayah.reference)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer(minLength: 0)
                ShareLink(item: ayah.shareText) {
                    Label("مشاركة", systemImage: "square.and.arrow.up")
                        .font(.subheadline.weight(.semibold))
                        .frame(minHeight: 30)
                }
                .buttonStyle(.glass)
            }
        }
        .padding(Spacing.cardLarge)
        .glassEffect(.regular, in: .card)
    }
}
