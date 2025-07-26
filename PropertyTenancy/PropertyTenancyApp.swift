//
//  PropertyTenancyApp.swift
//  PropertyTenancy
//
//  Created by Prashanth Rao on 20/7/2025.
//

import SwiftUI
import SwiftData
import PropertyTenancy

@main
struct PropertyTenancyApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
