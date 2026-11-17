//
//  FavoritesRow.swift
//  Tasbee7
//
//  Starred chapters as square glass tiles in a sideways row that snaps.
//

import SwiftUI

struct FavoritesRow: View {
    let sections: [AthkarSection]

    @ScaledMetric(relativeTo: .title3) private var side: CGFloat = 176

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "المفضلة")

            ScrollView(.horizontal) {
                GlassEffectContainer(spacing: 0) {
                    LazyHStack(spacing: Spacing.grid) {
                        ForEach(sections) { section in
                            NavigationLink(value: AthkarRoute.section(section.title)) {
                                FavoriteTile(section: section, side: side)
                            }
                            .buttonStyle(.card)
                        }
                    }
                    .scrollTargetLayout()
                }
            }
            .scrollTargetBehavior(.viewAligned)
            .softScroll()
            .scrollClipDisabled()
        }
    }
}

private struct FavoriteTile: View {
    let section: AthkarSection
    let side: CGFloat

    private var systemImage: String {
        section.groupName.flatMap(AthkarCatalog.group(named:))?.systemImage ?? "star.fill"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Artwork(systemImage: systemImage, symbolSize: 30, cornerRadius: 16)
                .frame(width: 56, height: 56)
            Spacer(minLength: 8)
            Text(section.title)
                .font(.headline)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
                .lineLimit(3)
                .minimumScaleFactor(0.8)
            Text(ArabicNoun.dhikr.count(section.athkar.count))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .frame(width: side, height: side, alignment: .topLeading)
        .glassEffect(.regular, in: .card)
        .contentShape(.rect(cornerRadius: Radius.card, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}
