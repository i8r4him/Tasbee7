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
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("طلب ميزات جديدة")
                        .font(.largeTitle.bold())
                    
                    Text("نحن نستمع لأفكارك! شاركنا بمقترحاتك لتحسين التطبيق")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 8)
                
                Divider()
                
                // Contact Methods
                VStack(alignment: .leading, spacing: 16) {
                    Text("طرق التواصل")
                        .font(.title2.bold())
                    
                    VStack(spacing: 12) {
                        Link(destination: URL(string: "https://x.com/i8r4him")!) {
                            HStack {
                                Image(systemName: "bird.fill")
                                    .foregroundStyle(themeColor)
                                    .frame(width: 24)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("X (Twitter)")
                                        .font(.headline)
                                    Text("@i8r4him")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "arrow.up.forward")
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        
                        Link(destination: URL(string: "https://instagram.com/i8r4him")!) {
                            HStack {
                                Image(systemName: "camera.fill")
                                    .foregroundStyle(themeColor)
                                    .frame(width: 24)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Instagram")
                                        .font(.headline)
                                    Text("@i8r4him")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "arrow.up.forward")
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                }
                
                Divider()
                
                // Guidelines
                VStack(alignment: .leading, spacing: 12) {
                    Text("نصائح لطلب الميزات")
                        .font(.title2.bold())
                    
                    VStack(alignment: .leading, spacing: 8) {
                        InfoRow(icon: "lightbulb.fill", text: "كن محدداً في وصف الميزة المطلوبة")
                        InfoRow(icon: "checkmark.circle.fill", text: "اشرح كيف ستساعدك هذه الميزة")
                        InfoRow(icon: "heart.fill", text: "نقدر كل المقترحات ونراجعها بعناية")
                    }
                }
            }
            .padding()
        }
        .navigationTitle("طلب ميزات")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct InfoRow: View {
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
        FeatureRequestView()
    }
}

