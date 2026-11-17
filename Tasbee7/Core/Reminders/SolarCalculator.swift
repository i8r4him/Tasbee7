//
//  SolarCalculator.swift
//  Tasbee7
//
//  Sunrise and sunset from NOAA's general solar position equations.
//  Works in UTC and returns absolute dates, so time zones and daylight saving are always right.
//  Accurate to about a minute away from the poles.
//

import Foundation

struct SunTimes: Equatable {
    let sunrise: Date
    let sunset: Date
}

enum SolarCalculator {
    /// Sunrise and sunset on the calendar day of `date` in `timeZone`.
    /// Returns nil when the sun doesn't rise or set that day (polar day or night).
    static func sunTimes(
        latitude: Double,
        longitude: Double,
        on date: Date,
        timeZone: TimeZone = .current
    ) -> SunTimes? {
        // A NaN or out-of-range place (e.g. from a corrupted preferences file) would otherwise
        // produce NaN dates, and scheduling a reminder at a NaN date crashes.
        guard latitude.isFinite, longitude.isFinite,
              (-90...90).contains(latitude), (-180...180).contains(longitude) else {
            return nil
        }
        var local = Calendar(identifier: .gregorian)
        local.timeZone = timeZone
        let day = local.dateComponents([.year, .month, .day], from: date)

        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = TimeZone(identifier: "UTC")!
        guard let utcMidnight = utc.date(from: day),
              let dayOfYear = utc.ordinality(of: .day, in: .year, for: utcMidnight) else {
            return nil
        }

        let daysInYear = Double(utc.range(of: .day, in: .year, for: utcMidnight)?.count ?? 365)
        // Fractional year (radians), taken at solar noon.
        let gamma = 2 * Double.pi / daysInYear * Double(dayOfYear - 1)

        let equationOfTime = 229.18 * (0.000075
            + 0.001868 * cos(gamma)
            - 0.032077 * sin(gamma)
            - 0.014615 * cos(2 * gamma)
            - 0.040849 * sin(2 * gamma))

        let declination = 0.006918
            - 0.399912 * cos(gamma)
            + 0.070257 * sin(gamma)
            - 0.006758 * cos(2 * gamma)
            + 0.000907 * sin(2 * gamma)
            - 0.002697 * cos(3 * gamma)
            + 0.00148 * sin(3 * gamma)

        let latitudeRad = latitude * .pi / 180
        // 90.833° accounts for refraction and the size of the sun's disc.
        let zenith = 90.833 * Double.pi / 180
        let cosHourAngle = cos(zenith) / (cos(latitudeRad) * cos(declination)) - tan(latitudeRad) * tan(declination)
        guard (-1...1).contains(cosHourAngle) else { return nil }
        let hourAngle = acos(cosHourAngle) * 180 / .pi

        // Minutes after UTC midnight.
        let sunriseMinutes = 720 - 4 * (longitude + hourAngle) - equationOfTime
        let sunsetMinutes = 720 - 4 * (longitude - hourAngle) - equationOfTime

        return SunTimes(
            sunrise: utcMidnight.addingTimeInterval(sunriseMinutes * 60),
            sunset: utcMidnight.addingTimeInterval(sunsetMinutes * 60)
        )
    }
}
