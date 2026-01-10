//
//  AppTemplateApp.swift
//  AppTemplate
//
//  App entry point - configure services and environment
//

import SwiftUI

@main
struct AppTemplateApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var purchaseManager = PurchaseManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(purchaseManager)
                .preferredColorScheme(.dark) // Force dark mode - remove for light mode support
                .task {
                    await purchaseManager.configure()
                }
        }
    }
}

