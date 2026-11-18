//
//  DayTextCard.swift
//  Tasbee7
//
//  A glass card for a text of the day (ayah, dua): a tag in the theme colour, the text in the reading font,
//  where it comes from, and a share button.
//

import SwiftUI

struct DayTextCard: View {
    let tag: String
    let tagSymbol: String
    let text: String
    let reference: String
    let shareText: String

    @Environment(ReadingPreferences.self) private var reading
    @ScaledMetric(relativeTo: .body) private var scale: CGFloat = 1

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center) {
                Label(tag, systemImage: tagSymbol)
                    .textRole(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.accent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.accentFill.opacity(0.18), in: .capsule)
                    .accessibilityAddTraits(.isHeader)
                Spacer(minLength: 8)
                ShareLink(item: shareText) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 36, height: 36)
                        .glassEffect(.regular.interactive(), in: .circle)
                        .frame(width: Spacing.minTouchTarget, height: Spacing.minTouchTarget)
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("مشاركة \(tag)")
            }

            Text(verbatim: text)
                .font(reading.font.font(size: (reading.size.baseSize + 1) * scale))
                .lineSpacing(reading.font.lineSpacing * scale)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)

            Text(reference)
                .textRole(.meta)
                .foregroundStyle(.secondary)
        }
        .padding(Spacing.cardLarge)
        .glassEffect(.regular, in: .card)
    }
}
