//
//  SettingsView.swift
//  Tasbee7
//

import SwiftUI

struct SettingsView: View {
    @Environment(ReadingPreferences.self) private var reading
    @Environment(\.dismiss) private var dismiss

    private let theme = Theme.shared
    private let reminders = ReminderScheduler.shared

    static let appStoreURL = URL(string: "https://apps.apple.com/app/tasbee7/id6755359818")!
    static let developerXURL = URL(string: "https://x.com/i8r4him")!
    static let developerInstagramURL = URL(string: "https://instagram.com/i8r4him")!

    var body: some View {
        @Bindable var reading = reading
        NavigationStack {
            Form {
                Section("المظهر") {
                    NavigationLink {
                        ThemePickerView()
                    } label: {
                        SettingsRow(systemImage: "paintpalette.fill", title: "لون التطبيق", value: theme.palette.name, tint: .accentFill, foreground: .onAccent)
                    }
                }

                Section("القراءة") {
                    Picker(selection: $reading.font) {
                        ForEach(AthkarFont.allCases) { Text($0.name).tag($0) }
                    } label: {
                        SettingsRow(systemImage: "textformat", title: "نوع الخط")
                    }
                    Picker(selection: $reading.size) {
                        ForEach(AthkarFontSize.allCases) { Text($0.name).tag($0) }
                    } label: {
                        SettingsRow(systemImage: "textformat.size", title: "حجم الخط")
                    }
                }

                Section("التذكيرات") {
                    NavigationLink {
                        RemindersView()
                    } label: {
                        SettingsRow(systemImage: "bell.badge.fill", title: "أذكار الصباح والمساء", value: reminders.anyEnabled ? "مفعّلة" : "متوقفة")
                    }
                }

                Section("عن التطبيق") {
                    NavigationLink { WhatsNewView() } label: {
                        SettingsRow(systemImage: "sparkles", title: "ما الجديد")
                    }
                    NavigationLink { AboutView() } label: {
                        SettingsRow(systemImage: "info.circle.fill", title: "عن تسبيح")
                    }
                    NavigationLink { SupportView() } label: {
                        SettingsRow(systemImage: "questionmark.bubble.fill", title: "المساعدة والاقتراحات")
                    }
                    NavigationLink { PrivacyView() } label: {
                        SettingsRow(systemImage: "lock.fill", title: "الخصوصية")
                    }
                }

                Section("شارك") {
                    ShareLink(
                        item: Self.appStoreURL,
                        subject: Text("تسبيح"),
                        message: Text("تسبيح: أذكار حصن المسلم وسبحة رقمية، مجاناً وبلا إعلانات.")
                    ) {
                        SettingsRow(systemImage: "square.and.arrow.up.fill", title: "شارك التطبيق")
                    }
                    Link(destination: Self.developerXURL) {
                        SettingsRow(systemImage: "at", title: "تابع المطوّر", value: "@i8r4him")
                    }
                }

                Section {
                    Dedication()
                        .listRowBackground(Color.clear)
                }
            }
            .softScroll()
            .navigationTitle("الإعدادات")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) { dismiss() }
                }
            }
        }
    }
}

/// A settings row: a symbol square, a title, and an optional value.
struct SettingsRow: View {
    let systemImage: String
    let title: String
    var value: String?
    var tint: Color = .controlFill
    var foreground: Color = .primary

    var body: some View {
        HStack(spacing: 12) {
            SymbolSquare(systemImage: systemImage, tint: tint, foreground: foreground)
            Text(title)
                .foregroundStyle(.primary)
            Spacer(minLength: 0)
            if let value {
                Text(value)
                    .textRole(.bodySmall)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(minHeight: 36)
        .accessibilityElement(children: .combine)
    }
}

private struct Dedication: View {
    private var version: String {
        let info = Bundle.main.infoDictionary
        let short = info?["CFBundleShortVersionString"] as? String ?? "–"
        let build = info?["CFBundleVersion"] as? String ?? "–"
        return "\(short) (\(build))"
    }

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "heart.fill")
                .foregroundStyle(.accent)
                .accessibilityHidden(true)
            Text("صدقة جارية عن فاعل خير")
                .font(.headline)
            Text("الإصدار \(version)")
                .textRole(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

#Preview {
    SettingsView()
        .environment(ReadingPreferences())
}
