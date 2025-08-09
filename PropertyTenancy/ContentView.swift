//
//  ContentView.swift
//  PropertyTenancy
//
//  Created by Prashanth Rao on 20/7/2025.
//

import SwiftUI
import Combine

@available(iOS 17.0, *)
public struct ContentView: View {
    @State private var properties: [AddressModel] = []
    @State private var tenancies: [TenancyModel] = []
    @State private var latestPaymentsByTenancyId: [Int64: RentPaymentModel] = [:]
    @State private var isLoading = true
    @State private var showingAddressForm = false
    @State private var showingTenancyForm = false
    @State private var showingRentAddForm = false
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
                            
                            CollapsibleView(title: "Tenancies (\(tenancies.count))", actions: {
                                Button {
                                    showingRentAddForm = true
                                } label: {
                                    Label("Add Rent", systemImage: "indianrupeesign.circle")
                                }
                                .disabled(tenancies.isEmpty)
                            }) {
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

                            CollapsibleView(title: "Latest Rent Summary") {
                                VStack(spacing: 12) {
                                    if tenancies.isEmpty {
                                        ContentUnavailableView("No Tenancies", systemImage: "person.2.fill", description: Text("Add a tenancy to track rent."))
                                            .padding(.vertical)
                                    } else {
                                        ForEach(tenancies, id: \.id) { tenancy in
                                            HStack(alignment: .firstTextBaseline) {
                                                Text(tenancy.name)
                                                    .font(.subheadline)
                                                Spacer()
                                                if let id = tenancy.id, let payment = latestPaymentsByTenancyId[id] {
                                                    VStack(alignment: .trailing) {
                                                        Text(NumberFormatter.localizedString(from: NSNumber(value: payment.amount), number: .currency))
                                                            .font(.subheadline)
                                                            .fontWeight(.medium)
                                                        Text(dateFormatter.string(from: payment.paidOn))
                                                            .font(.caption)
                                                            .foregroundColor(.secondary)
                                                    }
                                                } else {
                                                    Text("—")
                                                        .foregroundColor(.secondary)
                                                }
                                            }
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

                        Button(action: {
                            showingRentAddForm = true
                        }) {
                            Label("Add Rent", systemImage: "indianrupeesign.circle.fill")
                        }
                        .disabled(tenancies.isEmpty)
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
        .onReceive(NotificationCenter.default.publisher(for: .rentPaymentSaved)) { notification in
            guard let userInfo = notification.userInfo,
                  let tenancyId = userInfo["tenancyId"] as? Int64 else { return }
            if let payment = try? DatabaseManager.shared.getLatestRentPayment(forTenancyId: tenancyId) {
                latestPaymentsByTenancyId[tenancyId] = payment
            }
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
        .sheet(isPresented: $showingRentAddForm) {
            NavigationView {
                RentAddView(tenancies: tenancies) {
                    showingRentAddForm = false
                    loadLatestPayments()
                }
                .navigationTitle("Add Rent")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") { showingRentAddForm = false }
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
            loadLatestPayments()
        } catch {
            print("Error loading data: \(error)")
        }
        
        isLoading = false
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }

    private func loadLatestPayments() {
        var map: [Int64: RentPaymentModel] = [:]
        for tenancy in tenancies {
            if let id = tenancy.id, let payment = try? DatabaseManager.shared.getLatestRentPayment(forTenancyId: id) {
                map[id] = payment
            }
        }
        latestPaymentsByTenancyId = map
    }
}
@available(iOS 17.0, *)
#Preview {
    ContentView()
}
