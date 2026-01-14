//
//  ContentView.swift
//  Tasbee7
//
//  Created by Ibrahim Abdullah on 06.11.25.
//

import SwiftUI
import StoreKit

enum Tabs {
    case home, sebha, settings, search
}

struct ContentView: View {
    @AppStorage(AppTheme.storageKey) private var themeColorRaw: String = ThemeColor.أزرق.rawValue
    
    @State private var selectedTab: Tabs = .home
    @State private var search: String = "ابحث هنا"
    @State private var subscriptionStatusState: EntitlementTaskState<SubscriptionStatus> = .loading
    
    @Environment(SubscriptionStatusModel.self) var subscriptionStatusModel: SubscriptionStatusModel
    @Environment(\.subscriptionIDs) private var subscriptionIDs
    
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
        .subscriptionStatusTask(for: subscriptionIDs.group) { taskStatus in
            self.subscriptionStatusState = taskStatus.map { statuses in
                StoreManager.shared.subscriptionStatus(
                    for: statuses,
                    ids: subscriptionIDs
                )
            }
            
            switch self.subscriptionStatusState {
            case .failure(let error):
                subscriptionStatusModel.status = .notSubscribed
                print("Failed to check subscription status: \(error)")
            case .success(let status):
                subscriptionStatusModel.status = status
            case .loading: 
                break
            @unknown default: 
                break
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(FavoritesStore())
        .environment(SubscriptionStatusModel())
}
