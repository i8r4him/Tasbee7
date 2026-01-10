//
//  HelpFeedbackView.swift
//  Tasbee7
//
//  Created by Ibrahim Abdullah on 09.11.25.
//

import SwiftUI

struct HelpFeedbackView: View {
    @AppStorage(AppTheme.storageKey) private var themeColorRaw: String = ThemeColor.أزرق.rawValue
    
    private var themeColor: Color {
        (ThemeColor(rawValue: themeColorRaw) ?? .أزرق).color
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 8) {
                    Text("المساعدة والدعم")
                        .font(.largeTitle.bold())
                    
                    Text("نحن هنا لمساعدتك! ابحث عن إجابات أو تواصل معنا")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                Divider()
                
                // Help Sections
                VStack(spacing: 20) {
                    HelpSection(
                        title: "كيفية الاستخدام",
                        icon: "book.fill",
                        themeColor: themeColor,
                        items: [
                            "تصفح الأذكار من الصفحة الرئيسية",
                            "استخدم البحث للعثور على أذكار محددة",
                            "احفظ أذكارك المفضلة للوصول السريع",
                            "استخدم عداد التسبيح لتتبع التسبيحات",
                            "فعّل التذكيرات في الإعدادات"
                        ]
                    )
                    
                    HelpSection(
                        title: "الإشعارات",
                        icon: "bell.fill",
                        themeColor: themeColor,
                        items: [
                            "اذهب إلى الإعدادات → الإشعارات",
                            "فعّل تذكير الصباح أو المساء",
                            "اسمح بالوصول للموقع لحساب أوقات شروق/غروب الشمس",
                            "سيتم إرسال التذكير بعد 15 دقيقة من شروق/غروب الشمس"
                        ]
                    )
                    
                    HelpSection(
                        title: "المفضلة",
                        icon: "star.fill",
                        themeColor: themeColor,
                        items: [
                            "اضغط على أيقونة النجم في أي ذكر",
                            "ستظهر في قسم المفضلة في الصفحة الرئيسية",
                            "يمكنك إزالة المفضلة بنفس الطريقة"
                        ]
                    )
                }
                
                Divider()
                
                // Contact Support
                VStack(alignment: .leading, spacing: 12) {
                    Text("تواصل معنا")
                        .font(.title2.bold())
                    
                    Text("إذا كنت بحاجة إلى مساعدة إضافية أو لديك ملاحظات، لا تتردد في التواصل معنا:")
                        .font(.body)
                        .foregroundStyle(.secondary)
                    
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
                }
            }
            .padding()
        }
        .gradientBackground(
            startColor: themeColor.opacity(0.3),
            endColor: .clear
        )
        .navigationTitle("المساعدة")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct HelpSection: View {
    let title: String
    let icon: String
    let themeColor: Color
    let items: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(themeColor)
                    .frame(width: 32, height: 32)
                    .background(themeColor.opacity(0.1))
                    .clipShape(Circle())
                
                Text(title)
                    .font(.headline)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .foregroundStyle(.secondary)
                        Text(item)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(.leading, 8)
        }
    }
}

#Preview {
    NavigationStack {
        HelpFeedbackView()
    }
}

