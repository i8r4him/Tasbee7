//
//  SebhaStore.swift
//  Tasbee7
//
//  The counter: one count per phrase, a target, and the user's own phrases.
//

import Foundation
import Observation

@Observable
final class SebhaStore {
    static let basePhrases = [
        "سبحان الله",
        "الحمد لله",
        "الله أكبر",
        "لا إله إلا الله",
        "أستغفر الله"
    ]
    static let presetTargets = [33, 99, 100]
    /// Bounds for anything read back from storage or typed by the user.
    static let targetRange = 1...100_000
    static let maxPhraseLength = 120
    static let maxCustomPhrases = 100

    private enum Key {
        static let counts = "sebha.counts"
        static let selected = "sebha.selectedPhrase"
        static let customPhrases = "sebhaCustomPhrases"
        static let target = "sebhaTarget"
        static let haptics = "sebhaHapticEnabled"
        static let sound = "sebhaSoundEnabled"
        // Version 1.x kept one shared counter.
        static let legacyCounter = "sebhaCounter"
        static let legacyPhraseIndex = "sebhaPhraseIndex"
    }

    private let defaults: UserDefaults

    private(set) var customPhrases: [String]
    private(set) var counts: [String: Int]
    private(set) var selectedPhrase: String

    /// Always within `targetRange`, so the round maths can never divide by zero.
    var target: Int {
        didSet {
            let clamped = Self.clampTarget(target)
            if clamped != target { target = clamped }
            defaults.set(target, forKey: Key.target)
        }
    }

    var hapticsEnabled: Bool {
        didSet { defaults.set(hapticsEnabled, forKey: Key.haptics) }
    }

    var soundEnabled: Bool {
        didSet { defaults.set(soundEnabled, forKey: Key.sound) }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        let stored = defaults.string(forKey: Key.customPhrases)
            .flatMap { $0.data(using: .utf8) }
            .flatMap { try? JSONDecoder().decode([String].self, from: $0) } ?? []
        // Stored phrases go through the same cleaning as typed ones; duplicates and junk are dropped.
        var custom: [String] = []
        for raw in stored {
            guard let phrase = Self.sanitizedPhrase(raw),
                  !Self.basePhrases.contains(phrase), !custom.contains(phrase) else { continue }
            custom.append(phrase)
            if custom.count == Self.maxCustomPhrases { break }
        }
        customPhrases = custom

        let all = Self.basePhrases + custom
        let storedTarget = defaults.integer(forKey: Key.target)
        target = Self.targetRange.contains(storedTarget) ? storedTarget : 33
        hapticsEnabled = defaults.object(forKey: Key.haptics) as? Bool ?? true
        soundEnabled = defaults.object(forKey: Key.sound) as? Bool ?? true

        // A local first: reading `self` before every stored property is set doesn't compile.
        let selected: String
        if let stored = defaults.string(forKey: Key.selected), all.contains(stored) {
            selected = stored
        } else {
            let index = defaults.integer(forKey: Key.legacyPhraseIndex)
            selected = all.indices.contains(index) ? all[index] : all[0]
        }
        selectedPhrase = selected

        if let data = defaults.data(forKey: Key.counts),
           let storedCounts = try? JSONDecoder().decode([String: Int].self, from: data) {
            // Negative counts can only come from a tampered file; drop them.
            counts = storedCounts.filter { $0.value > 0 }
        } else {
            // Carry the old shared counter over to the phrase that was selected.
            let legacy = max(0, defaults.integer(forKey: Key.legacyCounter))
            counts = legacy > 0 ? [selected: legacy] : [:]
        }
    }

    // MARK: - Reading

    var allPhrases: [String] { Self.basePhrases + customPhrases }

    var count: Int { counts[selectedPhrase] ?? 0 }

    func count(for phrase: String) -> Int { counts[phrase] ?? 0 }

    /// Completed rounds of the target.
    var rounds: Int { count / target }

    /// Progress through the current round, 0...1. A finished round shows a full ring until the next tap.
    var progress: Double {
        guard count > 0 else { return 0 }
        let rest = count % target
        return rest == 0 ? 1 : Double(rest) / Double(target)
    }

    /// True right after a tap that finished a round.
    var justFinishedRound: Bool {
        count > 0 && count % target == 0
    }

    // MARK: - Changing

    /// Adds one. Stops at `Int.max` instead of overflowing, which would crash the app.
    func increment() {
        let (next, overflow) = count.addingReportingOverflow(1)
        guard !overflow else { return }
        counts[selectedPhrase] = next
        saveCounts()
    }

    func reset() {
        counts[selectedPhrase] = nil
        saveCounts()
    }

    func select(_ phrase: String) {
        guard allPhrases.contains(phrase) else { return }
        selectedPhrase = phrase
        defaults.set(phrase, forKey: Key.selected)
    }

    /// Adds a phrase and selects it. Returns false when it's empty, too long, already there,
    /// or the list is full.
    @discardableResult
    func addPhrase(_ text: String) -> Bool {
        guard let phrase = Self.sanitizedPhrase(text),
              !allPhrases.contains(phrase),
              customPhrases.count < Self.maxCustomPhrases else { return false }
        customPhrases.append(phrase)
        saveCustomPhrases()
        select(phrase)
        return true
    }

    func deleteCustomPhrases(at offsets: IndexSet) {
        let removed = offsets.map { customPhrases[$0] }
        customPhrases.remove(atOffsets: offsets)
        for phrase in removed { counts[phrase] = nil }
        saveCustomPhrases()
        saveCounts()
        if removed.contains(selectedPhrase) {
            select(Self.basePhrases[0])
        }
    }

    // MARK: - Validation

    static func clampTarget(_ value: Int) -> Int {
        min(max(value, targetRange.lowerBound), targetRange.upperBound)
    }

    /// The phrase as it should be stored, or nil when nothing usable is left.
    /// Removes control characters and invisible bidi overrides (which can make text display
    /// differently from what it contains), collapses whitespace, and rejects overly long text.
    static func sanitizedPhrase(_ text: String) -> String? {
        var scalars = String.UnicodeScalarView()
        for scalar in text.unicodeScalars {
            switch scalar.value {
            case 0x202A...0x202E, 0x2066...0x2069, 0x200E, 0x200F, 0x061C, 0xFEFF:
                continue
            default:
                if scalar.properties.generalCategory == .control {
                    scalars.append(" ")
                } else {
                    scalars.append(scalar)
                }
            }
        }
        let phrase = String(scalars)
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")
        guard !phrase.isEmpty, phrase.count <= maxPhraseLength else { return nil }
        return phrase
    }

    private func saveCounts() {
        if let data = try? JSONEncoder().encode(counts) {
            defaults.set(data, forKey: Key.counts)
        }
    }

    private func saveCustomPhrases() {
        if let data = try? JSONEncoder().encode(customPhrases), let string = String(data: data, encoding: .utf8) {
            defaults.set(string, forKey: Key.customPhrases)
        }
    }
}
