//
//  ArabicText.swift
//  Tasbee7
//
//  Arabic-aware matching: ignores tashkeel and tatweel and treats hamza/alef forms alike,
//  so "اذكار" finds "أَذْكَار". Ranges map back to the original text for highlighting.
//

import Foundation

enum ArabicText {
    /// Folds one scalar to its search form, or nil when it should be ignored.
    static func fold(_ scalar: Unicode.Scalar) -> Unicode.Scalar? {
        switch scalar.value {
        // Tashkeel (fathatan … sukun), superscript alef, Quranic marks, tatweel.
        case 0x064B...0x065F, 0x0670, 0x06D6...0x06ED, 0x0640:
            return nil
        // أ إ آ ٱ → ا
        case 0x0622, 0x0623, 0x0625, 0x0671:
            return "\u{0627}"
        // ى → ي, ئ → ي
        case 0x0649, 0x0626:
            return "\u{064A}"
        // ؤ → و
        case 0x0624:
            return "\u{0648}"
        // ة → ه
        case 0x0629:
            return "\u{0647}"
        default:
            let folded = String(scalar).folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
            return folded.unicodeScalars.count == 1 ? folded.unicodeScalars.first : scalar
        }
    }

    /// The search form of a whole string, with runs of whitespace collapsed.
    static func normalize(_ text: String) -> String {
        Folded(text).string
    }

    /// Every range of `query` in `text`, as ranges of the original text.
    static func ranges(of query: String, in text: String) -> [Range<String.Index>] {
        let needle = Array(normalize(query).unicodeScalars)
        guard !needle.isEmpty else { return [] }

        let folded = Folded(text)
        let haystack = folded.scalars
        guard haystack.count >= needle.count else { return [] }

        var result: [Range<String.Index>] = []
        var start = 0
        while start <= haystack.count - needle.count {
            if haystack[start] == needle[0], Array(haystack[start..<(start + needle.count)]) == needle {
                let lower = folded.origins[start].lowerBound
                let upper = folded.origins[start + needle.count - 1].upperBound
                result.append(lower..<extendOverMarks(upper, in: text))
                start += needle.count
            } else {
                start += 1
            }
        }
        return result
    }

    static func contains(_ query: String, in text: String) -> Bool {
        let needle = normalize(query)
        guard !needle.isEmpty else { return false }
        return normalize(text).contains(needle)
    }

    /// Moves past any tashkeel right after a match, so the highlight covers whole letters.
    private static func extendOverMarks(_ index: String.Index, in text: String) -> String.Index {
        var index = index
        let scalars = text.unicodeScalars
        while index < scalars.endIndex, fold(scalars[index]) == nil {
            index = scalars.index(after: index)
        }
        return index
    }
}

/// A folded copy of a string that remembers where each folded scalar came from.
private struct Folded {
    var scalars: [Unicode.Scalar] = []
    var origins: [Range<String.Index>] = []

    init(_ text: String) {
        let source = text.unicodeScalars
        var index = source.startIndex
        var lastWasSpace = true
        while index < source.endIndex {
            let next = source.index(after: index)
            if let folded = ArabicText.fold(source[index]) {
                let isSpace = folded.properties.isWhitespace
                if !(isSpace && lastWasSpace) {
                    scalars.append(isSpace ? " " : folded)
                    origins.append(index..<next)
                }
                lastWasSpace = isSpace
            }
            index = next
        }
        if scalars.last == " " {
            scalars.removeLast()
            origins.removeLast()
        }
    }

    var string: String {
        var view = String.UnicodeScalarView()
        view.append(contentsOf: scalars)
        return String(view)
    }
}
