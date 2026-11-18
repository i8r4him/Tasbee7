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
    /// When set, each dhikr can be ticked for this daily sitting, and the reader opens at the first open one.
    var sitting: DailyKey?

    @Environment(AthkarRepository.self) private var repository
    @Environment(FavoritesStore.self) private var favorites
    @Environment(ReadingPreferences.self) private var reading
    @Environment(\.reducesMotion) private var reduceMotion

    @State private var toastMessage: String?
    @State private var scrolledToStart = false
    private let progress = DailyProgressStore.shared

    var body: some View {
        ScrollViewReader { proxy in
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
                                isDone: sitting.map { progress.isDone(dhikr.id, in: $0) },
                                onToggle: { tick(dhikr, in: section, proxy: proxy) },
                                onCopy: { copy(dhikr.text) }
                            )
                            .id(dhikr.id)
                        }
                    }
                    .padding(Spacing.screen)
                    .task {
                        continueWhereLeft(in: section, proxy: proxy)
                    }
                } else {
                    StateCard(
                        systemImage: "book.closed",
                        title: "الباب غير موجود",
                        message: "ربما تغيّر عنوانه في تحديث. ابحث عنه من جديد."
                    )
                    .padding(Spacing.screen)
                }
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
            if let sitting {
                let done = progress.doneCount(in: sitting, total: section.athkar.count)
                Text("\(sitting.kind.title) · \(done.formatted()) من \(section.athkar.count.formatted())")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(Motion.easeOut(duration: 0.25), value: done)
            } else {
                Text(ArabicNoun.dhikr.count(section.athkar.count))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }

    /// Opens at the first dhikr not ticked yet, once.
    private func continueWhereLeft(in section: AthkarSection, proxy: ScrollViewProxy) {
        guard !scrolledToStart, let sitting else { return }
        scrolledToStart = true
        guard let first = progress.firstOpen(in: sitting, total: section.athkar.count), first > 0 else { return }
        proxy.scrollTo(first, anchor: .top)
    }

    /// Ticks or unticks a dhikr; after a tick, moves on to the next open one. Finishing the sitting shows a toast.
    private func tick(_ dhikr: Dhikr, in section: AthkarSection, proxy: ScrollViewProxy) {
        guard let sitting else { return }
        let wasDone = progress.isDone(dhikr.id, in: sitting)
        progress.toggle(dhikr.id, in: sitting)
        guard !wasDone else { return }

        if let next = progress.firstOpen(in: sitting, total: section.athkar.count) {
            if next > dhikr.id {
                withAnimation(Motion.push(reduceMotion: reduceMotion)) {
                    proxy.scrollTo(next, anchor: .top)
                }
            }
        } else {
            toastMessage = "أتممت \(sitting.kind.title)، تقبّل الله منك"
        }
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
        ReaderView(title: AthkarCatalog.morningEveningTitle, sitting: TodayContext.currentSitting())
    }
    .environment(AthkarRepository())
    .environment(FavoritesStore())
    .environment(ReadingPreferences())
}
