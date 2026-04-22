//
//  HomeSections.swift
//  Tasbee7
//
//  Created by Assistant on 06.11.25.
//

import Foundation

struct HomeSections {
    struct Group: Identifiable, Equatable, Sendable {
        let id: String
        let title: String
        let items: [AthkarSection]
    }

    var favorites: [AthkarSection]
    var groups: [Group] // الأقسام المجمعة حسب الفهرس

    var isEmpty: Bool {
        favorites.isEmpty && groups.isEmpty
    }

    static let empty = HomeSections(favorites: [], groups: [])
}

extension HomeSections {
    /// Builds organized sections from raw athkar data
    /// - Parameters:
    ///   - sections: All athkar sections to organize
    ///   - favorites: Set of favorite athkar titles
    /// - Returns: Organized HomeSections with favorites and grouped sections
    static func build(from sections: [AthkarSection], favorites: Set<String>) -> HomeSections {
        // Filter and sort favorites
        let sortedFavorites: [AthkarSection]
        if favorites.isEmpty {
            sortedFavorites = []
        } else {
            let favoritesList = sections.filter { favorites.contains($0.id) }
            sortedFavorites = sortByIndex(favoritesList)
        }

        // Group all sections by index-defined categories
        let grouped = AthkarIndex.groupSections(sections)
        
        // Build ordered groups in one pass (pre-allocated for performance)
        var orderedGroups: [Group] = []
        orderedGroups.reserveCapacity(AthkarIndex.sectionOrder.count + 1)
        
        for groupName in AthkarIndex.sectionOrder {
            if let items = grouped[groupName], !items.isEmpty {
                orderedGroups.append(Group(id: groupName, title: groupName, items: items))
            }
        }
        
        // Add "أخرى" section at the end if it exists
        if let others = grouped["أخرى"], !others.isEmpty {
            orderedGroups.append(Group(id: "أخرى", title: "أخرى", items: others))
        }

        return HomeSections(
            favorites: sortedFavorites,
            groups: orderedGroups
        )
    }
    
    /// Sorts sections according to their order in AthkarIndex
    /// Uses cached indexDictionary for O(1) lookups
    private static func sortByIndex(_ sections: [AthkarSection]) -> [AthkarSection] {
        guard !sections.isEmpty else { return [] }
        
        return sections.sorted { section1, section2 in
            let index1 = AthkarIndex.indexDictionary[section1.title] ?? Int.max
            let index2 = AthkarIndex.indexDictionary[section2.title] ?? Int.max
            return index1 < index2
        }
    }
}

