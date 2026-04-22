//
//  HelpFeedbackView.swift
//  Tasbee7
//
//  Created by Ibrahim Abdullah on 09.11.25.
//

import SwiftUI

struct HelpFeedbackView: View {
    @Environment(AppSettings.self) private var appSettings
    
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
                
                // Help Sections
                VStack(spacing: 24) {
                    HelpSection(
                        title: "كيفية الاستخدام",
                        icon: "book.fill",
                        themeColor: appSettings.themeColor,
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
                        themeColor: appSettings.themeColor,
                        items: [
                            "اذهب إلى الإعدادات → الإشعارات",
                            "فعّل تذكير الصباح أو المساء",
                            "اسمح بالوصول للموقع لحساب الأوقات",
                            "التذكير بعد 15 دقيقة من شروق/غروب الشمس"
                        ]
                    )
                    
                    HelpSection(
                        title: "المفضلة",
                        icon: "star.fill",
                        themeColor: appSettings.themeColor,
                        items: [
                            "اضغط على أيقونة النجم في أي ذكر",
                            "ستظهر في قسم المفضلة بالصفحة الرئيسية",
                            "يمكنك إزالة المفضلة بنفس الطريقة"
                        ]
                    )
                }
                .padding(.top, 8)
                
                // Contact Support
                VStack(spacing: 16) {
                    VStack(spacing: 8) {
                        Text("تواصل معنا")
                            .font(.title2.bold())
                        
                        Text("لديك سؤال أو اقتراح؟")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack(spacing: 16) {
                        Link(destination: URL(string: "https://x.com/i8r4him")!) {
                            VStack(spacing: 12) {
                                Image(systemName: "bird.fill")
                                    .font(.system(size: 32))
                                    .foregroundStyle(appSettings.themeColor)
                                
                                Text("X")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.primary)
                            }
                            .frame(maxWidth: .infinity, minHeight: 80)
                            .padding(.vertical, 20)
                            .glassEffect(.regular.interactive(false), in: RoundedRectangle(cornerRadius: 20))
                        }
                        
                        Link(destination: URL(string: "https://instagram.com/i8r4him")!) {
                            VStack(spacing: 12) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 32))
                                    .foregroundStyle(appSettings.themeColor)
                                
                                Text("Instagram")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.primary)
                            }
                            .frame(maxWidth: .infinity, minHeight: 80)
                            .padding(.vertical, 20)
                            .glassEffect(.regular.interactive(false), in: RoundedRectangle(cornerRadius: 20))
                        }
                    }
                }
                .padding(.top, 16)
            }
            .padding()
        }
        .appGradientBackground()
        .symbolRenderingMode(.hierarchical)
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
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(themeColor)
                    .frame(width: 40, height: 40)
                
                Text(title)
                    .font(.title3.bold())
            }
            
            // Section Items
            VStack(alignment: .leading, spacing: 10) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 12) {
                        Circle()
                            .fill(themeColor)
                            .frame(width: 6, height: 6)
                            .padding(.top, 7)
                        
                        Text(item)
                            .font(.body)
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
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
        HelpFeedbackView()
    }
    .environment(AppSettings())
}
