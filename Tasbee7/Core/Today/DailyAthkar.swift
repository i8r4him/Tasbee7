//
//  DailyAthkar.swift
//  Tasbee7
//
//  Which athkar fit "now": morning from Fajr, evening from Asr, sleep from Isha until the next Fajr.
//  Each sitting has a key (its day plus its kind) that its progress is saved under.
//

import Foundation

enum DailyAthkar: String, CaseIterable, Identifiable, Hashable {
    case morning, evening, sleep

    var id: Self { self }

    /// The chapter in the book that this sitting reads.
    var chapterTitle: String {
        switch self {
        case .morning, .evening: AthkarCatalog.morningEveningTitle
        case .sleep: AthkarCatalog.sleepTitle
        }
    }

    var title: String {
        switch self {
        case .morning: "أذكار الصباح"
        case .evening: "أذكار المساء"
        case .sleep: "أذكار النوم"
        }
    }

    var line: String {
        switch self {
        case .morning: "ابدأ يومك بذكر الله."
        case .evening: "اختم نهارك بذكر الله."
        case .sleep: "نَم على ذكر الله."
        }
    }

    var systemImage: String {
        switch self {
        case .morning: "sun.horizon.fill"
        case .evening: "sunset.fill"
        case .sleep: "moon.zzz.fill"
        }
    }

    /// The reminder that belongs to this sitting, if there is one.
    var reminder: ReminderKind? {
        switch self {
        case .morning: .morning
        case .evening: .evening
        case .sleep: nil
        }
    }
}

/// One sitting on one day, e.g. the evening athkar of 18 November. Progress is saved under `storageKey`.
struct DailyKey: Hashable {
    let kind: DailyAthkar
    /// The day the sitting belongs to, as yyyy-MM-dd. Sleep athkar after midnight belong to the evening before.
    let day: String

    var storageKey: String { "\(day).\(kind.rawValue)" }

    init(kind: DailyAthkar, day: String) {
        self.kind = kind
        self.day = day
    }

    init?(storageKey: String) {
        let parts = storageKey.split(separator: ".", maxSplits: 1).map(String.init)
        guard parts.count == 2, let kind = DailyAthkar(rawValue: parts[1]), DailyKey.date(from: parts[0]) != nil else {
            return nil
        }
        self.init(kind: kind, day: parts[0])
    }

    static func dayString(for date: Date, calendar: Calendar) -> String {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", parts.year ?? 0, parts.month ?? 0, parts.day ?? 0)
    }

    static func date(from day: String) -> DateComponents? {
        let parts = day.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3, (1...12).contains(parts[1]), (1...31).contains(parts[2]) else { return nil }
        return DateComponents(year: parts[0], month: parts[1], day: parts[2])
    }
}

enum DailySchedule {
    /// Used when the place isn't known: Fajr 4:30, Asr 15:30, Isha 19:30 local time.
    static let fallbackHours = (fajr: 4.5, asr: 15.5, isha: 19.5)

    /// The sitting that fits `date`.
    /// - Parameter prayers: a function giving the prayer times for a day, or nil when the place isn't known.
    static func current(
        at date: Date,
        calendar: Calendar = .current,
        prayers: @MainActor (Date) -> PrayerTimes?
    ) -> DailyKey {
        let today = boundaries(on: date, calendar: calendar, prayers: prayers)
        let todayString = DailyKey.dayString(for: date, calendar: calendar)

        if date < today.fajr {
            // Before dawn: still the night that began yesterday.
            let yesterday = calendar.date(byAdding: .day, value: -1, to: date) ?? date
            return DailyKey(kind: .sleep, day: DailyKey.dayString(for: yesterday, calendar: calendar))
        }
        if date < today.asr { return DailyKey(kind: .morning, day: todayString) }
        if date < today.isha { return DailyKey(kind: .evening, day: todayString) }
        return DailyKey(kind: .sleep, day: todayString)
    }

    /// The three sittings of the day that `date` falls in, morning first.
    static func keys(forDayOf date: Date, calendar: Calendar = .current) -> [DailyKey] {
        let day = DailyKey.dayString(for: date, calendar: calendar)
        return DailyAthkar.allCases.map { DailyKey(kind: $0, day: day) }
    }

    private static func boundaries(
        on date: Date,
        calendar: Calendar,
        prayers: @MainActor (Date) -> PrayerTimes?
    ) -> (fajr: Date, asr: Date, isha: Date) {
        if let times = prayers(date) {
            return (times.fajr, times.asr, times.isha)
        }
        let midnight = calendar.startOfDay(for: date)
        func at(_ hours: Double) -> Date {
            calendar.date(byAdding: .minute, value: Int(hours * 60), to: midnight) ?? midnight
        }
        return (at(fallbackHours.fajr), at(fallbackHours.asr), at(fallbackHours.isha))
    }
}

extension PrayerTimes {
    /// The next of the five prayers after `date` today, if any is left.
    func nextPrayer(after date: Date) -> PrayerTime? {
        all.first { $0.prayer.isPrayer && $0.time > date }
    }

    /// The prayer whose time it is now (the last one that has started), if any has started today.
    func currentPrayer(at date: Date) -> Prayer? {
        all.last { $0.prayer.isPrayer && $0.time <= date }?.prayer
    }
}
