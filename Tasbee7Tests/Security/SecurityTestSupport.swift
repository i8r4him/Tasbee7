//
//  SecurityTestSupport.swift
//  Tasbee7Tests
//
//  Shared helpers for the security tests.
//

import Foundation

/// A throwaway preferences store per test, so tests never read or write the real app's data.
final class IsolatedDefaults {
    let suiteName = "tasbee7.security-tests.\(UUID().uuidString)"
    let defaults: UserDefaults

    init() {
        defaults = UserDefaults(suiteName: suiteName)!
    }

    deinit {
        defaults.removePersistentDomain(forName: suiteName)
    }
}

enum SecurityTestSupport {
    /// The app bundle: unit tests run inside the app, so its resources and Info.plist are here.
    static var appBundle: Bundle { .main }

    /// Invisible characters that can make text display differently from what it contains
    /// (bidi embeddings, overrides and isolates, marks, BOM).
    static let invisibleFormattingScalars: Set<UInt32> = Set(
        Array(0x202A...0x202E) + Array(0x2066...0x2069) + [0x200E, 0x200F, 0x061C, 0xFEFF]
    )
}
