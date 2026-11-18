//
//  OccasionsCard.swift
//  Tasbee7
//
//  "مناسبة اليوم": Friday, sunnah fasts, the white days, Ramadan and the other special days, as rows in one
//  glass card. A row with a matching chapter opens it.
//

import SwiftUI

struct OccasionsCard: View {
    let occasions: [Occasion]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: occasions.count == 1 ? "مناسبة اليوم" : "مناسبات اليوم")

            VStack(spacing: 0) {
                ForEach(Array(occasions.enumerated()), id: \.element.id) { index, occasion in
                    if index > 0 { Divider().padding(.leading, 62) }
                    if let chapter = occasion.chapterTitle {
                        NavigationLink(value: AthkarRoute.section(chapter)) {
                            OccasionRow(occasion: occasion, opensChapter: true)
                        }
                        .buttonStyle(.plain)
                        .accessibilityHint("يفتح \(chapter).")
                    } else {
                        OccasionRow(occasion: occasion, opensChapter: false)
                    }
                }
            }
            .glassEffect(.regular, in: .card)
        }
    }
}

private struct OccasionRow: View {
    let occasion: Occasion
    let opensChapter: Bool

    var body: some View {
        HStack(alignment: .center, spacing: Spacing.grid) {
            Image(systemName: occasion.systemImage)
                .font(.title3)
                .foregroundStyle(.accent)
                .frame(width: 34, height: 34)
                .background(.accent.opacity(0.10), in: .rect(cornerRadius: Radius.tile, style: .continuous))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 3) {
                Text(occasion.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(occasion.detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if opensChapter {
                Image(systemName: "chevron.forward")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
        }
        .padding(Spacing.card)
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
    }
}
