//
//  PrivacyView.swift
//  Tasbee7
//

import SwiftUI

struct PrivacyView: View {
    private let policyURL = URL(string: "https://i8r4him.github.io/Privacy-Policy-for-Tasbee7-App/")!

    private let points: [(String, String, String)] = [
        ("iphone", "كل شيء على جهازك", "المفضلة والسبحة وسجل البحث محفوظة على جهازك فقط، ولا نملك وصولاً إليها."),
        ("location.fill", "موقع تقريبي فقط", "إذا فعّلت التذكيرات نستخدم موقعاً تقريبياً لحساب الشروق والغروب على جهازك، ولا نرسله لأحد."),
        ("eye.slash.fill", "بلا تتبع", "لا إعلانات، ولا خدمات تحليل، ولا خوادم خارجية."),
        ("trash.fill", "التحكم لك", "أوقف الموقع أو الإشعارات من إعدادات iPhone متى شئت، وحذف التطبيق يمسح كل بياناته.")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.section) {
                VStack(spacing: 0) {
                    ForEach(Array(points.enumerated()), id: \.offset) { index, point in
                        if index > 0 { Divider().padding(.leading, 62) }
                        FeatureRow(systemImage: point.0, title: point.1, detail: point.2)
                    }
                }
                .glassEffect(.regular, in: .card)

                Link(destination: policyURL) {
                    Label("اقرأ السياسة كاملة", systemImage: "safari")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: 30)
                }
                .buttonStyle(.glass)
            }
            .padding(Spacing.screen)
        }
        .softScroll()
        .readableContentMargins()
        .plainBackground()
        .navigationTitle("الخصوصية")
        .toolbarTitleDisplayMode(.inline)
    }
}
