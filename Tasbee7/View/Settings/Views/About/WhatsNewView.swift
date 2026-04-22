//
//  WhatsNewView.swift
//  Tasbee7
//
//  Created by Ibrahim Abdullah on 09.11.25.
//

import SwiftUI

struct WhatsNewView: View {
    @Environment(AppSettings.self) private var appSettings
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Version Header
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Text("الإصدار 1.0")
                            .font(.title.bold())
                        
                        Text("الأحدث")
                            .font(.caption.bold())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(appSettings.themeColor.opacity(0.2))
                            .foregroundStyle(appSettings.themeColor)
                            .cornerRadius(8)
                    }
                    
                    Text("نوفمبر 2025")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 20)
                
                Divider()
                
                // Features List
                VStack(alignment: .leading, spacing: 24) {
                    FeatureRow(
                        icon: "sparkles",
                        title: "الإطلاق الأولي",
                        description: "تطبيق شامل للأذكار والتسبيحات من كتاب حصن المسلم"
                    )
                    
                    FeatureRow(
                        icon: "book.fill",
                        title: "مجموعة واسعة من الأذكار",
                        description: "أذكار منظمة في أقسام مختلفة: الصباح والمساء، النوم، الصلاة، وغيرها"
                    )
                    
                    FeatureRow(
                        icon: "magnifyingglass",
                        title: "بحث متقدم",
                        description: "ابحث في جميع الأذكار بالعنوان أو المحتوى"
                    )
                    
                    FeatureRow(
                        icon: "star.fill",
                        title: "نظام المفضلة",
                        description: "احفظ أذكارك المفضلة للوصول السريع"
                    )
                    
                    FeatureRow(
                        icon: "point.3.connected.trianglepath.dotted",
                        title: "عداد تسبيح",
                        description: "عداد رقمي مع إشعارات هابتك وصوتية"
                    )
                    
                    FeatureRow(
                        icon: "bell.fill",
                        title: "تذكيرات ذكية",
                        description: "تذكيرات تلقائية بناءً على شروق وغروب الشمس"
                    )
                    
                    FeatureRow(
                        icon: "paintpalette.fill",
                        title: "ألوان قابلة للتخصيص",
                        description: "اختر من مجموعة متنوعة من ألوان الواجهة"
                    )
                    
                    FeatureRow(
                        icon: "textformat",
                        title: "خطوط عربية جميلة",
                        description: "دعم خط شهرزاد الجميل لعرض الأذكار"
                    )
                }
            }
            .padding()
        }
        .appGradientBackground()
        .navigationTitle("ما الجديد")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct FeatureRow: View {
    @Environment(AppSettings.self) private var appSettings

    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(appSettings.themeColor)
                .frame(width: 32, height: 32)
                .background(appSettings.themeColor.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    NavigationStack {
        WhatsNewView()
    }
    .environment(AppSettings())
}
