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

    private static let key = "recentSearches"
    private static let limit = 10

    private(set) var queries: [String]

    private init() {
        queries = UserDefaults.standard.data(forKey: Self.key)
            .flatMap { try? JSONDecoder().decode([String].self, from: $0) } ?? []
    }

    func add(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        queries.removeAll { ArabicText.normalize($0) == ArabicText.normalize(trimmed) }
        queries.insert(trimmed, at: 0)
        queries = Array(queries.prefix(Self.limit))
        save()
    }

    func remove(_ query: String) {
        queries.removeAll { $0 == query }
        save()
    }

    func clear() {
        queries = []
        save()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(queries) {
            UserDefaults.standard.set(data, forKey: Self.key)
        }
    }
}
