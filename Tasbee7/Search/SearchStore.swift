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
    
    var recentSearches: [String] = []
    
    private init() {
        loadRecentSearches()
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
    
    func addRecentSearch(_ query: String) {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        var searches = recentSearches
        // Remove if already exists
        searches.removeAll { $0 == query }
        // Add to beginning
        searches.insert(query, at: 0)
        // Keep only max items
        if searches.count > maxRecentSearches {
            searches = Array(searches.prefix(maxRecentSearches))
        }
        recentSearches = searches
        saveRecentSearches()
    }
    
    func clearRecentSearches() {
        recentSearches = []
        saveRecentSearches()
    }
}

