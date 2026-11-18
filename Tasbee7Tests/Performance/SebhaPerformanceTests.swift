//
//  SebhaPerformanceTests.swift
//  Tasbee7Tests
//
//  Every tap on the counter saves the counts. Fast tappers do several taps a second,
//  so a tap must cost far less than a frame.
//

import XCTest
@testable import Tasbee7

@MainActor
final class SebhaPerformanceTests: XCTestCase {
    private func makeDefaults() throws -> (UserDefaults, String) {
        let suite = "perf.sebha.\(UUID().uuidString)"
        return (try XCTUnwrap(UserDefaults(suiteName: suite)), suite)
    }

    func testThousandTaps() throws {
        let (defaults, suite) = try makeDefaults()
        defer { defaults.removePersistentDomain(forName: suite) }
        let store = SebhaStore(defaults: defaults)

        measure(metrics: [XCTClockMetric(), XCTCPUMetric(), XCTStorageMetric()]) {
            for _ in 0..<1_000 { store.increment() }
        }
        XCTAssertGreaterThanOrEqual(store.count, 1_000)
    }

    func testOneTapStaysWithinBudget() throws {
        let (defaults, suite) = try makeDefaults()
        defer { defaults.removePersistentDomain(forName: suite) }
        let store = SebhaStore(defaults: defaults)

        // Many phrases with counts make the saved dictionary bigger, as for a long-time user.
        for index in 0..<50 { store.addPhrase("ذكر \(index)") }
        for phrase in store.allPhrases {
            store.select(phrase)
            for _ in 0..<10 { store.increment() }
        }

        assertMedianTime(under: Budget.sebhaTap, runs: 15, "One tap") {
            store.increment()
        }
    }

    /// Opening the Sebha tab reads everything back from storage.
    func testLoadingAStoreWithManyPhrases() throws {
        let (defaults, suite) = try makeDefaults()
        defer { defaults.removePersistentDomain(forName: suite) }
        let seed = SebhaStore(defaults: defaults)
        for index in 0..<200 { seed.addPhrase("ذكر \(index)") }
        for phrase in seed.allPhrases {
            seed.select(phrase)
            seed.increment()
        }

        measure {
            for _ in 0..<20 { _ = SebhaStore(defaults: defaults) }
        }
    }
}
