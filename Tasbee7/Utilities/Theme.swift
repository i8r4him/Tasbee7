//
//  Theme.swift
//  Uni
//
//  Created by AI Assistant on 22.09.25.
//

import SwiftUI
import UIKit

enum ThemeColor: String, CaseIterable, Identifiable {
    case اخضر
    case بني
    case أزرق
    //case purple
    //case pink
    //case orange
    //case teal
    //case indigo
    //case red

    var id: String { rawValue }

    var displayName: String { rawValue.capitalized }

    static func resolved(from rawValue: String) -> ThemeColor {
        ThemeColor(rawValue: rawValue) ?? .أزرق
    }

    static func resolvedColor(from rawValue: String) -> Color {
        resolved(from: rawValue).color
    }

    var color: Color {
        switch self {
        case .أزرق: return .blue
            //case .purple: return .purple
            //case .pink: return .pink
        case .اخضر: return .green
            //case .orange: return .orange
            //case .teal: return .teal
            //case .indigo: return .indigo
            //case .red: return .red
        case .بني: return .brown
        }
    }

    // Returns the onboarding app image asset name matching the theme color
    var onboardingImageName: String {
        switch self {
            //case .red: return "redApp"
            //case .purple: return "purpleApp"
        case .أزرق: return "blueApp"
            //case .teal: return "tealApp"
            //case .indigo: return "indigoApp"
            //case .orange: return "orangeApp"
        case .اخضر: return "greenApp"
            //case .pink: return "pinkApp"
        case .بني: return "brownApp"
        }
    }
}

enum AppTheme {
    static let storageKey: String = "themeColor"
    static let fontStorageKey: String = "athkarFont"

    static var selectedThemeColor: ThemeColor {
        let stored = UserDefaults.standard.string(forKey: storageKey) ?? ThemeColor.أزرق.rawValue
        return ThemeColor(rawValue: stored) ?? .أزرق
    }

    static func setSelectedThemeColor(_ theme: ThemeColor) {
        UserDefaults.standard.set(theme.rawValue, forKey: storageKey)
    }
}

enum AthkarFont: String, CaseIterable, Identifiable {
    case system = "النظام"
    case scheherazade = "شهرزاد"

    private static let candidateNames = [
        "ScheherazadeNew-Regular",
        "ScheherazadeNew",
        "Scheherazade New",
        "ScheherazadeNewRegular"
    ]

    private static let candidateFamilies = [
        "Scheherazade New",
        "ScheherazadeNew",
        "Scheherazade"
    ]
    
    var id: String { rawValue }
    
    var displayName: String { rawValue }
    
    var font: Font {
        font(size: 17)
    }

    func font(size: CGFloat) -> Font {
        switch self {
        case .system:
            return .system(size: size, design: .default)
        case .scheherazade:
            if let resolvedFont = resolvedUIFont(size: size) {
                return Font(resolvedFont)
            }
            return .system(size: size, design: .serif)
        }
    }
    
    static var selectedFont: AthkarFont {
        let stored = UserDefaults.standard.string(forKey: AppTheme.fontStorageKey) ?? AthkarFont.system.rawValue
        return AthkarFont(rawValue: stored) ?? .system
    }
    
    static func setSelectedFont(_ font: AthkarFont) {
        UserDefaults.standard.set(font.rawValue, forKey: AppTheme.fontStorageKey)
    }

    private func resolvedUIFont(size: CGFloat) -> UIFont? {
        switch self {
        case .system:
            return nil
        case .scheherazade:
            for fontName in Self.candidateNames {
                if let font = UIFont(name: fontName, size: size) {
                    return font
                }
            }

            for familyName in Self.candidateFamilies {
                let familyFonts = UIFont.fontNames(forFamilyName: familyName)
                if let firstFont = familyFonts.first,
                   let font = UIFont(name: firstFont, size: size) {
                    return font
                }
            }

            return nil
        }
    }
}
