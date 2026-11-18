//
//  DailyProgressTests.swift
//  Tasbee7Tests
//
//  Ticking athkar in a daily sitting, continuing where you left off, the tasbih count for today,
//  and the ayah of the day.
//

import Foundation
import Testing
@testable import Tasbee7

@MainActor
@Suite("Today: progress, tasbih and ayah")
struct DailyProgressTests {
    private let storage = IsolatedDefaults()
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Berlin")!
        return calendar
    }

    private func day(_ day: Int, hour: Int = 9) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 11, day: day, hour: hour))!
    }

    @Test("Ticks count, continue from the first open one, and survive a restart")
    func ticking() {
        let store = DailyProgressStore(defaults: storage.defaults, calendar: calendar)
        let morning = DailyKey(kind: .morning, day: "2026-11-18")
        let evening = DailyKey(kind: .evening, day: "2026-11-18")

        #expect(store.firstOpen(in: morning, total: 25) == 0)
        for id in 0..<7 { store.setDone(true, id: id, in: morning, now: day(18)) }
        store.toggle(9, in: morning, now: day(18))

        #expect(store.doneCount(in: morning, total: 25) == 8)
        #expect(store.firstOpen(in: morning, total: 25) == 7)
        // Morning and evening read the same chapter but count apart.
        #expect(store.doneCount(in: evening) == 0)

        let reopened = DailyProgressStore(defaults: storage.defaults, calendar: calendar)
        #expect(reopened.doneCount(in: morning) == 8)
        #expect(reopened.isDone(9, in: morning))

        reopened.toggle(9, in: morning, now: day(18))
        #expect(!reopened.isDone(9, in: morning))
        for id in 0..<25 { reopened.setDone(true, id: id, in: morning, now: day(18)) }
        #expect(reopened.firstOpen(in: morning, total: 25) == nil)

        reopened.reset(morning, now: day(18))
        #expect(reopened.doneCount(in: morning) == 0)
    }

    @Test("Only the last two weeks are kept")
    func oldDaysArePruned() {
        let store = DailyProgressStore(defaults: storage.defaults, calendar: calendar)
        let old = DailyKey(kind: .sleep, day: "2026-10-01")
        let recent = DailyKey(kind: .sleep, day: "2026-11-10")
        store.setDone(true, id: 0, in: old, now: day(1))
        store.setDone(true, id: 0, in: recent, now: day(18))
        #expect(store.doneCount(in: old) == 0)
        #expect(store.doneCount(in: recent) == 1)
    }

    @Test("A tampered file can't add junk keys, negative ids or huge ids")
    func tamperedStorage() throws {
        let junk: [String: [Int]] = [
            "2026-11-18.morning": [0, 1, -5, 100_000],
            "lunch": [1, 2],
            "2026-11-18.party": [3],
        ]
        storage.defaults.set(try JSONEncoder().encode(junk), forKey: "today.progress")
        let store = DailyProgressStore(defaults: storage.defaults, calendar: calendar)
        #expect(store.done.keys.sorted() == ["2026-11-18.morning"])
        #expect(store.doneCount(in: DailyKey(kind: .morning, day: "2026-11-18")) == 2)

        storage.defaults.set(Data("not json".utf8), forKey: "today.progress")
        #expect(DailyProgressStore(defaults: storage.defaults, calendar: calendar).done.isEmpty)
    }

    @Test("Today's tasbih counts every phrase and starts again the next day")
    func tasbihToday() {
        let store = SebhaStore(defaults: storage.defaults, calendar: calendar)
        for _ in 0..<5 { store.increment(now: day(18)) }
        store.select("الحمد لله")
        for _ in 0..<3 { store.increment(now: day(18, hour: 22)) }
        #expect(store.todayCount(on: day(18)) == 8)
        #expect(store.todayCount(on: day(19)) == 0)

        store.increment(now: day(19))
        #expect(store.todayCount(on: day(19)) == 1)
        // Survives a restart.
        #expect(SebhaStore(defaults: storage.defaults, calendar: calendar).todayCount(on: day(19)) == 1)
    }

    @Test("The ayah list ships with the app, verbatim from Tanzil, with its source")
    func ayatShip() throws {
        let ayat = AyahOfTheDay.load()
        #expect(ayat.count >= 30)
        for ayah in ayat {
            #expect((1...114).contains(ayah.surahNumber))
            #expect(ayah.ayah >= 1)
            #expect(!ayah.surah.isEmpty)
            #expect(!ayah.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            let scalars = ayah.text.unicodeScalars.map(\.value)
            #expect(scalars.allSatisfy { !SecurityTestSupport.invisibleFormattingScalars.contains($0) })
        }
        let url = try #require(Bundle.main.url(forResource: "ayat_of_the_day", withExtension: "json"))
        let raw = try String(contentsOf: url, encoding: .utf8)
        #expect(raw.contains("Tanzil"))
    }

    @Test("Same ayah all day, another the next day, and every ayah within one cycle")
    func ayahRotation() {
        let ayat = AyahOfTheDay.load()
        guard !ayat.isEmpty else {
            Issue.record("No ayat")
            return
        }
        #expect(AyahOfTheDay.pick(from: ayat, on: day(18, hour: 1), calendar: calendar)
            == AyahOfTheDay.pick(from: ayat, on: day(18, hour: 23), calendar: calendar))
        #expect(AyahOfTheDay.pick(from: ayat, on: day(18), calendar: calendar)
            != AyahOfTheDay.pick(from: ayat, on: day(19), calendar: calendar))

        var seen: Set<Ayah> = []
        for offset in 0..<ayat.count {
            let date = calendar.date(byAdding: .day, value: offset, to: day(1))!
            if let ayah = AyahOfTheDay.pick(from: ayat, on: date, calendar: calendar) { seen.insert(ayah) }
        }
        #expect(seen.count == ayat.count)
        #expect(AyahOfTheDay.pick(from: [], on: .now) == nil)
    }
}
