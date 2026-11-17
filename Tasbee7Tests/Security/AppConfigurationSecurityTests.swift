//
//  AppConfigurationSecurityTests.swift
//  Tasbee7Tests
//
//  Guards the app's privacy and network settings, so a later change can't quietly widen them.
//

import Foundation
import Testing
@testable import Tasbee7

@MainActor
@Suite("Security: app configuration")
struct AppConfigurationSecurityTests {
    private var info: [String: Any] { SecurityTestSupport.appBundle.infoDictionary ?? [:] }

    @Test("App Transport Security isn't weakened")
    func atsIsNotWeakened() {
        guard let ats = info["NSAppTransportSecurity"] as? [String: Any] else { return }
        #expect(ats["NSAllowsArbitraryLoads"] as? Bool != true)
        #expect(ats["NSAllowsArbitraryLoadsInWebContent"] as? Bool != true)
        #expect(ats["NSAllowsArbitraryLoadsForMedia"] as? Bool != true)
        #expect(ats["NSAllowsLocalNetworking"] as? Bool != true)
        #expect(ats["NSExceptionDomains"] == nil)
    }

    @Test("Location is only asked for while in use, never always or in the background")
    func locationIsWhenInUseOnly() {
        #expect(info["NSLocationWhenInUseUsageDescription"] as? String != nil)
        #expect(info["NSLocationAlwaysAndWhenInUseUsageDescription"] == nil)
        #expect(info["NSLocationAlwaysUsageDescription"] == nil)
        let modes = info["UIBackgroundModes"] as? [String] ?? []
        #expect(!modes.contains("location"))
    }

    @Test("No permissions the app doesn't use", arguments: [
        "NSCameraUsageDescription", "NSMicrophoneUsageDescription", "NSContactsUsageDescription",
        "NSPhotoLibraryUsageDescription", "NSPhotoLibraryAddUsageDescription", "NSCalendarsUsageDescription",
        "NSUserTrackingUsageDescription", "NSBluetoothAlwaysUsageDescription", "NSHealthShareUsageDescription",
        "NSFaceIDUsageDescription", "NSLocalNetworkUsageDescription", "NSSpeechRecognitionUsageDescription"
    ])
    func noUnusedPermissions(key: String) {
        #expect(info[key] == nil)
    }

    @Test("The app registers no URL schemes, so other apps can't drive it with crafted links")
    func noCustomURLSchemes() {
        #expect(info["CFBundleURLTypes"] == nil)
    }

    @Test("The privacy manifest says no tracking and no collected data")
    func privacyManifestIsStrict() throws {
        let url = try #require(SecurityTestSupport.appBundle.url(forResource: "PrivacyInfo", withExtension: "xcprivacy"))
        let plist = try PropertyListSerialization.propertyList(from: Data(contentsOf: url), format: nil)
        let manifest = try #require(plist as? [String: Any])
        #expect(manifest["NSPrivacyTracking"] as? Bool == false)
        #expect((manifest["NSPrivacyTrackingDomains"] as? [Any])?.isEmpty == true)
        #expect((manifest["NSPrivacyCollectedDataTypes"] as? [Any])?.isEmpty == true)
    }

    @Test("Every outside link is HTTPS to an expected host", arguments: [
        SettingsView.appStoreURL, SettingsView.developerXURL, SettingsView.developerInstagramURL
    ])
    func outsideLinksAreHTTPS(url: URL) {
        #expect(url.scheme == "https")
        #expect(["apps.apple.com", "x.com", "instagram.com"].contains(url.host() ?? ""))
        #expect(url.user() == nil && url.password() == nil)
    }
}
