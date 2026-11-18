//
//  OccasionsTests.swift
//  Tasbee7Tests
//
//  The "occasion of the day" card: the right days, and never a fasting suggestion on a day when fasting
//  isn't allowed (the two Eids and the days of Tashreeq). Hijri days are built with the same
//  Umm al-Qura calendar the app uses, so the tests don't depend on a hand-made date table.
//

import Foundation
import Testing
@testable import Tasbee7

@MainActor
@Suite("Today: occasions")
struct OccasionsTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Riyadh")!
        return calendar
    }

    private func gregorian(_ year: Int, _ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 12))!
    }

    private func hijri(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var hijri = Calendar(identifier: .islamicUmmAlQura)
        hijri.timeZone = calendar.timeZone
        return hijri.date(from: DateComponents(year: year, month: month, day: day, hour: 12))!
    }

    private func kinds(_ date: Date) -> [Occasion.Kind] {
        Occasions.on(date, calendar: calendar).map(\.kind)
    }

    private let fastingKinds: Set<Occasion.Kind> = [
        .whiteDays, .whiteDaysTomorrow, .mondayFast, .thursdayFast, .mondayTomorrow, .thursdayTomorrow,
    ]

    @Test("Friday brings Surat al-Kahf and salawat")
    func friday() {
        // 20 November 2026 is a Friday.
        let occasions = Occasions.on(gregorian(2026, 11, 20), calendar: calendar)
        let friday = occasions.first { $0.kind == .friday }
        #expect(friday != nil)
        #expect(friday?.detail.contains("الكهف") == true)
    }

    @Test("Monday and Thursday fasting, and a reminder the day before")
    func weeklyFasting() {
        #expect(kinds(gregorian(2026, 11, 16)).contains(.mondayFast))      // Monday
        #expect(kinds(gregorian(2026, 11, 19)).contains(.thursdayFast))    // Thursday
        #expect(kinds(gregorian(2026, 11, 15)).contains(.mondayTomorrow))  // Sunday
        #expect(kinds(gregorian(2026, 11, 18)).contains(.thursdayTomorrow)) // Wednesday
        let tuesday = kinds(gregorian(2026, 11, 17))
        #expect(!tuesday.contains(.mondayFast) && !tuesday.contains(.thursdayFast))
        #expect(!tuesday.contains(.mondayTomorrow) && !tuesday.contains(.thursdayTomorrow))
    }

    @Test("The white days are the 13th, 14th and 15th, with notice on the 12th")
    func whiteDays() {
        for day in 13...15 {
            #expect(kinds(hijri(1448, 6, day)).contains(.whiteDays), "Day \(day)")
        }
        #expect(kinds(hijri(1448, 6, 12)).contains(.whiteDaysTomorrow))
        #expect(!kinds(hijri(1448, 6, 16)).contains(.whiteDays))
    }

    @Test("Ramadan, and its last ten nights from the 21st")
    func ramadan() {
        #expect(kinds(hijri(1448, 9, 5)).contains(.ramadan))
        #expect(!kinds(hijri(1448, 9, 5)).contains(.lastTenNights))
        #expect(kinds(hijri(1448, 9, 25)).contains(.lastTenNights))
        // Everyone is fasting already: no extra fasting suggestions.
        for day in 1...29 {
            #expect(kinds(hijri(1448, 9, day)).allSatisfy { !fastingKinds.contains($0) }, "Day \(day)")
        }
    }

    @Test("Arafah, the ten days, Eid and Tashreeq")
    func dhulHijjah() {
        #expect(kinds(hijri(1448, 12, 3)).contains(.dhulHijjahTen))
        let arafah = Occasions.on(hijri(1448, 12, 9), calendar: calendar).first { $0.kind == .arafah }
        #expect(arafah?.chapterTitle == "الدعاء يوم عرفة")
        #expect(kinds(hijri(1448, 12, 10)).first == .eidAdha)
        #expect(kinds(hijri(1448, 12, 12)).first == .tashreeq)
        #expect(kinds(hijri(1447, 10, 1)).first == .eidFitr)
        #expect(kinds(hijri(1447, 10, 5)).contains(.shawwalSix))
        #expect(kinds(hijri(1448, 1, 10)).contains(.ashura))
        #expect(kinds(hijri(1448, 1, 9)).contains(.tasua))
    }

    @Test("Never suggests fasting on Eid or the days of Tashreeq, even on a Monday or the 13th")
    func noFastingOnForbiddenDays() {
        let forbidden = [hijri(1447, 10, 1), hijri(1448, 10, 1)]
            + (10...13).flatMap { [hijri(1447, 12, $0), hijri(1448, 12, $0), hijri(1449, 12, $0)] }
        for date in forbidden {
            #expect(kinds(date).allSatisfy { $0 != .whiteDays && $0 != .mondayFast && $0 != .thursdayFast })
        }
        // And no "fast tomorrow" when tomorrow is one of them.
        for date in forbidden {
            let eve = calendar.date(byAdding: .day, value: -1, to: date)!
            #expect(!kinds(eve).contains(.mondayTomorrow) && !kinds(eve).contains(.thursdayTomorrow))
        }
    }

    @Test("Chapters that occasions link to exist in the book")
    func linkedChaptersExist() throws {
        let titles = Set(try AthkarLoader.load().map(\.title))
        var start = hijri(1447, 9, 1)
        var seen: Set<String> = []
        // A whole Hijri year plus Fridays covers every occasion.
        for _ in 0..<400 {
            for occasion in Occasions.on(start, calendar: calendar) {
                if let chapter = occasion.chapterTitle { seen.insert(chapter) }
            }
            start = calendar.date(byAdding: .day, value: 1, to: start)!
        }
        #expect(seen.count >= 3)
        for chapter in seen {
            #expect(titles.contains(chapter), "Missing chapter: \(chapter)")
        }
    }
}
