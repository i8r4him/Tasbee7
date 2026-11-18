//
//  TodayContentTests.swift
//  Tasbee7Tests
//
//  The greeting for the time of day, the dua of the day and the shortcut chapters.
//

import Foundation
import Testing
@testable import Tasbee7

@MainActor
@Suite("Today: greeting, dua and shortcuts")
struct TodayContentTests {
    @Test("Morning greeting from 4 am to noon, evening greeting otherwise", arguments: [
        (3, Greeting.night), (4, Greeting.morning), (11, Greeting.morning),
        (12, Greeting.afternoon), (17, Greeting.afternoon), (18, Greeting.night), (23, Greeting.night),
    ])
    func greeting(hour: Int, expected: Greeting) {
        #expect(Greeting(hour: hour) == expected)
        #expect(Greeting(hour: hour).text == (expected == .morning ? "صباح الخير" : "مساء الخير"))
    }

    @Test("Every dua chapter exists, and the pool isn't empty")
    func duaChaptersExist() throws {
        let sections = try AthkarLoader.load()
        let byTitle = Dictionary(sections.map { ($0.title, $0) }, uniquingKeysWith: { first, _ in first })
        for title in DuaOfTheDay.chapterTitles {
            #expect(byTitle[title] != nil, "Missing chapter: \(title)")
        }
        let pool = DuaOfTheDay.pool { byTitle[$0] }
        #expect(pool.count >= 10)
        #expect(pool.allSatisfy { !$0.text.isEmpty && DuaOfTheDay.chapterTitles.contains($0.chapterTitle) })
    }

    @Test("Same dua all day, another tomorrow, every dua within one cycle")
    func duaRotation() throws {
        let sections = try AthkarLoader.load()
        let byTitle = Dictionary(sections.map { ($0.title, $0) }, uniquingKeysWith: { first, _ in first })
        let pool = DuaOfTheDay.pool { byTitle[$0] }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Berlin")!
        let morning = calendar.date(from: DateComponents(year: 2026, month: 11, day: 18, hour: 1))!
        let night = calendar.date(from: DateComponents(year: 2026, month: 11, day: 18, hour: 23))!
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: morning)!
        #expect(DuaOfTheDay.pick(from: pool, on: morning, calendar: calendar) == DuaOfTheDay.pick(from: pool, on: night, calendar: calendar))
        #expect(DuaOfTheDay.pick(from: pool, on: morning, calendar: calendar) != DuaOfTheDay.pick(from: pool, on: tomorrow, calendar: calendar))

        var seen: Set<DailyDua> = []
        for offset in 0..<pool.count {
            let day = calendar.date(byAdding: .day, value: offset, to: morning)!
            if let dua = DuaOfTheDay.pick(from: pool, on: day, calendar: calendar) { seen.insert(dua) }
        }
        #expect(seen.count == Set(pool).count)
        #expect(DuaOfTheDay.pick(from: [], on: morning) == nil)
    }

    @Test("Every chapter the Today shortcuts open exists in the book")
    func shortcutChaptersExist() throws {
        let titles = Set(try AthkarLoader.load().map(\.title))
        for title in [AthkarCatalog.afterPrayerTitle, AthkarCatalog.wakingTitle,
                      AthkarCatalog.morningEveningTitle, AthkarCatalog.sleepTitle] {
            #expect(titles.contains(title), "Missing chapter: \(title)")
        }
    }
}
