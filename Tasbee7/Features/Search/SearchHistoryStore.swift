//
//  SearchHistoryStore.swift
//  Tasbee7
//

import Foundation
import Observation

/// The last ten searches that found something. Same storage key as before.
@Observable
final class SearchHistoryStore {
    static let shared = SearchHistoryStore()

    static let key = "recentSearches"
    static let limit = 10
    /// Longer text isn't a search anyone typed; it isn't kept.
    static let maxQueryLength = 100

    private let defaults: UserDefaults
    private(set) var queries: [String]

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let stored = defaults.data(forKey: Self.key)
            .flatMap { try? JSONDecoder().decode([String].self, from: $0) } ?? []
        queries = Array(stored.filter { !$0.isEmpty && $0.count <= Self.maxQueryLength }.prefix(Self.limit))
    }

    func add(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed.count <= Self.maxQueryLength else { return }
        queries.removeAll { ArabicText.normalize($0) == ArabicText.normalize(trimmed) }
        queries.insert(trimmed, at: 0)
        queries = Array(queries.prefix(Self.limit))
        save()
    }

    func remove(_ query: String) {
        queries.removeAll { $0 == query }
        save()
    }

    /// Forgets every search, including the stored copy.
    func clear() {
        queries = []
        defaults.removeObject(forKey: Self.key)
    }

    private func save() {
        if let data = try? JSONEncoder().encode(queries) {
            defaults.set(data, forKey: Self.key)
        }
    }
}
