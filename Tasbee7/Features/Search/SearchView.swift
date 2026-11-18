//
//  SearchView.swift
//  Tasbee7
//
//  Search every title and dhikr. Ignores tashkeel and hamza forms, so "اذكار" finds "أَذْكَار".
//

import SwiftUI

struct SearchView: View {
    @Environment(AthkarRepository.self) private var repository
    @Bindable private var router = AppRouter.shared

    @State private var query = ""
    @State private var group: String?
    @State private var results: [SearchResult] = []
    @State private var searchedQuery = ""

    private let history = SearchHistoryStore.shared

    private var isSearching: Bool {
        !ArabicText.normalize(query).isEmpty
    }

    var body: some View {
        NavigationStack(path: $router.searchPath) {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.section) {
                    GroupFilter(groups: repository.groupNames, selection: $group)

                    if isSearching {
                        SearchResultsList(results: results, query: searchedQuery)
                    } else {
                        RecentSearches(history: history) { query = $0 }
                        Suggestions { query = $0 }
                    }
                }
                .padding(Spacing.screen)
            }
            .softScroll()
            .readableContentMargins()
            .skyBackground()
            .navigationTitle("البحث")
            .toolbarTitleDisplayMode(.inlineLarge)
            .searchable(text: $query, prompt: "ابحث في الأذكار")
            .onSubmit(of: .search) { remember() }
            .task(id: SearchKey(query: query, group: group)) {
                // A short pause so typing stays smooth.
                try? await Task.sleep(for: .milliseconds(180))
                guard !Task.isCancelled else { return }
                results = SearchEngine(sections: repository.sections).results(for: query, inGroup: group)
                searchedQuery = query
            }
            .onChange(of: router.searchPath.count) { old, new in
                if new > old { remember() }
            }
            .athkarDestinations(path: router.searchPath)
        }
    }

    private func remember() {
        guard isSearching, !results.isEmpty else { return }
        history.add(query)
    }
}

private struct SearchKey: Equatable {
    let query: String
    let group: String?
}

/// "All" plus every group, as chips in a sideways row.
private struct GroupFilter: View {
    let groups: [String]
    @Binding var selection: String?

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                FilterChip(title: "الكل", isSelected: selection == nil) {
                    selection = nil
                }
                ForEach(groups, id: \.self) { group in
                    FilterChip(title: group, isSelected: selection == group) {
                        selection = selection == group ? nil : group
                    }
                }
            }
        }
        .softScroll()
        .scrollClipDisabled()
    }
}

private struct SearchResultsList: View {
    let results: [SearchResult]
    let query: String

    var body: some View {
        if results.isEmpty {
            ContentUnavailableView.search(text: query)
        } else {
            VStack(alignment: .leading, spacing: 12) {
                Text(ArabicNoun.result.count(results.count))
                    .textRole(.meta)
                    .foregroundStyle(.secondary)

                LazyVStack(spacing: Spacing.grid) {
                    ForEach(results) { result in
                        NavigationLink(value: AthkarRoute.section(result.section.title)) {
                            SearchResultCard(result: result, query: query)
                        }
                        .buttonStyle(.card)
                    }
                }
            }
        }
    }
}

private struct SearchResultCard: View {
    let result: SearchResult
    let query: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let group = result.section.groupName {
                Text(group)
                    .textRole(.eyebrow)
                    .foregroundStyle(.accent)
            }
            Text(highlighted(result.section.title))
                .font(.headline)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
            if let snippet = result.snippet {
                Text(highlighted(snippet))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
            }
        }
        .padding(Spacing.cardLarge)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: .card)
        .contentShape(.rect(cornerRadius: Radius.card, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    /// The matching words in the accent colour and bold, even when the text has tashkeel.
    private func highlighted(_ text: String) -> AttributedString {
        var attributed = AttributedString(text)
        for range in ArabicText.ranges(of: query, in: text) {
            guard let attributedRange = Range(range, in: attributed) else { continue }
            attributed[attributedRange].foregroundColor = Color.accent
            attributed[attributedRange].inlinePresentationIntent = .stronglyEmphasized
        }
        return attributed
    }
}

/// Recent searches in one glass card. Long-press to remove one; clear all after a confirmation.
private struct RecentSearches: View {
    let history: SearchHistoryStore
    let apply: (String) -> Void

    @State private var confirmsClear = false

    var body: some View {
        if !history.queries.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    SectionHeader(title: "عمليات البحث الأخيرة")
                    Spacer()
                    Button("مسح") { confirmsClear = true }
                        .font(.subheadline.weight(.semibold))
                        .confirmationDialog("مسح كل عمليات البحث الأخيرة؟", isPresented: $confirmsClear, titleVisibility: .visible) {
                            Button("مسح الكل", role: .destructive, action: history.clear)
                        }
                }

                VStack(spacing: 0) {
                    ForEach(Array(history.queries.enumerated()), id: \.element) { index, query in
                        if index > 0 {
                            Divider().padding(.leading, 52)
                        }
                        Button {
                            apply(query)
                        } label: {
                            HStack(spacing: Spacing.grid) {
                                Image(systemName: "clock.arrow.circlepath")
                                    .foregroundStyle(.secondary)
                                    .frame(width: 28)
                                    .accessibilityHidden(true)
                                Text(query)
                                    .foregroundStyle(.primary)
                                Spacer(minLength: 0)
                            }
                            .padding(Spacing.card)
                            .frame(minHeight: Spacing.rowMinHeight)
                            .contentShape(.rect)
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button("إزالة", systemImage: "trash", role: .destructive) {
                                history.remove(query)
                            }
                        }
                    }
                }
                .glassEffect(.regular, in: .card)
            }
        }
    }
}

private struct Suggestions: View {
    let apply: (String) -> Void

    private let examples = ["أذكار الصباح", "الاستغفار", "دعاء السفر", "الكرب", "النوم"]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "جرّب")
            FlowingChips(items: examples, apply: apply)
        }
    }
}

private struct FlowingChips: View {
    let items: [String]
    let apply: (String) -> Void

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(items, id: \.self) { item in
                    FilterChip(title: item, isSelected: false) { apply(item) }
                }
            }
        }
        .softScroll()
        .scrollClipDisabled()
    }
}

#Preview {
    SearchView()
        .environment(AthkarRepository())
        .environment(FavoritesStore())
        .environment(ReadingPreferences())
}
