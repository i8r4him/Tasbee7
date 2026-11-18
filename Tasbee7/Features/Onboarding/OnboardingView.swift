//
//  OnboardingView.swift
//  Tasbee7
//
//  Two calm steps: what the app does, then an optional ask for reminders.
//  Permissions are only asked for when the user chooses reminders.
//

import SwiftUI

struct OnboardingView: View {
    let onFinish: () -> Void

    private enum Step: Int, CaseIterable {
        case welcome, reminders
    }

    @State private var step: Step = .welcome
    @State private var isEnabling = false
    @Environment(\.reducesMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 0) {
            StepIndicator(current: step.rawValue, total: Step.allCases.count)
                .padding(.top, Spacing.screen)

            ScrollView {
                Group {
                    switch step {
                    case .welcome:
                        WelcomeStep()
                    case .reminders:
                        RemindersStep()
                    }
                }
                .padding(Spacing.onboarding)
                .transition(Motion.pushTransition(reduceMotion: reduceMotion))
                .id(step)
            }
            .softScroll()
        }
        .readableWidth(Spacing.focusedWidth)
        .safeAreaInset(edge: .bottom) {
            GlassEffectContainer(spacing: 8) {
                VStack(spacing: 10) {
                    switch step {
                    case .welcome:
                        Button("متابعة") {
                            withAnimation(Motion.push(reduceMotion: reduceMotion)) { step = .reminders }
                        }
                        .buttonStyle(.primary)
                    case .reminders:
                        Button {
                            enableReminders()
                        } label: {
                            Label("ذكّرني صباحاً ومساءً", systemImage: "bell.fill")
                        }
                        .buttonStyle(.primary)
                        .disabled(isEnabling)

                        Button("ليس الآن", action: onFinish)
                            .font(.subheadline.weight(.semibold))
                            .frame(minHeight: Spacing.minTouchTarget)
                    }
                }
            }
            .padding(.horizontal, Spacing.onboarding)
            .padding(.bottom, 8)
            .readableWidth(Spacing.focusedWidth)
        }
        .skyBackground()
        .sensoryFeedback(.selection, trigger: step)
    }

    private func enableReminders() {
        isEnabling = true
        Task {
            await ReminderScheduler.shared.setEnabled(true, for: .morning)
            await ReminderScheduler.shared.setEnabled(true, for: .evening)
            isEnabling = false
            onFinish()
        }
    }
}

private struct WelcomeStep: View {
    @ScaledMetric(relativeTo: .largeTitle) private var artworkSize: CGFloat = 120

    private let features: [(String, String, String)] = [
        ("book.fill", "حصن المسلم كاملاً", "كل الأذكار في أقسام واضحة، بخط جميل."),
        ("circle.dotted", "سبحة رقمية", "عدّ لكل ذكر وهدف تختاره."),
        ("magnifyingglass", "بحث ذكي", "اكتب بلا تشكيل، ونجد لك الذكر."),
        ("star.fill", "المفضلة", "أبوابك اليومية في مكان واحد.")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.section) {
            Artwork(systemImage: "moon.stars.fill", symbolSize: 64, cornerRadius: 30)
                .frame(width: artworkSize, height: artworkSize)
                .padding(.top, 24)

            VStack(alignment: .leading, spacing: 8) {
                Text("أهلاً بك في تسبيح")
                    .textRole(.hero)
                Text("رفيقك اليومي للأذكار.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 0) {
                ForEach(Array(features.enumerated()), id: \.offset) { index, feature in
                    if index > 0 { Divider().padding(.leading, 62) }
                    FeatureRow(systemImage: feature.0, title: feature.1, detail: feature.2)
                }
            }
            .glassEffect(.regular, in: .card)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct RemindersStep: View {
    @ScaledMetric(relativeTo: .largeTitle) private var artworkSize: CGFloat = 120

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.section) {
            Artwork(systemImage: "sunrise.fill", symbolSize: 64, cornerRadius: 30)
                .frame(width: artworkSize, height: artworkSize)
                .padding(.top, 24)

            VStack(alignment: .leading, spacing: 8) {
                Text("لا تفوّت أذكارك")
                    .textRole(.hero)
                Text("نذكّرك بأذكار الصباح بعد الشروق، وبأذكار المساء بعد الغروب، على وقت الشمس في مدينتك.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Label("نطلب الإشعارات وموقعاً تقريبياً. يُحسب الوقت على جهازك ولا يغادره.", systemImage: "lock.fill")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// A row of short capsules: done in the accent, the rest dim.
private struct StepIndicator: View {
    let current: Int
    let total: Int

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<total, id: \.self) { index in
                Capsule()
                    .fill(index <= current ? Color.accentFill : Color.surfaceTertiary)
                    .frame(width: 28, height: 3)
            }
        }
        .animation(Motion.easeOut(duration: 0.3), value: current)
        .accessibilityElement()
        .accessibilityLabel("الخطوة")
        .accessibilityValue("\(current + 1) من \(total)")
    }
}

#Preview {
    OnboardingView {}
}
