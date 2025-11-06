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
    
    var id: String { rawValue }
    
    var displayName: String { rawValue }
    
    var font: Font {
        switch self {
        case .system:
            return .system(.body, design: .default)
        case .scheherazade:
            // Try multiple possible font names for Scheherazade
            let possibleNames = [
                "ScheherazadeNew-Regular",
                "ScheherazadeNew",
                "Scheherazade New",
                "ScheherazadeNewRegular"
            ]
            
            for fontName in possibleNames {
                if let font = UIFont(name: fontName, size: 17) {
                    return Font(font)
                }
            }
            
            // If font not found, try to find it by family name
            let familyNames = ["Scheherazade New", "ScheherazadeNew", "Scheherazade"]
            for familyName in familyNames {
                let familyFonts = UIFont.fontNames(forFamilyName: familyName)
                if !familyFonts.isEmpty, let firstFont = familyFonts.first {
                    if let font = UIFont(name: firstFont, size: 17) {
                        return Font(font)
                    }
                }
            }
            
            // Fallback to system serif if font not found
            return .system(.body, design: .serif)
        }
    }
    
    static var selectedFont: AthkarFont {
        let stored = UserDefaults.standard.string(forKey: AppTheme.fontStorageKey) ?? AthkarFont.system.rawValue
        return AthkarFont(rawValue: stored) ?? .system
    }
    
    static func setSelectedFont(_ font: AthkarFont) {
        UserDefaults.standard.set(font.rawValue, forKey: AppTheme.fontStorageKey)
    }
}

