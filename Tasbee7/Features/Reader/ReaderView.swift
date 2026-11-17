//
//  ReaderView.swift
//  Tasbee7
//
//  One chapter: every dhikr in its own glass card, in the reader's chosen font and size.
//

import SwiftUI
import UIKit

struct ReaderView: View {
    let title: String

    @Environment(AthkarRepository.self) private var repository
    @Environment(FavoritesStore.self) private var favorites
    @Environment(ReadingPreferences.self) private var reading

    @State private var toastMessage: String?

    var body: some View {
        ScrollView {
            if let section = repository.section(titled: title) {
                LazyVStack(alignment: .leading, spacing: Spacing.grid) {
                    header(for: section)
                        .padding(.bottom, Spacing.grid)

                    ForEach(section.athkar) { dhikr in
                        DhikrCard(
                            dhikr: dhikr,
                            position: dhikr.id + 1,
                            total: section.athkar.count,
                            onCopy: { copy(dhikr.text) }
                        )
                    }
                }
                .padding(Spacing.screen)
            } else {
                StateCard(
                    systemImage: "book.closed",
                    title: "الباب غير موجود",
                    message: "ربما تغيّر عنوانه في تحديث. ابحث عنه من جديد."
                )
                .padding(Spacing.screen)
            }
        }
        .softScroll()
        .readableContentMargins()
        .plainBackground()
        .navigationTitle(title)
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                ReaderFontMenu()
                FavoriteToolbarButton(title: title)
            }
        }
        .toast($toastMessage)
    }

    private func header(for section: AthkarSection) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let group = section.groupName {
                Text(group)
                    .textRole(.eyebrow)
                    .foregroundStyle(.accent)
            }
            Text(section.title)
                .textRole(.title2)
                .fixedSize(horizontal: false, vertical: true)
            Text(ArabicNoun.dhikr.count(section.athkar.count))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }

    private func copy(_ text: String) {
        UIPasteboard.general.string = text
        toastMessage = "تم النسخ"
    }
}

private struct FavoriteToolbarButton: View {
    let title: String
    @Environment(FavoritesStore.self) private var favorites

    var body: some View {
        let isFavorite = favorites.isFavorite(title)
        Button {
            favorites.toggle(title)
        } label: {
            Label(isFavorite ? "إزالة من المفضلة" : "إضافة إلى المفضلة",
                  systemImage: isFavorite ? "star.fill" : "star")
                .contentTransition(.symbolEffect(.replace))
        }
        .sensoryFeedback(.selection, trigger: isFavorite)
    }
}

#Preview {
    NavigationStack {
        ReaderView(title: AthkarCatalog.morningEveningTitle)
    }
    .environment(AthkarRepository())
    .environment(FavoritesStore())
    .environment(ReadingPreferences())
}
