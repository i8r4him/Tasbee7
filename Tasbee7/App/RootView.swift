//
//  RootView.swift
//  Tasbee7
//
//  The tab bar (Today first), the theme tint, rounded type and the app-wide motion setting.
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
        styled(tabs)
            .fullScreenCover(isPresented: showsOnboarding) {
                styled(onboarding)
            }
            .onChange(of: scenePhase, initial: true) { _, phase in
                appBecameActive(phase)
            }
            .onChange(of: location.coordinate) {
                Task { await reminders.reschedule() }
            }
    }

    // Split into small pieces so the type checker never has to solve one long chain.

    private var tabs: some View {
        TabView(selection: $router.selectedTab) {
            Tab("اليوم", systemImage: "sun.horizon", value: AppTab.today) {
                TodayView()
            }

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
    }

    private var onboarding: some View {
        OnboardingView {
            hasCompletedOnboarding = true
        }
    }

    /// The theme tint, rounded type and the app-wide motion setting.
    private func styled(_ content: some View) -> some View {
        let tint: Color = Theme.shared.palette.accent
        return content
            .tint(tint)
            .fontDesign(.rounded)
            .environment(\.reducesMotion, systemReduceMotion)
    }

    private func appBecameActive(_ phase: ScenePhase) {
        guard phase == .active else { return }
        UNUserNotificationCenter.current().setBadgeCount(0)
        // A fresh place for prayer times and reminders, but only once the user has allowed it
        // (or turned a reminder on, which asks).
        if reminders.anyEnabled || location.isAuthorized {
            location.refresh()
        }
        Task { await reminders.reschedule() }
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
