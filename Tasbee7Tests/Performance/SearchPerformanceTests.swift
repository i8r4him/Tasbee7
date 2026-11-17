//
//  SearchPerformanceTests.swift
//  Tasbee7Tests
//
//  Search runs on the main thread on every keystroke, over every dhikr in the book,
//  with Arabic folding (tashkeel, hamza, alef forms). These keep typing smooth.
//

import XCTest
@testable import Tasbee7

@MainActor
final class SearchPerformanceTests: XCTestCase {
    private static let sections: [AthkarSection] = (try? AthkarLoader.load()) ?? []

    private var engine: SearchEngine {
        SearchEngine(sections: Self.sections)
    }

    private var allText: [String] {
        Self.sections.flatMap { $0.athkar.map(\.text) }
    }

    func testBookIsLoaded() {
        XCTAssertFalse(Self.sections.isEmpty, "The book must load for the search numbers to mean anything")
    }

    /// "الله" is in almost every dhikr: the most results and the most snippets to cut.
    func testSearchWorstCaseCommonWord() {
        XCTAssertGreaterThan(engine.results(for: "الله").count, 50)

        measure(metrics: [XCTClockMetric(), XCTCPUMetric(), XCTMemoryMetric()]) {
            _ = engine.results(for: "الله")
        }
    }

    func testSearchWorstCaseStaysWithinBudget() {
        let engine = engine
        assertMedianTime(under: Budget.searchWorstCase, "Searching for الله") {
            _ = engine.results(for: "الله")
        }
    }

    /// A query with no match still folds and scans the whole book.
    func testSearchWithNoMatch() {
        XCTAssertTrue(engine.results(for: "كلمةغيرموجودة").isEmpty)

        measure {
            _ = engine.results(for: "كلمةغيرموجودة")
        }
    }

    /// Full tashkeel in the query, matched against text with different tashkeel and hamza forms.
    func testSearchWithTashkeelAndHamza() {
        measure {
            _ = engine.results(for: "أَسْتَغْفِرُ")
            _ = engine.results(for: "اذكار")
        }
    }

    func testSearchFilteredToOneGroup() {
        let group = AthkarCatalog.groups[1].name
        measure {
            _ = engine.results(for: "الله", inGroup: group)
        }
    }

    /// Search-as-you-type: every prefix of a word, as the user types it letter by letter.
    func testSearchAsYouType() {
        let word = "سبحان الله وبحمده"
        let prefixes = (1...word.count).map { String(word.prefix($0)) }

        measure {
            for prefix in prefixes { _ = engine.results(for: prefix) }
        }
    }

    func testEachKeystrokeStaysWithinBudget() {
        let engine = engine
        let word = "سبحان الله وبحمده"
        for length in 1...word.count {
            let prefix = String(word.prefix(length))
            assertMedianTime(under: Budget.searchKeystroke, runs: 3, "Keystroke “\(prefix)”") {
                _ = engine.results(for: prefix)
            }
        }
    }

    /// The reader highlights matches in every visible dhikr. Worst case: highlight all of them.
    func testHighlightRangesAcrossTheBook() {
        let texts = allText
        measure {
            for text in texts { _ = ArabicText.ranges(of: "الله", in: text) }
        }
    }

    func testNormalizeTheWholeBook() {
        let texts = allText
        measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
            for text in texts { _ = ArabicText.normalize(text) }
        }
    }

    /// The longest dhikr, repeated, so a slow (quadratic) match shows up clearly.
    func testHighlightInVeryLongText() throws {
        let longest = try XCTUnwrap(allText.max { $0.count < $1.count })
        let text = Array(repeating: longest, count: 20).joined(separator: " ")

        measure {
            _ = ArabicText.ranges(of: "الله", in: text)
        }
    }
}
