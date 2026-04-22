//
//  SettingsView.swift
//  Tasbee7
//
//  Created by Ibrahim Abdullah on 06.11.25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppSettings.self) private var appSettings
    
    private let shareURL = URL(string: "https://apps.apple.com/us/app/tasbee7/id6755359818")!
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "غير معروف"
    }
    
    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "غير معروف"
    }

    private var themeSelection: Binding<ThemeColor> {
        Binding(
            get: { appSettings.selectedTheme },
            set: { newValue in appSettings.setTheme(newValue) }
        )
    }

    private var versionLabel: String {
        "\(appVersion) (\(buildNumber))"
    }

    var body: some View {
        NavigationStack {
            Form {
                // 1. Preferences
                Section("التفضيلات") {
                    NavigationLink { NotificationsSettingsView() } label: {
                        Label("الإشعارات", systemImage: "bell.badge.fill")
                    }

                    Picker(selection: themeSelection) {
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
                }
                
                // 2. Support
                Section("المساعدة والدعم") {
                    NavigationLink { HelpFeedbackView() } label: {
                        Label("مساعدة وملاحظات", systemImage: "questionmark.bubble.fill")
                    }
                }
                
                // 3. About - App Information
                Section("عن التطبيق") {
                    NavigationLink { WhatsNewView() } label: {
                        Label("ما الجديد", systemImage: "text.badge.plus")
                    }
                    
                    NavigationLink { AboutView() } label: {
                        Label("عن التطبيق", systemImage: "info.circle.fill")
                    }
                    
                    NavigationLink { PrivacyPolicyView() } label: {
                        Label("سياسة الخصوصية", systemImage: "lock.fill")
                    }
                }
                
                // 4. Share & Connect
                Section("المشاركة والتواصل") {
                    ShareLink(
                        item: shareURL,
                        subject: Text("تطبيق تسبيح - رفيقك اليومي للأذكار والتسبيحات"),
                        message: Text("تطبيق تسبيح - رفيقك اليومي للأذكار والتسبيحات\n\nتطبيق شامل ومجاني للأذكار والتسبيحات اليومية من كتاب حصن المسلم.\n\nحمله الآن: \(shareURL.absoluteString)")
                    ) {
                        Label("مشاركة التطبيق", systemImage: "square.and.arrow.up.fill")
                    }
                    
                    Link(destination: URL(string: "https://x.com/i8r4him")!) {
                        HStack {
                            Label("تابع المطور", systemImage: "bird.fill")
                            Spacer()
                            Image(systemName: "arrow.up.forward")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                // 5. Version & Dedication
                Section {
                    VStack(spacing: 20) {
                        // Logo with gradient background
                        VStack {
                            Image("sign")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 70)
                                .foregroundStyle(appSettings.themeColor)
                                .shadow(color: appSettings.themeColor.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(appSettings.themeColor.opacity(0.08))
                        )
                        
                        // Dedication text with decorative elements
                        VStack(spacing: 12) {
                            // Top ornament
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(appSettings.themeColor.opacity(0.3))
                                    .frame(width: 4, height: 4)
                                
                                Rectangle()
                                    .fill(appSettings.themeColor.opacity(0.3))
                                    .frame(width: 40, height: 1)
                                
                                Image(systemName: "heart.fill")
                                    .font(.caption)
                                    .foregroundStyle(appSettings.themeColor)
                                
                                Rectangle()
                                    .fill(appSettings.themeColor.opacity(0.3))
                                    .frame(width: 40, height: 1)
                                
                                Circle()
                                    .fill(appSettings.themeColor.opacity(0.3))
                                    .frame(width: 4, height: 4)
                            }
                            
                            // Main dedication text
                            Text("صدقة جارية عن فاعلا خير")
                                .font(.title3.weight(.medium))
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.center)
                            
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                        )
                        
                        // Version info - minimal and subtle
                        HStack(spacing: 6) {
                            Text("الإصدار")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                            
                            Text(versionLabel)
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical, 12)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }
            }
            .symbolRenderingMode(.hierarchical)
            .navigationTitle("الإعدادات")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("تم") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environment(AppSettings())
}
