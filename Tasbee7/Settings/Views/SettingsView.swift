//
//  SettingsView.swift
//  Tasbee7
//
//  Created by Ibrahim Abdullah on 06.11.25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage(AppTheme.storageKey) private var themeColorRaw: String = ThemeColor.أزرق.rawValue
    
    private let shareURL = URL(string: "https://tasbee7.app")!
    
    private var themeColor: Color {
        (ThemeColor(rawValue: themeColorRaw) ?? .أزرق).color
    }
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "غير معروف"
    }
    
    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "غير معروف"
    }

    var body: some View {
        NavigationStack {
            Form {
                // 1. Preferences
                Section("التفضيلات") {
                    let selection = Binding<ThemeColor>(
                        get: { ThemeColor(rawValue: themeColorRaw) ?? .أزرق },
                        set: { newValue in
                            themeColorRaw = newValue.rawValue
                            AppTheme.setSelectedThemeColor(newValue)
                        }
                    )
                    
                    Picker(selection: selection) {
                        ForEach(ThemeColor.allCases) { theme in
                            HStack {
                                Circle()
                                    .fill(theme.color)
                                    .frame(width: 20, height: 20)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.primary.opacity(0.15), lineWidth: 1)
                                    )
                                Text(theme.displayName)
                            }
                            .tag(theme)
                        }
                    } label: {
                        Label("لون الواجهة", systemImage: "paintpalette.fill")
                    }
                    .pickerStyle(.navigationLink)
                    
                    NavigationLink { NotificationsSettingsView() } label: {
                        Label("الإشعارات", systemImage: "bell.badge.fill")
                    }
                }
                
                // 2. About the App
                Section("عن التطبيق") {
                    NavigationLink { WhatsNewView() } label: {
                        Label("ما الجديد", systemImage: "text.badge.plus")
                    }
                    
                    NavigationLink { OnboardingView() } label: {
                        Label("جولة تعريفية", systemImage: "hand.wave.fill")
                    }
                    
                    NavigationLink { AboutView() } label: {
                        Label("عن التطبيق", systemImage: "info.circle.fill")
                    }
                    
                    NavigationLink { PrivacyPolicyView() } label: {
                        Label("سياسة الخصوصية", systemImage: "lock.fill")
                    }
                }
                
                // 3. Support - Help and feedback
                Section("الدعم") {
                    NavigationLink { HelpFeedbackView() } label: {
                        Label("مساعدة", systemImage: "questionmark.bubble.fill")
                    }
                    
                    NavigationLink { FeatureRequestView() } label: {
                        Label("طلب ميزات", systemImage: "exclamationmark.bubble.fill")
                    }
                }
                
                // 4. Share - Social actions
                Section("المشاركة") {
                    ShareLink(
                        item: shareURL,
                        subject: Text("تطبيق تسبيح - رفيقك اليومي للأذكار والتسبيحات"),
                        message: Text("تطبيق تسبيح - رفيقك اليومي للأذكار والتسبيحات\n\nتطبيق شامل ومجاني للأذكار والتسبيحات اليومية من كتاب حصن المسلم.\n\nحمله الآن: \(shareURL.absoluteString)")
                    ) {
                        Label("نشر تسبيح", systemImage: "square.and.arrow.up.fill")
                    }
                }
                
                // 5. Developer - Credits and follow
                Section("المطور") {
                    Link(destination: URL(string: "https://x.com/i8r4him")!) {
                        HStack {
                            Image(systemName: "bird.fill")
                            Text("تابع المطور على X")
                            Spacer()
                            Image(systemName: "arrow.up.forward")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                // 6. Version info
                Section {
                    Image("sign")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 80)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(themeColor)
                        .listRowBackground(Color.clear)
                    
                    VStack(spacing: 5) {
                        VStack(spacing: 6) {
                            Text("صدقة جارية عن فاعلا خير")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        HStack(spacing: 4) {
                            Text("الإصدار")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(" \(appVersion) (\(buildNumber))")
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .listRowBackground(Color.clear)
                }
            }
            .symbolRenderingMode(.hierarchical)
            .navigationTitle("الإعدادات")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}

