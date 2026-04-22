//
//  ContentView.swift
//  Tasbee7
//
//  Created by Ibrahim Abdullah on 06.11.25.
//

import SwiftUI



struct ContentView: View {
    @Environment(AppSettings.self) private var appSettings
    
    @State private var selectedTab: Tabs = .home
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(Tabs.home.name, systemImage: Tabs.home.icon, value: .home) {
                HomeView()
            }

            Tab(Tabs.sebha.name, systemImage: Tabs.sebha.icon, value: .sebha) {
                SebhaView()
            }
            
            Tab(value: .search, role: .search) {
                SearchView()
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NotificationTapped"))) { _ in
            selectedTab = .home
        }
    }
}

#Preview {
    ContentView()
        .environment(FavoritesStore())
        .environment(AppSettings())
}
