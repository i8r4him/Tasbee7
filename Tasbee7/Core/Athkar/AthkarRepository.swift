//
//  AthkarRepository.swift
//  Tasbee7
//
//  Holds the whole book in memory and answers "which chapters are in this group" or "give me this chapter".
//

import Foundation
import Observation

@Observable
final class AthkarRepository {
    enum State {
        case loading
        case loaded
        case failed(String)
    }

    /// A catalog group together with the chapters that exist for it.
    struct Group: Identifiable, Hashable {
        var id: String { catalog.id }
        let catalog: CatalogGroup
        let sections: [AthkarSection]
    }

    private(set) var state: State = .loading
    private(set) var sections: [AthkarSection] = []
    private(set) var groups: [Group] = []
    private var sectionsByTitle: [String: AthkarSection] = [:]

    init() {
        load()
    }

    /// Chapters that the catalog doesn't list yet, so nothing in the book is ever hidden.
    private(set) var uncataloged: [AthkarSection] = []

    func load() {
        do {
            let loaded = try AthkarLoader.load()
            sections = loaded
            sectionsByTitle = Dictionary(loaded.map { ($0.title, $0) }, uniquingKeysWith: { first, _ in first })

            groups = AthkarCatalog.groups.compactMap { group in
                let items = group.titles.compactMap { sectionsByTitle[$0] }
                return items.isEmpty ? nil : Group(catalog: group, sections: items)
            }
            uncataloged = loaded.filter { AthkarCatalog.groupNameByTitle[$0.title] == nil }
            if !uncataloged.isEmpty {
                groups.append(Group(
                    catalog: CatalogGroup(name: "أخرى", systemImage: "square.grid.2x2.fill", titles: uncataloged.map(\.title)),
                    sections: uncataloged
                ))
            }
            state = .loaded
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func section(titled title: String) -> AthkarSection? {
        sectionsByTitle[title]
    }

    func group(named name: String) -> Group? {
        groups.first { $0.catalog.name == name }
    }

    /// Group names that have chapters, in book order (used by the search filters).
    var groupNames: [String] {
        groups.map(\.catalog.name)
    }
}
