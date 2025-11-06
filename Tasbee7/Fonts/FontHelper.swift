//
//  FontHelper.swift
//  Tasbee7
//
//  Helper to detect font names from font files
//

import UIKit

struct FontHelper {
    /// Get the actual font name from a font file
    /// - Parameter fontFileName: The name of the font file (e.g., "Quran-Madina.ttf")
    /// - Returns: The PostScript name of the font that you should use in UIFont(name:size:)
    static func getFontName(from fontFileName: String) -> String? {
        // Try common font name variations
        let baseName = fontFileName
            .replacingOccurrences(of: ".ttf", with: "")
            .replacingOccurrences(of: ".otf", with: "")
        
        // Common variations
        let possibleNames = [
            baseName,
            baseName.replacingOccurrences(of: "-", with: ""),
            baseName.replacingOccurrences(of: "_", with: "-"),
            baseName + "-Regular"
        ]
        
        for name in possibleNames {
            if UIFont(name: name, size: 17) != nil {
                return name
            }
        }
        
        return nil
    }
    
    /// List all available font names in the app
    /// This checks registered fonts that are available via UIFont
    static func listAllFonts() -> [String] {
        var fontNames: [String] = []
        
        // Get all font family names
        let fontFamilies = UIFont.familyNames.sorted()
        
        for family in fontFamilies {
            let fontNamesInFamily = UIFont.fontNames(forFamilyName: family)
            for fontName in fontNamesInFamily {
                // Filter to only include fonts that are likely custom (not system fonts)
                if !fontName.contains("System") && 
                   !fontName.contains("SF") &&
                   !fontName.contains("Helvetica") &&
                   !fontName.contains("Times") &&
                   !fontName.contains("Courier") {
                    fontNames.append(fontName)
                }
            }
        }
        
        return fontNames.sorted()
    }
    
    /// Find the actual PostScript name for Scheherazade font
    static func findScheherazadeFontName() -> String? {
        // Check all font families for Scheherazade
        let families = UIFont.familyNames.filter { $0.localizedCaseInsensitiveContains("scheherazade") }
        
        for family in families {
            let fonts = UIFont.fontNames(forFamilyName: family)
            if let firstFont = fonts.first {
                print("Found Scheherazade font: \(firstFont) in family: \(family)")
                return firstFont
            }
        }
        
        // Try common variations
        let variations = [
            "ScheherazadeNew-Regular",
            "ScheherazadeNew",
            "Scheherazade New Regular",
            "ScheherazadeNew-Regular"
        ]
        
        for variation in variations {
            if UIFont(name: variation, size: 17) != nil {
                print("Found Scheherazade font: \(variation)")
                return variation
            }
        }
        
        return nil
    }
}

