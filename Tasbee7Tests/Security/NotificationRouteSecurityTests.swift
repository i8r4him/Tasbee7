//
//  NotificationRouteSecurityTests.swift
//  Tasbee7Tests
//
//  A notification's payload decides which chapter opens. Only chapters the catalog knows
//  may be opened; anything else falls back to the morning and evening athkar.
//

import Testing
@testable import Tasbee7

@MainActor
@Suite("Security: notification routing")
struct NotificationRouteSecurityTests {
    private let fallback = AthkarCatalog.morningEveningTitle

    @Test("A known chapter title is opened")
    func knownTitleIsAccepted() {
        let title = "أذكار النوم"
        #expect(AthkarCatalog.groupNameByTitle[title] != nil)
        #expect(NotificationRoute.sectionTitle(from: title) == title)
    }

    @Test("Every catalog title is accepted, so no real chapter is ever blocked")
    func everyCatalogTitleIsAccepted() {
        for group in AthkarCatalog.groups {
            for title in group.titles {
                #expect(NotificationRoute.sectionTitle(from: title) == title)
                #expect(title.count <= NotificationRoute.maxTitleLength)
            }
        }
    }

    @Test("Missing, empty, unknown or hostile payloads fall back", arguments: [
        nil,
        "",
        "عنوان غير موجود",
        "../../etc/passwd",
        "tasbee7://open?x=1",
        "<script>alert(1)</script>",
        "أذكار النوم\u{0000}",
        "\u{202E}أذكار النوم",
        " أذكار النوم ",
        String(repeating: "ذ", count: 10_000)
    ] as [String?])
    func untrustedPayloadFallsBack(payload: String?) {
        #expect(NotificationRoute.sectionTitle(from: payload) == fallback)
    }

    @Test("A title longer than the limit is rejected even if the check would accept it")
    func oversizedTitleIsRejectedBeforeLookup() {
        let long = String(repeating: "ا", count: NotificationRoute.maxTitleLength + 1)
        var lookedUp = false
        let result = NotificationRoute.sectionTitle(from: long) { _ in
            lookedUp = true
            return true
        }
        #expect(result == fallback)
        #expect(!lookedUp)
    }

    @Test("The router only ever receives a validated title")
    func routerOpensValidatedTitle() {
        let router = AppRouter.shared
        let previousTab = router.selectedTab
        let previousPath = router.homePath
        defer {
            router.selectedTab = previousTab
            router.homePath = previousPath
        }

        router.openSection(titled: NotificationRoute.sectionTitle(from: "not a chapter"))
        #expect(router.selectedTab == .home)
        #expect(router.homePath == [.section(fallback)])
    }
}
