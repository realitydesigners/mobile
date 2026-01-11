//
//  PurchaseManager.swift
//  AppTemplate
//
//  Native StoreKit 2 subscription management - no third-party dependencies
//

import Foundation
import Combine
import StoreKit

/// Manages subscription state using native StoreKit 2
@MainActor
class PurchaseManager: ObservableObject {
    
    static let shared = PurchaseManager()
    
    /// Product ID from AppConfig - configure in AppConfig.swift
    static var productId: String { AppConfig.productId }
    
    @Published var isSubscribed: Bool = false
    @Published var isLoading: Bool = true
    @Published var products: [Product] = []
    @Published var hasEverPurchased: Bool = false
    
    private var updates: Task<Void, Never>? = nil
    
    private init() {
        updates = observeTransactionUpdates()
    }
    
    deinit {
        updates?.cancel()
    }
    
    /// Configure purchase manager and load products
    func configure() async {
        // Debug bypass for testing
        if AppConfig.debugBypassPaywall {
            isSubscribed = true
            isLoading = false
            return
        }
        
        await loadProducts()
        await updateSubscriptionStatus()
        isLoading = false
    }
    
    /// Load products from App Store
    func loadProducts() async {
        do {
            print("[PurchaseManager] Loading products for ID: \(Self.productId)")
            products = try await Product.products(for: [Self.productId])
            print("[PurchaseManager] Loaded \(products.count) products")
            if let product = products.first {
                print("[PurchaseManager] Product: \(product.displayName) - \(product.displayPrice)")
            }
        } catch {
            print("[PurchaseManager] Failed to load products: \(error)")
        }
    }
    
    /// Check current subscription status
    func checkSubscriptionStatus() async {
        isLoading = true
        await updateSubscriptionStatus()
        isLoading = false
    }
    
    /// Update subscription status based on current entitlements
    private func updateSubscriptionStatus() async {
        var hasActiveSubscription = false
        var hasEverMadePurchase = false
        
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID == Self.productId {
                    hasEverMadePurchase = true
                    
                    if transaction.revocationDate == nil {
                        let now = Date()
                        if let expirationDate = transaction.expirationDate {
                            hasActiveSubscription = now < expirationDate
                        } else {
                            // Lifetime purchase (no expiration)
                            hasActiveSubscription = true
                        }
                    }
                }
            }
        }
        
        self.hasEverPurchased = hasEverMadePurchase
        self.isSubscribed = hasActiveSubscription || hasEverMadePurchase
    }
    
    /// Start purchase flow
    func startPurchase() async -> Bool {
        print("[PurchaseManager] Starting purchase flow...")
        
        guard let product = products.first else {
            print("[PurchaseManager] No products loaded, attempting to load...")
            await loadProducts()
            guard let product = products.first else {
                print("[PurchaseManager] ERROR: No products found after loading!")
                return false
            }
            return await purchaseProduct(product)
        }
        
        return await purchaseProduct(product)
    }
    
    /// Purchase a specific product
    func purchaseProduct(_ product: Product) async -> Bool {
        isLoading = true
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await updateSubscriptionStatus()
                isLoading = false
                return true
                
            case .userCancelled, .pending:
                isLoading = false
                return false
                
            @unknown default:
                isLoading = false
                return false
            }
        } catch {
            print("[PurchaseManager] Purchase failed: \(error)")
            isLoading = false
            return false
        }
    }
    
    /// Verify transaction
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    /// Restore purchases
    func restorePurchases() async -> Bool {
        isLoading = true
        
        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
            isLoading = false
            return isSubscribed
        } catch {
            print("[PurchaseManager] Restore failed: \(error)")
            isLoading = false
            return false
        }
    }
    
    /// Observe transaction updates
    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await updateSubscriptionStatus()
                }
            }
        }
    }
}

// MARK: - Store Errors

enum StoreError: Error {
    case failedVerification
    case productNotFound
}
