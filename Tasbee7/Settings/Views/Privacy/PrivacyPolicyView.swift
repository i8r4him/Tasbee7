//
//  PrivacyPolicyView.swift
//  Tasbee7
//
//  Created by Ibrahim Abdullah on 09.11.25.
//

import SwiftUI

struct PrivacyPolicyView: View {
    @AppStorage(AppTheme.storageKey) private var themeColorRaw: String = ThemeColor.أزرق.rawValue
    
    // Privacy policy hosted on GitHub Pages
    private let privacyPolicyURL = URL(string: "https://i8r4him.github.io/Privacy-Policy-for-Tasbee7-App/")!
    
    private var themeColor: Color {
        (ThemeColor(rawValue: themeColorRaw) ?? .أزرق).color
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("سياسة الخصوصية")
                        .font(.largeTitle.bold())
                    
                    Text("آخر تحديث: 9 نوفمبر 2025")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 20)
                
                // Introduction Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: "lock.shield.fill")
                            .font(.title2)
                            .foregroundStyle(themeColor)
                            .frame(width: 40, height: 40)
                        
                        Text("مقدمة")
                            .font(.title3.bold())
                    }
                    
                    Text("تطبيق تسبيح يحترم خصوصيتك. توضح سياسة الخصوصية هذه كيفية جمع واستخدام وحماية معلوماتك عند استخدام تطبيقنا المحمول.")
                        .font(.body)
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .glassEffect(.regular.interactive(false), in: RoundedRectangle(cornerRadius: 20))
                
                // Location Data Card
                PrivacySection(
                    title: "بيانات الموقع",
                    icon: "location.fill",
                    themeColor: themeColor,
                    items: [
                        ("ما نجمع", "بيانات الموقع التقريبية (إحداثيات خطوط الطول والعرض)"),
                        ("لماذا نجمعها", "لحساب أوقات شروق وغروب الشمس لإرسال تذكيرات في الوقت المناسب"),
                        ("كيف نستخدمها", "للحسابات الفلكية فقط. لا نخزن أو نشارك بيانات موقعك"),
                        ("التخزين", "تتم المعالجة محلياً على جهازك فقط")
                    ]
                )
                
                // Data Storage Card
                PrivacySection(
                    title: "تخزين البيانات",
                    icon: "externaldrive.fill",
                    themeColor: themeColor,
                    items: [
                        "جميع البيانات تُخزن محلياً على جهازك",
                        "لا نملك إمكانية الوصول إلى بياناتك",
                        "لا نستخدم خدمات تتبع خارجية",
                        "لا يتم إرسال بيانات إلى خوادم خارجية"
                    ]
                )
                
                // Your Rights Card
                PrivacySection(
                    title: "حقوقك",
                    icon: "hand.raised.fill",
                    themeColor: themeColor,
                    items: [
                        "تعطيل خدمات الموقع في أي وقت من إعدادات iOS",
                        "حذف التطبيق يزيل جميع البيانات المخزنة",
                        "التحكم الكامل في جميع بياناتك المحلية"
                    ]
                )
                
                // Full Policy Link Card
                Link(destination: privacyPolicyURL) {
                    HStack(spacing: 12) {
                        Image(systemName: "doc.text.fill")
                            .font(.title2)
                            .foregroundStyle(themeColor)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("عرض السياسة الكاملة")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(.primary)
                            
                            Text("على الويب")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.forward.circle.fill")
                            .font(.title2)
                            .foregroundStyle(themeColor)
                    }
                    .padding(20)
                    .glassEffect(.regular.interactive(false), in: RoundedRectangle(cornerRadius: 20))
                }
            }
            .padding()
        }
        .gradientBackground(
            startColor: themeColor.opacity(0.3),
            endColor: .clear
        )
        .symbolRenderingMode(.hierarchical)
        .navigationTitle("سياسة الخصوصية")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct PrivacySection: View {
    let title: String
    let icon: String
    let themeColor: Color
    let items: [(String, String)]
    
    init(title: String, icon: String, themeColor: Color, items: [(String, String)]) {
        self.title = title
        self.icon = icon
        self.themeColor = themeColor
        self.items = items
    }
    
    init(title: String, icon: String, themeColor: Color, items: [String]) {
        self.title = title
        self.icon = icon
        self.themeColor = themeColor
        self.items = items.map { ("", $0) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(themeColor)
                    .frame(width: 40, height: 40)
                
                Text(title)
                    .font(.title3.bold())
            }
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    if item.0.isEmpty {
                        // Simple bullet point
                        HStack(alignment: .top, spacing: 12) {
                            Circle()
                                .fill(themeColor)
                                .frame(width: 6, height: 6)
                                .padding(.top, 7)
                            
                            Text(item.1)
                                .font(.body)
                                .foregroundStyle(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    } else {
                        // Title and content
                        VStack(alignment: .leading, spacing: 6) {
                            Text(item.0)
                                .font(.body.weight(.semibold))
                                .foregroundStyle(themeColor)
                            
                            Text(item.1)
                                .font(.body)
                                .foregroundStyle(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .glassEffect(.regular.interactive(false), in: RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    NavigationStack {
        PrivacyPolicyView()
    }
}
