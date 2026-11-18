//
//  TodayContext.swift
//  Tasbee7
//
//  The user's prayer times and current sitting, from the last known place and their chosen method.
//

import Foundation

enum TodayContext {
    /// Prayer times on the day of `date`, or nil while the place isn't known.
    static func prayerTimes(on date: Date) -> PrayerTimes? {
        guard let coordinate = LocationService.shared.coordinate else { return nil }
        return PrayerSettings.shared.times(at: coordinate, on: date)
    }

    /// The sitting that fits right now (or at `date`).
    static func currentSitting(at date: Date = .now) -> DailyKey {
        DailySchedule.current(at: date) { prayerTimes(on: $0) }
    }
}
