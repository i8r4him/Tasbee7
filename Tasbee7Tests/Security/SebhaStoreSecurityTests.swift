//
//  SebhaStoreSecurityTests.swift
//  Tasbee7Tests
//
//  The tasbih reads its state from preferences and from text the user types.
//  Neither a corrupted/tampered preferences file nor odd input may crash it or store junk.
//

import Foundation
import Testing
@testable import Tasbee7

@MainActor
@Suite("Security: tasbih input and stored state")
struct SebhaStoreSecurityTests {
    private let storage = IsolatedDefaults()
    private var defaults: UserDefaults { storage.defaults }

    // MARK: - Target (division by zero)

    @Test("A zero, negative or huge stored target is replaced by the default", arguments: [0, -1, -33, Int.min, 100_001, Int.max])
    func invalidStoredTargetIsIgnored(stored: Int) {
        defaults.set(stored, forKey: "sebhaTarget")
        let store = SebhaStore(defaults: defaults)
        #expect(store.target == 33)
        // The round maths divide by target; this must not trap.
        _ = store.rounds
        _ = store.progress
        _ = store.justFinishedRound
    }

    @Test("Setting the target out of range is clamped, never zero", arguments: [0, -5, Int.min, Int.max])
    func targetIsClamped(value: Int) {
        let store = SebhaStore(defaults: defaults)
        store.target = value
        #expect(SebhaStore.targetRange.contains(store.target))
        #expect(SebhaStore.targetRange.contains(defaults.integer(forKey: "sebhaTarget")))
        store.increment()
        _ = store.rounds
        _ = store.progress
    }

    // MARK: - Counts (overflow)

    @Test("Counting past Int.max stops instead of crashing")
    func incrementDoesNotOverflow() throws {
        let phrase = SebhaStore.basePhrases[0]
        defaults.set(try JSONEncoder().encode([phrase: Int.max]), forKey: "sebha.counts")
        let store = SebhaStore(defaults: defaults)
        store.select(phrase)
        store.increment()
        #expect(store.count == Int.max)
    }

    @Test("Negative stored counts are dropped")
    func negativeCountsAreDropped() throws {
        let phrase = SebhaStore.basePhrases[1]
        defaults.set(try JSONEncoder().encode([phrase: -50, SebhaStore.basePhrases[2]: 7]), forKey: "sebha.counts")
        let store = SebhaStore(defaults: defaults)
        #expect(store.count(for: phrase) == 0)
        #expect(store.count(for: SebhaStore.basePhrases[2]) == 7)
    }

    @Test("A negative legacy counter is not carried over")
    func negativeLegacyCounterIsIgnored() {
        defaults.set(-10, forKey: "sebhaCounter")
        let store = SebhaStore(defaults: defaults)
        #expect(store.count == 0)
    }

    @Test("Corrupted stored data falls back to an empty, working state", arguments: [
        "not json", "{", "[1,2,3]", "null", String(repeating: "[", count: 5_000)
    ])
    func corruptedDataIsIgnored(garbage: String) {
        defaults.set(Data(garbage.utf8), forKey: "sebha.counts")
        defaults.set(garbage, forKey: "sebhaCustomPhrases")
        let store = SebhaStore(defaults: defaults)
        #expect(store.customPhrases.isEmpty)
        #expect(store.count == 0)
        store.increment()
        #expect(store.count == 1)
    }

    @Test("An out-of-range legacy phrase index doesn't crash", arguments: [-1, 5, 9_999, Int.max, Int.min])
    func legacyPhraseIndexIsBoundsChecked(index: Int) {
        defaults.set(index, forKey: "sebhaPhraseIndex")
        let store = SebhaStore(defaults: defaults)
        #expect(store.allPhrases.contains(store.selectedPhrase))
    }

    @Test("A stored selected phrase that isn't in the list is ignored")
    func unknownSelectedPhraseIsIgnored() {
        defaults.set("phrase that was never added", forKey: "sebha.selectedPhrase")
        let store = SebhaStore(defaults: defaults)
        #expect(store.selectedPhrase == SebhaStore.basePhrases[0])
    }

    // MARK: - Custom phrases

    @Test("Empty and whitespace-only phrases are rejected", arguments: ["", " ", "\n\t", "\u{202E}", "\u{0000}\u{0007}"])
    func blankPhrasesAreRejected(text: String) {
        let store = SebhaStore(defaults: defaults)
        #expect(!store.addPhrase(text))
        #expect(store.customPhrases.isEmpty)
    }

    @Test("Overly long phrases are rejected")
    func longPhraseIsRejected() {
        let store = SebhaStore(defaults: defaults)
        #expect(!store.addPhrase(String(repeating: "س", count: SebhaStore.maxPhraseLength + 1)))
        #expect(store.addPhrase(String(repeating: "س", count: SebhaStore.maxPhraseLength)))
    }

    @Test("Bidi overrides and control characters are stripped")
    func invisibleCharactersAreStripped() throws {
        let store = SebhaStore(defaults: defaults)
        #expect(store.addPhrase("\u{202E}سبحان\u{0000}  ربي\u{2066} العظيم\u{FEFF}\n"))
        let phrase = try #require(store.customPhrases.last)
        #expect(phrase == "سبحان ربي العظيم")
        let scalars = phrase.unicodeScalars
        #expect(!scalars.contains { SecurityTestSupport.invisibleFormattingScalars.contains($0.value) })
        #expect(!scalars.contains { $0.properties.generalCategory == .control })
    }

    @Test("A disguised duplicate of a built-in phrase is not added")
    func disguisedDuplicateIsRejected() {
        let store = SebhaStore(defaults: defaults)
        #expect(!store.addPhrase("\u{200F}سبحان الله\u{202C}"))
        #expect(store.customPhrases.isEmpty)
    }

    @Test("The number of custom phrases is capped")
    func customPhraseCountIsCapped() {
        let store = SebhaStore(defaults: defaults)
        for index in 0..<SebhaStore.maxCustomPhrases {
            #expect(store.addPhrase("ذكر \(index)"))
        }
        #expect(!store.addPhrase("ذكر إضافي"))
        #expect(store.customPhrases.count == SebhaStore.maxCustomPhrases)
    }

    @Test("Tampered stored phrases are cleaned, deduplicated and capped on load")
    func storedPhrasesAreSanitizedOnLoad() throws {
        var stored = ["\u{202E}ذكر", "ذكر", "", String(repeating: "x", count: 10_000), "سبحان الله"]
        stored += (0..<500).map { "ذكر \($0)" }
        let json = try #require(String(data: JSONEncoder().encode(stored), encoding: .utf8))
        defaults.set(json, forKey: "sebhaCustomPhrases")

        let store = SebhaStore(defaults: defaults)
        #expect(store.customPhrases.first == "ذكر")
        #expect(store.customPhrases.count == SebhaStore.maxCustomPhrases)
        #expect(Set(store.customPhrases).count == store.customPhrases.count)
        #expect(!store.customPhrases.contains("سبحان الله"))
        #expect(store.customPhrases.allSatisfy { !$0.isEmpty && $0.count <= SebhaStore.maxPhraseLength })
    }

    @Test("Deleting a custom phrase also deletes its count")
    func deletingPhraseRemovesItsCount() {
        let store = SebhaStore(defaults: defaults)
        store.addPhrase("ذكر خاص")
        store.increment()
        store.deleteCustomPhrases(at: IndexSet(integer: 0))
        #expect(store.count(for: "ذكر خاص") == 0)
        #expect(store.selectedPhrase == SebhaStore.basePhrases[0])
        let reloaded = SebhaStore(defaults: defaults)
        #expect(reloaded.count(for: "ذكر خاص") == 0)
        #expect(!reloaded.allPhrases.contains("ذكر خاص"))
    }

    @Test("Selecting a phrase that isn't in the list does nothing")
    func selectingUnknownPhraseIsIgnored() {
        let store = SebhaStore(defaults: defaults)
        store.select("غير موجود")
        #expect(store.selectedPhrase == SebhaStore.basePhrases[0])
    }
}
