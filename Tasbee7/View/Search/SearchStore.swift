//
//  SearchStore.swift
//  Tasbee7
//
//  Manages recent searches
//

import Foundation
import Observation

@MainActor
@Observable
final class SearchStore {
    static let shared = SearchStore()

    private let recentSearchesKey = "recentSearches"
    private let maxRecentSearches = 10
    private let lastSearchQueryKey = "lastSearchQuery"
    private let lastSearchSectionKey = "lastSearchSection"

    var recentSearches: [String] = []
    var lastSearchQuery: String = ""
    var lastSearchSection: String? = nil

    private init() {
        loadRecentSearches()
        loadLastSearch()
    }

    private func loadRecentSearches() {
        guard let data = UserDefaults.standard.data(forKey: recentSearchesKey),
              let searches = try? JSONDecoder().decode([String].self, from: data) else {
            recentSearches = []
            return
        }
        recentSearches = searches
    }

    private func saveRecentSearches() {
        if let data = try? JSONEncoder().encode(recentSearches) {
            UserDefaults.standard.set(data, forKey: recentSearchesKey)
        }
    }

    private func loadLastSearch() {
        lastSearchQuery = UserDefaults.standard.string(forKey: lastSearchQueryKey) ?? ""
        lastSearchSection = UserDefaults.standard.string(forKey: lastSearchSectionKey)
    }

    private func saveLastSearch() {
        UserDefaults.standard.set(lastSearchQuery, forKey: lastSearchQueryKey)
        UserDefaults.standard.set(lastSearchSection, forKey: lastSearchSectionKey)
    }

    func addRecentSearch(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        var searches = recentSearches
        searches.removeAll { $0 == trimmed }
        searches.insert(trimmed, at: 0)
        if searches.count > maxRecentSearches {
            searches = Array(searches.prefix(maxRecentSearches))
        }
        recentSearches = searches
        saveRecentSearches()
    }

    func removeRecentSearch(_ query: String) {
        recentSearches.removeAll { $0 == query }
        saveRecentSearches()
    }

    func clearRecentSearches() {
        recentSearches = []
        saveRecentSearches()
    }

    func setLastSearch(query: String, section: String?) {
        lastSearchQuery = query
        lastSearchSection = section
        saveLastSearch()
    }
}
