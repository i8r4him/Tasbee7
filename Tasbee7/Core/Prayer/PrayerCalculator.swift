//
//  PrayerCalculator.swift
//  Tasbee7
//
//  The five prayer times (plus sunrise) worked out on the device from the place and the date.
//  Sun position from the U.S. Naval Observatory's approximate formulas (the same ones PrayTimes.org uses),
//  refined twice at each moment, so the result is within about a minute away from the poles.
//  Works in UTC and returns absolute dates, so time zones and daylight saving are always right.
//

import Foundation

enum Prayer: String, CaseIterable, Identifiable, Hashable {
    case fajr, sunrise, dhuhr, asr, maghrib, isha

    var id: Self { self }

    var name: String {
        switch self {
        case .fajr: "الفجر"
        case .sunrise: "الشروق"
        case .dhuhr: "الظهر"
        case .asr: "العصر"
        case .maghrib: "المغرب"
        case .isha: "العشاء"
        }
    }

    var systemImage: String {
        switch self {
        case .fajr: "sun.horizon.fill"
        case .sunrise: "sunrise.fill"
        case .dhuhr: "sun.max.fill"
        case .asr: "sun.min.fill"
        case .maghrib: "sunset.fill"
        case .isha: "moon.stars.fill"
        }
    }

    /// Sunrise is shown with the prayers but isn't one.
    var isPrayer: Bool { self != .sunrise }
}

/// One time of the day: a prayer (or sunrise) and when it is.
struct PrayerTime: Identifiable, Equatable {
    let prayer: Prayer
    let time: Date

    var id: Prayer { prayer }
}

struct PrayerTimes: Equatable {
    let fajr: Date
    let sunrise: Date
    let dhuhr: Date
    let asr: Date
    let maghrib: Date
    let isha: Date

    func time(of prayer: Prayer) -> Date {
        switch prayer {
        case .fajr: fajr
        case .sunrise: sunrise
        case .dhuhr: dhuhr
        case .asr: asr
        case .maghrib: maghrib
        case .isha: isha
        }
    }

    /// All six in order of the day.
    var all: [PrayerTime] {
        Prayer.allCases.map { PrayerTime(prayer: $0, time: time(of: $0)) }
    }
}

/// How Fajr and Isha are found. The angles are how far the sun is below the horizon.
enum CalculationMethod: String, CaseIterable, Identifiable {
    case muslimWorldLeague, ummAlQura, egyptian, karachi, northAmerica, dubai, turkey

    var id: Self { self }

    var name: String {
        switch self {
        case .muslimWorldLeague: "رابطة العالم الإسلامي"
        case .ummAlQura: "أم القرى، مكة المكرمة"
        case .egyptian: "الهيئة المصرية العامة للمساحة"
        case .karachi: "جامعة العلوم الإسلامية، كراتشي"
        case .northAmerica: "الجمعية الإسلامية لأمريكا الشمالية"
        case .dubai: "دبي"
        case .turkey: "رئاسة الشؤون الدينية التركية"
        }
    }

    var fajrAngle: Double {
        switch self {
        case .muslimWorldLeague: 18
        case .ummAlQura: 18.5
        case .egyptian: 19.5
        case .karachi: 18
        case .northAmerica: 15
        case .dubai: 18.2
        case .turkey: 18
        }
    }

    enum Isha: Equatable {
        case angle(Double)
        /// Minutes after Maghrib, and a different number in Ramadan.
        case minutesAfterMaghrib(Double, ramadan: Double)
    }

    var isha: Isha {
        switch self {
        case .muslimWorldLeague: .angle(17)
        case .ummAlQura: .minutesAfterMaghrib(90, ramadan: 120)
        case .egyptian: .angle(17.5)
        case .karachi: .angle(18)
        case .northAmerica: .angle(15)
        case .dubai: .angle(18.2)
        case .turkey: .angle(17)
        }
    }

    /// The method most people in a country follow; the Muslim World League elsewhere.
    static func recommended(forRegion region: String?) -> CalculationMethod {
        switch region?.uppercased() {
        case "SA", "YE", "BH", "OM", "QA", "KW": .ummAlQura
        case "EG", "SD", "LY", "SY", "LB", "IQ", "JO", "PS", "MY": .egyptian
        case "PK", "IN", "BD", "AF": .karachi
        case "US", "CA": .northAmerica
        case "AE": .dubai
        case "TR": .turkey
        default: .muslimWorldLeague
        }
    }
}

/// When the shadow is the length of the object (most schools) or twice it (Hanafi).
enum AsrMethod: String, CaseIterable, Identifiable {
    case standard, hanafi

    var id: Self { self }

    var name: String {
        switch self {
        case .standard: "الجمهور (ظل الشيء مثله)"
        case .hanafi: "الحنفي (ظل الشيء مثلاه)"
        }
    }

    var shadowFactor: Double {
        switch self {
        case .standard: 1
        case .hanafi: 2
        }
    }
}

enum PrayerCalculator {
    /// Prayer times on the calendar day of `date` in `timeZone`.
    /// Returns nil for a place that isn't real, or when the sun doesn't rise or set that day (polar day or night).
    /// Far from the equator, where the sky may never get dark enough for the Fajr or Isha angle in summer,
    /// Fajr and Isha are kept within the "angle-based" share of the night (angle ÷ 60).
    static func times(
        latitude: Double,
        longitude: Double,
        on date: Date,
        timeZone: TimeZone = .current,
        method: CalculationMethod = .muslimWorldLeague,
        asr: AsrMethod = .standard
    ) -> PrayerTimes? {
        guard latitude.isFinite, longitude.isFinite,
              (-90...90).contains(latitude), (-180...180).contains(longitude) else {
            return nil
        }

        var local = Calendar(identifier: .gregorian)
        local.timeZone = timeZone
        let day = local.dateComponents([.year, .month, .day], from: date)
        guard let year = day.year, let month = day.month, let dayOfMonth = day.day else { return nil }

        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = TimeZone(identifier: "UTC")!
        guard let utcMidnight = utc.date(from: DateComponents(year: year, month: month, day: dayOfMonth)) else {
            return nil
        }

        let sky = Sky(julianMidnight: julianDay(year: year, month: month, day: dayOfMonth),
                      latitude: latitude, longitude: longitude)

        // Hours after UTC midnight.
        let noon = sky.noon()
        guard let sunrise = sky.time(altitude: -0.833, beforeNoon: true),
              let sunset = sky.time(altitude: -0.833, beforeNoon: false),
              let asrTime = sky.time(beforeNoon: false, altitudeAt: { declination in
                  // The sun's altitude when a shadow is `factor` times its object plus the noon shadow.
                  let factor = asr.shadowFactor + tan(abs(latitude - declination) * .pi / 180)
                  return atan(1 / factor) * 180 / .pi
              }) else {
            return nil
        }

        let night = 24 - (sunset - sunrise)

        // Fajr: by angle, but never earlier than the angle-based share of the night before sunrise.
        let fajrLimit = sunrise - method.fajrAngle / 60 * night
        var fajr = sky.time(altitude: -method.fajrAngle, beforeNoon: true) ?? fajrLimit
        if fajr < fajrLimit { fajr = fajrLimit }

        let isha: Double
        switch method.isha {
        case .angle(let angle):
            let ishaLimit = sunset + angle / 60 * night
            let byAngle = sky.time(altitude: -angle, beforeNoon: false) ?? ishaLimit
            isha = min(byAngle, ishaLimit)
        case .minutesAfterMaghrib(let minutes, let ramadanMinutes):
            isha = sunset + (isRamadan(date, timeZone: timeZone) ? ramadanMinutes : minutes) / 60
        }

        func moment(_ hours: Double) -> Date {
            utcMidnight.addingTimeInterval(hours * 3600)
        }

        return PrayerTimes(
            fajr: moment(fajr),
            sunrise: moment(sunrise),
            dhuhr: moment(noon),
            asr: moment(asrTime),
            maghrib: moment(sunset),
            isha: moment(isha)
        )
    }

    static func isRamadan(_ date: Date, timeZone: TimeZone = .current) -> Bool {
        var hijri = Calendar(identifier: .islamicUmmAlQura)
        hijri.timeZone = timeZone
        return hijri.component(.month, from: date) == 9
    }

    /// Julian day at 0h UTC of a Gregorian date.
    static func julianDay(year: Int, month: Int, day: Int) -> Double {
        var y = year
        var m = month
        if m <= 2 {
            y -= 1
            m += 12
        }
        let a = (Double(y) / 100).rounded(.down)
        let b = 2 - a + (a / 4).rounded(.down)
        return (365.25 * Double(y + 4716)).rounded(.down)
            + (30.6001 * Double(m + 1)).rounded(.down)
            + Double(day) + b - 1524.5
    }
}

/// The sun over one place on one day. Times are hours after UTC midnight.
private struct Sky {
    let julianMidnight: Double
    let latitude: Double
    let longitude: Double

    private struct SunPosition {
        let declination: Double   // degrees
        let equationOfTime: Double // hours
    }

    private func sun(atHour hour: Double) -> SunPosition {
        let d = julianMidnight + hour / 24 - 2451545.0
        let g = Angle.normalized(357.529 + 0.98560028 * d)
        let q = Angle.normalized(280.459 + 0.98564736 * d)
        let l = Angle.normalized(q + 1.915 * Angle.sin(g) + 0.020 * Angle.sin(2 * g))
        let e = 23.439 - 0.00000036 * d
        let rightAscension = Angle.normalizedHours(Angle.atan2(Angle.cos(e) * Angle.sin(l), Angle.cos(l)) / 15)
        return SunPosition(
            declination: Angle.asin(Angle.sin(e) * Angle.sin(l)),
            equationOfTime: q / 15 - rightAscension
        )
    }

    private func noon(atHour hour: Double) -> Double {
        let equation = sun(atHour: hour).equationOfTime
        // Keep the equation of time within ±12 h, then shift by longitude.
        return Angle.normalizedHours(12 - equation) - longitude / 15
    }

    /// Solar noon (Dhuhr), refined at the moment itself.
    func noon() -> Double {
        var hour = 12 - longitude / 15
        for _ in 0..<2 { hour = noon(atHour: hour) }
        return hour
    }

    /// When the sun is at `altitude` degrees, before or after noon. Nil when it never gets there.
    func time(altitude: Double, beforeNoon: Bool) -> Double? {
        time(beforeNoon: beforeNoon) { _ in altitude }
    }

    /// Like `time(altitude:beforeNoon:)` for an altitude that depends on the sun's declination (Asr).
    func time(beforeNoon: Bool, altitudeAt: (Double) -> Double) -> Double? {
        var hour = beforeNoon ? 6 - longitude / 15 : 18 - longitude / 15
        for _ in 0..<3 {
            let position = sun(atHour: hour)
            let altitude = altitudeAt(position.declination)
            let cosine = (Angle.sin(altitude) - Angle.sin(latitude) * Angle.sin(position.declination))
                / (Angle.cos(latitude) * Angle.cos(position.declination))
            guard (-1...1).contains(cosine) else { return nil }
            let hourAngle = Angle.acos(cosine) / 15
            let noon = noon(atHour: hour)
            hour = beforeNoon ? noon - hourAngle : noon + hourAngle
        }
        return hour.isFinite ? hour : nil
    }
}

/// Trigonometry in degrees.
private enum Angle {
    static func sin(_ degrees: Double) -> Double { Foundation.sin(degrees * .pi / 180) }
    static func cos(_ degrees: Double) -> Double { Foundation.cos(degrees * .pi / 180) }
    static func asin(_ x: Double) -> Double { Foundation.asin(x) * 180 / .pi }
    static func acos(_ x: Double) -> Double { Foundation.acos(x) * 180 / .pi }
    static func atan2(_ y: Double, _ x: Double) -> Double { Foundation.atan2(y, x) * 180 / .pi }

    static func normalized(_ degrees: Double) -> Double {
        let value = degrees.truncatingRemainder(dividingBy: 360)
        return value < 0 ? value + 360 : value
    }

    static func normalizedHours(_ hours: Double) -> Double {
        let value = hours.truncatingRemainder(dividingBy: 24)
        return value < 0 ? value + 24 : value
    }
}
