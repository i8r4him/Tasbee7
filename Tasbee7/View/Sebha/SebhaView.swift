//
//  SebhaView.swift
//  Tasbee7
//
//  Created by Ibrahim Abdullah on 06.11.25.
//

import AudioToolbox
import SwiftUI

struct SebhaView: View {
    @Environment(AppSettings.self) private var appSettings
    @AppStorage("sebhaCounter") private var counter = 0
    @AppStorage("sebhaHapticEnabled") private var hapticEnabled = true
    @AppStorage("sebhaSoundEnabled") private var soundEnabled = true
    @AppStorage("sebhaTarget") private var target = 33
    @AppStorage("sebhaPhraseIndex") private var phraseIndex = 0
    @AppStorage("sebhaCustomPhrases") private var customPhrasesRaw = "[]"

    @State private var pulse = false
    @State private var customPhrases: [String] = []
    @State private var showAddPhrase = false
    @State private var newPhrase = ""
    @State private var pulseTask: Task<Void, Never>?

    private let basePhrases = [
        "سبحان الله",
        "الحمد لله",
        "الله أكبر",
        "لا إله إلا الله",
        "أستغفر الله"
    ]

    private let presetTargets = [33, 99, 100]

    private var allPhrases: [String] {
        basePhrases + customPhrases
    }

    private var currentPhrase: String {
        guard !allPhrases.isEmpty else { return "سبحان الله" }
        let safeIndex = min(max(phraseIndex, 0), allPhrases.count - 1)
        return allPhrases[safeIndex]
    }

    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(Double(counter) / Double(target), 1)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer(minLength: 16)

                SebhaCounterRing(
                    counter: counter,
                    target: target,
                    progress: progress,
                    pulse: pulse,
                    themeColor: appSettings.themeColor,
                    increment: incrementCounter
                )

                SebhaPhraseCard(
                    currentPhrase: currentPhrase,
                    allPhrases: allPhrases,
                    phraseIndex: phraseIndex,
                    themeColor: appSettings.themeColor,
                    selectPhrase: selectPhrase,
                    showAddPhraseSheet: presentAddPhraseSheet
                )

                TargetPresetPicker(
                    target: target,
                    presetTargets: presetTargets,
                    themeColor: appSettings.themeColor,
                    selectTarget: selectTarget
                )

                Spacer(minLength: 16)

                ResetSebhaButton(themeColor: appSettings.themeColor, reset: resetCounter)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("السبحة")
            .toolbarTitleDisplayMode(.inlineLarge)
            .appGradientBackground()
            .onAppear(perform: loadPhrases)
            .onDisappear {
                pulseTask?.cancel()
            }
            .sheet(isPresented: $showAddPhrase) {
                NavigationStack {
                    AddPhraseForm(
                        phrase: $newPhrase,
                        dismiss: dismissAddPhraseSheet,
                        addPhrase: addPhrase
                    )
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    ToggleToolbarButton(
                        systemImage: hapticEnabled ? "hand.tap.fill" : "hand.tap",
                        isEnabled: hapticEnabled,
                        tint: appSettings.themeColor,
                        accessibilityLabel: "الاهتزاز",
                        action: toggleHaptics
                    )

                    ToggleToolbarButton(
                        systemImage: soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill",
                        isEnabled: soundEnabled,
                        tint: appSettings.themeColor,
                        accessibilityLabel: "الصوت",
                        action: toggleSound
                    )
                }
            }
        }
    }

    private func incrementCounter() {
        counter += 1
        triggerHaptic(style: .light)

        if soundEnabled {
            AudioServicesPlaySystemSound(1104)
        }

        animatePulse()
    }

    private func resetCounter() {
        withAnimation(.spring(response: 0.3)) {
            counter = 0
        }

        triggerHaptic(style: .medium)

        if soundEnabled {
            AudioServicesPlaySystemSound(1103)
        }
    }

    private func toggleHaptics() {
        hapticEnabled.toggle()
    }

    private func toggleSound() {
        soundEnabled.toggle()
    }

    private func selectTarget(_ value: Int) {
        target = value
    }

    private func selectPhrase(_ index: Int) {
        phraseIndex = index
    }

    private func presentAddPhraseSheet() {
        newPhrase = ""
        showAddPhrase = true
    }

    private func dismissAddPhraseSheet() {
        showAddPhrase = false
    }

    private func addPhrase() {
        let trimmed = newPhrase.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard !allPhrases.contains(trimmed) else {
            showAddPhrase = false
            return
        }

        customPhrases.append(trimmed)
        saveCustomPhrases()
        phraseIndex = allPhrases.count - 1
        showAddPhrase = false
    }

    private func animatePulse() {
        pulseTask?.cancel()
        pulse = true
        pulseTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 150_000_000)
            guard !Task.isCancelled else { return }
            pulse = false
        }
    }

    private func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard hapticEnabled else { return }
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    private func loadPhrases() {
        if let data = customPhrasesRaw.data(using: .utf8),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            customPhrases = decoded
        } else {
            customPhrases = []
        }

        if phraseIndex < 0 || phraseIndex >= allPhrases.count {
            phraseIndex = 0
        }
    }

    private func saveCustomPhrases() {
        if let data = try? JSONEncoder().encode(customPhrases),
           let string = String(data: data, encoding: .utf8) {
            customPhrasesRaw = string
        }
    }
}

private struct SebhaCounterRing: View {
    let counter: Int
    let target: Int
    let progress: Double
    let pulse: Bool
    let themeColor: Color
    let increment: () -> Void

    var body: some View {
        Button(action: increment) {
            ZStack {
                Circle()
                    .stroke(themeColor.opacity(0.2), lineWidth: 14)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        themeColor,
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 6) {
                    Text("\(counter)")
                        .font(.system(size: 84, weight: .bold, design: .rounded))
                        .foregroundStyle(themeColor)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.3), value: counter)

                    Text("عدد التسبيحات")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text("الهدف: \(target)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 240, height: 240)
            .scaleEffect(pulse ? 1.03 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: pulse)
        }
        .buttonStyle(.plain)
    }
}

private struct SebhaPhraseCard: View {
    let currentPhrase: String
    let allPhrases: [String]
    let phraseIndex: Int
    let themeColor: Color
    let selectPhrase: (Int) -> Void
    let showAddPhraseSheet: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Text(currentPhrase)
                .font(.title3.weight(.semibold))
                .multilineTextAlignment(.center)

            Menu {
                ForEach(Array(allPhrases.enumerated()), id: \.offset) { index, phrase in
                    Button {
                        selectPhrase(index)
                    } label: {
                        HStack {
                            Text(phrase)
                            if phraseIndex == index {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }

                Divider()

                Button(action: showAddPhraseSheet) {
                    Label("إضافة ذكر جديد", systemImage: "plus")
                }
            } label: {
                Label("تغيير الذكر", systemImage: "text.quote")
                    .font(.caption)
                    .foregroundStyle(themeColor)
            }
        }
        .padding(12)
        .glassEffect(.regular.interactive(false), in: RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal)
    }
}

private struct TargetPresetPicker: View {
    let target: Int
    let presetTargets: [Int]
    let themeColor: Color
    let selectTarget: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("الهدف")
                .font(.headline)

            HStack(spacing: 8) {
                ForEach(presetTargets, id: \.self) { preset in
                    Button {
                        selectTarget(preset)
                    } label: {
                        Text("\(preset)")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            
                            .overlay(
                                Capsule()
                                    .stroke(target == preset ? themeColor : Color.clear, lineWidth: 1)
                            )
                            .foregroundStyle(target == preset ? themeColor : .primary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ResetSebhaButton: View {
    let themeColor: Color
    let reset: () -> Void

    var body: some View {
        Button(action: reset) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.counterclockwise")
                Text("إعادة تعيين")
            }
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .glassEffect(.clear.tint(themeColor).interactive(true), in: RoundedRectangle(cornerRadius: 20))
        }
        .padding(.bottom, 28)
    }
}

private struct AddPhraseForm: View {
    @Binding var phrase: String

    let dismiss: () -> Void
    let addPhrase: () -> Void

    var body: some View {
        Form {
            Section("الذكر الجديد") {
                TextField("اكتب الذكر هنا", text: $phrase)
            }
        }
        .navigationTitle("إضافة ذكر")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("إلغاء", action: dismiss)
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("إضافة", action: addPhrase)
                    .disabled(phrase.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
}

private struct ToggleToolbarButton: View {
    let systemImage: String
    let isEnabled: Bool
    let tint: Color
    let accessibilityLabel: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .foregroundStyle(isEnabled ? tint : .secondary)
        }
        .accessibilityLabel(Text(accessibilityLabel))
    }
}

#Preview {
    SebhaView()
        .environment(FavoritesStore())
        .environment(AppSettings())
}
