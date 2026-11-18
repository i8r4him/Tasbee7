//
//  ReminderScheduler.swift
//  Tasbee7
//
//  Morning and evening reminders, 15 minutes after sunrise and sunset.
//  The sun moves every day, so instead of one repeating trigger we schedule the next 30 days
//  one by one, and top them up whenever the app becomes active or the place changes.
//

import Foundation
import Observation
import UserNotifications

enum ReminderKind: String, CaseIterable, Identifiable {
    case morning, evening

    var id: Self { self }

    var title: String {
        switch self {
        case .morning: "أذكار الصباح"
        case .evening: "أذكار المساء"
        }
    }

    var body: String {
        switch self {
        case .morning: "حان وقت أذكار الصباح، ابدأ يومك بذكر الله."
        case .evening: "حان وقت أذكار المساء، اختم يومك بذكر الله."
        }
    }

    var systemImage: String {
        switch self {
        case .morning: "sunrise.fill"
        case .evening: "sunset.fill"
        }
    }

    /// Same keys as before, so existing choices carry over.
    var storageKey: String {
        switch self {
        case .morning: "morningReminderEnabled"
        case .evening: "eveningReminderEnabled"
        }
    }

    /// Used when the place isn't known yet or the sun doesn't rise or set (polar regions).
    var fallbackTime: DateComponents {
        switch self {
        case .morning: DateComponents(hour: 6, minute: 30)
        case .evening: DateComponents(hour: 17, minute: 30)
        }
    }
}

@Observable
final class ReminderScheduler {
    static let shared = ReminderScheduler()

    static let offsetMinutes = 15
    private static let daysAhead = 30
    private static let identifierPrefix = "reminder."
    /// The old repeating triggers from version 1.x. Removed on every schedule so they never fire at the wrong time again.
    private static let legacyIdentifiers = ["morningAthkar", "eveningAthkar"]

    private let center = UNUserNotificationCenter.current()
    private let location = LocationService.shared
    private let defaults = UserDefaults.standard

    private(set) var notificationStatus: UNAuthorizationStatus = .notDetermined
    private(set) var enabledKinds: Set<ReminderKind>

    private init() {
        enabledKinds = Set(ReminderKind.allCases.filter { UserDefaults.standard.bool(forKey: $0.storageKey) })
    }

    func isEnabled(_ kind: ReminderKind) -> Bool {
        enabledKinds.contains(kind)
    }

    var anyEnabled: Bool {
        !enabledKinds.isEmpty
    }

    var isNotificationPermissionDenied: Bool {
        notificationStatus == .denied
    }

    /// Turns a reminder on or off. Turning one on asks for notification and location permission if needed.
    func setEnabled(_ enabled: Bool, for kind: ReminderKind) async {
        defaults.set(enabled, forKey: kind.storageKey)
        if enabled {
            enabledKinds.insert(kind)
        } else {
            enabledKinds.remove(kind)
        }
        if enabled {
            await requestNotificationPermissionIfNeeded()
            location.refresh()
        }
        await reschedule()
    }

    func refreshNotificationStatus() async {
        notificationStatus = await center.notificationSettings().authorizationStatus
    }

    private func requestNotificationPermissionIfNeeded() async {
        await refreshNotificationStatus()
        guard notificationStatus == .notDetermined else { return }
        _ = try? await center.requestAuthorization(options: [.alert, .sound])
        await refreshNotificationStatus()
    }

    /// The next reminder time for display, or nil when the reminder is off.
    func nextTime(for kind: ReminderKind, after now: Date = .now) -> Date? {
        guard isEnabled(kind) else { return nil }
        let calendar = Calendar.current
        for dayOffset in 0...1 {
            guard let day = calendar.date(byAdding: .day, value: dayOffset, to: now) else { continue }
            if let time = reminderTime(for: kind, on: day), time > now { return time }
        }
        return nil
    }

    /// Whether times come from the user's place (true) or the fallback hours (false).
    var usesLocation: Bool {
        location.coordinate != nil
    }

    /// Replaces every pending reminder with fresh ones for the next 30 days.
    func reschedule(now: Date = .now) async {
        let pending = await center.pendingNotificationRequests()
        let stale = pending.map(\.identifier).filter { $0.hasPrefix(Self.identifierPrefix) } + Self.legacyIdentifiers
        center.removePendingNotificationRequests(withIdentifiers: stale)

        await refreshNotificationStatus()
        guard anyEnabled, notificationStatus == .authorized || notificationStatus == .provisional else { return }

        let calendar = Calendar.current
        for kind in ReminderKind.allCases where isEnabled(kind) {
            for dayOffset in 0..<Self.daysAhead {
                guard let day = calendar.date(byAdding: .day, value: dayOffset, to: now),
                      let time = reminderTime(for: kind, on: day),
                      time > now else { continue }
                try? await center.add(request(for: kind, at: time))
            }
        }
    }

    private func reminderTime(for kind: ReminderKind, on day: Date) -> Date? {
        let calendar = Calendar.current
        if let coordinate = location.coordinate,
           let sun = SolarCalculator.sunTimes(latitude: coordinate.latitude, longitude: coordinate.longitude, on: day) {
            let base = kind == .morning ? sun.sunrise : sun.sunset
            return base.addingTimeInterval(TimeInterval(Self.offsetMinutes * 60))
        }
        var components = calendar.dateComponents([.year, .month, .day], from: day)
        components.hour = kind.fallbackTime.hour
        components.minute = kind.fallbackTime.minute
        return calendar.date(from: components)
    }

    private func request(for kind: ReminderKind, at time: Date) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = kind.title
        content.body = kind.body
        content.sound = .default
        content.userInfo = [NotificationRoute.sectionKey: AthkarCatalog.morningEveningTitle]

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let stamp = components.year! * 10_000 + components.month! * 100 + components.day!
        return UNNotificationRequest(
            identifier: "\(Self.identifierPrefix)\(kind.rawValue).\(stamp)",
            content: content,
            trigger: trigger
        )
    }
}
