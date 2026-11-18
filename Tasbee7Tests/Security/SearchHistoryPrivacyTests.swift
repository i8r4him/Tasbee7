//
//  SearchHistoryPrivacyTests.swift
//  Tasbee7Tests
//
//  Recent searches are personal. Only a few are kept, and clearing them really removes them.
//

import Foundation
import Testing
@testable import Tasbee7

@MainActor
@Suite("Security: search history privacy")
struct SearchHistoryPrivacyTests {
    private let storage = IsolatedDefaults()
    private var defaults: UserDefaults { storage.defaults }

    @Test("Clearing removes the stored copy, not just the list on screen")
    func clearRemovesStoredData() {
        let history = SearchHistoryStore(defaults: defaults)
        history.add("أذكار النوم")
        #expect(defaults.data(forKey: SearchHistoryStore.key) != nil)

        history.clear()
        #expect(history.queries.isEmpty)
        #expect(defaults.object(forKey: SearchHistoryStore.key) == nil)
        #expect(SearchHistoryStore(defaults: defaults).queries.isEmpty)
    }

    @Test("Removing one search removes it from storage too")
    func removeIsPersisted() {
        let history = SearchHistoryStore(defaults: defaults)
        history.add("الصباح")
        history.add("المساء")
        history.remove("الصباح")
        #expect(SearchHistoryStore(defaults: defaults).queries == ["المساء"])
    }

    @Test("At most ten searches are kept")
    func historyIsCapped() {
        let history = SearchHistoryStore(defaults: defaults)
        for index in 0..<50 { history.add("بحث \(index)") }
        #expect(history.queries.count == SearchHistoryStore.limit)
        #expect(SearchHistoryStore(defaults: defaults).queries.count == SearchHistoryStore.limit)
    }

    @Test("Blank and oversized text isn't stored")
    func junkIsNotStored() {
        let history = SearchHistoryStore(defaults: defaults)
        history.add("   ")
        history.add(String(repeating: "ب", count: SearchHistoryStore.maxQueryLength + 1))
        #expect(history.queries.isEmpty)
        #expect(defaults.object(forKey: SearchHistoryStore.key) == nil)
    }

    @Test("A tampered stored history is trimmed on load")
    func tamperedHistoryIsTrimmed() throws {
        let stored = [""] + [String(repeating: "x", count: 5_000)] + (0..<100).map { "بحث \($0)" }
        defaults.set(try JSONEncoder().encode(stored), forKey: SearchHistoryStore.key)
        let history = SearchHistoryStore(defaults: defaults)
        #expect(history.queries.count == SearchHistoryStore.limit)
        #expect(history.queries.allSatisfy { !$0.isEmpty && $0.count <= SearchHistoryStore.maxQueryLength })
    }

    @Test("Corrupted stored history is ignored")
    func corruptedHistoryIsIgnored() {
        defaults.set(Data("{not json".utf8), forKey: SearchHistoryStore.key)
        #expect(SearchHistoryStore(defaults: defaults).queries.isEmpty)
    }
}
