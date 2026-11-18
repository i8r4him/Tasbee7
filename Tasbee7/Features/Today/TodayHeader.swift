//
//  TodayHeader.swift
//  Tasbee7
//
//  The top of Today: a greeting for the time of day, the athkar that fit now as the big button,
//  how long until the next prayer, and a glass date card with the weekday, Hijri and Gregorian dates.
//

import SwiftUI

struct TodayHeader: View {
    let now: Date
    let sitting: DailyKey
    let nextPrayer: PrayerTime?

    @Environment(\.dynamicTypeSize) private var typeSize
    @ScaledMetric(relativeTo: .title2) private var dateCardWidth: CGFloat = 140

    var body: some View {
        // Side by side like a page header; stacked at the largest text sizes.
        if typeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 16) {
                DateCard(date: now)
                GreetingColumn(now: now, sitting: sitting, nextPrayer: nextPrayer)
            }
        } else {
            HStack(alignment: .top, spacing: 16) {
                GreetingColumn(now: now, sitting: sitting, nextPrayer: nextPrayer)
                DateCard(date: now)
                    .frame(width: dateCardWidth)
            }
        }
    }
}

private struct GreetingColumn: View {
    let now: Date
    let sitting: DailyKey
    let nextPrayer: PrayerTime?

    @Environment(AthkarRepository.self) private var repository
    private let progress = DailyProgressStore.shared

    var body: some View {
        let greeting = Greeting(at: now)
        let total = repository.section(titled: sitting.kind.chapterTitle)?.athkar.count ?? 0
        let done = progress.doneCount(in: sitting, total: total)

        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                Text(greeting.text)
                    .textRole(.title2)
                Image(systemName: greeting.systemImage)
                    .font(.title2)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.accent)
                    .accessibilityHidden(true)
            }

            GlassEffectContainer {
                NavigationLink(value: AthkarRoute.daily(sitting)) {
                    Text(buttonTitle(done: done, total: total))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .buttonStyle(.primary)
                .disabled(total == 0)
            }
            .accessibilityValue(total > 0 ? "\(done) من \(total)" : "")

            if let nextPrayer {
                NextPrayerChip(now: now, next: nextPrayer)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func buttonTitle(done: Int, total: Int) -> String {
        if total > 0, done == total { return "تمّت \(sitting.kind.title)" }
        if done > 0 { return "تابع \(sitting.kind.title)" }
        return "اقرأ \(sitting.kind.title)"
    }
}

/// "صلاة الظهر بعد  ٢ س و١٩ د"
private struct NextPrayerChip: View {
    let now: Date
    let next: PrayerTime

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: next.prayer.systemImage)
                .font(.subheadline)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.accent)
                .accessibilityHidden(true)
            Text("صلاة \(next.prayer.name) بعد")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Pill(title: Self.remaining(from: now, to: next.time))
                .monospacedDigit()
        }
        .lineLimit(1)
        .minimumScaleFactor(0.8)
        .accessibilityElement(children: .combine)
    }

    /// Whole minutes, rounded up, as "٢ س و١٩ د" or "١٩ د".
    static func remaining(from now: Date, to time: Date) -> String {
        let minutes = max(0, Int((time.timeIntervalSince(now) / 60).rounded(.up)))
        let hours = minutes / 60
        let rest = minutes % 60
        if hours == 0 { return "\(rest.formatted()) د" }
        if rest == 0 { return "\(hours.formatted()) س" }
        return "\(hours.formatted()) س و\(rest.formatted()) د"
    }
}

/// The weekday large, then the Hijri and Gregorian day and month side by side, and the two years under them.
private struct DateCard: View {
    let date: Date

    private var hijri: Calendar {
        var calendar = Calendar(identifier: .islamicUmmAlQura)
        calendar.timeZone = .current
        calendar.locale = .current
        return calendar
    }

    private func month(in calendar: Calendar) -> String {
        var style = Date.FormatStyle.dateTime.month(.wide)
        style.calendar = calendar
        return date.formatted(style)
    }

    var body: some View {
        let hijri = hijri
        let gregorian = Calendar.current

        VStack(spacing: 10) {
            Text(date, format: .dateTime.weekday(.wide))
                .textRole(.title2)
                .foregroundStyle(.accent)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Divider()

            HStack(spacing: 0) {
                column(month: month(in: hijri), day: hijri.component(.day, from: date))
                Divider().frame(height: 44)
                column(month: month(in: gregorian), day: gregorian.component(.day, from: date))
            }

            Divider()

            HStack(spacing: 0) {
                Text(hijri.component(.year, from: date).formatted(.number.grouping(.never)))
                    .frame(maxWidth: .infinity)
                Text(gregorian.component(.year, from: date).formatted(.number.grouping(.never)))
                    .frame(maxWidth: .infinity)
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .monospacedDigit()
        }
        .padding(Spacing.card)
        .glassEffect(.regular, in: .rect(cornerRadius: Radius.option + 6, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(TodayView.dateLine(for: date)))
    }

    private func column(month: String, day: Int) -> some View {
        VStack(spacing: 2) {
            Text(month)
                .textRole(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(day.formatted())
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity)
    }
}
