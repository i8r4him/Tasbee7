//
//  AthkarDataIntegrityTests.swift
//  Tasbee7Tests
//
//  The book shipped in the app is religious text people read and share, so it must load safely,
//  contain no hidden characters or markup, and malformed data must fail cleanly.
//

import Foundation
import Testing
@testable import Tasbee7

@MainActor
@Suite("Security: athkar data integrity")
struct AthkarDataIntegrityTests {
    private func bookData() throws -> Data {
        let url = try #require(SecurityTestSupport.appBundle.url(forResource: "hisn_almuslim", withExtension: "json"))
        return try Data(contentsOf: url)
    }

    @Test("Malformed data throws instead of crashing", arguments: [
        "", "{", "[]", "null", "\"text\"", "{\"t\": 1}", "{\"t\": {\"text\": \"not an array\"}}",
        "{\"t\": {\"footnote\": []}}", String(repeating: "{\"a\":", count: 2_000)
    ])
    func malformedDataThrows(json: String) {
        #expect(throws: (any Error).self) {
            _ = try AthkarLoader.sections(from: Data(json.utf8))
        }
    }

    @Test("More footnotes than texts, or fewer, never index out of range")
    func mismatchedFootnotesAreSafe() throws {
        let json = #"{"أ": {"text": ["one"], "footnote": ["a", "b", "c"]}, "ب": {"text": ["one", "two", "three"], "footnote": ["a"]}}"#
        let sections = try AthkarLoader.sections(from: Data(json.utf8))
        let first = try #require(sections.first { $0.title == "أ" })
        let second = try #require(sections.first { $0.title == "ب" })
        #expect(first.athkar.count == 1)
        #expect(second.athkar.map(\.source) == ["a", nil, nil])
    }

    @Test("The shipped book loads completely")
    func bundledBookLoads() throws {
        let sections = try AthkarLoader.sections(from: bookData())
        #expect(sections.count == 134)
        #expect(sections.contains { $0.title == AthkarCatalog.morningEveningTitle })
    }

    @Test("The shipped book has no hidden direction overrides or control characters")
    func bundledBookHasNoHiddenCharacters() throws {
        let sections = try AthkarLoader.sections(from: bookData())
        for section in sections {
            let strings = [section.title] + section.athkar.flatMap { [$0.text, $0.source ?? ""] }
            for string in strings {
                let offending = string.unicodeScalars.filter { scalar in
                    SecurityTestSupport.invisibleFormattingScalars.contains(scalar.value)
                        || (scalar.properties.generalCategory == .control && !"\n\r\t".unicodeScalars.contains(scalar))
                }
                #expect(offending.isEmpty, "Hidden characters in \(section.title)")
            }
        }
    }

    @Test("The shipped book contains no links, scripts or markup")
    func bundledBookHasNoMarkup() throws {
        let text = try #require(String(data: bookData(), encoding: .utf8))
        for pattern in ["<script", "javascript:", "http://", "https://", "<a ", "<img", "<iframe", "data:text"] {
            #expect(text.range(of: pattern, options: .caseInsensitive) == nil, "Found \(pattern)")
        }
    }

    @Test("Every catalog title exists in the book, so routes can't point at missing chapters")
    func catalogMatchesBook() throws {
        let titles = Set(try AthkarLoader.sections(from: bookData()).map(\.title))
        for group in AthkarCatalog.groups {
            for title in group.titles {
                #expect(titles.contains(title), "Catalog title missing from book: \(title)")
            }
        }
    }
}
