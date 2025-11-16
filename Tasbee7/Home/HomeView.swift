//
//  HomeView.swift
//  Tasbee7
//
//  Created by Ibrahim Abdullah on 06.11.25.
//

import SwiftUI

struct HomeView: View {
    @Environment(FavoritesStore.self) private var favorites
    
    private let cache = AthkarCache.shared
    @State private var catalog: HomeSections = .empty
    @State private var catalogBuildTask: Task<Void, Never>?
    @State private var lastSectionsHash: Int = 0
    @State private var lastFavoritesHash: Int = 0
    @State private var isExpanded: Bool = false
    
    @Namespace private var animation
    
    @AppStorage(AppTheme.storageKey) private var themeColorRaw: String = ThemeColor.أزرق.rawValue
    
    // Grid columns for favorites (computed once)
    private let gridColumns = [
        GridItem(.flexible(minimum: 160), spacing: 12, alignment: .top),
        GridItem(.flexible(minimum: 160), spacing: 12, alignment: .top)
    ]
    
    // Cache icon mapping for better performance
    private static let iconMap: [String: String] = [
        "مقدمة": "book.fill",
        "الاستيقاظ والنوم": "bed.double.fill",
        "الصباح والمساء": "sun.horizon.fill",
        "الصلاة": "pray",
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
                    ContentUnavailableView("تعذر التحميل", systemImage: "exclamationmark.triangle")
                } else if cache.sections.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 24) {
                            // Favorites - always show with placeholder
                            VStack(alignment: .leading, spacing: 12) {
                                Label {
                                    Text("المفضلة")
                                        .font(.title3.weight(.semibold))
                                } icon: {
                                    Image(systemName: "star.fill")
                                        .symbolRenderingMode(.hierarchical)
                                }
                                .tint(.accentColor)

                                if catalog.favorites.isEmpty {
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
                                    LazyVGrid(columns: gridColumns, alignment: .leading, spacing: 12, pinnedViews: []) {
                                        ForEach(catalog.favorites) { item in
                                            navigationLink(for: item)
                                        }
                                    }
                                }
                            }
                            // Grouped sections in exact order
                            ForEach(catalog.groups) { group in
                                SectionGrid(title: group.title, systemImage: iconForGroup(group.title), items: group.items) { item in
                                    navigationLink(for: item)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("الأذكار")
            .toolbarTitleDisplayMode(.inlineLarge)
            .gradientBackground(
                startColor: (ThemeColor(rawValue: themeColorRaw) ?? .أزرق).color.opacity(0.3),
                endColor: .clear
            )
            .sheet(isPresented: $isExpanded) {
                SettingsView()
                    .navigationTransition(
                        .zoom(sourceID: "Settings", in: animation)
                    )
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isExpanded.toggle()
                    }) {
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
        .onAppear {
            rebuildCatalog()
        }
        .onChange(of: cache.sections) { _, _ in
            rebuildCatalog()
        }
        .onChange(of: favorites.titles) { _, _ in
            rebuildCatalog()
        }
        .onDisappear {
            catalogBuildTask?.cancel()
            catalogBuildTask = nil
        }
    }

    private func navigationLink(for item: AthkarSection) -> some View {
        NavigationLink(value: item) {
            AthkarCard(title: item.title)
                .equatable()
        }
        .buttonStyle(.plain)
    }

    private func rebuildCatalog() {
        catalogBuildTask?.cancel()
        let sections = cache.sections
        let favoritesSet = favorites.allTitles
        
        // Performance: Only rebuild if data actually changed
        // Use count + a simple hash for quick comparison
        let sectionsKey = sections.count
        let favoritesKey = favoritesSet.count
        
        // Quick check: if counts match and we have cached data, check deeper
        if sectionsKey == lastSectionsHash && favoritesKey == lastFavoritesHash && !catalog.isEmpty {
            // Verify favorites actually match (quick Set comparison)
            let currentFavIds = Set(catalog.favorites.map { $0.id })
            if currentFavIds == favoritesSet {
                return // No changes detected, skip rebuild
            }
        }
        
        lastSectionsHash = sectionsKey
        lastFavoritesHash = favoritesKey

        catalogBuildTask = Task(priority: .userInitiated) {
            let newCatalog = HomeSections.build(from: sections, favorites: favoritesSet)
            guard !Task.isCancelled else { return }
            await MainActor.run {
                guard !Task.isCancelled else { return }
                catalog = newCatalog
                catalogBuildTask = nil
            }
        }
    }
    
    private func iconForGroup(_ groupName: String) -> String {
        Self.iconMap[groupName] ?? "square.grid.2x2"
    }
}

#Preview {
    HomeView()
        .environment(FavoritesStore())
}
