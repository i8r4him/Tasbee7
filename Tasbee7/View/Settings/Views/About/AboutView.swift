//
//  AboutView.swift
//  Tasbee7
//
//  Created by Ibrahim Abdullah on 09.11.25.
//

import SwiftUI

struct AboutView: View {
    @Environment(AppSettings.self) private var appSettings
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "غير معروف"
    }
    
    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "غير معروف"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("تسبيح")
                        .font(.largeTitle.bold())
                    
                    Text("تطبيق شامل للأذكار والتسبيحات اليومية")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // App Info Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .font(.title2)
                            .foregroundStyle(appSettings.themeColor)
                            .frame(width: 40, height: 40)
                        
                        Text("معلومات التطبيق")
                            .font(.title3.bold())
                    }
                    
                    VStack(spacing: 10) {
                        InfoRow(title: "الإصدار", value: appVersion, themeColor: appSettings.themeColor)
                        InfoRow(title: "رقم البناء", value: buildNumber, themeColor: appSettings.themeColor)
                        InfoRow(title: "الفئة", value: "أذكار وتسبيحات", themeColor: appSettings.themeColor)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .glassEffect(.regular.interactive(false), in: RoundedRectangle(cornerRadius: 20))
                
                // Description Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: "text.alignright")
                            .font(.title2)
                            .foregroundStyle(appSettings.themeColor)
                            .frame(width: 40, height: 40)
                        
                        Text("عن التطبيق")
                            .font(.title3.bold())
                    }
                    
                    Text("تطبيق تسبيح هو تطبيق شامل للأذكار والتسبيحات اليومية من كتاب حصن المسلم. يوفر التطبيق مجموعة واسعة من الأذكار مع ميزات متقدمة مثل البحث، المفضلة، عداد التسبيح، والتذكيرات الذكية بناءً على أوقات شروق وغروب الشمس.")
                        .font(.body)
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .glassEffect(.regular.interactive(false), in: RoundedRectangle(cornerRadius: 20))
                
                // Features Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 12) {
                        Image(systemName: "star.fill")
                            .font(.title2)
                            .foregroundStyle(appSettings.themeColor)
                            .frame(width: 40, height: 40)
                        
                        Text("المميزات")
                            .font(.title3.bold())
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        FeatureRow(icon: "book.fill", text: "أذكار الصباح والمساء من حصن المسلم", themeColor: appSettings.themeColor)
                        FeatureRow(icon: "magnifyingglass", text: "بحث سريع في جميع الأذكار", themeColor: appSettings.themeColor)
                        FeatureRow(icon: "star.fill", text: "نظام المفضلة لحفظ الأذكار المهمة", themeColor: appSettings.themeColor)
                        FeatureRow(icon: "point.3.connected.trianglepath.dotted", text: "عداد تسبيح رقمي", themeColor: appSettings.themeColor)
                        FeatureRow(icon: "bell.fill", text: "تذكيرات ذكية بناءً على شروق وغروب الشمس", themeColor: appSettings.themeColor)
                        FeatureRow(icon: "paintpalette.fill", text: "ألوان واجهة قابلة للتخصيص", themeColor: appSettings.themeColor)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .glassEffect(.regular.interactive(false), in: RoundedRectangle(cornerRadius: 20))
                
                // Developer Section
                VStack(spacing: 16) {
                    VStack(spacing: 8) {
                        Text("المطور")
                            .font(.title2.bold())
                        
                        Text("تواصل مع مطور التطبيق")
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
            }
            .padding()
        }
        .appGradientBackground()
        .symbolRenderingMode(.hierarchical)
        .navigationTitle("عن التطبيق")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct InfoRow: View {
    let title: String
    let value: String
    let themeColor: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.body.weight(.semibold))
                .foregroundStyle(themeColor)
        }
    }
}

private struct FeatureRow: View {
    let icon: String
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
        AboutView()
    }
    .environment(AppSettings())
}
