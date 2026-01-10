//
//  FeatureRequestView.swift
//  Tasbee7
//
//  Created by Ibrahim Abdullah on 09.11.25.
//

import SwiftUI

struct FeatureRequestView: View {
    @AppStorage(AppTheme.storageKey) private var themeColorRaw: String = ThemeColor.أزرق.rawValue
    
    private var themeColor: Color {
        (ThemeColor(rawValue: themeColorRaw) ?? .أزرق).color
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 8) {
                    Text("طلب ميزات جديدة")
                        .font(.largeTitle.bold())
                    
                    Text("نحن نستمع لأفكارك! شاركنا بمقترحاتك لتحسين التطبيق")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                Divider()
                
                // Contact Methods
                VStack(alignment: .leading, spacing: 12) {
                    Text("طرق التواصل")
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
                }
                
                Divider()
                
                // Guidelines
                VStack(alignment: .leading, spacing: 12) {
                    Text("نصائح لطلب الميزات")
                        .font(.title2.bold())
                    
                    VStack(alignment: .leading, spacing: 12) {
                        InfoRow(icon: "lightbulb.fill", text: "كن محدداً في وصف الميزة المطلوبة", themeColor: themeColor)
                        InfoRow(icon: "checkmark.circle.fill", text: "اشرح كيف ستساعدك هذه الميزة", themeColor: themeColor)
                        InfoRow(icon: "heart.fill", text: "نقدر كل المقترحات ونراجعها بعناية", themeColor: themeColor)
                    }
                }
            }
            .padding()
        }
        .gradientBackground(
            startColor: themeColor.opacity(0.3),
            endColor: .clear
        )
        .navigationTitle("طلب ميزات")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct InfoRow: View {
    let icon: String
    let text: String
    let themeColor: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(themeColor)
                .frame(width: 32, height: 32)
                .background(themeColor.opacity(0.1))
                .clipShape(Circle())
            
            Text(text)
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    NavigationStack {
        FeatureRequestView()
    }
}

