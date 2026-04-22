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
    @State private var appSettings = AppSettings()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showOnboarding = false

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
                .environment(appSettings)
                .onAppear {
                    prepareAppSession()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    NotificationManager.shared.clearBadge()
                }
                .sheet(isPresented: $showOnboarding) {
                    OnboardingView()
                }
        }
    }

    private func prepareAppSession() {
        if !hasCompletedOnboarding {
            showOnboarding = true
        }

        NotificationManager.shared.clearBadge()
        LocationManager.shared.requestPermission()
        LocationManager.shared.startLocationUpdates()
    }
}
