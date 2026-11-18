//
//  RemindersView.swift
//  Tasbee7
//
//  Morning and evening reminders, timed from the user's own sunrise and sunset.
//

import SwiftUI
import UIKit

struct RemindersView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase

    private let reminders = ReminderScheduler.shared
    private let location = LocationService.shared

    var body: some View {
        Form {
            Section {
                ForEach(ReminderKind.allCases) { kind in
                    Toggle(isOn: binding(for: kind)) {
                        HStack(spacing: 12) {
                            SymbolSquare(systemImage: kind.systemImage, tint: .accentFill.opacity(0.18), foreground: .accent)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(kind.title)
                                if let next = reminders.nextTime(for: kind) {
                                    Text("التالي \(next, format: .dateTime.weekday(.wide).hour().minute())")
                                        .textRole(.meta)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .tint(.success)
                    .frame(minHeight: Spacing.rowMinHeight)
                }
            } footer: {
                Text("يصلك التذكير بعد \(ReminderScheduler.offsetMinutes.formatted()) دقيقة من شروق الشمس وغروبها في مكانك.")
            }

            if reminders.isNotificationPermissionDenied {
                Section {
                    PermissionRow(
                        systemImage: "bell.slash.fill",
                        title: "الإشعارات متوقفة",
                        message: "اسمح لتسبيح بالإشعارات من إعدادات iPhone ليصلك التذكير."
                    ) { openSettings() }
                }
            }

            Section {
                if let sun = todaySunTimes {
                    LabeledContent {
                        Text(sun.sunrise, format: .dateTime.hour().minute())
                    } label: {
                        SettingsRow(systemImage: "sunrise.fill", title: "الشروق اليوم")
                    }
                    LabeledContent {
                        Text(sun.sunset, format: .dateTime.hour().minute())
                    } label: {
                        SettingsRow(systemImage: "sunset.fill", title: "الغروب اليوم")
                    }
                } else if location.isDenied {
                    PermissionRow(
                        systemImage: "location.slash.fill",
                        title: "الموقع متوقف",
                        message: "نذكّرك ٦:٣٠ صباحاً و٥:٣٠ مساءً. اسمح بالموقع لنتبع شروق الشمس وغروبها عندك."
                    ) { openSettings() }
                } else {
                    Button {
                        location.refresh()
                    } label: {
                        SettingsRow(systemImage: "location.fill", title: "استخدم موقعي", value: "لأوقات أدق")
                    }
                }
            } header: {
                Text("أوقات الشمس")
            } footer: {
                Text("نستخدم موقعاً تقريبياً لحساب الأوقات على جهازك فقط، ولا يغادر جهازك.")
            }
        }
        .softScroll()
        .navigationTitle("التذكيرات")
        .navigationBarTitleDisplayMode(.inline)
        .task { await reminders.refreshNotificationStatus() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                Task { await reminders.refreshNotificationStatus() }
            }
        }
    }

    private var todaySunTimes: SunTimes? {
        guard let coordinate = location.coordinate else { return nil }
        return SolarCalculator.sunTimes(latitude: coordinate.latitude, longitude: coordinate.longitude, on: .now)
    }

    private func binding(for kind: ReminderKind) -> Binding<Bool> {
        Binding(
            get: { reminders.isEnabled(kind) },
            set: { isOn in Task { await reminders.setEnabled(isOn, for: kind) } }
        )
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            openURL(url)
        }
    }
}

private struct PermissionRow: View {
    let systemImage: String
    let title: String
    let message: String
    let openSettings: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                SymbolSquare(systemImage: systemImage, tint: .mistake.opacity(0.16), foreground: .mistake)
                Text(title).font(.headline)
            }
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button("افتح الإعدادات", action: openSettings)
                .font(.subheadline.weight(.semibold))
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack { RemindersView() }
}
