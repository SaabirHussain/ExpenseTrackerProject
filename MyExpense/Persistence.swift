//
//  Persistence.swift
//  MyExpense
//
//  Created by Saabir Hussain on 2026-01-01.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    // Preview Instance
    @MainActor
    static let preview: PersistenceController = {
        PersistenceController(inMemory: true)
    }()

    // Core Data (Database Manager)
    let container: NSPersistentContainer

    // Set-up the database
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "MyExpense")
        // Data dissappears when app closes (Previews, tests):
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null") // Throw it away
        }
        // Load/Open the database
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
        // Auto-merge changes (when have multiple contexts)
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
