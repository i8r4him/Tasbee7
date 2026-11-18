//
//  RemindersPerformanceTests.swift
//  Tasbee7Tests
//
//  Reminders are re-scheduled every time the app becomes active: 2 kinds × 30 days of
//  sunrise and sunset. This must never make opening the app feel slow.
//

import XCTest
@testable import Tasbee7

@MainActor
final class RemindersPerformanceTests: XCTestCase {
    private struct Place {
        let latitude: Double
        let longitude: Double
        let timeZone: TimeZone
    }

    private let places = [
        Place(latitude: 21.4225, longitude: 39.8262, timeZone: TimeZone(identifier: "Asia/Riyadh")!),   // Makkah
        Place(latitude: 51.5074, longitude: -0.1278, timeZone: TimeZone(identifier: "Europe/London")!), // London (DST)
        Place(latitude: -6.2088, longitude: 106.8456, timeZone: TimeZone(identifier: "Asia/Jakarta")!), // Jakarta
        Place(latitude: 69.6492, longitude: 18.9553, timeZone: TimeZone(identifier: "Europe/Oslo")!),   // Tromsø (polar day and night)
    ]

    private func days(_ count: Int) -> [Date] {
        let calendar = Calendar(identifier: .gregorian)
        let start = calendar.date(from: DateComponents(year: 2026, month: 1, day: 1, hour: 12))!
        return (0..<count).map { calendar.date(byAdding: .day, value: $0, to: start)! }
    }

    func testSunTimesForAWholeYearInSeveralPlaces() {
        let year = days(365)
        measure(metrics: [XCTClockMetric(), XCTCPUMetric()]) {
            for place in places {
                for day in year {
                    _ = SolarCalculator.sunTimes(latitude: place.latitude, longitude: place.longitude, on: day, timeZone: place.timeZone)
                }
            }
        }
    }

    func testAYearOfSunTimesStaysWithinBudget() {
        let year = days(365)
        let makkah = places[0]
        assertMedianTime(under: Budget.solarYear, "A year of sun times") {
            for day in year {
                _ = SolarCalculator.sunTimes(latitude: makkah.latitude, longitude: makkah.longitude, on: day, timeZone: makkah.timeZone)
            }
        }
    }

    /// What one reschedule computes: morning and evening for the next 30 days.
    func testOneRescheduleWorthOfTimesStaysWithinBudget() {
        let month = days(30)
        let makkah = places[0]
        assertMedianTime(under: Budget.reminderTimes, "60 reminder times") {
            for day in month {
                guard let sun = SolarCalculator.sunTimes(latitude: makkah.latitude, longitude: makkah.longitude, on: day, timeZone: makkah.timeZone) else {
                    continue
                }
                _ = sun.sunrise.addingTimeInterval(TimeInterval(ReminderScheduler.offsetMinutes * 60))
                _ = sun.sunset.addingTimeInterval(TimeInterval(ReminderScheduler.offsetMinutes * 60))
            }
        }
    }
}
