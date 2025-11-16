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
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("المساعدة والدعم")
                        .font(.largeTitle.bold())
                    
                    Text("نحن هنا لمساعدتك! ابحث عن إجابات أو تواصل معنا")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 8)
                
                Divider()
                
                // Help Sections
                VStack(alignment: .leading, spacing: 20) {
                    HelpSection(
                        title: "كيفية الاستخدام",
                        icon: "book.fill",
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
                                Text("X (Twitter): @i8r4him")
                                Spacer()
                                Image(systemName: "arrow.up.forward")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Link(destination: URL(string: "https://instagram.com/i8r4him")!) {
                            HStack {
                                Image(systemName: "camera.fill")
                                    .foregroundStyle(themeColor)
                                Text("Instagram: @i8r4him")
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
            }
            .padding()
        }
        .navigationTitle("المساعدة")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct HelpSection: View {
    let title: String
    let icon: String
    let items: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(.blue)
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
                    }
                }
            }
            .padding(.leading, 8)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationStack {
        HelpFeedbackView()
    }
}

