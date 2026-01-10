//
//  Persistence.swift
//  mobile
//
//  Created by Raymond on 1/10/26.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Create a sample UserProfile for previews
        // IMPORTANT: UserProfile entity needs these attributes in Core Data model:
        // - createdAt (Date, optional)
        // - updatedAt (Date, optional)  
        // - hasCompletedOnboarding (Boolean)
        // - name (String, optional)
        // - email (String, optional)
        // - id (UUID, optional)
        // - avatarURL (String, optional)
        let sampleProfile = UserProfile(context: viewContext)
        
        // Set properties using setValue to avoid compile errors if attributes don't exist yet
        sampleProfile.setValue(Date(), forKey: "createdAt")
        sampleProfile.setValue(Date(), forKey: "updatedAt")
        sampleProfile.setValue(true, forKey: "hasCompletedOnboarding")
        sampleProfile.setValue("Preview User", forKey: "name")
        
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "mobile")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
