//
//  CategoryGrid.swift
//  Tasbee7
//
//  Every group of the book as a glass tile, two to a row.
//

import SwiftUI

struct CategoryGrid: View {
    let groups: [AthkarRepository.Group]

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.grid, alignment: .top),
        GridItem(.flexible(), spacing: Spacing.grid, alignment: .top)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "الأقسام")

            GlassEffectContainer(spacing: 0) {
                LazyVGrid(columns: columns, spacing: Spacing.grid) {
                    ForEach(groups) { group in
                        NavigationLink(value: group.route) {
                            CategoryTile(group: group)
                        }
                        .buttonStyle(.tile)
                    }
                }
            }
        }
    }
}

private struct CategoryTile: View {
    let group: AthkarRepository.Group

    @ScaledMetric(relativeTo: .headline) private var artworkSize: CGFloat = 52
    @ScaledMetric(relativeTo: .headline) private var minHeight: CGFloat = 150

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Artwork(systemImage: group.catalog.systemImage, symbolSize: 26, cornerRadius: 15)
                .frame(width: artworkSize, height: artworkSize)
            Spacer(minLength: 10)
            Text(group.catalog.name)
                .font(.headline)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            Text(ArabicNoun.chapter.count(group.sections.count))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(Spacing.card)
        .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .topLeading)
        .glassEffect(.regular, in: .card)
        .contentShape(.rect(cornerRadius: Radius.card, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}
