//
//  Tasbee7App.swift
//  Tasbee7
//
//  Created by Ibrahim Abdullah on 06.11.25.
//

import SwiftUI
import UserNotifications

@main
struct Tasbee7App: App {
    @State private var repository = AthkarRepository()
    @State private var favorites = FavoritesStore()
    @State private var reading = ReadingPreferences()

    init() {
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(repository)
                .environment(favorites)
                .environment(reading)
        }
    }
}
