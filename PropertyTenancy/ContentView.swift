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
    @State private var showingSettings = false

    public init() {}

    @available(iOS 17.0, *)
    public var body: some View {
        NavigationStack {
            Group {
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
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                    }
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
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
    
    private func loadData() {
        isLoading = true
        
        do {
            properties = try DatabaseManager.shared.getAllAddresses()
            tenancies = try DatabaseManager.shared.getAllTenancies()
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
