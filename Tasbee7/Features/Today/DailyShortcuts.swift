//
//  DailyShortcuts.swift
//  Tasbee7
//
//  "تطبيقاتك اليومية": round glass shortcuts in a sideways row. Only things that exist in the app.
//

import SwiftUI

struct DailyShortcuts: View {
    @Bindable private var router = AppRouter.shared
    @State private var taps = 0
    @ScaledMetric(relativeTo: .title2) private var circle: CGFloat = 64

    private struct Shortcut: Identifiable {
        enum Target { case route(AthkarRoute), tab(AppTab) }
        let id: String
        let title: String
        let systemImage: String
        let target: Target
    }

    private let shortcuts: [Shortcut] = [
        Shortcut(id: "sebha", title: "السبحة", systemImage: "circle.dotted", target: .tab(.sebha)),
        Shortcut(id: "afterPrayer", title: "أذكار بعد الصلاة", systemImage: "hands.sparkles.fill",
                 target: .route(.section(AthkarCatalog.afterPrayerTitle))),
        Shortcut(id: "morningEvening", title: "الصباح والمساء", systemImage: "sun.horizon.fill",
                 target: .route(.section(AthkarCatalog.morningEveningTitle))),
        Shortcut(id: "sleep", title: "أذكار النوم", systemImage: "moon.zzz.fill",
                 target: .route(.section(AthkarCatalog.sleepTitle))),
        Shortcut(id: "waking", title: "الاستيقاظ", systemImage: "sunrise.fill",
                 target: .route(.section(AthkarCatalog.wakingTitle))),
        Shortcut(id: "book", title: "حصن المسلم", systemImage: "book.fill", target: .tab(.home)),
        Shortcut(id: "search", title: "البحث", systemImage: "magnifyingglass", target: .tab(.search)),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "تطبيقاتك اليومية")

            ScrollView(.horizontal) {
                GlassEffectContainer(spacing: 0) {
                    LazyHStack(alignment: .top, spacing: 14) {
                        ForEach(shortcuts) { shortcut in
                            Button {
                                open(shortcut)
                            } label: {
                                VStack(spacing: 8) {
                                    Image(systemName: shortcut.systemImage)
                                        .font(.system(size: circle * 0.36, weight: .semibold))
                                        .symbolRenderingMode(.hierarchical)
                                        .foregroundStyle(.accent)
                                        .frame(width: circle, height: circle)
                                        .background(Color.accentFill.opacity(0.10), in: .circle)
                                        .glassEffect(.regular.interactive(), in: .circle)
                                    Text(shortcut.title)
                                        .font(.footnote.weight(.medium))
                                        .foregroundStyle(.primary)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                        .frame(width: circle + 20)
                                }
                                .contentShape(.rect)
                            }
                            .buttonStyle(.plain)
                            .accessibilityElement(children: .combine)
                            .accessibilityAddTraits(.isButton)
                        }
                    }
                    .scrollTargetLayout()
                    .padding(.vertical, 4)
                }
            }
            .scrollTargetBehavior(.viewAligned)
            .softScroll()
            .scrollClipDisabled()
            .sensoryFeedback(.impact(weight: .medium), trigger: taps)
        }
    }

    private func open(_ shortcut: Shortcut) {
        taps += 1
        switch shortcut.target {
        case .route(let route):
            router.todayPath.append(route)
        case .tab(let tab):
            router.selectedTab = tab
        }
    }
}
