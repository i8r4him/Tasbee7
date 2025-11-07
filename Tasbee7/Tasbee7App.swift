//
//  Tasbee7App.swift
//  Tasbee7
//
//  Created by Ibrahim Abdullah on 06.11.25.
//

import SwiftUI

@main
struct Tasbee7App: App {
    @State private var favorites = FavoritesStore()

    init() {
        // Request notification authorization on app launch
        Task { @MainActor in
            await NotificationManager.shared.requestAuthorization()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(favorites)
                .onAppear {
                    // Request location permission and start updates
                    LocationManager.shared.requestPermission()
                    LocationManager.shared.startLocationUpdates()
                }
        }
    }
}
