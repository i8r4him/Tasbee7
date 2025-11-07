//
//  SebhaView.swift
//  Tasbee7
//
//  Created by Ibrahim Abdullah on 06.11.25.
//

import SwiftUI
import AudioToolbox

struct SebhaView: View {
    @AppStorage(AppTheme.storageKey) private var themeColorRaw: String = ThemeColor.أزرق.rawValue
    @AppStorage("sebhaCounter") private var counter: Int = 0
    @AppStorage("sebhaHapticEnabled") private var hapticEnabled: Bool = true
    @AppStorage("sebhaSoundEnabled") private var soundEnabled: Bool = true
    
    private var themeColor: Color {
        (ThemeColor(rawValue: themeColorRaw) ?? .أزرق).color
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 16) {
                    Text("\(counter)")
                        .font(.system(size: 120, weight: .bold, design: .rounded))
                        .foregroundStyle(themeColor)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.3), value: counter)
                    
                    Text("عدد التسبيحات")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Reset Button - Bottom
                Button {
                    resetCounter()
                } label: {
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
                .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .onTapGesture {
                incrementCounter()
            }
            .navigationTitle("السبحة")
            .toolbarTitleDisplayMode(.inlineLarge)
            .gradientBackground(
                startColor: themeColor.opacity(0.3),
                endColor: .clear
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        hapticEnabled.toggle()
                    } label: {
                        Image(systemName: hapticEnabled ? "hand.tap.fill" : "hand.tap")
                            .foregroundStyle(hapticEnabled ? themeColor : .secondary)
                    }
                    .accessibilityLabel(Text("الاهتزاز"))
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        soundEnabled.toggle()
                    } label: {
                        Image(systemName: soundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                            .foregroundStyle(soundEnabled ? themeColor : .secondary)
                    }
                    .accessibilityLabel(Text("الصوت"))
                }
            }
        }
    }
    
    private func incrementCounter() {
        counter += 1
        
        // Haptic feedback
        if hapticEnabled {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
        
        // Sound feedback
        if soundEnabled {
            AudioServicesPlaySystemSound(1104)
        }
    }
    
    private func resetCounter() {
        withAnimation(.spring(response: 0.3)) {
            counter = 0
        }
        
        // Haptic feedback
        if hapticEnabled {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        }
        
        // Sound feedback
        if soundEnabled {
            AudioServicesPlaySystemSound(1103)
        }
    }
}

#Preview {
    SebhaView()
        .environment(FavoritesStore())
}
