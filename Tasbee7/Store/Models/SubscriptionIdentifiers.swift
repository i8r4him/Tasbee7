//
//  SubscriptionIdentifiers.swift
//  Tasbee7
//
//  Created by Ibrahim Abdullah on 14.01.26.
//

import SwiftUI

struct SubscriptionIdentifiers: Sendable {
    let group: String
    let monthly: String
    let annual: String
}

extension EnvironmentValues {
    private enum SubscriptionIDsKey: EnvironmentKey {
        static var defaultValue = SubscriptionIdentifiers(
            group: "21891681",
            monthly: "com.tasbee7.premium.monthly",
            annual: "com.tasbee7.premium.annual"
        )
    }
    
    var subscriptionIDs: SubscriptionIdentifiers {
        get { self[SubscriptionIDsKey.self] }
        set { self[SubscriptionIDsKey.self] = newValue }
    }
}
