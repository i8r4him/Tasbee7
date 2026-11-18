//
//  TodayView.swift
//  Tasbee7
//
//  The home of the app: a greeting with the date and the athkar that fit now, prayer times,
//  daily shortcuts, today's wird, the occasion of the day, and an ayah and a dua of the day.
//

import SwiftUI

struct TodayView: View {
    @Environment(AthkarRepository.self) private var repository
    @Bindable private var router = AppRouter.shared

    @State private var showsSettings = false
    @State private var ayat = AyahOfTheDay.load()
    @Namespace private var zoom

    // Read here so the screen redraws when the place or the method changes.
    private let location = LocationService.shared
    private let prayerSettings = PrayerSettings.shared

    var body: some View {
        NavigationStack(path: $router.todayPath) {
            TimelineView(.everyMinute) { context in
                content(now: context.date)
            }
            .navigationTitle("اليوم")
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showsSettings = true
                    } label: {
                        Label("الإعدادات", systemImage: "gearshape.fill")
                    }
                }
                .matchedTransitionSource(id: "settings", in: zoom)
            }
            .sheet(isPresented: $showsSettings) {
                SettingsView()
                    .navigationTransition(.zoom(sourceID: "settings", in: zoom))
            }
            .sensoryFeedback(.impact(weight: .medium), trigger: showsSettings) { _, shows in shows }
            .athkarDestinations(path: router.todayPath)
        }
    }

    private func content(now: Date) -> some View {
        let times = prayerTimes(on: now)
        let tomorrowTimes = prayerTimes(on: tomorrow(after: now))
        let next = times?.nextPrayer(after: now) ?? tomorrowTimes.map { PrayerTime(prayer: .fajr, time: $0.fajr) }
        let sitting = DailySchedule.current(at: now) { prayerTimes(on: $0) }
        let occasions = Occasions.on(now)
        let dua = DuaOfTheDay.pick(from: DuaOfTheDay.pool(from: repository.section(titled:)), on: now)

        return ScrollView {
            VStack(alignment: .leading, spacing: Spacing.section) {
                TodayHeader(now: now, sitting: sitting, nextPrayer: next)

                PrayerTimesSection(now: now, today: times, tomorrow: tomorrowTimes)

                DailyShortcuts()

                DailyWirdCard(day: sitting.day)

                if !occasions.isEmpty {
                    OccasionsCard(occasions: occasions)
                }

                if let ayah = AyahOfTheDay.pick(from: ayat, on: now) {
                    DayTextCard(
                        tag: "آية اليوم",
                        tagSymbol: "book.closed.fill",
                        text: "﴿\(ayah.text)﴾",
                        reference: ayah.reference,
                        shareText: ayah.shareText
                    )
                }

                if let dua {
                    DayTextCard(
                        tag: "دعاء اليوم",
                        tagSymbol: "hands.and.sparkles.fill",
                        text: dua.text,
                        reference: "\(dua.chapterTitle) · حصن المسلم",
                        shareText: dua.shareText
                    )
                }
            }
            .padding(Spacing.screen)
        }
        .softScroll()
        .readableContentMargins()
        .skyBackground()
    }

    private func prayerTimes(on date: Date) -> PrayerTimes? {
        guard let coordinate = location.coordinate else { return nil }
        return prayerSettings.times(at: coordinate, on: date)
    }

    private func tomorrow(after date: Date) -> Date {
        Calendar.current.date(byAdding: .day, value: 1, to: date) ?? date
    }

    /// "الأربعاء ١٨ نوفمبر · ٢٧ جمادى الأولى ١٤٤٨"
    static func dateLine(for date: Date) -> String {
        let gregorian = date.formatted(.dateTime.weekday(.wide).day().month(.wide))
        var hijriStyle = Date.FormatStyle.dateTime.day().month(.wide).year()
        hijriStyle.calendar = Calendar(identifier: .islamicUmmAlQura)
        return "\(gregorian) · \(date.formatted(hijriStyle))"
    }
}

#Preview {
    TodayView()
        .environment(AthkarRepository())
        .environment(FavoritesStore())
        .environment(ReadingPreferences())
}
