//
//  SearchEngine.swift
//  Tasbee7
//

import Foundation

struct SearchResult: Identifiable, Hashable {
    var id: String { section.id }
    let section: AthkarSection
    let titleMatches: Bool
    /// A short piece of the first matching dhikr, or nil when only the title matched.
    let snippet: String?
}

struct SearchEngine {
    let sections: [AthkarSection]

    /// Chapters whose title or text contains the query, title matches first, then in book order.
    func results(for query: String, inGroup group: String? = nil) -> [SearchResult] {
        let needle = ArabicText.normalize(query)
        guard !needle.isEmpty else { return [] }

        return sections
            .filter { group == nil || $0.groupName == group }
            .compactMap { section -> SearchResult? in
                let titleMatches = ArabicText.normalize(section.title).contains(needle)
                let snippet = section.athkar.lazy.compactMap { makeSnippet(of: $0.text, around: query) }.first
                guard titleMatches || snippet != nil else { return nil }
                return SearchResult(section: section, titleMatches: titleMatches, snippet: snippet)
            }
            .sorted { lhs, rhs in
                if lhs.titleMatches != rhs.titleMatches { return lhs.titleMatches }
                return AthkarCatalog.order(of: lhs.section.title) < AthkarCatalog.order(of: rhs.section.title)
            }
    }

    /// About 24 characters before the match and 72 after, with ellipses where cut.
    private func makeSnippet(of text: String, around query: String) -> String? {
        guard let range = ArabicText.ranges(of: query, in: text).first else { return nil }
        let lower = text.index(range.lowerBound, offsetBy: -24, limitedBy: text.startIndex) ?? text.startIndex
        let upper = text.index(range.upperBound, offsetBy: 72, limitedBy: text.endIndex) ?? text.endIndex
        let body = text[lower..<upper].trimmingCharacters(in: .whitespacesAndNewlines)
        return (lower > text.startIndex ? "…" : "") + body + (upper < text.endIndex ? "…" : "")
    }
}
