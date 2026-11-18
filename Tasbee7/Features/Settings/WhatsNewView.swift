//
//  WhatsNewView.swift
//  Tasbee7
//

import SwiftUI

struct WhatsNewView: View {
    private struct Release: Identifiable {
        var id: String { title }
        let title: String
        let isLatest: Bool
        let items: [(String, String, String)]
    }

    private let releases: [Release] = [
        Release(title: "تصميم جديد", isLatest: true, items: [
            ("sparkles", "مظهر جديد بالكامل", "زجاج سائل وسماء ليلية دافئة بلون تختاره."),
            ("paintpalette.fill", "سبعة ألوان", "ذهبي ونحاسي ولؤلؤي وغيرها، يتلوّن بها التطبيق كله."),
            ("bell.badge.fill", "تذكير بوقت أدق", "يتبع شروق الشمس وغروبها في مكانك كل يوم."),
            ("circle.dotted", "سبحة أذكى", "عدّ مستقل لكل ذكر، وتنبيه عند إتمام الهدف، وحذف أذكارك."),
            ("magnifyingglass", "بحث أذكى", "يجد الذكر ولو كتبته بلا تشكيل أو همزات.")
        ]),
        Release(title: "الإطلاق الأول", isLatest: false, items: [
            ("book.fill", "حصن المسلم", "الأذكار مرتبة في أقسام: الصباح والمساء، النوم، الصلاة، وغيرها."),
            ("star.fill", "المفضلة", "احفظ الأبواب التي تقرؤها كثيراً."),
            ("textformat", "خط شهرزاد", "خط عربي جميل لقراءة الأذكار.")
        ])
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.section) {
                ForEach(releases) { release in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            SectionHeader(title: release.title)
                            if release.isLatest {
                                Pill(title: "الأحدث")
                            }
                        }
                        VStack(spacing: 0) {
                            ForEach(Array(release.items.enumerated()), id: \.offset) { index, item in
                                if index > 0 { Divider().padding(.leading, 62) }
                                FeatureRow(systemImage: item.0, title: item.1, detail: item.2)
                            }
                        }
                        .glassEffect(.regular, in: .card)
                    }
                }
            }
            .padding(Spacing.screen)
        }
        .softScroll()
        .readableContentMargins()
        .plainBackground()
        .navigationTitle("ما الجديد")
        .toolbarTitleDisplayMode(.inline)
    }
}
