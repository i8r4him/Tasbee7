//
//  ContentView.swift
//  Tasbee7
//
//  Created by Ibrahim Abdullah on 06.11.25.
//

import SwiftUI

enum Tabs {
    case home, sebha, settings, search
}

struct ContentView: View {
    @AppStorage(AppTheme.storageKey) private var themeColorRaw: String = ThemeColor.أزرق.rawValue
    
    @State private var selectedTab: Tabs = .home
    @State private var search: String = "ابحث هنا"
    
    private var themeColor: Color {
        (ThemeColor(rawValue: themeColorRaw) ?? .أزرق).color
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("الرئيسية", systemImage: "house", value: Tabs.home) {
                HomeView()
            }

            Tab("السبحة", systemImage: "point.3.connected.trianglepath.dotted", value: Tabs.sebha) {
                SebhaView()
            }
            
            Tab("البحث", systemImage: "magnifyingglass", value: Tabs.search, role: .search) {
                SearchView()
            }
        }
        .tint(themeColor)
        .tabBarMinimizeBehavior(.onScrollDown)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NotificationTapped"))) { notification in
            selectedTab = .home
        }
    }
}

#Preview {
    ContentView()
        .environment(FavoritesStore())
}
