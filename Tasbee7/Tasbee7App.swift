//
//  Tasbee7App.swift
//  Tasbee7
//
//  Created by Ibrahim Abdullah on 06.11.25.
//

import SwiftUI
import UIKit

@main
struct Tasbee7App: App {
    @State private var favorites = FavoritesStore()

    init() {
        // Set notification delegate
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        
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
                    // Clear badge when app opens
                    NotificationManager.shared.clearBadge()
                    
                    // Request location permission and start updates
                    LocationManager.shared.requestPermission()
                    LocationManager.shared.startLocationUpdates()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    // Clear badge when app comes to foreground
                    NotificationManager.shared.clearBadge()
                }
        }
    }
}
