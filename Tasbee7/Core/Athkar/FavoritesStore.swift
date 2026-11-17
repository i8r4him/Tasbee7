//
//  FavoritesStore.swift
//  Tasbee7
//

import Foundation
import Observation

/// The chapters the user starred, by title. Kept in the same storage key as before, so nobody loses favourites.
@Observable
final class FavoritesStore {
    private static let key = "favoriteTitles"
    private let defaults: UserDefaults

    private(set) var titles: Set<String>

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.string(forKey: Self.key)?.data(using: .utf8),
           let stored = try? JSONDecoder().decode([String].self, from: data) {
            titles = Set(stored)
        } else {
            titles = []
        }
    }

    func isFavorite(_ title: String) -> Bool {
        titles.contains(title)
    }

    func toggle(_ title: String) {
        if titles.contains(title) {
            titles.remove(title)
        } else {
            titles.insert(title)
        }
        save()
    }

    /// Favourites in book order.
    func sections(in repository: AthkarRepository) -> [AthkarSection] {
        titles
            .compactMap { repository.section(titled: $0) }
            .sorted { AthkarCatalog.order(of: $0.title) < AthkarCatalog.order(of: $1.title) }
    }

    private func save() {
        let sorted = titles.sorted()
        if let data = try? JSONEncoder().encode(sorted), let string = String(data: data, encoding: .utf8) {
            defaults.set(string, forKey: Self.key)
        }
    }
}
