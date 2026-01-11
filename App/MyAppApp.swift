//
//  MyAppApp.swift
//  MyApp
//
//  App entry point - configure services and environment
//

import SwiftUI
import CoreData

@main
struct MyAppApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var purchaseManager = PurchaseManager.shared
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var favoritesService = FavoritesService.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(purchaseManager)
                .environmentObject(DashboardProvider.shared)
                .environmentObject(authManager)
                .environmentObject(favoritesService)
                .preferredColorScheme(.dark)
                .task {
                    await purchaseManager.configure()
                }
                .onOpenURL { url in
                    Task {
                        await authManager.handleURL(url)
                    }
                }
        }
    }
}
