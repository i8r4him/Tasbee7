//
//  SebhaView.swift
//  Tasbee7
//
//  The digital tasbih: tap the ring to count, pick a phrase and a target.
//

import AudioToolbox
import SwiftUI

struct SebhaView: View {
    @Bindable private var store = SebhaStore.shared
    @State private var showsPhrases = false
    @State private var confirmsReset = false
    @State private var resets = 0
    @State private var toastMessage: String?
    @Namespace private var zoom

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.section) {
                    PhraseButton(phrase: store.selectedPhrase) {
                        showsPhrases = true
                    }
                    .matchedTransitionSource(id: "phrases", in: zoom)

                    CounterRing(store: store, onTap: count)

                    TargetPicker(store: store)

                    Button {
                        confirmsReset = true
                    } label: {
                        Label("إعادة العدّ", systemImage: "arrow.counterclockwise")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity, minHeight: 30)
                    }
                    .buttonStyle(.glass)
                    .disabled(store.count == 0)
                    .confirmationDialog("إعادة العدّ إلى صفر؟", isPresented: $confirmsReset, titleVisibility: .visible) {
                        Button("إعادة العدّ", role: .destructive, action: reset)
                    } message: {
                        Text("سيُمسح عدّ «\(store.selectedPhrase)» فقط.")
                    }
                }
                .padding(Spacing.screen)
                .readableWidth(Spacing.focusedWidth)
            }
            .softScroll()
            .skyBackground()
            .navigationTitle("السبحة")
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Toggle(isOn: $store.hapticsEnabled) {
                            Label("الاهتزاز", systemImage: "iphone.radiowaves.left.and.right")
                        }
                        Toggle(isOn: $store.soundEnabled) {
                            Label("الصوت", systemImage: "speaker.wave.2.fill")
                        }
                    } label: {
                        Label("خيارات السبحة", systemImage: "slider.horizontal.3")
                    }
                }
            }
            .sheet(isPresented: $showsPhrases) {
                PhrasePickerSheet(store: store)
                    .navigationTransition(.zoom(sourceID: "phrases", in: zoom))
            }
            .sensoryFeedback(.impact(weight: .medium), trigger: showsPhrases) { _, shows in shows }
            .sensoryFeedback(.impact(weight: .medium), trigger: resets)
            .toast($toastMessage)
        }
    }

    private func count() {
        store.increment()
        if store.soundEnabled {
            AudioServicesPlaySystemSound(1104)
        }
        if store.justFinishedRound {
            toastMessage = "أتممت \(ArabicNoun.tasbiha.count(store.count))، بارك الله فيك"
        }
    }

    private func reset() {
        store.reset()
        resets += 1
    }
}

/// The selected phrase as a glass capsule that opens the phrase list.
private struct PhraseButton: View {
    let phrase: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(phrase)
                    .font(.title2.weight(.semibold))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                Image(systemName: "chevron.down")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 12)
            .frame(minHeight: Spacing.minTouchTarget)
            .glassEffect(.regular.interactive(), in: .capsule)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("الذكر: \(phrase)")
        .accessibilityHint("يفتح قائمة الأذكار.")
    }
}

/// The big ring. The whole ring is one button.
private struct CounterRing: View {
    let store: SebhaStore
    let onTap: () -> Void

    @ScaledMetric(relativeTo: .largeTitle) private var diameter: CGFloat = 270
    @ScaledMetric(relativeTo: .largeTitle) private var numberSize: CGFloat = 72

    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(.clear)
                    .glassEffect(.regular.interactive(), in: .circle)
                    .padding(26)

                ProgressRing(fraction: store.progress, lineWidth: 14)

                VStack(spacing: 6) {
                    Text(store.count, format: .number)
                        .font(.system(size: numberSize, weight: .bold, design: .rounded).monospacedDigit())
                        .contentTransition(.numericText())
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    Text("الهدف \(store.target.formatted())")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if store.rounds > 0 {
                        Pill(title: "الدورة \(store.rounds.formatted())")
                    }
                }
                .padding(48)
            }
            .frame(width: min(diameter, 340), height: min(diameter, 340))
            .contentShape(.circle)
        }
        .buttonStyle(.plain)
        .animation(Motion.easeOut(duration: 0.25), value: store.count)
        .sensoryFeedback(trigger: store.count) { old, new in
            guard store.hapticsEnabled, new > old else { return nil }
            return store.justFinishedRound ? SensoryFeedback.success : SensoryFeedback.impact(weight: .light)
        }
        .accessibilityLabel("عداد التسبيح")
        .accessibilityValue("\(store.count) من \(store.target)")
        .accessibilityHint("اضغط مرتين للتسبيح.")
    }
}

private struct TargetPicker: View {
    @Bindable var store: SebhaStore

    var body: some View {
        VStack(spacing: 10) {
            Text("الهدف")
                .textRole(.eyebrow)
                .foregroundStyle(.secondary)
            HStack(spacing: 8) {
                ForEach(SebhaStore.presetTargets, id: \.self) { preset in
                    FilterChip(title: preset.formatted(), isSelected: store.target == preset) {
                        store.target = preset
                    }
                }
            }
        }
    }
}

#Preview {
    SebhaView()
}
