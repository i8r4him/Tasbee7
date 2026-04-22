//
//  NotificationDelegate.swift
//  Tasbee7
//
//  Created by Assistant on 06.11.25.
//

import Foundation
import UserNotifications

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    
    private override init() {
        super.init()
    }
    
    // Called when notification is received while app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    // Called when user taps on notification
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Clear badge when notification is tapped
        DispatchQueue.main.async {
            UNUserNotificationCenter.current().setBadgeCount(0)
        }
        
        // Handle notification tap
        let userInfo = response.notification.request.content.userInfo
        
        if let notificationType = userInfo["notificationType"] as? String {
            // Post notification to trigger navigation in ContentView
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: NSNotification.Name("NotificationTapped"),
                    object: nil,
                    userInfo: ["type": notificationType]
                )
            }
        }
        
        completionHandler()
    }
}

