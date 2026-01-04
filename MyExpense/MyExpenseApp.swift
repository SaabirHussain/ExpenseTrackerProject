//
//  MyExpenseApp.swift
//  MyExpense
//
//  Created by Saabir Hussain on 2026-01-01.
//

import SwiftUI

@main
struct MyExpenseApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext,
                              persistenceController.container.viewContext)
        }
    }
}

