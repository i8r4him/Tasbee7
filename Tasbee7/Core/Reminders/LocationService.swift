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
        let defaults = UserDefaults.standard
        if defaults.object(forKey: Self.latitudeKey) != nil {
            coordinate = Coordinate(
                latitude: defaults.double(forKey: Self.latitudeKey),
                longitude: defaults.double(forKey: Self.longitudeKey)
            )
        }
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
        // Two decimals ≈ 1 km: plenty for sun times, and no more precise than needed.
        let rounded = Coordinate(
            latitude: (location.coordinate.latitude * 100).rounded() / 100,
            longitude: (location.coordinate.longitude * 100).rounded() / 100
        )
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
