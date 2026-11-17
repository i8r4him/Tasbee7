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
    /// Longer than any chapter title in the book, so a valid title is never cut.
    nonisolated static let maxTitleLength = 200

    /// The chapter a notification should open. The payload is only trusted when it names a chapter
    /// the catalog knows; anything else (missing, wrong type, oversized, unknown) opens the
    /// morning and evening athkar, which is what every reminder this app schedules points to.
    static func sectionTitle(
        from payload: String?,
        isKnown: (String) -> Bool = { AthkarCatalog.groupNameByTitle[$0] != nil }
    ) -> String {
        guard let title = payload,
              !title.isEmpty,
              title.count <= maxTitleLength,
              isKnown(title) else {
            return AthkarCatalog.morningEveningTitle
        }
        return title
    }
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
        // Only a plain string leaves the notification; it's checked against the catalog on the main actor.
        let payload = response.notification.request.content.userInfo[NotificationRoute.sectionKey] as? String
        await MainActor.run {
            AppRouter.shared.openSection(titled: NotificationRoute.sectionTitle(from: payload))
        }
    }
}
