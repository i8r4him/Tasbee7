//
//  AthkarDestinations.swift
//  Tasbee7
//
//  The screens any tab can push for a place in the book, plus a medium haptic on every push.
//

import SwiftUI

extension View {
    /// Registers the athkar screens for `AthkarRoute` and plays a medium haptic whenever one opens.
    func athkarDestinations(path: [AthkarRoute]) -> some View {
        self
            .navigationDestination(for: AthkarRoute.self) { route in
                switch route {
                case .group(let name):
                    CategoryView(groupName: name)
                case .section(let title):
                    ReaderView(title: title)
                }
            }
            .sensoryFeedback(.impact(weight: .medium), trigger: path.count) { old, new in new > old }
    }
}

extension AthkarRepository.Group {
    /// A group with one chapter opens that chapter straight away.
    var route: AthkarRoute {
        if sections.count == 1, let only = sections.first {
            return .section(only.title)
        }
        return .group(catalog.name)
    }
}
