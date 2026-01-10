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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(purchaseManager)
                .environmentObject(DashboardProvider.shared)
                .preferredColorScheme(.dark) // Force dark mode - remove for light mode support
                .task {
                    await purchaseManager.configure()
                }
        }
    }
}
