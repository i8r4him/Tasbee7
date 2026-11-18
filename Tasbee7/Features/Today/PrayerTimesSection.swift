//
//  PrayerTimesSection.swift
//  Tasbee7
//
//  "أوقات الصلاة": the next prayer as a wide tile tinted with the theme, with a live countdown,
//  and the day's six times as glass tiles under it. Without a place it asks for one; it never shows
//  made-up times.
//

import SwiftUI
import UIKit

struct PrayerTimesSection: View {
    let now: Date
    let today: PrayerTimes?
    let tomorrow: PrayerTimes?

    private let location = LocationService.shared
    private let settings = PrayerSettings.shared
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                SectionHeader(title: "أوقات الصلاة")
                Spacer(minLength: 8)
                if today != nil {
                    Label("حسب موقعك", systemImage: "location.fill")
                        .textRole(.meta)
                        .foregroundStyle(.secondary)
                        .labelStyle(.titleAndIcon)
                }
            }

            content
        }
    }

    @ViewBuilder
    private var content: some View {
        if let today {
            if let next = today.nextPrayer(after: now) {
                PrayerGrid(now: now, times: today, next: next, method: settings.method)
            } else if let tomorrow {
                PrayerGrid(now: now, times: tomorrow, next: PrayerTime(prayer: .fajr, time: tomorrow.fajr),
                           method: settings.method)
            } else {
                unavailable
            }
        } else if location.coordinate != nil {
            unavailable
        } else if location.isDenied {
            StateCard(
                systemImage: "location.slash.fill",
                title: "الموقع متوقف",
                message: "فعّل الوصول إلى الموقع من الإعدادات لنحسب أوقات الصلاة عندك.",
                actionTitle: "افتح الإعدادات",
                actionSystemImage: "gearshape.fill",
                action: openSettings
            )
        } else if location.isAuthorized {
            // A fix is on its way: show the grid's shape, not a spinner.
            PrayerGrid.placeholder
        } else {
            StateCard(
                systemImage: "location.fill",
                title: "اعرف أوقات الصلاة",
                message: "اسمح بموقع تقريبي لنحسب الأوقات على جهازك. موقعك لا يغادر الجهاز.",
                actionTitle: "استخدم موقعي",
                actionSystemImage: "location.fill",
                action: location.refresh
            )
        }
    }

    private var unavailable: some View {
        StateCard(
            systemImage: "sun.horizon",
            title: "لا تُحسب أوقات الصلاة هنا اليوم",
            message: "الشمس لا تشرق أو لا تغرب في موقعك في هذا الوقت من السنة."
        )
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            openURL(url)
        }
    }
}

private struct PrayerGrid: View {
    let now: Date
    let times: PrayerTimes
    let next: PrayerTime
    let method: CalculationMethod

    @Environment(\.dynamicTypeSize) private var typeSize

    static var placeholder: some View {
        let start = Calendar.current.startOfDay(for: .now)
        func at(_ hour: Double) -> Date { start.addingTimeInterval(hour * 3600) }
        let sample = PrayerTimes(fajr: at(5), sunrise: at(6.5), dhuhr: at(12), asr: at(15), maghrib: at(17.5), isha: at(19))
        return PrayerGrid(now: at(11), times: sample, next: PrayerTime(prayer: .dhuhr, time: at(12)), method: .muslimWorldLeague)
            .redacted(reason: .placeholder)
            .accessibilityHidden(true)
    }

    private var columns: [GridItem] {
        let count = typeSize.isAccessibilitySize ? 2 : 3
        return Array(repeating: GridItem(.flexible(), spacing: 10), count: count)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            GlassEffectContainer(spacing: 0) {
                VStack(spacing: 10) {
                    NextTile(now: now, next: next)
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(times.all) { item in
                            TimeTile(item: item, isNext: item == next)
                        }
                    }
                }
            }

            Text("طريقة الحساب: \(method.name)")
                .textRole(.caption)
                .foregroundStyle(.tertiary)
        }
    }
}

/// The next prayer: name and time on one side, "تبقى على الأذان" and the countdown on the other.
private struct NextTile: View {
    let now: Date
    let next: PrayerTime

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Label(next.prayer.name, systemImage: next.prayer.systemImage)
                    .font(.headline)
                Text(next.time, format: .dateTime.hour().minute())
                    .font(.title2.weight(.bold))
                    .monospacedDigit()
            }
            Spacer(minLength: 8)
            VStack(alignment: .trailing, spacing: 2) {
                Text("تبقى على الأذان")
                    .textRole(.meta)
                    .opacity(0.8)
                Text(timerInterval: now...max(now, next.time), countsDown: true)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
        }
        .foregroundStyle(Color.onAccent)
        .padding(Spacing.cardLarge)
        .frame(maxWidth: .infinity)
        .background(Color.accentFill.opacity(0.9), in: .rect(cornerRadius: Radius.hero, style: .continuous))
        .glassEffect(.regular, in: .rect(cornerRadius: Radius.hero, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("الصلاة القادمة \(next.prayer.name)")
        .accessibilityValue(Text(next.time, style: .relative))
    }
}

private struct TimeTile: View {
    let item: PrayerTime
    let isNext: Bool

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: item.prayer.systemImage)
                .font(.subheadline)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.accent)
                .accessibilityHidden(true)
            Text(item.prayer.name)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(item.time, format: .dateTime.hour().minute())
                .font(.headline)
                .monospacedDigit()
                .foregroundStyle(isNext ? Color.accent : (item.prayer.isPrayer ? Color.primary : Color.secondary))
        }
        .lineLimit(1)
        .minimumScaleFactor(0.8)
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity)
        .overlay {
            if isNext {
                RoundedRectangle(cornerRadius: Radius.option + 4, style: .continuous)
                    .strokeBorder(Color.accentFill.opacity(0.55), lineWidth: 1)
            }
        }
        .glassEffect(.regular, in: .rect(cornerRadius: Radius.option + 4, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isNext ? .isSelected : [])
    }
}
