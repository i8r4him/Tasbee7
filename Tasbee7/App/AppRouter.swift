//
//  AppRouter.swift
//  Tasbee7
//
//  Which tab is open and where each tab's navigation stands. Lets a notification open a chapter.
//

import Observation
import SwiftUI

enum AppTab: Hashable {
    case home, sebha, search
}

/// Places inside the athkar book that any tab can push.
enum AthkarRoute: Hashable {
    case group(String)
    case section(String)
}

@Observable
final class AppRouter {
    static let shared = AppRouter()

    var selectedTab: AppTab = .home
    var homePath: [AthkarRoute] = []
    var searchPath: [AthkarRoute] = []

    private init() {}

    /// Opens a chapter on the home tab, e.g. from a reminder.
    func openSection(titled title: String) {
        selectedTab = .home
        homePath = [.section(title)]
    }
}
