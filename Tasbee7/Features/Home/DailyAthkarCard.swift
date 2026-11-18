//
//  DailyAthkarCard.swift
//  Tasbee7
//
//  The hero card: morning or evening athkar, whichever fits the time of day.
//

import SwiftUI

struct DailyAthkarCard: View {
    @ScaledMetric(relativeTo: .title) private var artworkSize: CGFloat = 96

    private let reminders = ReminderScheduler.shared

    var body: some View {
        TimelineView(.everyMinute) { context in
            let period = Period(at: context.date)
            VStack(spacing: 18) {
                HStack(alignment: .center, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        if let next = reminders.nextTime(for: period.reminder, after: context.date) {
                            Label {
                                Text("التذكير \(next, format: .dateTime.hour().minute())")
                            } icon: {
                                Image(systemName: "bell.fill")
                            }
                            .textRole(.meta)
                            .fontWeight(.semibold)
                            .foregroundStyle(.accent)
                        }
                        Text(period.title)
                            .font(.title3.weight(.semibold))
                        Text(period.line)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityElement(children: .combine)

                    Artwork(systemImage: period.systemImage)
                        .frame(width: artworkSize, height: artworkSize)
                }

                GlassEffectContainer {
                    NavigationLink(value: AthkarRoute.section(AthkarCatalog.morningEveningTitle)) {
                        Label("ابدأ الأذكار", systemImage: "book.fill")
                    }
                    .buttonStyle(.primary)
                }
            }
            .padding(Spacing.cardLarge)
            .glassEffect(.regular, in: .card)
        }
    }
}

private enum Period {
    case morning, evening

    /// Morning from 3 am until noon, evening the rest of the day.
    init(at date: Date) {
        let hour = Calendar.current.component(.hour, from: date)
        self = (3..<12).contains(hour) ? .morning : .evening
    }

    var title: String {
        switch self {
        case .morning: "أذكار الصباح"
        case .evening: "أذكار المساء"
        }
    }

    var line: String {
        switch self {
        case .morning: "ابدأ يومك بذكر الله."
        case .evening: "اختم يومك بذكر الله."
        }
    }

    var systemImage: String {
        switch self {
        case .morning: "sun.horizon.fill"
        case .evening: "moon.stars.fill"
        }
    }

    var reminder: ReminderKind {
        switch self {
        case .morning: .morning
        case .evening: .evening
        }
    }
}
