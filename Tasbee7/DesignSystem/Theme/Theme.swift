//
//  Theme.swift
//  Tasbee7
//
//  The current theme and the colour tokens every view uses.
//  Views that read `.accent` & co. redraw when the theme changes.
//

import Observation
import SwiftUI
import UIKit

@Observable
final class Theme {
    static let shared = Theme()

    private static let storageKey = "theme.palette"

    var palette: ThemePalette {
        didSet { UserDefaults.standard.set(palette.rawValue, forKey: Self.storageKey) }
    }

    private init() {
        palette = UserDefaults.standard.string(forKey: Self.storageKey).flatMap(ThemePalette.init) ?? .gold
    }
}

// MARK: - Accent

extension Color {
    static var accent: Color { Theme.shared.palette.accent }
    static var accentFill: Color { Theme.shared.palette.accentFill }
    static var onAccent: Color { Theme.shared.palette.onAccent }
}

extension ShapeStyle where Self == Color {
    static var accent: Color { .accent }
    static var accentFill: Color { .accentFill }
    static var onAccent: Color { .onAccent }
}

// MARK: - Meaning colours (the only fixed colours)

extension Color {
    /// Right, saved, done.
    static let success = Color(light: 0x007E46, dark: 0x7FD69A)
    /// A mistake or something to fix (coral).
    static let mistake = Color(light: 0xB05139, dark: 0xF2A08A)
}

extension ShapeStyle where Self == Color {
    static var success: Color { .success }
    static var mistake: Color { .mistake }
}

// MARK: - Neutral surfaces

extension Color {
    /// Screen background. Dark #000000, light #F2F2F7.
    static let screenBackground = Color(uiColor: .systemGroupedBackground)
    /// Solid cards (when not glass).
    static let surface = Color(uiColor: .secondarySystemGroupedBackground)
    /// Tiles inside cards only.
    static let surfaceSecondary = Color(uiColor: .tertiarySystemGroupedBackground)
    /// Bars, empty progress, inactive elements.
    static let surfaceTertiary = Color(uiColor: .systemGray4)
    /// Translucent fill for chips, pills and symbol squares.
    static let controlFill = Color(uiColor: .secondarySystemFill)
}

extension ShapeStyle where Self == Color {
    static var screenBackground: Color { .screenBackground }
    static var surface: Color { .surface }
    static var surfaceSecondary: Color { .surfaceSecondary }
    static var surfaceTertiary: Color { .surfaceTertiary }
    static var controlFill: Color { .controlFill }
}

// MARK: - Hex helpers

extension Color {
    init(hex: UInt32) {
        self.init(uiColor: UIColor(hex: hex))
    }

    /// A colour with a light-mode and a dark-mode variant.
    init(light: UInt32, dark: UInt32) {
        let lightColor = UIColor(hex: light)
        let darkColor = UIColor(hex: dark)
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? darkColor : lightColor
        })
    }
}

extension UIColor {
    nonisolated convenience init(hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}
