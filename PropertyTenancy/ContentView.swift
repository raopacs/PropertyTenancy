//
//  ContentView.swift
//  PropertyTenancy
//
//  Created by Prashanth Rao on 20/7/2025.
//

import SwiftUI

@available(iOS 17.0, *)
public struct ContentView: View {
    @State private var properties: [AddressModel] = []
    @State private var tenancies: [TenancyModel] = []
    @State private var isLoading = true
    @State private var showingAddressForm = false
    @State private var showingTenancyForm = false

    public init() {}

    @available(iOS 17.0, *)
    public var body: some View {
        NavigationStack {
            if isLoading {
                ProgressView("Loading data...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        CollapsibleView(title: "Properties (\(properties.count))") {
                            VStack(spacing: 15) {
                                if properties.isEmpty {
                                    ContentUnavailableView("No Properties", systemImage: "house.fill", description: Text("Properties you add will appear here."))
                                        .padding(.vertical)
                                } else {
                                    ForEach(properties, id: \.id) { property in
                                        AddressDisplayView(address: property)
                                    }
                                }
                                
                                Button(action: {
                                    showingAddressForm = true
                                }) {
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Add New Property")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                                }
                            }
                        }
                        
                        CollapsibleView(title: "Tenancies (\(tenancies.count))") {
                            VStack(spacing: 15) {
                                if tenancies.isEmpty {
                                    ContentUnavailableView("No Tenancies", systemImage: "person.2.fill", description: Text("Tenancies you add will appear here."))
                                        .padding(.vertical)
                                } else {
                                    ForEach(tenancies, id: \.id) { tenancy in
                                        TenancyDisplayView(tenancy: tenancy)
                                    }
                                }
                                
                                Button(action: {
                                    showingTenancyForm = true
                                }) {
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Add New Tenancy")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .cornerRadius(10)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Property Tenancy")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Menu {
                    Button(action: {
                        showingAddressForm = true
                    }) {
                        Label("Add Property", systemImage: "house.fill")
                    }
                    
                    Button(action: {
                        showingTenancyForm = true
                    }) {
                        Label("Add Tenancy", systemImage: "person.2.fill")
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    loadData() // Refresh data
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .onAppear {
            loadData()
        }
        .sheet(isPresented: $showingAddressForm) {
            NavigationView {
                AddressView(address: AddressModel()) {
                    showingAddressForm = false
                    loadData() // Reload data after saving
                }
                .navigationTitle("Add Property")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            showingAddressForm = false
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingTenancyForm) {
            NavigationView {
                TenancyView(tenancy: TenancyModel()) {
                    showingTenancyForm = false
                    loadData() // Reload data after saving
                }
                .navigationTitle("Add Tenancy")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            showingTenancyForm = false
                        }
                    }
                }
            }
        }
    }
    
    private func loadData() {
        isLoading = true
        
        do {
            properties = try DatabaseManager.shared.getAllAddresses()
            // Note: TenancyModel SQLite implementation would need to be added separately
            tenancies = []
        } catch {
            print("Error loading data: \(error)")
        }
        
        isLoading = false
    }
}
@available(iOS 17.0, *)
#Preview {
    ContentView()
}
