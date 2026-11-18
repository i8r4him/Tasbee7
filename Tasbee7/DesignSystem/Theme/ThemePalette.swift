//
//  ThemePalette.swift
//  Tasbee7
//
//  The themes the user can pick. Every accent in the app reads from the current palette.
//

import SwiftUI

enum ThemePalette: String, CaseIterable, Identifiable {
    case gold, copper, roseGold, champagne, pearl, coral, lavender

    var id: Self { self }

    var name: String {
        switch self {
        case .gold: "ذهبي"
        case .copper: "نحاسي"
        case .roseGold: "ذهبي وردي"
        case .champagne: "شمبانيا"
        case .pearl: "لؤلؤي"
        case .coral: "مرجاني"
        case .lavender: "لافندر"
        }
    }

    /// Text, icons and the system tint. Passes 4.5:1 in both modes.
    var accent: Color {
        switch self {
        case .gold: Color(light: 0x9A6100, dark: 0xF2B24E)
        case .copper: Color(light: 0x9C4A1E, dark: 0xE8894A)
        case .roseGold: Color(light: 0x9A4E42, dark: 0xF2A58E)
        case .champagne: Color(light: 0x7D6236, dark: 0xE6CFA3)
        case .pearl: Color(light: 0x4C5A7A, dark: 0xC9D4EE)
        case .coral: Color(light: 0xA8402A, dark: 0xFF8A6B)
        case .lavender: Color(light: 0x5B45B8, dark: 0xB9A3FF)
        }
    }

    /// Filled buttons, glows, rings and progress.
    var accentFill: Color {
        switch self {
        case .gold: Color(light: 0xEFA831, dark: 0xF2B24E)
        case .copper: Color(hex: 0xE07B45)
        case .roseGold: Color(hex: 0xEBA08A)
        case .champagne: Color(hex: 0xE3C894)
        case .pearl: Color(hex: 0xD5DEF2)
        case .coral: Color(hex: 0xFF8466)
        case .lavender: Color(hex: 0x9C83F0)
        }
    }

    /// Text and icons on top of `accentFill`.
    var onAccent: Color {
        switch self {
        case .gold: Color(hex: 0x1A1408)
        case .copper: Color(hex: 0x1F0E05)
        case .roseGold: Color(hex: 0x2A1410)
        case .champagne: Color(hex: 0x241B0C)
        case .pearl: Color(hex: 0x151A26)
        case .coral: Color(hex: 0x2A0C05)
        case .lavender: Color(hex: 0xFFFFFF)
        }
    }

    /// The darkest tone: bottom of gradients, start of rings.
    var deep: Color {
        switch self {
        case .gold: Color(hex: 0xCC6B0A)
        case .copper: Color(hex: 0x8A3A12)
        case .roseGold: Color(hex: 0x7A3A34)
        case .champagne: Color(hex: 0x6E5634)
        case .pearl: Color(hex: 0x39445E)
        case .coral: Color(hex: 0x8A2E1E)
        case .lavender: Color(hex: 0x3E2E7A)
        }
    }

    /// The "silk" middle tone.
    var mid: Color {
        switch self {
        case .gold: Color(hex: 0xFFB829)
        case .copper: Color(hex: 0xC8642E)
        case .roseGold: Color(hex: 0xD9826E)
        case .champagne: Color(hex: 0xD8B98A)
        case .pearl: Color(hex: 0xB8C4E0)
        case .coral: Color(hex: 0xE86A4E)
        case .lavender: Color(hex: 0x8E72E8)
        }
    }

    /// Highlights and reflections.
    var light: Color {
        switch self {
        case .gold: Color(hex: 0xFFF2B8)
        case .copper: Color(hex: 0xF6D2B0)
        case .roseGold: Color(hex: 0xFBE0D6)
        case .champagne: Color(hex: 0xFFF4E0)
        case .pearl: Color(hex: 0xFFFFFF)
        case .coral: Color(hex: 0xFFE0D2)
        case .lavender: Color(hex: 0xEEE8FF)
        }
    }

    /// Halos, rims and glows.
    var rim: Color {
        switch self {
        case .gold: Color(hex: 0xFF9E1A)
        case .copper: Color(hex: 0xE8894A)
        case .roseGold: Color(hex: 0xF2A58E)
        case .champagne: Color(hex: 0xF3DDB8)
        case .pearl: Color(hex: 0xEAF0FF)
        case .coral: Color(hex: 0xFF8A6B)
        case .lavender: Color(hex: 0xB9A3FF)
        }
    }
}
