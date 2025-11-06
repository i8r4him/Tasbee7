//
//  Theme.swift
//  Uni
//
//  Created by AI Assistant on 22.09.25.
//

import SwiftUI

enum ThemeColor: String, CaseIterable, Identifiable {
    case blue
    case purple
    case pink
    case green
    case orange
    case teal
    case indigo
    case red

    var id: String { rawValue }

    var displayName: String { rawValue.capitalized }

    var color: Color {
        switch self {
        case .blue: return .blue
        case .purple: return .purple
        case .pink: return .pink
        case .green: return .green
        case .orange: return .orange
        case .teal: return .teal
        case .indigo: return .indigo
        case .red: return .red
        }
    }

    // Returns the onboarding app image asset name matching the theme color
    var onboardingImageName: String {
        switch self {
        case .red: return "redApp"
        case .purple: return "purpleApp"
        case .blue: return "blueApp"
        case .teal: return "tealApp"
        case .indigo: return "indigoApp"
        case .orange: return "orangeApp"
        case .green: return "greenApp"
        case .pink: return "pinkApp"
        }
    }
}

enum AppTheme {
    static let storageKey: String = "themeColor"

    static var selectedThemeColor: ThemeColor {
        let stored = UserDefaults.standard.string(forKey: storageKey) ?? ThemeColor.blue.rawValue
        return ThemeColor(rawValue: stored) ?? .blue
    }

    static func setSelectedThemeColor(_ theme: ThemeColor) {
        UserDefaults.standard.set(theme.rawValue, forKey: storageKey)
    }
}

