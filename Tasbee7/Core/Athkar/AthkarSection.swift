//
//  AthkarSection.swift
//  Tasbee7
//

import Foundation

/// One chapter of Hisn al-Muslim: a title and its athkar, each with an optional source note.
struct AthkarSection: Identifiable, Hashable {
    /// Titles are unique in the book, so they double as stable ids for favourites and navigation.
    var id: String { title }
    let title: String
    let athkar: [Dhikr]

    var groupName: String? { AthkarCatalog.groupNameByTitle[title] }
}

struct Dhikr: Identifiable, Hashable {
    let id: Int
    let text: String
    let source: String?
}

/// The shape of `hisn_almuslim.json`: `{ "title": { "text": [...], "footnote": [...] } }`.
private struct SectionContent: Decodable {
    let text: [String]
    let footnote: [String]?
}

enum AthkarLoaderError: LocalizedError {
    case fileNotFound

    var errorDescription: String? {
        switch self {
        case .fileNotFound: "لم يتم العثور على ملف الأذكار في التطبيق."
        }
    }
}

enum AthkarLoader {
    /// Reads the book from the app bundle. The bundle is the only source, so a corrected text
    /// in an app update reaches every user straight away.
    static func load(bundle: Bundle = .main) throws -> [AthkarSection] {
        guard let url = bundle.url(forResource: "hisn_almuslim", withExtension: "json") else {
            throw AthkarLoaderError.fileNotFound
        }
        return try sections(from: Data(contentsOf: url))
    }

    /// Decodes the book. Malformed data throws instead of crashing.
    static func sections(from data: Data) throws -> [AthkarSection] {
        let decoded = try JSONDecoder().decode([String: SectionContent].self, from: data)

        return decoded
            .map { title, content in
                let sources = content.footnote ?? []
                let athkar = content.text.enumerated().map { index, text in
                    Dhikr(
                        id: index,
                        text: text.trimmingCharacters(in: .whitespacesAndNewlines),
                        source: sources.indices.contains(index) ? sources[index].nilIfBlank : nil
                    )
                }
                return AthkarSection(title: title, athkar: athkar)
            }
            .sorted { AthkarCatalog.order(of: $0.title) < AthkarCatalog.order(of: $1.title) }
    }
}

private extension String {
    var nilIfBlank: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
