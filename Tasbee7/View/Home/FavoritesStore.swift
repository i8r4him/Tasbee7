//
//  FavoritesStore.swift
//  Tasbee7
//
//  Created by Assistant on 06.11.25.
//

import SwiftUI
import Observation

@MainActor
@Observable
final class FavoritesStore {
    private let userDefaults = UserDefaults.standard
    private let key = "favoriteTitles"

    private(set) var titles: Set<String> = []

    var allTitles: Set<String> { titles }

    init() {
        load()
    }

    func isFavorite(title: String) -> Bool {
        titles.contains(title)
    }

    func toggle(title: String) {
        if titles.contains(title) {
            titles.remove(title)
        } else {
            titles.insert(title)
        }
        save()
    }

    private func load() {
        if let data = userDefaults.string(forKey: key)?.data(using: .utf8),
           let arr = try? JSONDecoder().decode([String].self, from: data) {
            titles = Set(arr)
        } else {
            titles = []
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(Array(titles)),
           let str = String(data: data, encoding: .utf8) {
            userDefaults.set(str, forKey: key)
        }
    }
}


