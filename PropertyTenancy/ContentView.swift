//
//  ContentView.swift
//  PropertyTenancy
//
//  Created by Prashanth Rao on 20/7/2025.
//

import SwiftUI
import SwiftData

@available(iOS 17.0, *)
public struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \AddressModel.title) private var properties: [AddressModel]
    @Query(sort: \TenancyModel.name) private var tenancies: [TenancyModel]

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    CollapsibleView(title: "Properties (\(properties.count))") {
                        if properties.isEmpty {
                            ContentUnavailableView("No Properties", systemImage: "house.fill", description: Text("Properties you add will appear here."))
                                .padding(.vertical)
                        } else {
                            VStack(spacing: 15) {
                                ForEach(properties) { property in
                                    AddressDisplayView(address: property)
                                }
                            }
                        }
                    }
                    
                    CollapsibleView(title: "Tenancies (\(tenancies.count))") {
                        if tenancies.isEmpty {
                            ContentUnavailableView("No Tenancies", systemImage: "person.2.fill", description: Text("Tenancies you add will appear here."))
                                .padding(.vertical)
                        } else {
                            VStack(spacing: 15) {
                                ForEach(tenancies) { tenancy in
                                    TenancyDisplayView(tenancy: tenancy)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Property Tenancy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Action for the button
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}
@available(iOS 17.0, *)
#Preview {
    ContentView()
        .modelContainer(for: [AddressModel.self, TenancyModel.self], inMemory: true)
}
