//
//  PaywallView.swift
//  AppTemplate
//
//  Native StoreKit 2 subscription paywall - customize features and branding
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject var purchaseManager: PurchaseManager
    
    @State private var selectedProduct: Product?
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var appearAnimation = false
    
    var body: some View {
        ZStack {
            // Background
            AppTheme.background1
                .ignoresSafeArea()
            
            EtherealBackgroundView()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    Spacer(minLength: 60)
                    
                    // Header
                    headerSection
                    
                    // Features
                    featuresSection
                    
                    // Pricing options
                    if !purchaseManager.products.isEmpty {
                        pricingSection
                    } else if purchaseManager.isLoading {
                        VStack(spacing: 12) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.pearl))
                            Text("Loading subscription options...")
                                .font(.system(size: 13, weight: .light))
                                .foregroundColor(AppTheme.textMuted)
                        }
                        .padding(24)
                    } else {
                        // Error state with retry
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.icloud")
                                .font(.system(size: 32))
                                .foregroundColor(AppTheme.textMuted)
                            
                            Text("Unable to load subscription options. Please check your connection and try again.")
                                .font(.system(size: 14, weight: .light))
                                .foregroundColor(AppTheme.textSecondary)
                                .multilineTextAlignment(.center)
                            
                            Button(action: {
                                Task {
                                    await purchaseManager.loadProducts()
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.clockwise")
                                    Text("Try Again")
                                }
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppTheme.celestialBlue)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(AppTheme.celestialBlue.opacity(0.1))
                                .cornerRadius(20)
                            }
                        }
                        .padding(24)
                        .glass(intensity: 0.05, cornerRadius: 20)
                    }
                    
                    // Subscribe button
                    subscribeButton
                    
                    // Restore & Terms
                    footerSection
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                appearAnimation = true
            }
            
            // Pre-select first product if available
            if selectedProduct == nil, let firstProduct = purchaseManager.products.first {
                selectedProduct = firstProduct
            }
        }
        .onChange(of: purchaseManager.products) { _, products in
            if selectedProduct == nil, let firstProduct = products.first {
                selectedProduct = firstProduct
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(spacing: 24) {
            // Logo
            ZStack {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .stroke(AppTheme.pearl.opacity(0.04 - Double(i) * 0.01), lineWidth: 0.5)
                        .frame(width: 100 + CGFloat(i) * 35)
                }
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [AppTheme.pearl, AppTheme.opal, AppTheme.moonstone],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: 50
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(color: AppTheme.pearl.opacity(0.25), radius: 40)
                
                // Replace with your app icon
                Image(systemName: "star.fill")
                    .font(.system(size: 32))
                    .foregroundColor(AppTheme.void)
            }
            .scaleEffect(appearAnimation ? 1 : 0.8)
            .opacity(appearAnimation ? 1 : 0)
            
            VStack(spacing: 12) {
                Text(AppConfig.paywallTitle)
                    .font(.system(size: 28, weight: .light, design: .serif))
                    .foregroundColor(AppTheme.pearl)
                
                Text(AppConfig.paywallSubtitle)
                    .font(.system(size: 16, weight: .light))
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .opacity(appearAnimation ? 1 : 0)
        }
    }
    
    // MARK: - Features
    
    private var featuresSection: some View {
        VStack(spacing: 16) {
            ForEach(AppConfig.paywallFeatures, id: \.text) { feature in
                FeatureRow(icon: feature.icon, text: feature.text)
            }
        }
        .padding(20)
        .glass(intensity: 0.05, cornerRadius: 20)
        .opacity(appearAnimation ? 1 : 0)
    }
    
    // MARK: - Pricing
    
    private var pricingSection: some View {
        VStack(spacing: 12) {
            ForEach(purchaseManager.products, id: \.id) { product in
                PricingOption(
                    product: product,
                    isSelected: selectedProduct?.id == product.id,
                    onSelect: { selectedProduct = product }
                )
            }
        }
        .opacity(appearAnimation ? 1 : 0)
    }
    
    // MARK: - Subscribe Button
    
    private var subscribeButton: some View {
        Button(action: subscribe) {
            HStack {
                if isPurchasing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.void))
                        .scaleEffect(0.8)
                } else {
                    Text("Start Your Journey")
                }
            }
            .etherealButton(isEnabled: selectedProduct != nil && !isPurchasing)
        }
        .disabled(selectedProduct == nil || isPurchasing)
        .opacity(appearAnimation ? 1 : 0)
    }
    
    // MARK: - Footer
    
    private var footerSection: some View {
        VStack(spacing: 16) {
            Button(action: restore) {
                Text("Restore Purchases")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            HStack(spacing: 16) {
                Link("Terms of Use", destination: AppConfig.termsOfServiceURL)
                Text("·")
                Link("Privacy Policy", destination: AppConfig.privacyPolicyURL)
            }
            .font(.system(size: 12))
            .foregroundColor(AppTheme.textMuted)
            
            if let product = selectedProduct {
                Text(subscriptionDisclaimer(for: product))
                    .font(.system(size: 10))
                    .foregroundColor(AppTheme.textMuted)
                    .multilineTextAlignment(.center)
            } else {
                Text("Payment will be charged to your Apple ID account. Subscription automatically renews unless canceled at least 24 hours before the end of the current period. You can manage or cancel your subscription in your Apple ID account settings.")
                    .font(.system(size: 10))
                    .foregroundColor(AppTheme.textMuted)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 8)
        .opacity(appearAnimation ? 1 : 0)
    }
    
    // MARK: - Helpers
    
    private func subscriptionDisclaimer(for product: Product) -> String {
        let productName = product.displayName
        let price = product.displayPrice
        
        // Determine subscription period
        if let subscription = product.subscription {
            let unit = subscription.subscriptionPeriod.unit
            let value = subscription.subscriptionPeriod.value
            
            let duration: String
            switch unit {
            case .year:
                duration = value == 1 ? "year" : "\(value) years"
            case .month:
                duration = value == 1 ? "month" : "\(value) months"
            case .week:
                duration = value == 1 ? "week" : "\(value) weeks"
            case .day:
                duration = value == 1 ? "day" : "\(value) days"
            @unknown default:
                duration = "period"
            }
            
            return "\(productName) subscription: \(price) per \(duration). Payment will be charged to your Apple ID account at confirmation of purchase. Subscription automatically renews unless canceled at least 24 hours before the end of the current period. You can manage or cancel your subscription in your Apple ID account settings."
        } else {
            // One-time purchase
            return "\(productName) (\(price)) is a one-time purchase. Payment will be charged to your Apple ID account."
        }
    }
    
    // MARK: - Actions
    
    private func subscribe() {
        guard let product = selectedProduct else { return }
        
        isPurchasing = true
        
        Task {
            let success = await purchaseManager.purchaseProduct(product)
            if !success && !purchaseManager.isSubscribed {
                errorMessage = "Purchase could not be completed."
                showError = true
            }
            isPurchasing = false
        }
    }
    
    private func restore() {
        isPurchasing = true
        
        Task {
            let success = await purchaseManager.restorePurchases()
            if !success {
                errorMessage = "No active subscription found."
                showError = true
            }
            isPurchasing = false
        }
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(AppTheme.celestialBlue)
                .frame(width: 24)
            
            Text(text)
                .font(.system(size: 15, weight: .light))
                .foregroundColor(AppTheme.textPrimary)
            
            Spacer()
        }
    }
}

// MARK: - Pricing Option

struct PricingOption: View {
    let product: Product
    let isSelected: Bool
    let onSelect: () -> Void
    
    private var title: String {
        // Try to determine type from subscription period
        if let subscription = product.subscription {
            switch subscription.subscriptionPeriod.unit {
            case .year: return "Yearly"
            case .month: return "Monthly"
            case .week: return "Weekly"
            case .day: return "Daily"
            @unknown default: return product.displayName
            }
        }
        return "Lifetime"
    }
    
    private var durationText: String {
        if let subscription = product.subscription {
            let unit = subscription.subscriptionPeriod.unit
            let value = subscription.subscriptionPeriod.value
            
            switch unit {
            case .year:
                return value == 1 ? "per year" : "per \(value) years"
            case .month:
                return value == 1 ? "per month" : "per \(value) months"
            case .week:
                return value == 1 ? "per week" : "per \(value) weeks"
            case .day:
                return value == 1 ? "per day" : "per \(value) days"
            @unknown default:
                return ""
            }
        }
        return "one-time purchase"
    }
    
    private var savings: String? {
        if let subscription = product.subscription,
           subscription.subscriptionPeriod.unit == .year {
            return "Best Value"
        }
        return nil
    }
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppTheme.textPrimary)
                        
                        if let savings = savings {
                            Text(savings)
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(AppTheme.void)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(AppTheme.starlightGold)
                                .cornerRadius(4)
                        }
                    }
                    
                    HStack(spacing: 4) {
                        Text(product.displayPrice)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(AppTheme.textSecondary)
                        
                        Text(durationText)
                            .font(.system(size: 12, weight: .light))
                            .foregroundColor(AppTheme.textMuted)
                    }
                }
                
                Spacer()
                
                // Selection indicator
                Circle()
                    .stroke(isSelected ? AppTheme.celestialBlue : AppTheme.textMuted.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                    .frame(width: 22, height: 22)
                    .overlay(
                        Circle()
                            .fill(isSelected ? AppTheme.celestialBlue : Color.clear)
                            .frame(width: 12, height: 12)
                    )
            }
            .padding(18)
            .background(isSelected ? AppTheme.celestialBlue.opacity(0.1) : Color.white.opacity(0.04))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? AppTheme.celestialBlue.opacity(0.5) : Color.white.opacity(0.08), lineWidth: isSelected ? 1.5 : 0.5)
            )
        }
    }
}

#Preview {
    PaywallView()
        .environmentObject(PurchaseManager.shared)
}
