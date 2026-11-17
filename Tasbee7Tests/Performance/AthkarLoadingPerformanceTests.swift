//
//  AthkarLoadingPerformanceTests.swift
//  Tasbee7Tests
//
//  The book is read on launch, so its cost is launch time.
//

import XCTest
@testable import Tasbee7

@MainActor
final class AthkarLoadingPerformanceTests: XCTestCase {
    func testLoadBookFromBundle() throws {
        let sections = try AthkarLoader.load()
        XCTAssertGreaterThan(sections.count, 100, "The book should have all its chapters")

        measure(metrics: [XCTClockMetric(), XCTCPUMetric(), XCTMemoryMetric()]) {
            _ = try? AthkarLoader.load()
        }
    }

    func testLoadBookStaysWithinBudget() throws {
        try assertMedianTime(under: Budget.loadBook, "Loading the book") {
            _ = try AthkarLoader.load()
        }
    }

    func testBuildRepository() {
        let repository = AthkarRepository()
        guard case .loaded = repository.state else {
            return XCTFail("The repository should load the bundled book")
        }

        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            _ = AthkarRepository()
        }
    }

    func testBuildRepositoryStaysWithinBudget() {
        assertMedianTime(under: Budget.buildRepository, "Building the repository") {
            _ = AthkarRepository()
        }
    }

    /// Opening a chapter or a group happens on every tap, so lookups must be instant.
    func testChapterAndGroupLookups() {
        let repository = AthkarRepository()
        let titles = repository.sections.map(\.title)
        let groupNames = repository.groupNames

        measure {
            for _ in 0..<100 {
                for title in titles { _ = repository.section(titled: title) }
                for name in groupNames { _ = repository.group(named: name) }
            }
        }
    }

    /// The favourites row sorts in book order on every change. Worst case: every chapter starred.
    func testFavoritesInBookOrderWithEveryChapterStarred() throws {
        let suite = "perf.favorites.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }

        let repository = AthkarRepository()
        let favorites = FavoritesStore(defaults: defaults)
        for section in repository.sections { favorites.toggle(section.title) }
        XCTAssertEqual(favorites.sections(in: repository).count, repository.sections.count)

        measure {
            for _ in 0..<50 { _ = favorites.sections(in: repository) }
        }
    }
}
