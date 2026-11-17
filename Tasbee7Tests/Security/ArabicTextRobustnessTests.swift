//
//  ArabicTextRobustnessTests.swift
//  Tasbee7Tests
//
//  Search runs on whatever the user types or pastes. Odd input must not crash it or produce
//  highlight ranges outside the text.
//

import Foundation
import Testing
@testable import Tasbee7

@MainActor
@Suite("Security: search input robustness")
struct ArabicTextRobustnessTests {
    /// A small deterministic generator, so a failure always reproduces.
    private struct SeededGenerator: RandomNumberGenerator {
        var state: UInt64
        mutating func next() -> UInt64 {
            state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
            return state
        }
    }

    /// Scalars that stress the folding: tashkeel, hamza forms, tatweel, bidi controls,
    /// zero-width joiners, combining marks, emoji, whitespace and Latin.
    private static let alphabet: [Unicode.Scalar] = [
        "ا", "أ", "إ", "آ", "ٱ", "ى", "ي", "ئ", "ؤ", "ة", "ه", "ل", "م", "ـ",
        "\u{064B}", "\u{0650}", "\u{0651}", "\u{0652}", "\u{0670}", "\u{06D6}",
        "\u{202E}", "\u{2066}", "\u{200D}", "\u{200C}", "\u{FEFF}", "\u{0301}", "\u{0000}",
        " ", "\n", "\t", "\u{00A0}", "a", "Z", "é", "😀", "👨", "\u{1F3FD}", "ß", "İ"
    ]

    private static func randomString(using generator: inout SeededGenerator, maxLength: Int) -> String {
        let length = Int.random(in: 0...maxLength, using: &generator)
        var scalars = String.UnicodeScalarView()
        for _ in 0..<length {
            scalars.append(alphabet.randomElement(using: &generator)!)
        }
        return String(scalars)
    }

    @Test("Random input never crashes and ranges stay inside the text")
    func fuzzRanges() {
        var generator = SeededGenerator(state: 0x7A5BEE7)
        for _ in 0..<2_000 {
            let text = Self.randomString(using: &generator, maxLength: 60)
            let query = Self.randomString(using: &generator, maxLength: 6)
            let ranges = ArabicText.ranges(of: query, in: text)
            for range in ranges {
                #expect(range.lowerBound >= text.startIndex && range.upperBound <= text.endIndex)
                #expect(!range.isEmpty)
                _ = text[range]
            }
        }
    }

    @Test("Very long input is handled", arguments: [10_000, 100_000])
    func longInput(length: Int) {
        let text = String(repeating: "سُبْحَانَ اللهِ ", count: length / 16)
        let query = String(repeating: "ا", count: 500)
        #expect(ArabicText.ranges(of: query, in: text).isEmpty)
        #expect(ArabicText.ranges(of: "سبحان", in: text).count == length / 16)
    }

    @Test("Queries made only of marks or controls match nothing", arguments: [
        "", " ", "\u{064B}\u{0651}", "ـــ", "\u{202E}\u{2066}", "\n\t"
    ])
    func emptyAfterFoldingMatchesNothing(query: String) {
        #expect(ArabicText.normalize(query).isEmpty)
        #expect(ArabicText.ranges(of: query, in: "أَذْكَارُ الصَّبَاحِ").isEmpty)
        #expect(SearchEngine(sections: []).results(for: query).isEmpty)
    }

    @Test("The search engine survives hostile queries on the real book")
    func searchEngineHandlesHostileQueries() throws {
        let url = try #require(SecurityTestSupport.appBundle.url(forResource: "hisn_almuslim", withExtension: "json"))
        let engine = SearchEngine(sections: try AthkarLoader.sections(from: Data(contentsOf: url)))
        let queries = [
            String(repeating: "ا", count: 5_000),
            "%@%@%@%n%s",
            "'; DROP TABLE athkar; --",
            "<script>alert(1)</script>",
            "\u{202E}الله",
            ".*",
            "(((((((((("
        ]
        for query in queries {
            for result in engine.results(for: query) {
                #expect(result.snippet.map { $0.count <= 200 } ?? true)
            }
        }
        #expect(!engine.results(for: "\u{202E}الله").isEmpty, "Bidi overrides shouldn't hide real matches")
    }
}
