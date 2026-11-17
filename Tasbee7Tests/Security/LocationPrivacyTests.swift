//
//  LocationPrivacyTests.swift
//  Tasbee7Tests
//
//  The app only keeps a rough place (two decimals, about 1 km) and must survive a tampered one.
//

import Foundation
import Testing
@testable import Tasbee7

@MainActor
@Suite("Security: location privacy")
struct LocationPrivacyTests {
    private let storage = IsolatedDefaults()
    private var defaults: UserDefaults { storage.defaults }
    private let latitudeKey = "lat"
    private let longitudeKey = "lon"

    @Test("A precise fix is rounded to two decimals before it's kept")
    func preciseLocationIsRounded() {
        let precise = Coordinate(latitude: 24.713_552_9, longitude: 46.675_296_3)
        let stored = precise.roundedForStorage()
        #expect(stored == Coordinate(latitude: 24.71, longitude: 46.68))
        // No more than about 1.1 km from the real place in either direction.
        #expect(abs(stored.latitude - precise.latitude) <= 0.005)
        #expect(abs(stored.longitude - precise.longitude) <= 0.005)
    }

    @Test("Rounding never keeps more than two decimals", arguments: [
        (51.507_351, -0.127_758), (-33.868_820, 151.209_296), (89.999_9, 179.999_9), (-89.999_9, -179.999_9)
    ])
    func roundingDropsPrecision(latitude: Double, longitude: Double) {
        let stored = Coordinate(latitude: latitude, longitude: longitude).roundedForStorage()
        for value in [stored.latitude, stored.longitude] {
            #expect(abs(value * 100 - (value * 100).rounded()) < 1e-6)
        }
    }

    @Test("Impossible coordinates are invalid", arguments: [
        (Double.nan, 0.0), (0.0, Double.nan), (Double.infinity, 0.0), (0.0, -Double.infinity),
        (90.01, 0.0), (-91.0, 0.0), (0.0, 180.5), (0.0, -1_000.0)
    ])
    func impossibleCoordinatesAreInvalid(latitude: Double, longitude: Double) {
        #expect(!Coordinate(latitude: latitude, longitude: longitude).isValid)
    }

    @Test("A tampered stored place is ignored instead of driving reminder times", arguments: [
        (Double.nan, 10.0), (1e300, 10.0), (45.0, -500.0)
    ])
    func tamperedStoredPlaceIsIgnored(latitude: Double, longitude: Double) {
        defaults.set(latitude, forKey: latitudeKey)
        defaults.set(longitude, forKey: longitudeKey)
        #expect(Coordinate.stored(in: defaults, latitudeKey: latitudeKey, longitudeKey: longitudeKey) == nil)
    }

    @Test("A stored place of the wrong type is ignored")
    func wrongTypeIsIgnored() {
        defaults.set("24.7", forKey: latitudeKey)
        defaults.set(Data([1, 2, 3]), forKey: longitudeKey)
        #expect(Coordinate.stored(in: defaults, latitudeKey: latitudeKey, longitudeKey: longitudeKey) == nil)
    }

    @Test("Only half a stored place is ignored")
    func halfAPlaceIsIgnored() {
        defaults.set(24.71, forKey: latitudeKey)
        #expect(Coordinate.stored(in: defaults, latitudeKey: latitudeKey, longitudeKey: longitudeKey) == nil)
    }

    @Test("A valid stored place is read back, still rounded")
    func validStoredPlaceIsRead() {
        defaults.set(24.713_5, forKey: latitudeKey)
        defaults.set(46.675_2, forKey: longitudeKey)
        #expect(Coordinate.stored(in: defaults, latitudeKey: latitudeKey, longitudeKey: longitudeKey)
                == Coordinate(latitude: 24.71, longitude: 46.68))
    }

    @Test("The sun calculator refuses impossible places instead of returning NaN dates", arguments: [
        (Double.nan, 0.0), (0.0, Double.nan), (Double.infinity, 0.0), (0.0, -Double.infinity),
        (1e308, -1e308), (90.5, 0.0), (0.0, 181.0)
    ])
    func solarCalculatorRejectsBadInput(latitude: Double, longitude: Double) {
        #expect(SolarCalculator.sunTimes(latitude: latitude, longitude: longitude, on: .now) == nil)
    }

    @Test("Edge places give real dates or nil, never NaN", arguments: [
        (-90.0, 180.0), (90.0, -180.0), (0.0, 0.0), (69.65, 18.96), (-77.85, 166.67)
    ])
    func solarCalculatorEdgePlacesAreFinite(latitude: Double, longitude: Double) {
        for dayOffset in stride(from: 0, to: 365, by: 30) {
            let day = Date(timeIntervalSince1970: 1_790_000_000 + Double(dayOffset) * 86_400)
            if let times = SolarCalculator.sunTimes(latitude: latitude, longitude: longitude, on: day) {
                #expect(times.sunrise.timeIntervalSince1970.isFinite)
                #expect(times.sunset.timeIntervalSince1970.isFinite)
            }
        }
    }
}
