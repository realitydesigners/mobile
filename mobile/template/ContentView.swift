//
//  ContentView.swift
//  AppTemplate
//
//  Root content view - handles app flow: subscription → onboarding → main app
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var purchaseManager: PurchaseManager
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \UserProfile.createdAt, ascending: false)],
        animation: .default
    )
    private var userProfiles: FetchedResults<UserProfile>
    
    @State private var isLoaded = false
    
    /// Check if user has completed onboarding
    private var hasCompletedOnboarding: Bool {
        guard let profile = userProfiles.first else { return false }
        return profile.hasCompletedOnboarding
    }
    
    var body: some View {
        ZStack {
            AppTheme.background1
                .ignoresSafeArea()
            
            // Check subscription status first
            if purchaseManager.isLoading {
                // Still checking subscription status
                loadingIndicator
            } else if !purchaseManager.isSubscribed {
                // Not subscribed - show paywall
                PaywallView()
            } else if !hasCompletedOnboarding && AppConfig.enableOnboarding {
                // Subscribed but no profile - show onboarding
                OnboardingView()
            } else if !isLoaded && AppConfig.enableLoadingScreen {
                // Has profile but still loading
                LoadingView(isLoaded: $isLoaded)
            } else {
                // All good - show main app
                MainTabView()
            }
        }
    }
    
    private var loadingIndicator: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Loading...")
                .font(.system(size: 14, weight: .light))
                .foregroundColor(AppTheme.textMuted)
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(PurchaseManager.shared)
}
