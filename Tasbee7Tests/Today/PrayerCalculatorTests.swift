//
//  PrayerCalculatorTests.swift
//  Tasbee7Tests
//
//  Prayer times against an independent reference: NOAA's solar position (Meeus) with each moment found by
//  bisection on the sun's real altitude. The app uses a different, lighter formula, so agreeing within
//  two minutes means both are right. Also checks the order of the day, Umm al-Qura's Isha, Ramadan,
//  daylight saving, high latitudes and impossible places.
//

import Foundation
import Testing
@testable import Tasbee7

struct PrayerReference: CustomTestStringConvertible, Sendable {
    let name: String
    let latitude: Double
    let longitude: Double
    let timeZone: String
    let method: CalculationMethod
    let asr: AsrMethod
    let day: (Int, Int, Int)
    /// fajr, sunrise, dhuhr, asr, maghrib, isha as "HH:mm:ss" local time; nil isha = computed from Maghrib.
    let expected: [String?]

    var testDescription: String { name }
}

let prayerReferences: [PrayerReference] = [
    PrayerReference(name: "Makkah, Umm al-Qura", latitude: 21.4225, longitude: 39.8262, timeZone: "Asia/Riyadh",
        method: .ummAlQura, asr: .standard, day: (2026, 11, 18),
        expected: ["05:13:53", "06:33:21", "12:05:48", "15:15:36", "17:38:04", nil]),
    PrayerReference(name: "Cairo, Egyptian, summer time", latitude: 30.0444, longitude: 31.2357, timeZone: "Africa/Cairo",
        method: .egyptian, asr: .standard, day: (2026, 6, 21),
        expected: ["04:08:11", "05:54:22", "12:56:51", "16:32:24", "19:59:22", "21:32:58"]),
    PrayerReference(name: "London, MWL", latitude: 51.5074, longitude: -0.1278, timeZone: "Europe/London",
        method: .muslimWorldLeague, asr: .standard, day: (2026, 11, 18),
        expected: ["05:25:33", "07:23:30", "11:45:38", "13:45:30", "16:07:16", "17:58:37"]),
    PrayerReference(name: "Berlin, MWL, Hanafi Asr", latitude: 52.52, longitude: 13.405, timeZone: "Europe/Berlin",
        method: .muslimWorldLeague, asr: .hanafi, day: (2026, 3, 20),
        expected: ["04:12:58", "06:09:14", "12:13:49", "16:20:14", "18:19:28", "20:09:03"]),
    PrayerReference(name: "New York, ISNA", latitude: 40.7128, longitude: -74.006, timeZone: "America/New_York",
        method: .northAmerica, asr: .standard, day: (2026, 3, 20),
        expected: ["05:43:55", "06:59:16", "13:03:23", "16:29:05", "19:08:12", "20:23:46"]),
    PrayerReference(name: "Jakarta, south of the equator", latitude: -6.2088, longitude: 106.8456, timeZone: "Asia/Jakarta",
        method: .muslimWorldLeague, asr: .standard, day: (2026, 12, 21),
        expected: ["04:19:35", "05:35:56", "11:50:32", "15:17:56", "18:05:09", "19:17:00"]),
    PrayerReference(name: "Sydney, far east and south", latitude: -33.8688, longitude: 151.2093, timeZone: "Australia/Sydney",
        method: .muslimWorldLeague, asr: .standard, day: (2026, 1, 15),
        expected: ["04:19:11", "05:59:29", "13:04:25", "16:49:07", "20:09:00", "21:42:33"]),
]

@MainActor
@Suite("Today: prayer times")
struct PrayerCalculatorTests {
    private static func noon(_ day: (Int, Int, Int), in timeZone: TimeZone) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return calendar.date(from: DateComponents(year: day.0, month: day.1, day: day.2, hour: 12))!
    }

    private static func date(_ clock: String, on day: (Int, Int, Int), in timeZone: TimeZone) -> Date {
        let parts = clock.split(separator: ":").compactMap { Int($0) }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return calendar.date(from: DateComponents(
            year: day.0, month: day.1, day: day.2, hour: parts[0], minute: parts[1], second: parts[2]
        ))!
    }

    @Test("Matches the independent reference within two minutes", arguments: prayerReferences)
    func matchesReference(_ reference: PrayerReference) throws {
        let zone = try #require(TimeZone(identifier: reference.timeZone))
        let times = try #require(PrayerCalculator.times(
            latitude: reference.latitude, longitude: reference.longitude,
            on: Self.noon(reference.day, in: zone), timeZone: zone,
            method: reference.method, asr: reference.asr
        ))
        for (prayer, expected) in zip(Prayer.allCases, reference.expected) {
            guard let expected else { continue }
            let difference = times.time(of: prayer).timeIntervalSince(Self.date(expected, on: reference.day, in: zone))
            #expect(abs(difference) <= 120, "\(prayer.name) is off by \(Int(difference)) s")
        }
    }

    @Test("Umm al-Qura: Isha is 90 minutes after Maghrib, 120 in Ramadan")
    func ummAlQuraIsha() throws {
        let zone = try #require(TimeZone(identifier: "Asia/Riyadh"))
        var hijri = Calendar(identifier: .islamicUmmAlQura)
        hijri.timeZone = zone

        let ordinary = try #require(hijri.date(from: DateComponents(year: 1448, month: 5, day: 10, hour: 12)))
        let ramadan = try #require(hijri.date(from: DateComponents(year: 1448, month: 9, day: 10, hour: 12)))

        for (date, minutes) in [(ordinary, 90.0), (ramadan, 120.0)] {
            let times = try #require(PrayerCalculator.times(
                latitude: 21.4225, longitude: 39.8262, on: date, timeZone: zone, method: .ummAlQura
            ))
            #expect(abs(times.isha.timeIntervalSince(times.maghrib) - minutes * 60) < 1)
        }
    }

    @Test("Every day of the year, the times come in order", arguments: [
        (21.4225, 39.8262, "Asia/Riyadh"),
        (52.52, 13.405, "Europe/Berlin"),
        (59.9139, 10.7522, "Europe/Oslo"),
        (-33.8688, 151.2093, "Australia/Sydney"),
        (40.7128, -74.006, "America/New_York"),
    ])
    func timesAreInOrder(latitude: Double, longitude: Double, zoneID: String) throws {
        let zone = try #require(TimeZone(identifier: zoneID))
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = zone
        let start = calendar.date(from: DateComponents(year: 2026, month: 1, day: 1, hour: 12))!
        for offset in 0..<365 {
            let day = calendar.date(byAdding: .day, value: offset, to: start)!
            for method in CalculationMethod.allCases {
                let times = try #require(PrayerCalculator.times(
                    latitude: latitude, longitude: longitude, on: day, timeZone: zone, method: method
                ))
                let moments = times.all.map(\.time)
                #expect(moments == moments.sorted(), "Out of order on day \(offset) with \(method)")
                #expect(calendar.isDate(times.dhuhr, inSameDayAs: day))
            }
        }
    }

    @Test("High latitudes in summer: Fajr and Isha stay within the night instead of disappearing")
    func highLatitudeSummer() throws {
        let zone = try #require(TimeZone(identifier: "Europe/Berlin"))
        let times = try #require(PrayerCalculator.times(
            latitude: 52.52, longitude: 13.405, on: Self.noon((2026, 6, 21), in: zone), timeZone: zone
        ))
        // The sun never gets 18° below the horizon in Berlin in June; the night is shared out instead.
        let night = 24 * 3600 - times.maghrib.timeIntervalSince(times.sunrise)
        #expect(times.sunrise.timeIntervalSince(times.fajr) <= 18.0 / 60 * night + 1)
        #expect(times.isha.timeIntervalSince(times.maghrib) <= 17.0 / 60 * night + 1)
        #expect(times.fajr < times.sunrise)
        #expect(times.isha > times.maghrib)
    }

    @Test("Daylight saving moves the clock times by an hour, not the sun")
    func daylightSaving() throws {
        let zone = try #require(TimeZone(identifier: "Europe/London"))
        let before = try #require(PrayerCalculator.times(
            latitude: 51.5074, longitude: -0.1278, on: Self.noon((2026, 3, 28), in: zone), timeZone: zone))
        let after = try #require(PrayerCalculator.times(
            latitude: 51.5074, longitude: -0.1278, on: Self.noon((2026, 3, 29), in: zone), timeZone: zone))

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = zone
        let hourBefore = calendar.component(.hour, from: before.dhuhr)
        let hourAfter = calendar.component(.hour, from: after.dhuhr)
        #expect(hourBefore == 12)
        #expect(hourAfter == 13)
        // In absolute time the sun barely moves from one day to the next.
        #expect(abs(after.dhuhr.timeIntervalSince(before.dhuhr) - 24 * 3600) < 60)
    }

    @Test("No times where the sun doesn't rise or set")
    func polarNight() throws {
        let zone = try #require(TimeZone(identifier: "Europe/Oslo"))
        #expect(PrayerCalculator.times(
            latitude: 69.6492, longitude: 18.9553, on: Self.noon((2026, 12, 21), in: zone), timeZone: zone) == nil)
        #expect(PrayerCalculator.times(
            latitude: 69.6492, longitude: 18.9553, on: Self.noon((2026, 6, 21), in: zone), timeZone: zone) == nil)
    }

    @Test("Impossible places give no times instead of NaN dates", arguments: [
        (Double.nan, 0.0), (0.0, Double.infinity), (91.0, 0.0), (0.0, -181.0)
    ])
    func impossiblePlaces(latitude: Double, longitude: Double) {
        #expect(PrayerCalculator.times(latitude: latitude, longitude: longitude, on: .now) == nil)
    }

    @Test("The first method follows the region")
    func recommendedMethod() {
        #expect(CalculationMethod.recommended(forRegion: "SA") == .ummAlQura)
        #expect(CalculationMethod.recommended(forRegion: "eg") == .egyptian)
        #expect(CalculationMethod.recommended(forRegion: "PK") == .karachi)
        #expect(CalculationMethod.recommended(forRegion: "US") == .northAmerica)
        #expect(CalculationMethod.recommended(forRegion: "TR") == .turkey)
        #expect(CalculationMethod.recommended(forRegion: "DE") == .muslimWorldLeague)
        #expect(CalculationMethod.recommended(forRegion: nil) == .muslimWorldLeague)
    }

    @Test("Settings remember the method and ignore junk")
    func settingsPersist() {
        let storage = IsolatedDefaults()
        let settings = PrayerSettings(defaults: storage.defaults, region: "SA")
        #expect(settings.method == .ummAlQura)
        settings.method = .egyptian
        settings.asr = .hanafi
        let reloaded = PrayerSettings(defaults: storage.defaults, region: "SA")
        #expect(reloaded.method == .egyptian)
        #expect(reloaded.asr == .hanafi)

        storage.defaults.set("not-a-method", forKey: "prayer.method")
        #expect(PrayerSettings(defaults: storage.defaults, region: "DE").method == .muslimWorldLeague)
    }

    @Test("Next and current prayer")
    func nextAndCurrent() throws {
        let zone = try #require(TimeZone(identifier: "Asia/Riyadh"))
        let times = try #require(PrayerCalculator.times(
            latitude: 21.4225, longitude: 39.8262, on: Self.noon((2026, 11, 18), in: zone), timeZone: zone,
            method: .ummAlQura))

        let afterSunrise = times.sunrise.addingTimeInterval(60)
        #expect(times.nextPrayer(after: afterSunrise)?.prayer == .dhuhr) // sunrise is skipped
        #expect(times.currentPrayer(at: afterSunrise) == .fajr)
        #expect(times.nextPrayer(after: times.fajr.addingTimeInterval(-60))?.prayer == .fajr)
        #expect(times.currentPrayer(at: times.fajr.addingTimeInterval(-60)) == nil)
        #expect(times.nextPrayer(after: times.isha.addingTimeInterval(1)) == nil)
        #expect(times.currentPrayer(at: times.isha.addingTimeInterval(1)) == .isha)
    }
}
