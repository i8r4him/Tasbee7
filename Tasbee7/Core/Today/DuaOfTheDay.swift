//
//  DuaOfTheDay.swift
//  Tasbee7
//
//  One dua a day, taken from general-purpose chapters of Hisn al-Muslim that are already in the app.
//

import Foundation

struct DailyDua: Hashable {
    let text: String
    let chapterTitle: String

    var shareText: String { "\(text)\n\n\(chapterTitle) · حصن المسلم" }
}

enum DuaOfTheDay {
    /// Chapters whose duas suit any day. Their order is the rotation order.
    static let chapterTitles = [
        "الدعاء بعد التشهد الأخير وقبل السلام",
        "دعاء الهم والحزن",
        "دعاء الكرب",
        "دعاء من استصعب عليه أمر",
        "دعاء من أصيب بمصيبة",
        "الدعاء قضاء الدين",
    ]

    /// Every dua in the rotation, in order. Chapters missing from the book are skipped.
    static func pool(from sections: @MainActor (String) -> AthkarSection?) -> [DailyDua] {
        chapterTitles.flatMap { title in
            (sections(title)?.athkar ?? []).map { DailyDua(text: $0.text, chapterTitle: title) }
        }
        .filter { !$0.text.isEmpty }
    }

    /// The same dua all day, the next one tomorrow, round and round.
    static func pick(from pool: [DailyDua], on date: Date, calendar: Calendar = .current) -> DailyDua? {
        guard !pool.isEmpty else { return nil }
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        let days = Int(PrayerCalculator.julianDay(year: parts.year ?? 2000, month: parts.month ?? 1, day: parts.day ?? 1))
        return pool[((days % pool.count) + pool.count) % pool.count]
    }
}
