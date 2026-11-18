//
//  RootView.swift
//  Tasbee7
//
//  The tab bar, the theme tint, rounded type and the app-wide motion setting.
//

import SwiftUI
import UserNotifications

struct RootView: View {
    @Bindable private var router = AppRouter.shared
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.scenePhase) private var scenePhase

    private let reminders = ReminderScheduler.shared
    private let location = LocationService.shared

    var body: some View {
        TabView(selection: $router.selectedTab) {
            Tab("الأذكار", systemImage: "book", value: AppTab.home) {
                HomeView()
            }

            Tab("السبحة", systemImage: "circle.dotted", value: AppTab.sebha) {
                SebhaView()
            }

            Tab(value: AppTab.search, role: .search) {
                SearchView()
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .tint(Color.accent)
        .fontDesign(.rounded)
        .environment(\.reducesMotion, systemReduceMotion)
        .fullScreenCover(isPresented: showsOnboarding) {
            OnboardingView {
                hasCompletedOnboarding = true
            }
            .tint(Color.accent)
            .fontDesign(.rounded)
            .environment(\.reducesMotion, systemReduceMotion)
        }
        .onChange(of: scenePhase, initial: true) { _, phase in
            guard phase == .active else { return }
            UNUserNotificationCenter.current().setBadgeCount(0)
            if reminders.anyEnabled {
                location.refresh()
            }
            Task { await reminders.reschedule() }
        }
        .onChange(of: location.coordinate) {
            Task { await reminders.reschedule() }
        }
    }

    private var showsOnboarding: Binding<Bool> {
        Binding(
            get: { !hasCompletedOnboarding },
            set: { hasCompletedOnboarding = !$0 }
        )
    }
}

#Preview {
    RootView()
        .environment(AthkarRepository())
        .environment(FavoritesStore())
        .environment(ReadingPreferences())
}
