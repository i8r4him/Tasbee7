//
//  LocationService.swift
//  Tasbee7
//
//  A rough, one-shot location for sun times. Only asked for when the user turns a reminder on.
//  The last place is remembered (rounded to about 1 km), so reminders keep working without a new fix.
//

import CoreLocation
import Foundation
import Observation

struct Coordinate: Equatable {
    let latitude: Double
    let longitude: Double

    /// A real place on Earth: finite and within ±90° latitude and ±180° longitude.
    var isValid: Bool {
        latitude.isFinite && longitude.isFinite
            && (-90...90).contains(latitude) && (-180...180).contains(longitude)
    }

    /// Two decimals ≈ 1 km: plenty for sun times, and no more precise than needed.
    /// This is the only precision that is ever stored.
    func roundedForStorage() -> Coordinate {
        Coordinate(
            latitude: (latitude * 100).rounded() / 100,
            longitude: (longitude * 100).rounded() / 100
        )
    }

    /// The stored place, or nil when nothing is stored or the stored values aren't a real place
    /// (e.g. a tampered or corrupted preferences file).
    static func stored(in defaults: UserDefaults, latitudeKey: String, longitudeKey: String) -> Coordinate? {
        guard let latitude = defaults.object(forKey: latitudeKey) as? Double,
              let longitude = defaults.object(forKey: longitudeKey) as? Double else { return nil }
        let coordinate = Coordinate(latitude: latitude, longitude: longitude)
        return coordinate.isValid ? coordinate.roundedForStorage() : nil
    }
}

@Observable
final class LocationService: NSObject {
    static let shared = LocationService()

    private static let latitudeKey = "reminders.lastLatitude"
    private static let longitudeKey = "reminders.lastLongitude"

    private let manager = CLLocationManager()
    private(set) var authorizationStatus: CLAuthorizationStatus
    private(set) var coordinate: Coordinate?

    var isAuthorized: Bool {
        authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }

    var isDenied: Bool {
        authorizationStatus == .denied || authorizationStatus == .restricted
    }

    private override init() {
        authorizationStatus = manager.authorizationStatus
        coordinate = Coordinate.stored(in: .standard, latitudeKey: Self.latitudeKey, longitudeKey: Self.longitudeKey)
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    /// Asks for permission if needed, then for one fresh location.
    func refresh() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        default:
            break
        }
    }

    private func store(_ location: CLLocation) {
        let raw = Coordinate(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        guard raw.isValid else { return }
        let rounded = raw.roundedForStorage()
        guard rounded != coordinate else { return }
        coordinate = rounded
        UserDefaults.standard.set(rounded.latitude, forKey: Self.latitudeKey)
        UserDefaults.standard.set(rounded.longitude, forKey: Self.longitudeKey)
    }
}

extension LocationService: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            self.store(location)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Keep the last known place; reminders fall back to it.
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            self.authorizationStatus = status
            if self.isAuthorized {
                self.manager.requestLocation()
            }
        }
    }
}
