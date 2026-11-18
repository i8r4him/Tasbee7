//
//  ReadingPreferences.swift
//  Tasbee7
//
//  How athkar are shown: the typeface and the size. Stored under the same keys as before.
//

import Observation
import SwiftUI
import UIKit

enum AthkarFont: String, CaseIterable, Identifiable {
    case system = "النظام"
    case scheherazade = "شهرزاد"

    var id: Self { self }
    var name: String { rawValue }

    /// The font at a given point size. Scheherazade falls back to the system serif if it can't be loaded.
    func font(size: CGFloat) -> Font {
        switch self {
        case .system:
            return .system(size: size)
        case .scheherazade:
            if let uiFont = UIFont(name: "ScheherazadeNew-Regular", size: size)
                ?? UIFont.fontNames(forFamilyName: "Scheherazade New").first.flatMap({ UIFont(name: $0, size: size) }) {
                return Font(uiFont)
            }
            return .system(size: size, design: .serif)
        }
    }

    /// Scheherazade has tall marks, so it needs a little more room between lines.
    var lineSpacing: CGFloat {
        switch self {
        case .system: 10
        case .scheherazade: 6
        }
    }
}

enum AthkarFontSize: String, CaseIterable, Identifiable {
    case small = "صغير"
    case medium = "متوسط"
    case large = "كبير"
    case extraLarge = "كبير جداً"

    var id: Self { self }
    var name: String { rawValue }

    /// The size at the default Dynamic Type setting. The reader scales it with Dynamic Type.
    var baseSize: CGFloat {
        switch self {
        case .small: 17
        case .medium: 20
        case .large: 24
        case .extraLarge: 28
        }
    }
}

@Observable
final class ReadingPreferences {
    private static let fontKey = "athkarFont"
    private static let sizeKey = "athkarFontSize"

    var font: AthkarFont {
        didSet { UserDefaults.standard.set(font.rawValue, forKey: Self.fontKey) }
    }

    var size: AthkarFontSize {
        didSet { UserDefaults.standard.set(size.rawValue, forKey: Self.sizeKey) }
    }

    init() {
        let defaults = UserDefaults.standard
        font = defaults.string(forKey: Self.fontKey).flatMap(AthkarFont.init) ?? .scheherazade
        size = defaults.string(forKey: Self.sizeKey).flatMap(AthkarFontSize.init) ?? .medium
    }
}
