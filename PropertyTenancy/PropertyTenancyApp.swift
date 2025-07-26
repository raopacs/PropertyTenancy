//
//  PropertyTenancyApp.swift
//  PropertyTenancy
//
//  Created by Prashanth Rao on 20/7/2025.
//

import SwiftUI
import SwiftData

@main
@available(iOS 17.0, *)
struct PropertyTenancyApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([AddressModel.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        return try! ModelContainer(for: schema, configurations: [modelConfiguration])
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
