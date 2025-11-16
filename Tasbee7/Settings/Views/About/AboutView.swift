//
//  AboutView.swift
//  Tasbee7
//
//  Created by Ibrahim Abdullah on 09.11.25.
//

import SwiftUI

struct AboutView: View {
    @AppStorage(AppTheme.storageKey) private var themeColorRaw: String = ThemeColor.أزرق.rawValue
    
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
        ScrollView {
            VStack(spacing: 32) {
                // App Icon Placeholder
                VStack(spacing: 16) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 80))
                        .foregroundStyle(themeColor)
                        .padding()
                        .background(
                            Circle()
                                .fill(themeColor.opacity(0.1))
                        )
                    
                    Text("تسبيح")
                        .font(.largeTitle.bold())
                    
                    Text("تطبيق شامل للأذكار والتسبيحات اليومية")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                Divider()
                
                // App Info
                VStack(alignment: .leading, spacing: 16) {
                    InfoRow(title: "الإصدار", value: appVersion)
                    InfoRow(title: "رقم البناء", value: buildNumber)
                    InfoRow(title: "الفئة", value: "أذكار وتسبيحات")
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Description
                VStack(alignment: .leading, spacing: 12) {
                    Text("عن التطبيق")
                        .font(.title2.bold())
                    
                    Text("تطبيق تسبيح هو تطبيق شامل للأذكار والتسبيحات اليومية من كتاب حصن المسلم. يوفر التطبيق مجموعة واسعة من الأذكار مع ميزات متقدمة مثل البحث، المفضلة، عداد التسبيح، والتذكيرات الذكية بناءً على أوقات شروق وغروب الشمس.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                
                Divider()
                
                // Features
                VStack(alignment: .leading, spacing: 12) {
                    Text("المميزات")
                        .font(.title2.bold())
                    
                    VStack(alignment: .leading, spacing: 8) {
                        FeatureRow(icon: "book.fill", text: "أذكار الصباح والمساء من كتاب حصن المسلم")
                        FeatureRow(icon: "magnifyingglass", text: "بحث سريع في جميع الأذكار")
                        FeatureRow(icon: "star.fill", text: "نظام المفضلة لحفظ الأذكار المهمة")
                        FeatureRow(icon: "point.3.connected.trianglepath.dotted", text: "عداد تسبيح رقمي")
                        FeatureRow(icon: "bell.fill", text: "تذكيرات ذكية بناءً على شروق وغروب الشمس")
                        FeatureRow(icon: "paintpalette.fill", text: "ألوان واجهة قابلة للتخصيص")
                        FeatureRow(icon: "textformat", text: "خطوط عربية جميلة")
                    }
                }
                
                Divider()
                
                // Developer
                VStack(alignment: .leading, spacing: 12) {
                    Text("المطور")
                        .font(.title2.bold())
                    
                    VStack(spacing: 12) {
                        Link(destination: URL(string: "https://x.com/i8r4him")!) {
                            HStack {
                                Image(systemName: "bird.fill")
                                    .foregroundStyle(themeColor)
                                Text("تابع المطور على X")
                                Spacer()
                                Image(systemName: "arrow.up.forward")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Link(destination: URL(string: "https://instagram.com/i8r4him")!) {
                            HStack {
                                Image(systemName: "camera.fill")
                                    .foregroundStyle(themeColor)
                                Text("تابع المطور على Instagram")
                                Spacer()
                                Image(systemName: "arrow.up.forward")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                // Footer
                VStack(spacing: 8) {
                    Text("صدقة جارية عن فاعلا خير")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 8)
            }
            .padding()
        }
        .gradientBackground(
            startColor: themeColor.opacity(0.3),
            endColor: .clear
        )
        .navigationTitle("عن التطبيق")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

private struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 20)
            Text(text)
                .font(.body)
        }
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}

