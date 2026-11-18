//
//  NextPrayerCard.swift
//  Tasbee7
//
//  The next prayer with a live countdown, and the whole day's times under it.
//  Without a place it asks for one; it never shows made-up times.
//

import SwiftUI
import UIKit

struct NextPrayerCard: View {
    let now: Date
    let today: PrayerTimes?
    /// Tomorrow's times, asked for only after Isha.
    let tomorrow: () -> PrayerTimes?

    private let location = LocationService.shared
    private let settings = PrayerSettings.shared
    @Environment(\.openURL) private var openURL

    var body: some View {
        if let today {
            if let next = today.nextPrayer(after: now) {
                TimesCard(now: now, times: today, next: next, method: settings.method)
            } else if let tomorrow = tomorrow() {
                TimesCard(now: now, times: tomorrow, next: PrayerTime(prayer: .fajr, time: tomorrow.fajr), method: settings.method)
            } else {
                unavailable
            }
        } else if location.coordinate != nil {
            unavailable
        } else if location.isDenied {
            StateCard(
                systemImage: "location.slash.fill",
                title: "أوقات الصلاة",
                message: "الوصول إلى الموقع متوقف. فعّله من الإعدادات لنحسب أوقات الصلاة عندك.",
                actionTitle: "افتح الإعدادات",
                actionSystemImage: "gearshape.fill",
                action: openSettings
            )
        } else if location.isAuthorized {
            // A fix is on its way: show the card's shape, not a spinner.
            TimesCard.placeholder
        } else {
            StateCard(
                systemImage: "location.fill",
                title: "أوقات الصلاة",
                message: "اسمح بموقع تقريبي لنحسب أوقات الصلاة على جهازك. موقعك لا يغادر الجهاز.",
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

private struct TimesCard: View {
    let now: Date
    let times: PrayerTimes
    let next: PrayerTime
    let method: CalculationMethod

    static var placeholder: some View {
        let start = Calendar.current.startOfDay(for: .now)
        func at(_ hour: Double) -> Date { start.addingTimeInterval(hour * 3600) }
        let sample = PrayerTimes(fajr: at(5), sunrise: at(6.5), dhuhr: at(12), asr: at(15), maghrib: at(17.5), isha: at(19))
        return TimesCard(now: at(11), times: sample, next: PrayerTime(prayer: .dhuhr, time: at(12)), method: .muslimWorldLeague)
            .redacted(reason: .placeholder)
            .accessibilityHidden(true)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("الصلاة القادمة")
                        .textRole(.eyebrow)
                        .foregroundStyle(.accent)
                    Text(next.prayer.name)
                        .textRole(.title2)
                    Text(next.time, format: .dateTime.hour().minute())
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .trailing, spacing: 2) {
                    Text(timerInterval: now...max(now, next.time), countsDown: true)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    Text("متبقٍّ")
                        .textRole(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("الصلاة القادمة \(next.prayer.name)")
            .accessibilityValue(Text(next.time, style: .relative))

            Divider()

            ViewThatFits(in: .horizontal) {
                HStack(spacing: 0) {
                    ForEach(times.all) { item in
                        column(item.prayer, item.time)
                    }
                }
                VStack(spacing: 10) {
                    ForEach(times.all) { item in
                        row(item.prayer, item.time)
                    }
                }
            }

            Text("حسب \(method.name)")
                .textRole(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(Spacing.cardLarge)
        .glassEffect(.regular, in: .card)
    }

    private func isNext(_ prayer: Prayer, _ time: Date) -> Bool {
        prayer == next.prayer && time == next.time
    }

    private func column(_ prayer: Prayer, _ time: Date) -> some View {
        let highlighted = isNext(prayer, time)
        return VStack(spacing: 4) {
            Image(systemName: prayer.systemImage)
                .font(.subheadline)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(highlighted ? Color.accent : Color.secondary)
                .accessibilityHidden(true)
            Text(prayer.name)
                .textRole(.caption)
                .fontWeight(highlighted ? .semibold : .regular)
                .foregroundStyle(highlighted ? Color.accent : Color.secondary)
            Text(time, format: .dateTime.hour(.defaultDigits(amPM: .omitted)).minute())
                .font(.subheadline.weight(highlighted ? .bold : .medium))
                .monospacedDigit()
                .foregroundStyle(highlighted ? Color.accent : (prayer.isPrayer ? Color.primary : Color.secondary))
        }
        .lineLimit(1)
        .fixedSize()
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }

    private func row(_ prayer: Prayer, _ time: Date) -> some View {
        let highlighted = isNext(prayer, time)
        return HStack {
            Label(prayer.name, systemImage: prayer.systemImage)
                .symbolRenderingMode(.hierarchical)
            Spacer(minLength: 8)
            Text(time, format: .dateTime.hour().minute())
                .monospacedDigit()
        }
        .font(.body.weight(highlighted ? .semibold : .regular))
        .foregroundStyle(highlighted ? Color.accent : Color.primary)
        .accessibilityElement(children: .combine)
    }
}
