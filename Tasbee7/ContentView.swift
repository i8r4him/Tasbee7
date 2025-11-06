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
    
    @State private var selectedTab: Tabs = .home
    @State private var search: String = "ابحث هنا"
    
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
        .tabBarMinimizeBehavior(.onScrollDown)
        .searchable(text: $search, placement: .navigationBarDrawer, prompt: "ابحث هنا")
    }
}

#Preview {
    ContentView()
        .environment(FavoritesStore())
}
