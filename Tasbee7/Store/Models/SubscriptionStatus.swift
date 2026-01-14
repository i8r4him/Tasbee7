//
//  SubscriptionStatus.swift
//  Tasbee7
//
//  Created by Ibrahim Abdullah on 14.01.26.
//

import Foundation
import StoreKit

enum SubscriptionStatus: Comparable, Hashable, Sendable {
    case notSubscribed
    case monthly
    case annual
    
    init?(productID: Product.ID, ids: SubscriptionIdentifiers) {
        switch productID {
        case ids.monthly: self = .monthly
        case ids.annual: self = .annual
        default: return nil
        }
    }
    
    var description: String {
        switch self {
        case .notSubscribed:
            "غير مشترك"
        case .monthly:
            "شهري"
        case .annual:
            "سنوي"
        }
    }
    
    var isPremium: Bool {
        self != .notSubscribed
    }
}
