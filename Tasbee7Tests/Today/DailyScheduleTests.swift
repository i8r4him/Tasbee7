//
//  DailyScheduleTests.swift
//  Tasbee7Tests
//
//  The "now" card: morning athkar from Fajr, evening from Asr, sleep from Isha until the next Fajr,
//  each saved under the right day. Also the fallback hours when the place isn't known.
//

import Foundation
import Testing
@testable import Tasbee7

@MainActor
@Suite("Today: time of day")
struct DailyScheduleTests {
    private let zone = TimeZone(identifier: "Asia/Riyadh")!
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = zone
        return calendar
    }

    private func at(_ day: Int, _ hour: Int, _ minute: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 11, day: day, hour: hour, minute: minute))!
    }

    /// Makkah, with Umm al-Qura: Fajr 05:13, Asr 15:15, Isha 19:08 on 18 November.
    private func makkah(_ date: Date) -> PrayerTimes? {
        PrayerCalculator.times(latitude: 21.4225, longitude: 39.8262, on: date, timeZone: zone, method: .ummAlQura)
    }

    @Test("Each part of the day gets its athkar, saved under the right day", arguments: [
        // (hour, minute, kind, day of month the sitting belongs to)
        (0, 30, DailyAthkar.sleep, 17),   // after midnight: still last night
        (5, 0, DailyAthkar.sleep, 17),    // just before Fajr
        (5, 20, DailyAthkar.morning, 18), // just after Fajr
        (12, 0, DailyAthkar.morning, 18),
        (15, 10, DailyAthkar.morning, 18), // just before Asr
        (15, 20, DailyAthkar.evening, 18), // just after Asr
        (19, 0, DailyAthkar.evening, 18),  // just before Isha
        (19, 15, DailyAthkar.sleep, 18),   // just after Isha
        (23, 59, DailyAthkar.sleep, 18),
    ])
    func sittingForTime(hour: Int, minute: Int, kind: DailyAthkar, day: Int) {
        let key = DailySchedule.current(at: at(18, hour, minute), calendar: calendar, prayers: makkah)
        #expect(key.kind == kind)
        #expect(key.day == String(format: "2026-11-%02d", day))
    }

    @Test("Without a place, fixed hours stand in for the prayers", arguments: [
        (3, 0, DailyAthkar.sleep), (4, 40, DailyAthkar.morning), (15, 20, DailyAthkar.morning),
        (15, 40, DailyAthkar.evening), (19, 40, DailyAthkar.sleep),
    ])
    func fallbackHours(hour: Int, minute: Int, kind: DailyAthkar) {
        let key = DailySchedule.current(at: at(18, hour, minute), calendar: calendar) { _ in nil }
        #expect(key.kind == kind)
    }

    @Test("Morning and evening read the morning and evening chapter, sleep reads the sleep chapter")
    func chapters() {
        #expect(DailyAthkar.morning.chapterTitle == AthkarCatalog.morningEveningTitle)
        #expect(DailyAthkar.evening.chapterTitle == AthkarCatalog.morningEveningTitle)
        #expect(DailyAthkar.sleep.chapterTitle == AthkarCatalog.sleepTitle)
    }

    @Test("Every daily chapter exists in the book")
    func chaptersExist() throws {
        let sections = try AthkarLoader.load()
        let titles = Set(sections.map(\.title))
        for kind in DailyAthkar.allCases {
            #expect(titles.contains(kind.chapterTitle), "Missing chapter: \(kind.chapterTitle)")
        }
    }

    @Test("A day has three sittings, morning first")
    func dayKeys() {
        let keys = DailySchedule.keys(forDayOf: at(18, 9), calendar: calendar)
        #expect(keys.map(\.kind) == [.morning, .evening, .sleep])
        #expect(Set(keys.map(\.day)) == ["2026-11-18"])
    }

    @Test("Keys survive a round trip through storage and reject junk")
    func keyStorage() {
        let key = DailyKey(kind: .evening, day: "2026-11-18")
        #expect(DailyKey(storageKey: key.storageKey) == key)
        for junk in ["", "2026-11-18", "2026-11-18.lunch", "yesterday.morning", "2026-13-01.morning", ".morning"] {
            #expect(DailyKey(storageKey: junk) == nil, "Accepted \(junk)")
        }
    }
}
