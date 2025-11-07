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
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "غير معروف"
    }
    
    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "غير معروف"
    }

    var body: some View {
        NavigationStack {
            Form {
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

                Section {
                    VStack(spacing: 8) {
                        HStack(spacing: 4) {
                            Text("صُنع بـ")
                            Image(systemName: "heart.fill")
                                .foregroundStyle(.red)
                            Text("إبراهيم")
                        }
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        
                        Text("الإصدار \(appVersion) (\(buildNumber))")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        
                        Link("@i8r4him", destination: URL(string: "https://instagram.com/i8r4him")!)
                            .font(.footnote)
                            .foregroundColor(.accentColor)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(Color.clear)
                }
            }
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
