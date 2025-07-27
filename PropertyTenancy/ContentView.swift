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
    @State private var newAddress = AddressModel()
    @State private var newTenancy = TenancyModel()

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    CollapsibleView(title: "Properties") {
                        AddressView(address: newAddress, onSave: {})
                    }
                    
                    CollapsibleView(title: "Tenancy") {
                        TenancyView(tenancy: newTenancy, onSave: {})
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
        .modelContainer(for: AddressModel.self, inMemory: true)
}
