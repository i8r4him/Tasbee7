//
//  SearchEngine.swift
//  Tasbee7
//
//  Created by Codex on 28.03.26.
//

import Foundation

struct SearchEngine {
    let sections: [AthkarSection]

    var availableSections: [String] {
        let names = Set(sections.compactMap { AthkarIndex.sectionMap[$0.title] })
        return names.sorted(by: localizedAscending)
    }

    func results(for rawQuery: String, in selectedSection: String?) -> [AthkarSection] {
        let query = normalizedQuery(from: rawQuery)
        guard !query.isEmpty else { return [] }

        return scopedSections(for: selectedSection)
            .filter { matches($0, query: query) }
            .sorted { lhs, rhs in
                let lhsTitleMatch = lhs.title.contains(query)
                let rhsTitleMatch = rhs.title.contains(query)

                if lhsTitleMatch != rhsTitleMatch {
                    return lhsTitleMatch
                }

                return localizedAscending(lhs.title, rhs.title)
            }
    }

    func snippet(for section: AthkarSection, query rawQuery: String) -> String? {
        let query = normalizedQuery(from: rawQuery)
        guard !query.isEmpty else { return nil }

        for text in section.text {
            guard let range = text.range(
                of: query,
                options: [.caseInsensitive, .diacriticInsensitive]
            ) else {
                continue
            }

            let lowerBound = text.index(range.lowerBound, offsetBy: -24, limitedBy: text.startIndex) ?? text.startIndex
            let upperBound = text.index(range.upperBound, offsetBy: 72, limitedBy: text.endIndex) ?? text.endIndex
            let snippet = text[lowerBound..<upperBound].trimmingCharacters(in: .whitespacesAndNewlines)
            let prefix = lowerBound > text.startIndex ? "..." : ""
            let suffix = upperBound < text.endIndex ? "..." : ""
            return prefix + snippet + suffix
        }

        return nil
    }
}

private extension SearchEngine {
    func normalizedQuery(from rawQuery: String) -> String {
        rawQuery.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func scopedSections(for selectedSection: String?) -> [AthkarSection] {
        guard let selectedSection else { return sections }
        return sections.filter { AthkarIndex.sectionMap[$0.title] == selectedSection }
    }

    func matches(_ section: AthkarSection, query: String) -> Bool {
        if section.title.contains(query) {
            return true
        }

        return section.text.contains { $0.contains(query) }
    }

    func localizedAscending(_ lhs: String, _ rhs: String) -> Bool {
        lhs.localizedStandardCompare(rhs) == .orderedAscending
    }
}

private extension String {
    func contains(_ query: String) -> Bool {
        range(of: query, options: [.caseInsensitive, .diacriticInsensitive]) != nil
    }
}
