//
//  mobileApp.swift
//  mobile
//
//  Created by Raymond on 1/10/26.
//

import SwiftUI
import CoreData

@main
struct mobileApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
