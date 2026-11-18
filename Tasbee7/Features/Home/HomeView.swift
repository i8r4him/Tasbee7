//
//  HomeView.swift
//  Tasbee7
//
//  The book: favourites first, then every group. Today's athkar live on the Today tab.
//

import SwiftUI

struct HomeView: View {
    @Environment(AthkarRepository.self) private var repository
    @Environment(FavoritesStore.self) private var favorites
    @Bindable private var router = AppRouter.shared

    @State private var showsSettings = false
    @Namespace private var zoom

    var body: some View {
        NavigationStack(path: $router.homePath) {
            content
                .navigationTitle("الأذكار")
                .toolbarTitleDisplayMode(.inlineLarge)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showsSettings = true
                        } label: {
                            Label("الإعدادات", systemImage: "gearshape.fill")
                        }
                    }
                    .matchedTransitionSource(id: "settings", in: zoom)
                }
                .sheet(isPresented: $showsSettings) {
                    SettingsView()
                        .navigationTransition(.zoom(sourceID: "settings", in: zoom))
                }
                .sensoryFeedback(.impact(weight: .medium), trigger: showsSettings) { _, shows in shows }
                .athkarDestinations(path: router.homePath)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch repository.state {
        case .failed(let message):
            ScrollView {
                StateCard(
                    systemImage: "exclamationmark.triangle",
                    title: "تعذّر فتح الأذكار",
                    message: message,
                    actionTitle: "حاول مرة أخرى",
                    action: repository.load
                )
                .padding(Spacing.screen)
            }
            .softScroll()
            .skyBackground()
        case .loading, .loaded:
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.section) {
                    let favoriteSections = favorites.sections(in: repository)
                    if !favoriteSections.isEmpty {
                        FavoritesRow(sections: favoriteSections)
                    }

                    CategoryGrid(groups: repository.groups)
                }
                .padding(Spacing.screen)
            }
            .softScroll()
            .readableContentMargins()
            .skyBackground()
        }
    }
}

#Preview {
    HomeView()
        .environment(AthkarRepository())
        .environment(FavoritesStore())
        .environment(ReadingPreferences())
}
