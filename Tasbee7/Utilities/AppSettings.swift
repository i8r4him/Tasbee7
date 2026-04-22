//
//  AppSettings.swift
//  Tasbee7
//
//  Created by Codex on 22.04.26.
//

import SwiftUI
import Observation

@MainActor
@Observable
final class AppSettings {
    private let userDefaults = UserDefaults.standard

    var selectedTheme: ThemeColor {
        didSet {
            userDefaults.set(selectedTheme.rawValue, forKey: AppTheme.storageKey)
        }
    }

    var themeColor: Color {
        selectedTheme.color
    }

    init() {
        let rawValue = userDefaults.string(forKey: AppTheme.storageKey) ?? ThemeColor.أزرق.rawValue
        selectedTheme = ThemeColor(rawValue: rawValue) ?? .أزرق
    }

    func setTheme(_ theme: ThemeColor) {
        selectedTheme = theme
    }
}

