//
//  NotificationManager.swift
//  Tasbee7
//
//  Created by Assistant on 06.11.25.
//

import Foundation
import UserNotifications
import CoreLocation

@MainActor
@Observable
class NotificationManager {
    static let shared = NotificationManager()
    
    private let locationManager = LocationManager.shared
    private let center = UNUserNotificationCenter.current()
    
    private init() {}
    
    func requestAuthorization() async {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            if !granted {
                print("Notification authorization denied")
            }
        } catch {
            print("Notification authorization error: \(error.localizedDescription)")
        }
    }
    
    func scheduleMorningReminder(enabled: Bool) async {
        // Remove existing morning notification
        center.removePendingNotificationRequests(withIdentifiers: ["morningAthkar"])
        
        guard enabled else { return }
        
        guard let location = locationManager.location else {
            // Request location if not available
            locationManager.requestPermission()
            locationManager.startLocationUpdates()
            return
        }
        
        guard let (sunrise, _) = SunriseSunsetCalculator.calculateSunriseSunset(for: location) else {
            return
        }
        
        // Schedule 15 minutes after sunrise
        let reminderTime = Calendar.current.date(byAdding: .minute, value: 15, to: sunrise) ?? sunrise
        
        let content = UNMutableNotificationContent()
        content.title = "أذكار الصباح"
        content.body = "حان وقت أذكار الصباح 🌅"
        content.sound = .default
        content.badge = 1
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(identifier: "morningAthkar", content: content, trigger: trigger)
        
        do {
            try await center.add(request)
        } catch {
            print("Error scheduling morning reminder: \(error.localizedDescription)")
        }
    }
    
    func scheduleEveningReminder(enabled: Bool) async {
        // Remove existing evening notification
        center.removePendingNotificationRequests(withIdentifiers: ["eveningAthkar"])
        
        guard enabled else { return }
        
        guard let location = locationManager.location else {
            // Request location if not available
            locationManager.requestPermission()
            locationManager.startLocationUpdates()
            return
        }
        
        guard let (_, sunset) = SunriseSunsetCalculator.calculateSunriseSunset(for: location) else {
            return
        }
        
        // Schedule 15 minutes after sunset
        let reminderTime = Calendar.current.date(byAdding: .minute, value: 15, to: sunset) ?? sunset
        
        let content = UNMutableNotificationContent()
        content.title = "أذكار المساء"
        content.body = "حان وقت أذكار المساء 🌆"
        content.sound = .default
        content.badge = 1
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(identifier: "eveningAthkar", content: content, trigger: trigger)
        
        do {
            try await center.add(request)
        } catch {
            print("Error scheduling evening reminder: \(error.localizedDescription)")
        }
    }
    
    func updateSchedules() async {
        let morningEnabled = UserDefaults.standard.bool(forKey: "morningReminderEnabled")
        let eveningEnabled = UserDefaults.standard.bool(forKey: "eveningReminderEnabled")
        
        await scheduleMorningReminder(enabled: morningEnabled)
        await scheduleEveningReminder(enabled: eveningEnabled)
    }
    
    func getNextSunriseSunset() -> (sunrise: Date?, sunset: Date?) {
        guard let location = locationManager.location else {
            return (nil, nil)
        }
        
        let times = SunriseSunsetCalculator.calculateSunriseSunset(for: location)
        return (times?.sunrise, times?.sunset)
    }
}

