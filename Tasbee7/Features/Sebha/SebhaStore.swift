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

    var target: Int {
        didSet { defaults.set(target, forKey: Key.target) }
    }

    var hapticsEnabled: Bool {
        didSet { defaults.set(hapticsEnabled, forKey: Key.haptics) }
    }

    var soundEnabled: Bool {
        didSet { defaults.set(soundEnabled, forKey: Key.sound) }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        let custom = defaults.string(forKey: Key.customPhrases)
            .flatMap { $0.data(using: .utf8) }
            .flatMap { try? JSONDecoder().decode([String].self, from: $0) } ?? []
        customPhrases = custom

        let all = Self.basePhrases + custom
        let storedTarget = defaults.integer(forKey: Key.target)
        target = storedTarget > 0 ? storedTarget : 33
        hapticsEnabled = defaults.object(forKey: Key.haptics) as? Bool ?? true
        soundEnabled = defaults.object(forKey: Key.sound) as? Bool ?? true

        if let selected = defaults.string(forKey: Key.selected), all.contains(selected) {
            selectedPhrase = selected
        } else {
            let index = defaults.integer(forKey: Key.legacyPhraseIndex)
            selectedPhrase = all.indices.contains(index) ? all[index] : all[0]
        }

        if let data = defaults.data(forKey: Key.counts),
           let stored = try? JSONDecoder().decode([String: Int].self, from: data) {
            counts = stored
        } else {
            // Carry the old shared counter over to the phrase that was selected.
            let legacy = defaults.integer(forKey: Key.legacyCounter)
            counts = legacy > 0 ? [selectedPhrase: legacy] : [:]
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

    func increment() {
        counts[selectedPhrase, default: 0] += 1
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

    /// Adds a phrase and selects it. Returns false when it's empty or already there.
    @discardableResult
    func addPhrase(_ text: String) -> Bool {
        let phrase = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !phrase.isEmpty, !allPhrases.contains(phrase) else { return false }
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
