//
//  PrayerSettings.swift
//  Tasbee7
//
//  Which calculation method and Asr school the user follows. The first method is picked from the region.
//

import Foundation
import Observation

@Observable
final class PrayerSettings {
    static let shared = PrayerSettings()

    private enum Key {
        static let method = "prayer.method"
        static let asr = "prayer.asr"
    }

    private let defaults: UserDefaults

    var method: CalculationMethod {
        didSet { defaults.set(method.rawValue, forKey: Key.method) }
    }

    var asr: AsrMethod {
        didSet { defaults.set(asr.rawValue, forKey: Key.asr) }
    }

    init(defaults: UserDefaults = .standard, region: String? = Locale.current.region?.identifier) {
        self.defaults = defaults
        method = defaults.string(forKey: Key.method).flatMap(CalculationMethod.init(rawValue:))
            ?? CalculationMethod.recommended(forRegion: region)
        asr = defaults.string(forKey: Key.asr).flatMap(AsrMethod.init(rawValue:)) ?? .standard
    }

    /// Today's (or `date`'s) times at a place, with the user's method.
    func times(at coordinate: Coordinate, on date: Date, timeZone: TimeZone = .current) -> PrayerTimes? {
        PrayerCalculator.times(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            on: date,
            timeZone: timeZone,
            method: method,
            asr: asr
        )
    }
}
