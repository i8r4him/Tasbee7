//
//  DailyWirdCard.swift
//  Tasbee7
//
//  "ورد اليوم": three rings side by side. Athkar (morning, evening and sleep together), tasbih (a hundred a day)
//  and Quran, which is marked "coming soon" until the app has a Quran section.
//

import SwiftUI

struct DailyWirdCard: View {
    /// The day the current sitting belongs to, so the rings don't empty at midnight before the sleep athkar.
    let day: String

    @Environment(AthkarRepository.self) private var repository
    @Bindable private var router = AppRouter.shared
    @State private var opensSebha = 0

    private let progress = DailyProgressStore.shared
    private let sebha = SebhaStore.shared

    private var athkarProgress: (done: Int, total: Int) {
        DailyAthkar.allCases.reduce(into: (0, 0)) { sum, kind in
            let total = repository.section(titled: kind.chapterTitle)?.athkar.count ?? 0
            sum.0 += progress.doneCount(in: DailyKey(kind: kind, day: day), total: total)
            sum.1 += total
        }
    }

    var body: some View {
        let athkar = athkarProgress
        let tasbih = sebha.todayCount()

        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "ورد اليوم")

            HStack(alignment: .top, spacing: 0) {
                WirdRing(
                    title: "الأذكار",
                    value: athkar.done,
                    goal: athkar.total,
                    caption: "\(athkar.done.formatted()) من \(athkar.total.formatted())"
                )

                Button {
                    opensSebha += 1
                    router.selectedTab = .sebha
                } label: {
                    WirdRing(
                        title: "التسبيح",
                        value: tasbih,
                        goal: SebhaStore.dailyGoal,
                        caption: "\(tasbih.formatted()) من \(SebhaStore.dailyGoal.formatted())"
                    )
                }
                .buttonStyle(.tile)
                .accessibilityHint("يفتح السبحة.")

                WirdRing(title: "القرآن", value: 0, goal: 1, caption: "قريباً")
                    .opacity(0.55)
                    .accessibilityLabel("القرآن، قريباً")
            }
            .padding(.vertical, Spacing.cardLarge)
            .padding(.horizontal, Spacing.card)
            .glassEffect(.regular, in: .card)
            .sensoryFeedback(.impact(weight: .medium), trigger: opensSebha)
        }
    }
}

private struct WirdRing: View {
    let title: String
    let value: Int
    let goal: Int
    let caption: String

    @ScaledMetric(relativeTo: .title3) private var side: CGFloat = 72

    private var fraction: Double {
        goal > 0 ? min(Double(value) / Double(goal), 1) : 0
    }

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                ProgressRing(fraction: fraction, lineWidth: 8)
                if fraction >= 1 {
                    Image(systemName: "checkmark")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.accent)
                        .accessibilityHidden(true)
                } else {
                    Text(fraction, format: .percent.precision(.fractionLength(0)))
                        .font(.system(size: 15, weight: .heavy, design: .rounded))
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .minimumScaleFactor(0.6)
                        .padding(10)
                }
            }
            .frame(width: side, height: side)

            VStack(spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(caption)
                    .textRole(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            .lineLimit(1)
            .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .contentShape(.rect)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(caption)
        .animation(Motion.easeOut(duration: 0.3), value: value)
    }
}
