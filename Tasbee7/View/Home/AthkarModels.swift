//
//  AthkarModels.swift
//  Tasbee7
//
//  Created by Assistant on 06.11.25.
//

import Foundation

struct SectionContent: Decodable, Sendable {
    let text: [String]
    let footnote: [String]?
}

struct AthkarSection: Identifiable, Hashable, Codable, Sendable {
    // Use title as a stable identifier for favorites and navigation
    var id: String { title }
    let title: String
    let text: [String]
    let footnote: [String]
}

