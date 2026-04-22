//
//  FeatureRequestView.swift
//  Tasbee7
//
//  Created by Ibrahim Abdullah on 09.11.25.
//

import SwiftUI

struct FeatureRequestView: View {
    @Environment(AppSettings.self) private var appSettings
    
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
                
                // Guidelines Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 12) {
                        Image(systemName: "lightbulb.fill")
                            .font(.title2)
                            .foregroundStyle(appSettings.themeColor)
                            .frame(width: 40, height: 40)
                        
                        Text("نصائح مهمة")
                            .font(.title3.bold())
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        GuidelineItem(text: "كن محدداً في وصف الميزة المطلوبة", themeColor: appSettings.themeColor)
                        GuidelineItem(text: "اشرح كيف ستساعدك هذه الميزة", themeColor: appSettings.themeColor)
                        GuidelineItem(text: "نقدر كل المقترحات ونراجعها بعناية", themeColor: appSettings.themeColor)
                        GuidelineItem(text: "وقت الرد قد يستغرق عدة أيام", themeColor: appSettings.themeColor)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .glassEffect(.regular.interactive(false), in: RoundedRectangle(cornerRadius: 20))
                
                // Contact Section
                VStack(spacing: 16) {
                    VStack(spacing: 8) {
                        Text("تواصل معنا")
                            .font(.title2.bold())
                        
                        Text("شاركنا أفكارك ومقترحاتك")
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
                .padding(.top, 8)
            }
            .padding()
        }
        .appGradientBackground()
        .symbolRenderingMode(.hierarchical)
        .navigationTitle("طلب ميزات")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct GuidelineItem: View {
    let text: String
    let themeColor: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(themeColor)
                .frame(width: 6, height: 6)
                .padding(.top, 7)
            
            Text(text)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    NavigationStack {
        FeatureRequestView()
    }
    .environment(AppSettings())
}
