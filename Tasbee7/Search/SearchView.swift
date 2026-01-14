//
//  SearchView.swift
//  Tasbee7
//
//  Created by Ibrahim Abdullah on 06.11.25.
//

import SwiftUI

struct SearchView: View {
    @State private var searchText: String = ""
    @State private var selectedSection: String? = nil
    
    private let cache = AthkarCache.shared
    @State private var searchStore = SearchStore.shared
    @AppStorage(AppTheme.storageKey) private var themeColorRaw: String = ThemeColor.أزرق.rawValue
    
    private var themeColor: Color {
        (ThemeColor(rawValue: themeColorRaw) ?? .أزرق).color
    }
    
    // Get unique sections from all athkars
    private var availableSections: [String] {
        let allSections = Set(cache.sections.compactMap { section in
            AthkarIndex.sectionMap[section.title]
        })
        return Array(allSections).sorted()
    }
    
    // Computed property for filtered results
    private var filteredResults: [AthkarSection] {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
            return []
        }
        
        let query = searchText.lowercased().trimmingCharacters(in: .whitespaces)
        
        // Search in titles and content
        var results = cache.sections.filter { section in
            // Search in title
            let titleMatch = section.title.lowercased().contains(query)
            
            // Search in text content
            let contentMatch = section.text.joined(separator: " ").lowercased().contains(query)
            
            return titleMatch || contentMatch
        }
        
        // Filter by selected section if any
        if let selectedSection = selectedSection {
            results = results.filter { section in
                AthkarIndex.sectionMap[section.title] == selectedSection
            }
        }
        
        // Sort by relevance (title matches first)
        results.sort { section1, section2 in
            let title1Match = section1.title.lowercased().contains(query)
            let title2Match = section2.title.lowercased().contains(query)
            
            if title1Match && !title2Match {
                return true
            } else if !title1Match && title2Match {
                return false
            }
            return section1.title < section2.title
        }
        
        return results
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if searchText.isEmpty {
                    // Recent Searches
                    if !searchStore.recentSearches.isEmpty {
                        List {
                            Section {
                                ForEach(searchStore.recentSearches, id: \.self) { query in
                                    Button {
                                        searchText = query
                                    } label: {
                                        HStack {
                                            Image(systemName: "clock.arrow.circlepath")
                                                .foregroundStyle(.secondary)
                                            Text(query)
                                            Spacer()
                                        }
                                    }
                                    .listRowBackground(Color.clear)
                                }
                            } header: {
                                HStack {
                                    Text("البحث الأخير")
                                    Spacer()
                                    Button("مسح الكل") {
                                        searchStore.clearRecentSearches()
                                    }
                                    .font(.caption)
                                    .foregroundStyle(themeColor)
                                }
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    } else {
                        ContentUnavailableView(
                            "ابحث في الأذكار",
                            systemImage: "magnifyingglass",
                            description: Text("اكتب للبحث في العناوين والمحتوى")
                        )
                    }
                } else {
                    // Search Results
                    if filteredResults.isEmpty {
                        ContentUnavailableView(
                            "لا توجد نتائج",
                            systemImage: "magnifyingglass",
                            description: Text("جرب البحث بكلمات مختلفة")
                        )
                    } else {
                        List {
                            ForEach(filteredResults) { section in
                                NavigationLink(value: section) {
                                    SearchResultRow(section: section, searchText: searchText)
                                }
                                .listRowBackground(Color.clear)
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("البحث")
            .toolbarTitleDisplayMode(.inlineLarge)
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .automatic),
                prompt: "ابحث في الأذكار..."
            )
            .onSubmit(of: .search) {
                if !searchText.isEmpty && !filteredResults.isEmpty {
                    searchStore.addRecentSearch(searchText)
                }
            }
            .toolbar {
                // Section Filter (if searching)
                if !searchText.isEmpty && !availableSections.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Button {
                                selectedSection = nil
                            } label: {
                                HStack {
                                    Text("الكل")
                                    if selectedSection == nil {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                            
                            ForEach(availableSections, id: \.self) { section in
                                Button {
                                    selectedSection = selectedSection == section ? nil : section
                                } label: {
                                    HStack {
                                        Text(section)
                                        if selectedSection == section {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .foregroundStyle(themeColor)
                        }
                    }
                }
            }
            .gradientBackground(
                startColor: themeColor.opacity(0.3),
                endColor: .clear
            )
            .navigationDestination(for: AthkarSection.self) { section in
                AthkarDetailView(
                    title: section.title,
                    textItems: section.text,
                    footnotes: section.footnote
                )
            }
        }
    }
    
}

// MARK: - Search Result Row
struct SearchResultRow: View {
    let section: AthkarSection
    let searchText: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(section.title)
                .font(.headline)
                .foregroundStyle(.primary)
            
            // Show matching text snippet
            if let matchingText = findMatchingText(in: section.text) {
                Text(matchingText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            
            // Show section name if available
            if let sectionName = AthkarIndex.sectionMap[section.title] {
                Text(sectionName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                    )
            }
        }
        .padding(.vertical, 4)
    }
    
    private func findMatchingText(in texts: [String]) -> String? {
        let query = searchText.lowercased()
        for text in texts {
            if text.lowercased().contains(query) {
                // Return first 100 characters
                let snippet = String(text.prefix(100))
                return snippet + (text.count > 100 ? "..." : "")
            }
        }
        return nil
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let themeColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
               
                .overlay(
                    Capsule()
                        .stroke(isSelected ? themeColor : Color.clear, lineWidth: 1.5)
                )
                .foregroundStyle(isSelected ? themeColor : .primary)
        }
    }
}

#Preview {
    SearchView()
        .environment(FavoritesStore())
}
