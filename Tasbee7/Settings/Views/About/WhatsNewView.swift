//
//  WhatsNewView.swift
//  Tasbee7
//
//  Created by Ibrahim Abdullah on 09.11.25.
//

import SwiftUI

struct WhatsNewView: View {
    @AppStorage(AppTheme.storageKey) private var themeColorRaw: String = ThemeColor.أزرق.rawValue
    
    private var themeColor: Color {
        (ThemeColor(rawValue: themeColorRaw) ?? .أزرق).color
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("ما الجديد")
                        .font(.largeTitle.bold())
                    
                    Text("اكتشف آخر التحديثات والميزات الجديدة")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 8)
                
                Divider()
                
                // Version 1.0
                VersionSection(
                    version: "1.0",
                    date: "نوفمبر 2025",
                    isLatest: true,
                    features: [
                        FeatureItem(icon: "sparkles", title: "الإطلاق الأولي", description: "تطبيق شامل للأذكار والتسبيحات من كتاب حصن المسلم"),
                        FeatureItem(icon: "book.fill", title: "مجموعة واسعة من الأذكار", description: "أذكار منظمة في أقسام مختلفة: الصباح والمساء، النوم، الصلاة، وغيرها"),
                        FeatureItem(icon: "magnifyingglass", title: "بحث متقدم", description: "ابحث في جميع الأذكار بالعنوان أو المحتوى"),
                        FeatureItem(icon: "star.fill", title: "نظام المفضلة", description: "احفظ أذكارك المفضلة للوصول السريع"),
                        FeatureItem(icon: "point.3.connected.trianglepath.dotted", title: "عداد تسبيح", description: "عداد رقمي مع إشعارات هابتك وصوتية"),
                        FeatureItem(icon: "bell.fill", title: "تذكيرات ذكية", description: "تذكيرات تلقائية بناءً على شروق وغروب الشمس"),
                        FeatureItem(icon: "paintpalette.fill", title: "ألوان قابلة للتخصيص", description: "اختر من مجموعة متنوعة من ألوان الواجهة"),
                        FeatureItem(icon: "textformat", title: "خطوط عربية جميلة", description: "دعم خط شهرزاد الجميل لعرض الأذكار")
                    ]
                )
            }
            .padding()
        }
        .navigationTitle("ما الجديد")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct VersionSection: View {
    let version: String
    let date: String
    let isLatest: Bool
    let features: [FeatureItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("الإصدار \(version)")
                            .font(.title2.bold())
                        
                        if isLatest {
                            Text("الأحدث")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.2))
                                .foregroundStyle(.blue)
                                .cornerRadius(8)
                        }
                    }
                    
                    Text(date)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 16) {
                ForEach(features) { feature in
                    FeatureRow(feature: feature)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

private struct FeatureItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
}

private struct FeatureRow: View {
    let feature: FeatureItem
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: feature.icon)
                .foregroundStyle(.blue)
                .frame(width: 24)
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(feature.title)
                    .font(.headline)
                
                Text(feature.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        WhatsNewView()
    }
}

