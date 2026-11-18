//
//  SupportView.swift
//  Tasbee7
//
//  How to use the app, and how to reach the developer with a question or an idea.
//

import SwiftUI

struct SupportView: View {
    private let tips: [(String, String, String)] = [
        ("book.fill", "تصفّح الأذكار", "افتح أي قسم من الصفحة الرئيسية، أو ابدأ بأذكار اليوم من البطاقة الكبيرة."),
        ("star.fill", "المفضلة", "اضغط النجمة أعلى أي باب ليظهر في المفضلة. اضغطها مرة أخرى لإزالته."),
        ("circle.dotted", "السبحة", "اضغط الدائرة للعدّ. غيّر الذكر من الزر أعلاها، واسحب لحذف ذكر أضفته."),
        ("bell.badge.fill", "التذكيرات", "من الإعدادات ← التذكيرات. اسمح بالموقع لتكون الأوقات على شمس مدينتك."),
        ("doc.on.doc", "النسخ والمشاركة", "اضغط ⋯ على أي ذكر لنسخه أو مشاركته.")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.section) {
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "كيف تستخدم تسبيح")
                    VStack(spacing: 0) {
                        ForEach(Array(tips.enumerated()), id: \.offset) { index, tip in
                            if index > 0 { Divider().padding(.leading, 62) }
                            FeatureRow(systemImage: tip.0, title: tip.1, detail: tip.2)
                        }
                    }
                    .glassEffect(.regular, in: .card)
                }

                StateCard(
                    systemImage: "lightbulb.fill",
                    title: "عندك فكرة أو سؤال؟",
                    message: "نقرأ كل رسالة. صِف الميزة وكيف ستساعدك، وسنرد في أقرب وقت."
                )

                DeveloperLinks()
            }
            .padding(Spacing.screen)
        }
        .softScroll()
        .readableContentMargins()
        .plainBackground()
        .navigationTitle("المساعدة والاقتراحات")
        .toolbarTitleDisplayMode(.inline)
    }
}
