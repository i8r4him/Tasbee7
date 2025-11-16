//
//  PrivacyPolicyView.swift
//  Tasbee7
//
//  Created by Ibrahim Abdullah on 09.11.25.
//

import SwiftUI

struct PrivacyPolicyView: View {
    // Privacy policy hosted on GitHub Pages
    private let privacyPolicyURL = URL(string: "https://i8r4him.github.io/Privacy-Policy-for-Tasbee7-App/")!
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("سياسة الخصوصية")
                        .font(.largeTitle.bold())
                    
                    Text("آخر تحديث: 9 نوفمبر 2025")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 8)
                
                Divider()
                
                // Introduction
                VStack(alignment: .leading, spacing: 8) {
                    Text("مقدمة")
                        .font(.title2.bold())
                    
                    Text("تطبيق تسبيح يحترم خصوصيتك. توضح سياسة الخصوصية هذه كيفية جمع واستخدام وحماية معلوماتك عند استخدام تطبيقنا المحمول.")
                }
                
                Divider()
                
                // Location Data
                VStack(alignment: .leading, spacing: 12) {
                    Text("بيانات الموقع")
                        .font(.title2.bold())
                    
                    InfoRow(title: "ما نجمع", content: "بيانات الموقع التقريبية (إحداثيات خطوط الطول والعرض)")
                    InfoRow(title: "لماذا نجمعها", content: "لحساب أوقات شروق وغروب الشمس بدقة لموقعك، مما يسمح لنا بإرسال تذكيرات في الوقت المناسب لأذكار الصباح والمساء")
                    InfoRow(title: "كيف نستخدمها", content: "تُستخدم بيانات الموقع فقط للحسابات الفلكية. نحن لا نخزن أو نشارك أو نرسل بيانات موقعك إلى أي خوادم أو أطراف ثالثة")
                    InfoRow(title: "التخزين", content: "تتم معالجة بيانات الموقع محلياً على جهازك فقط")
                }
                
                Divider()
                
                // Data Storage
                VStack(alignment: .leading, spacing: 12) {
                    Text("تخزين البيانات")
                        .font(.title2.bold())
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("• جميع بيانات التطبيق (المفضلة، الإعدادات، التفضيلات) تُخزن محلياً على جهازك")
                        Text("• نحن لا نملك إمكانية الوصول إلى بياناتك الشخصية")
                        Text("• لا نستخدم أي خدمات تحليل أو تتبع تابعة لأطراف ثالثة")
                        Text("• لا يتم إرسال أي بيانات إلى خوادم خارجية")
                    }
                    .font(.body)
                }
                
                Divider()
                
                // Your Rights
                VStack(alignment: .leading, spacing: 12) {
                    Text("حقوقك")
                        .font(.title2.bold())
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("• يمكنك تعطيل خدمات الموقع في أي وقت من خلال إعدادات iOS")
                        Text("• يمكنك حذف التطبيق في أي وقت، مما سيزيل جميع البيانات المخزنة محلياً")
                        Text("• جميع بياناتك محلية ويمكنك التحكم الكامل فيها")
                    }
                    .font(.body)
                }
                
                Divider()
                
                // Contact
                VStack(alignment: .leading, spacing: 12) {
                    Text("الاتصال بنا")
                        .font(.title2.bold())
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Link(destination: URL(string: "https://x.com/i8r4him")!) {
                            HStack {
                                Image(systemName: "bird.fill")
                                Text("X (Twitter): @i8r4him")
                            }
                        }
                        
                        Link(destination: URL(string: "https://instagram.com/i8r4him")!) {
                            HStack {
                                Image(systemName: "camera.fill")
                                Text("Instagram: @i8r4him")
                            }
                        }
                    }
                }
                
                Divider()
                
                // Link to full policy
                Link(destination: privacyPolicyURL) {
                    HStack {
                        Text("عرض السياسة الكاملة على الويب")
                        Spacer()
                        Image(systemName: "arrow.up.forward")
                    }
                    .foregroundStyle(.blue)
                }
            }
            .padding()
        }
        .navigationTitle("سياسة الخصوصية")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct InfoRow: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
            Text(content)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        PrivacyPolicyView()
    }
}

