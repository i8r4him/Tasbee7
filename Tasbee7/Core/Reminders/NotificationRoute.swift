//
//  NotificationRoute.swift
//  Tasbee7
//
//  Shows reminders while the app is open and opens the right chapter when one is tapped.
//

import Foundation
import UserNotifications

enum NotificationRoute {
    nonisolated static let sectionKey = "sectionTitle"
}

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let title = response.notification.request.content.userInfo[NotificationRoute.sectionKey] as? String
        await MainActor.run {
            AppRouter.shared.openSection(titled: title ?? AthkarCatalog.morningEveningTitle)
        }
    }
}
