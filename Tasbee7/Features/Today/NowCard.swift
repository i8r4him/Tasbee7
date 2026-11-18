//
//  NowCard.swift
//  Tasbee7
//
//  The hero card: the athkar that fit now (morning after Fajr, evening after Asr, sleep after Isha),
//  how far the user got, and one button to start or continue where they left off.
//

import SwiftUI

struct NowCard: View {
    let sitting: DailyKey
    let now: Date

    @Environment(AthkarRepository.self) private var repository
    @ScaledMetric(relativeTo: .title) private var artworkSize: CGFloat = 96

    private let progress = DailyProgressStore.shared
    private let reminders = ReminderScheduler.shared

    private var chapterCount: Int {
        repository.section(titled: sitting.kind.chapterTitle)?.athkar.count ?? 0
    }

    var body: some View {
        let total = chapterCount
        let done = progress.doneCount(in: sitting, total: total)
        let isFinished = total > 0 && done == total

        VStack(spacing: 18) {
            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    status(isFinished: isFinished)
                    Text(sitting.kind.title)
                        .font(.title3.weight(.semibold))
                    Text(sitting.kind.line)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityElement(children: .combine)

                Artwork(systemImage: sitting.kind.systemImage)
                    .frame(width: artworkSize, height: artworkSize)
            }

            if total > 0 {
                VStack(alignment: .leading, spacing: 8) {
                    ProgressView(value: Double(done), total: Double(total))
                        .tint(.accentFill)
                    Text("\(done.formatted()) من \(total.formatted())")
                        .textRole(.meta)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("التقدّم")
                .accessibilityValue("\(done) من \(total)")
            }

            GlassEffectContainer {
                NavigationLink(value: AthkarRoute.daily(sitting)) {
                    buttonLabel(done: done, isFinished: isFinished)
                }
                .buttonStyle(.primary)
                .disabled(total == 0)
            }
        }
        .padding(Spacing.cardLarge)
        .glassEffect(.regular, in: .card)
        .animation(Motion.easeOut(duration: 0.25), value: done)
    }

    @ViewBuilder
    private func status(isFinished: Bool) -> some View {
        if isFinished {
            Label("تمّت اليوم", systemImage: "checkmark.circle.fill")
                .textRole(.meta)
                .fontWeight(.semibold)
                .foregroundStyle(.accent)
        } else if let reminder = sitting.kind.reminder, let next = reminders.nextTime(for: reminder, after: now) {
            Label {
                Text("التذكير \(next, format: .dateTime.hour().minute())")
            } icon: {
                Image(systemName: "bell.fill")
            }
            .textRole(.meta)
            .fontWeight(.semibold)
            .foregroundStyle(.accent)
        } else {
            Label("الآن", systemImage: "clock.fill")
                .textRole(.meta)
                .fontWeight(.semibold)
                .foregroundStyle(.accent)
        }
    }

    @ViewBuilder
    private func buttonLabel(done: Int, isFinished: Bool) -> some View {
        if isFinished {
            Label("اقرأها مرة أخرى", systemImage: "arrow.counterclockwise")
        } else if done > 0 {
            Label("تابع من حيث توقفت", systemImage: "book.fill")
        } else {
            Label("ابدأ \(sitting.kind.title)", systemImage: "book.fill")
        }
    }
}
