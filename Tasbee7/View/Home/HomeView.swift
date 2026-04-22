//
//  HomeView.swift
//  Tasbee7
//
//  Created by Ibrahim Abdullah on 06.11.25.
//

import SwiftUI

struct HomeView: View {
    @Environment(FavoritesStore.self) private var favorites
    @Environment(AppSettings.self) private var appSettings
    
    private let cache = AthkarCache.shared
    @State private var isShowingSettings = false
    
    @Namespace private var animation

    private var catalog: HomeSections {
        HomeSections.build(from: cache.sections, favorites: favorites.allTitles)
    }
    
    private let gridColumns = [
        GridItem(.flexible(minimum: 160), spacing: 12, alignment: .top),
        GridItem(.flexible(minimum: 160), spacing: 12, alignment: .top)
    ]
    
    private static let iconMap: [String: String] = [
        "مقدمة": "book.fill",
        "الاستيقاظ والنوم": "bed.double.fill",
        "الصباح والمساء": "sun.horizon.fill",
        "الصلاة": "hands.sparkles.fill",
        "الوضوء": "drop.fill",
        "الثياب": "tshirt.fill",
        "الخلاء": "toilet.fill",
        "المنزل": "house.fill",
        "الطعام": "fork.knife",
        "العطاس": "face.smiling",
        "الزواج": "heart.fill",
        "المرض والوفاة": "cross.case.fill",
        "المولود": "figure.child",
        "السفر": "airplane",
        "الحج": "building.columns.fill",
        "الطبيعة": "cloud.fill",
        "الحيوانات": "pawprint.fill",
        "الهم والحزن والكرب": "heart.text.square.fill",
        "الشيطان والوسوسة": "eye.trianglebadge.exclamationmark",
        "العدو والسلطان": "shield.fill",
        "الدين والمال": "dollarsign.circle.fill",
        "الغضب": "flame.fill",
        "العين": "eye.fill",
        "المجلس": "person.3.fill",
        "السلام": "hand.wave.fill",
        "الدعاء للمسلمين": "person.2.fill",
        "الذكر والتسبيح": "sparkles",
        "الصلاة على النبي": "star.fill",
        "الاستغفار": "arrow.uturn.backward.circle.fill",
        "الذبح": "scissors",
        "الكراهية": "xmark.circle.fill",
        "الخوف من الشرك": "exclamationmark.triangle.fill",
        "الذنب": "hand.raised.fill",
        "الصعوبة": "mountain.2.fill",
        "الفزع": "bolt.fill",
        "الشياطين": "eye.trianglebadge.exclamationmark.fill"
    ]

    var body: some View {
        NavigationStack {
            Group {
                if cache.sections.isEmpty && cache.loadError != nil {
                    HomeErrorState()
                } else if cache.sections.isEmpty {
                    HomeLoadingState()
                } else {
                    HomeCatalogView(
                        catalog: catalog,
                        columns: gridColumns,
                        iconForGroup: iconForGroup
                    )
                }
            }
            .navigationTitle("الأذكار")
            .toolbarTitleDisplayMode(.inlineLarge)
            .appGradientBackground()
            .sheet(isPresented: $isShowingSettings) {
                SettingsView()
                    .navigationTransition(
                        .zoom(sourceID: "Settings", in: animation)
                    )
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: openSettings) {
                        Image(systemName: "gearshape")
                    }
                }
                .matchedTransitionSource(
                    id: "Settings", in: animation
                )
            }
            .navigationDestination(for: AthkarSection.self) { section in
                AthkarDetailView(title: section.title, textItems: section.text, footnotes: section.footnote)
            }
        }
    }

    private func openSettings() {
        isShowingSettings = true
    }
    
    private func iconForGroup(_ groupName: String) -> String {
        Self.iconMap[groupName] ?? "square.grid.2x2"
    }
}

private struct HomeCatalogView: View {
    let catalog: HomeSections
    let columns: [GridItem]
    let iconForGroup: (String) -> String

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                FavoritesSectionView(items: catalog.favorites, columns: columns)
                CategoriesSectionView(
                    groups: catalog.groups,
                    columns: columns,
                    iconForGroup: iconForGroup
                )
            }
            .padding()
        }
    }
}

private struct FavoritesSectionView: View {
    let items: [AthkarSection]
    let columns: [GridItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "المفضلة", systemImage: "star.fill")

            if items.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "star")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text("لا توجد أذكار مفضلة")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
            } else {
                LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
                    ForEach(items) { item in
                        NavigationLink(value: item) {
                            AthkarCard(title: item.title)
                                .equatable()
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

private struct CategoriesSectionView: View {
    let groups: [HomeSections.Group]
    let columns: [GridItem]
    let iconForGroup: (String) -> String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "الأقسام", systemImage: "square.grid.2x2.fill")

            LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
                ForEach(groups) { group in
                    NavigationLink {
                        CategoryDetailView(group: group)
                    } label: {
                        CategoryCard(
                            title: group.title,
                            systemImage: iconForGroup(group.title),
                            count: group.items.count
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct SectionHeader: View {
    let title: String
    let systemImage: String

    var body: some View {
        Label {
            Text(title)
                .font(.title3.weight(.semibold))
        } icon: {
            Image(systemName: systemImage)
                .symbolRenderingMode(.hierarchical)
        }
        .tint(.accentColor)
    }
}

private struct HomeLoadingState: View {
    var body: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct HomeErrorState: View {
    var body: some View {
        ContentUnavailableView("تعذر التحميل", systemImage: "exclamationmark.triangle")
    }
}

#Preview {
    HomeView()
        .environment(FavoritesStore())
        .environment(AppSettings())
}
