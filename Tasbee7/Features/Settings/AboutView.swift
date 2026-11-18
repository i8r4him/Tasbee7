//
//  AboutView.swift
//  Tasbee7
//

import SwiftUI

struct AboutView: View {
    private let features: [(String, String, String)] = [
        ("sun.horizon.fill", "اليوم", "أوقات الصلاة على جهازك، وأذكار الوقت، وورد اليوم، وآية كل يوم."),
        ("book.fill", "حصن المسلم كاملاً", "١٣٤ باباً في ٣٦ قسماً، بخط شهرزاد أو خط النظام."),
        ("circle.dotted", "سبحة رقمية", "عدّ لكل ذكر، وهدف تختاره، واهتزاز خفيف مع كل تسبيحة."),
        ("magnifyingglass", "بحث ذكي", "يجد الذكر ولو كتبته بلا تشكيل أو همزات."),
        ("bell.badge.fill", "تذكير بالشمس", "أذكار الصباح والمساء على وقت الشروق والغروب عندك."),
        ("star.fill", "المفضلة", "احفظ الأبواب التي تقرؤها كل يوم.")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.section) {
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("تسبيح")
                            .textRole(.largeTitle)
                        Text("رفيقك اليومي للأذكار، مجاناً وبلا إعلانات.")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Artwork(systemImage: "moon.stars.fill")
                        .frame(width: 96, height: 96)
                }

                VStack(spacing: 0) {
                    ForEach(Array(features.enumerated()), id: \.offset) { index, feature in
                        if index > 0 { Divider().padding(.leading, 62) }
                        FeatureRow(systemImage: feature.0, title: feature.1, detail: feature.2)
                    }
                }
                .glassEffect(.regular, in: .card)

                Text("نص آية اليوم من مشروع تنزيل (tanzil.net) دون أي تعديل، برخصة CC BY 3.0.")
                    .textRole(.caption)
                    .foregroundStyle(.secondary)

                DeveloperLinks()
            }
            .padding(Spacing.screen)
        }
        .softScroll()
        .readableContentMargins()
        .plainBackground()
        .navigationTitle("عن تسبيح")
        .toolbarTitleDisplayMode(.inline)
    }
}

/// An accent icon on a faint tile, a headline and a secondary line. Used in glass list cards.
struct FeatureRow: View {
    let systemImage: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.grid) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(.accent)
                .frame(width: 34, height: 34)
                .background(.accent.opacity(0.10), in: .rect(cornerRadius: Radius.tile, style: .continuous))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.headline)
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(Spacing.card)
        .accessibilityElement(children: .combine)
    }
}

/// X and Instagram as two glass buttons.
struct DeveloperLinks: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "تواصل مع المطوّر")
            GlassEffectContainer(spacing: 8) {
                HStack(spacing: Spacing.grid) {
                    Link(destination: SettingsView.developerXURL) {
                        Label("إكس", systemImage: "at")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity, minHeight: 30)
                    }
                    .buttonStyle(.glass)
                    Link(destination: SettingsView.developerInstagramURL) {
                        Label("إنستغرام", systemImage: "camera.fill")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity, minHeight: 30)
                    }
                    .buttonStyle(.glass)
                }
            }
        }
    }
}
