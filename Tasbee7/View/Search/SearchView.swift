//
//  SearchView.swift
//  Tasbee7
//
//  Created by Ibrahim Abdullah on 06.11.25.
//

import SwiftUI

struct SearchView: View {
    @Environment(AppSettings.self) private var appSettings

    @State private var searchText = ""
    @State private var debouncedText = ""
    @State private var selectedSection: String?
    @State private var results: [AthkarSection] = []
    @State private var searchStore = SearchStore.shared
    @State private var debounceTask: Task<Void, Never>?

    private let cache = AthkarCache.shared

    private var searchEngine: SearchEngine {
        SearchEngine(sections: cache.sections)
    }

    private var trimmedSearchText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var hasActiveSearch: Bool {
        !trimmedSearchText.isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                Group {
                    if hasActiveSearch {
                        SearchResultsContentView(
                            results: results,
                            selectedSection: selectedSection,
                            searchText: debouncedText,
                            themeColor: appSettings.themeColor,
                            snippet: matchingSnippet,
                            clearSection: clearSelectedSection
                        )
                    } else {
                        SearchLandingView(
                            availableSections: searchEngine.availableSections,
                            selectedSection: selectedSection,
                            recentSearches: searchStore.recentSearches,
                            themeColor: appSettings.themeColor,
                            selectSection: toggleSectionFilter,
                            applyRecentSearch: applySearch,
                            removeRecentSearch: { query in
                                searchStore.removeRecentSearch(query)
                            },
                            clearRecentSearches: {
                                searchStore.clearRecentSearches()
                            },
                            applyExampleSearch: applySearch
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("البحث")
            .toolbarTitleDisplayMode(.inlineLarge)
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .automatic),
                prompt: "ابحث في الأذكار..."
            )
            .onAppear(perform: restoreLastSearch)
            .onSubmit(of: .search, persistSearchIfNeeded)
            .onChange(of: searchText) { _, newValue in
                handleSearchTextChange(newValue)
            }
            .onChange(of: debouncedText) { _, newValue in
                updateResults(for: newValue)
            }
            .onChange(of: selectedSection) { _, _ in
                handleSelectedSectionChange()
            }
            .onDisappear {
                debounceTask?.cancel()
            }
            .appGradientBackground()
            .navigationDestination(for: AthkarSection.self) { section in
                AthkarDetailView(
                    title: section.title,
                    textItems: section.text,
                    footnotes: section.footnote
                )
            }
        }
    }

    private func handleSearchTextChange(_ newValue: String) {
        scheduleDebounce(for: newValue)

        if newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            selectedSection = nil
            results = []
        }
    }

    private func handleSelectedSectionChange() {
        updateResults(for: debouncedText)

        guard hasActiveSearch else { return }
        searchStore.setLastSearch(query: trimmedSearchText, section: selectedSection)
    }

    private func toggleSectionFilter(_ section: String?) {
        if selectedSection == section {
            selectedSection = nil
        } else {
            selectedSection = section
        }
    }

    private func clearSelectedSection() {
        selectedSection = nil
    }

    private func applySearch(_ query: String) {
        searchText = query
        debouncedText = query
        updateResults(for: query)
    }

    private func scheduleDebounce(for newValue: String) {
        debounceTask?.cancel()
        debounceTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 250_000_000)
            guard !Task.isCancelled else { return }
            debouncedText = newValue
        }
    }

    private func updateResults(for query: String) {
        results = searchEngine.results(for: query, in: selectedSection)
    }

    private func matchingSnippet(for section: AthkarSection) -> String? {
        searchEngine.snippet(for: section, query: debouncedText)
    }

    private func persistSearchIfNeeded() {
        guard !trimmedSearchText.isEmpty else { return }

        if !results.isEmpty {
            searchStore.addRecentSearch(trimmedSearchText)
        }

        searchStore.setLastSearch(query: trimmedSearchText, section: selectedSection)
    }

    private func restoreLastSearch() {
        guard searchText.isEmpty else { return }

        let lastQuery = searchStore.lastSearchQuery
        guard !lastQuery.isEmpty else { return }

        searchText = lastQuery
        debouncedText = lastQuery
        selectedSection = searchStore.lastSearchSection
        updateResults(for: lastQuery)
    }
}

private struct SearchLandingView: View {
    let availableSections: [String]
    let selectedSection: String?
    let recentSearches: [String]
    let themeColor: Color
    let selectSection: (String?) -> Void
    let applyRecentSearch: (String) -> Void
    let removeRecentSearch: (String) -> Void
    let clearRecentSearches: () -> Void
    let applyExampleSearch: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            QuickSectionFilterView(
                availableSections: availableSections,
                selectedSection: selectedSection,
                themeColor: themeColor,
                selectSection: selectSection
            )
            RecentSearchesSectionView(
                recentSearches: recentSearches,
                themeColor: themeColor,
                applySearch: applyRecentSearch,
                removeSearch: removeRecentSearch,
                clearAll: clearRecentSearches
            )
            SearchExamplesView(applySearch: applyExampleSearch)
        }
    }
}

private struct SearchResultsContentView: View {
    let results: [AthkarSection]
    let selectedSection: String?
    let searchText: String
    let themeColor: Color
    let snippet: (AthkarSection) -> String?
    let clearSection: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let selectedSection {
                HStack(spacing: 10) {
                    ActiveSectionChip(title: selectedSection, clear: clearSection)
                    Spacer()
                }
            }

            HStack {
                Label("النتائج", systemImage: "list.bullet")
                    .font(.headline)
                Spacer()
                Text("\(results.count) نتيجة")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if results.isEmpty {
                ContentUnavailableView(
                    "لا توجد نتائج",
                    systemImage: "magnifyingglass",
                    description: Text("جرب البحث بكلمات مختلفة")
                )
                .padding(.vertical, 24)
            } else {
                VStack(spacing: 12) {
                    ForEach(results) { section in
                        NavigationLink(value: section) {
                            SearchResultRow(
                                title: section.title,
                                snippet: snippet(section),
                                sectionName: AthkarIndex.sectionMap[section.title],
                                searchText: searchText,
                                themeColor: themeColor
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

private struct QuickSectionFilterView: View {
    let availableSections: [String]
    let selectedSection: String?
    let themeColor: Color
    let selectSection: (String?) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("أقسام سريعة", systemImage: "square.grid.2x2")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    FilterChip(
                        title: "الكل",
                        isSelected: selectedSection == nil,
                        themeColor: themeColor
                    ) {
                        selectSection(nil)
                    }

                    ForEach(availableSections, id: \.self) { section in
                        FilterChip(
                            title: section,
                            isSelected: selectedSection == section,
                            themeColor: themeColor
                        ) {
                            selectSection(section)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
}

private struct RecentSearchesSectionView: View {
    let recentSearches: [String]
    let themeColor: Color
    let applySearch: (String) -> Void
    let removeSearch: (String) -> Void
    let clearAll: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("البحث الأخير", systemImage: "clock.arrow.circlepath")
                    .font(.headline)
                Spacer()

                if !recentSearches.isEmpty {
                    Button("مسح الكل", action: clearAll)
                        .font(.caption)
                        .foregroundStyle(themeColor)
                }
            }

            if recentSearches.isEmpty {
                ContentUnavailableView(
                    "لا يوجد بحث سابق",
                    systemImage: "clock",
                    description: Text("ابدأ البحث ليظهر هنا")
                )
                .padding(.vertical, 8)
            } else {
                VStack(spacing: 8) {
                    ForEach(recentSearches, id: \.self) { query in
                        HStack {
                            Button {
                                applySearch(query)
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundStyle(.secondary)
                                    Text(query)
                                    Spacer()
                                }
                            }
                            .buttonStyle(.plain)

                            Button {
                                removeSearch(query)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(12)
                        .glassEffect(.regular.interactive(false), in: RoundedRectangle(cornerRadius: 16))
                    }
                }
            }
        }
    }
}

private struct SearchExamplesView: View {
    let applySearch: (String) -> Void

    private let examples = [
        "أذكار الصباح",
        "الاستغفار",
        "دعاء السفر"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("جرّب هذه الأمثلة", systemImage: "sparkles")
                .font(.headline)

            HStack(spacing: 8) {
                ForEach(examples, id: \.self) { example in
                    ExampleChip(title: example) {
                        applySearch(example)
                    }
                }
            }
        }
    }
}

private struct ActiveSectionChip: View {
    let title: String
    let clear: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.primary)

            Button(action: clear) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.thinMaterial, in: Capsule())
    }
}

private struct SearchResultRow: View {
    let title: String
    let snippet: String?
    let sectionName: String?
    let searchText: String
    let themeColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(highlighted(title, query: searchText))
                .font(.headline)
                .foregroundStyle(.primary)

            if let snippet {
                Text(highlighted(snippet, query: searchText))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            if let sectionName {
                Text(sectionName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial, in: Capsule())
            }
        }
        .padding(14)
        .glassEffect(.regular.interactive(false), in: RoundedRectangle(cornerRadius: 16))
    }

    private func highlighted(_ text: String, query: String) -> AttributedString {
        var attributed = AttributedString(text)
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return attributed }

        let lowerText = text.lowercased()
        let lowerQuery = trimmedQuery.lowercased()
        var searchRange = lowerText.startIndex..<lowerText.endIndex

        while let range = lowerText.range(of: lowerQuery, range: searchRange) {
            if let attributedRange = Range(range, in: attributed) {
                attributed[attributedRange].foregroundColor = themeColor
                attributed[attributedRange].font = .body.bold()
            }

            searchRange = range.upperBound..<lowerText.endIndex
        }

        return attributed
    }
}

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let themeColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background {
                    if isSelected {
                        Capsule()
                            .fill(themeColor.opacity(0.2))
                    } else {
                        Capsule()
                            .fill(Color.clear)
                            .background(.ultraThinMaterial, in: Capsule())
                    }
                }
                .overlay(
                    Capsule()
                        .stroke(isSelected ? themeColor : Color.clear, lineWidth: 1.5)
                )
                .foregroundStyle(isSelected ? themeColor : .primary)
        }
        .buttonStyle(.plain)
    }
}

private struct ExampleChip: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SearchView()
        .environment(FavoritesStore())
        .environment(AppSettings())
}
