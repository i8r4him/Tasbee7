//
//  CategoryView.swift
//  Tasbee7
//
//  The chapters of one group, as rows in a single glass card.
//

import SwiftUI

struct CategoryView: View {
    let groupName: String

    @Environment(AthkarRepository.self) private var repository
    @Environment(FavoritesStore.self) private var favorites

    var body: some View {
        ScrollView {
            if let group = repository.group(named: groupName) {
                VStack(alignment: .leading, spacing: Spacing.section) {
                    header(for: group)
                    chapterList(group.sections)
                }
                .padding(Spacing.screen)
            } else {
                StateCard(
                    systemImage: "questionmark.folder",
                    title: "القسم غير موجود",
                    message: "ربما تغيّر اسمه في تحديث. ارجع إلى الأقسام واختره من جديد."
                )
                .padding(Spacing.screen)
            }
        }
        .softScroll()
        .readableContentMargins()
        .plainBackground()
        .navigationTitle(groupName)
        .toolbarTitleDisplayMode(.inline)
    }

    private func header(for group: AthkarRepository.Group) -> some View {
        HStack(alignment: .center, spacing: 16) {
            Artwork(systemImage: group.catalog.systemImage, symbolSize: 34, cornerRadius: 18)
                .frame(width: 72, height: 72)
            VStack(alignment: .leading, spacing: 4) {
                Text(group.catalog.name)
                    .textRole(.title2)
                Text(ArabicNoun.chapter.count(group.sections.count))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private func chapterList(_ sections: [AthkarSection]) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(sections.enumerated()), id: \.element.id) { index, section in
                if index > 0 {
                    Divider().padding(.leading, 62)
                }
                NavigationLink(value: AthkarRoute.section(section.title)) {
                    ChapterRow(
                        number: index + 1,
                        section: section,
                        isFavorite: favorites.isFavorite(section.title)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .glassEffect(.regular, in: .card)
    }
}

private struct ChapterRow: View {
    let number: Int
    let section: AthkarSection
    let isFavorite: Bool

    var body: some View {
        HStack(spacing: Spacing.grid) {
            Text(number.formatted())
                .font(.headline.monospacedDigit())
                .foregroundStyle(.accent)
                .frame(width: 34, height: 34)
                .background(.accent.opacity(0.10), in: .rect(cornerRadius: Radius.tile, style: .continuous))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(section.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                Text(ArabicNoun.dhikr.count(section.athkar.count))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            if isFavorite {
                Image(systemName: "star.fill")
                    .font(.footnote)
                    .foregroundStyle(.accent)
                    .accessibilityLabel("في المفضلة")
            }

            Image(systemName: "chevron.forward")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)
        }
        .padding(Spacing.card)
        .frame(minHeight: Spacing.rowMinHeight)
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
    }
}
