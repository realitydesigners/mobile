//
//  ContentView.swift
//  AppTemplate
//
//  Root content view - handles app flow: auth → subscription → onboarding → main app
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var purchaseManager: PurchaseManager
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var favoritesService: FavoritesService
    
    @FetchRequest(
        sortDescriptors: [],
        animation: .default
    )
    private var userProfiles: FetchedResults<UserProfile>
    
    @State private var isLoaded = false
    
    private var hasCompletedOnboarding: Bool {
        guard let profile = userProfiles.first else { return false }
        if let hasCompleted = profile.value(forKey: "hasCompletedOnboarding") as? Bool {
            return hasCompleted
        }
        return false
    }
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            // Check auth state first
            if authManager.isLoading {
                loadingIndicator
            } else if !authManager.isAuthenticated {
                // Not signed in - show sign in
                SignInView()
            } else if purchaseManager.isLoading && !AppConfig.debugBypassPaywall {
                loadingIndicator
            } else if !purchaseManager.isSubscribed && !AppConfig.debugBypassPaywall {
                PaywallView()
            } else if !hasCompletedOnboarding && AppConfig.enableOnboarding {
                OnboardingView()
            } else if !isLoaded && AppConfig.enableLoadingScreen {
                LoadingView(isLoaded: $isLoaded)
            } else {
                MainTabView()
            }
        }
        .onChange(of: authManager.isAuthenticated) { _, isAuthenticated in
            if isAuthenticated {
                Task {
                    await favoritesService.fetchFavorites()
                }
            }
        }
        .onAppear {
            // Fetch favorites if already authenticated on app start
            if authManager.isAuthenticated {
                Task {
                    await favoritesService.fetchFavorites()
                }
            }
        }
    }
    
    private var loadingIndicator: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Loading...")
                .font(.outfit(size: 14, weight: .light))
                .foregroundColor(AppTheme.textMuted)
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(PurchaseManager.shared)
        .environmentObject(AuthManager.shared)
        .environmentObject(FavoritesService.shared)
}
