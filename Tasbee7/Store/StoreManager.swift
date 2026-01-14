//
//  StoreManager.swift
//  Tasbee7
//
//  Created by Ibrahim Abdullah on 14.01.26.
//

import OSLog
import Foundation
import StoreKit

actor StoreManager {
    private let logger = Logger(
        subsystem: "com.tasbee7",
        category: "Store Manager"
    )
        
    private init() {}
    
    private(set) static var shared: StoreManager!
        
    static func createSharedInstance() {
        shared = StoreManager()
    }
    
    // MARK: - Subscription Status
    
    nonisolated func subscriptionStatus(for statuses: [Product.SubscriptionInfo.Status], ids: SubscriptionIdentifiers) -> SubscriptionStatus {
        // Find the highest-tier active subscription
        let effectiveStatus = statuses.max { lhs, rhs in
            // Compare subscription tiers directly using product IDs
            let lhsProductID = lhs.transaction.unsafePayloadValue.productID
            let rhsProductID = rhs.transaction.unsafePayloadValue.productID
            
            // Determine tier priority: annual > monthly
            let lhsPriority = (lhsProductID == ids.annual) ? 2 : (lhsProductID == ids.monthly) ? 1 : 0
            let rhsPriority = (rhsProductID == ids.annual) ? 2 : (rhsProductID == ids.monthly) ? 1 : 0
            
            return lhsPriority < rhsPriority
        }
        
        guard let effectiveStatus else {
            return .notSubscribed
        }
        
        let transaction: Transaction
        switch effectiveStatus.transaction {
        case .verified(let t):
            transaction = t
        case .unverified(_, let error):
            logger.error("Unverified transaction: \(error.localizedDescription)")
            return .notSubscribed
        }
        
        // Check if subscription is valid
        if case .autoRenewable = transaction.productType {
            // Check for revocation
            if !(transaction.revocationDate == nil && transaction.revocationReason == nil) {
                return .notSubscribed
            }
            
            // Check expiration
            if let subscriptionExpirationDate = transaction.expirationDate {
                if subscriptionExpirationDate.timeIntervalSince1970 < Date().timeIntervalSince1970 {
                    return .notSubscribed
                }
            }
        }
        
        // Convert product ID to subscription status
        let productID = transaction.productID
        if productID == ids.monthly {
            return .monthly
        } else if productID == ids.annual {
            return .annual
        } else {
            return .notSubscribed
        }
    }
    
    // MARK: - Transaction Processing
    
    func process(transaction verificationResult: VerificationResult<Transaction>) async {
        let unsafeTransaction = verificationResult.unsafePayloadValue
        logger.log("Processing transaction ID \(unsafeTransaction.id) for \(unsafeTransaction.productID)")
        
        let transaction: Transaction
        switch verificationResult {
        case .verified(let t):
            logger.debug("Transaction ID \(t.id) for \(t.productID) is verified")
            transaction = t
        case .unverified(let t, let error):
            logger.error("Transaction ID \(t.id) for \(t.productID) is unverified: \(error)")
            return
        }
        
        await transaction.finish()
    }
    
    func checkForUnfinishedTransactions() async {
        for await transaction in Transaction.unfinished {
            Task.detached(priority: .background) {
                await self.process(transaction: transaction)
            }
        }
    }
    
    func observeTransactionUpdates() async {
        for await update in Transaction.updates {
            await self.process(transaction: update)
        }
    }
}
