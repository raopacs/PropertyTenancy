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
    @State private var showingAddressEditForm = false
    @State private var showingTenancyForm = false
    @State private var showingTenancyEditForm = false
    @State private var showingRentAddForm = false
    @State private var showingSettings = false
    @State private var hasNotifications = false
    @State private var editingAddress: AddressModel?
    @State private var editingTenancy: TenancyModel?

    public init() {}

    @available(iOS 17.0, *)
    public var body: some View {
        TabView {
            // Properties Tab
            NavigationStack {
                Group {
                    if isLoading {
                        ProgressView("Loading data...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            VStack(spacing: 20) {
                                VStack(spacing: 15) {
                                    if properties.isEmpty {
                                        ContentUnavailableView("No Properties", systemImage: "house.fill", description: Text("Properties you add will appear here."))
                                            .padding(.vertical)
                                    } else {
                                        ForEach(properties, id: \.id) { property in
                                            AddressDisplayView(address: property)
                                                .onTapGesture {
                                                    editingAddress = property
                                                    showingAddressEditForm = true
                                                }
                                                .contextMenu {
                                                    Button {
                                                        editingAddress = property
                                                        showingAddressEditForm = true
                                                    } label: {
                                                        Label("Edit", systemImage: "pencil")
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
                .navigationTitle("Properties")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            showingAddressForm = true
                        }) {
                            Label("Add Property", systemImage: "plus.circle.fill")
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
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Properties")
            }
            
            // Tenancies Tab
            NavigationStack {
                Group {
                    if isLoading {
                        ProgressView("Loading data...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            VStack(spacing: 20) {
                                VStack(spacing: 15) {
                                    if tenancies.isEmpty {
                                        ContentUnavailableView("No Tenancies", systemImage: "person.2.fill", description: Text("Tenancies you add will appear here."))
                                            .padding(.vertical)
                                    } else {
                                        ForEach(tenancies, id: \.id) { tenancy in
                                            TenancyDisplayView(tenancy: tenancy)
                                                .onTapGesture {
                                                    editingTenancy = tenancy
                                                    showingTenancyEditForm = true
                                                }
                                                .contextMenu {
                                                    Button {
                                                        editingTenancy = tenancy
                                                        showingTenancyEditForm = true
                                                    } label: {
                                                        Label("Edit", systemImage: "pencil")
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
                .navigationTitle("Tenancies")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            showingTenancyForm = true
                        }) {
                            Label("Add Tenancy", systemImage: "plus.circle.fill")
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
            }
            .tabItem {
                Image(systemName: "person.2.fill")
                Text("Tenancies")
            }
            
            // Rent Tab
            NavigationStack {
                Group {
                    if isLoading {
                        ProgressView("Loading data...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            VStack(spacing: 20) {
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
                                            Button {
                                                collectDefaultRent(for: tenancy)
                                            } label: {
                                                Label("Quick Collect", systemImage: "checkmark.circle")
                                            }
                                            .buttonStyle(.bordered)
                                            .tint(.green)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding()
                                        .background(Color(.systemGroupedBackground))
                                        .cornerRadius(12)
                                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
                .navigationTitle("Rent")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            showingRentAddForm = true
                        }) {
                            Label("Add Rent", systemImage: "plus.circle.fill")
                        }
                        .disabled(tenancies.isEmpty)
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
                            ZStack {
                                Image(systemName: "gearshape.fill")
                                    .font(.title2)
                                
                                if hasNotifications {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 8, height: 8)
                                        .offset(x: 8, y: -8)
                                }
                            }
                        }
                    }
                }
            }
            .tabItem {
                Image(systemName: "indianrupeesign.circle.fill")
                Text("Rent")
            }
        }
        .onAppear {
            loadData()
            checkNotifications()
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
        .sheet(isPresented: $showingAddressEditForm) {
            NavigationView {
                if let toEdit = editingAddress {
                    AddressView(address: toEdit) {
                        showingAddressEditForm = false
                        editingAddress = nil
                        loadData()
                    }
                    .navigationTitle("Edit Property")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                showingAddressEditForm = false
                                editingAddress = nil
                            }
                        }
                    }
                } else {
                    Text("No property selected")
                        .navigationTitle("Edit Property")
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Close") { showingAddressEditForm = false }
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
        .sheet(isPresented: $showingTenancyEditForm) {
            NavigationView {
                if let toEdit = editingTenancy {
                    TenancyView(tenancy: toEdit) {
                        showingTenancyEditForm = false
                        editingTenancy = nil
                        loadData()
                    }
                    .navigationTitle("Edit Tenancy")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                showingTenancyEditForm = false
                                editingTenancy = nil
                            }
                        }
                    }
                } else {
                    Text("No tenancy selected")
                        .navigationTitle("Edit Tenancy")
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Close") { showingTenancyEditForm = false }
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

    private func collectDefaultRent(for tenancy: TenancyModel) {
        guard let tenancyId = tenancy.id else { return }
        let amount = tenancy.agreedRent
        guard amount > 0 else { return }
        do {
            let payment = RentPaymentModel(tenancyId: tenancyId, amount: amount, paidOn: Date(), notes: "quick collected rent")
            _ = try DatabaseManager.shared.saveRentPayment(payment)
            
            // Schedule notification for next month
            let nextMonthDueDate = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
            NotificationManager.shared.scheduleRentPaymentReminder(for: tenancy, dueDate: nextMonthDueDate)
            
            if let latest = try? DatabaseManager.shared.getLatestRentPayment(forTenancyId: tenancyId) {
                latestPaymentsByTenancyId[tenancyId] = latest
            }
        } catch {
            // Ignore errors for quick action
        }
    }
    
    private func checkNotifications() {
        // Check for overdue rent payments
        NotificationManager.shared.checkOverdueRentPayments()
        
        // Check for tenancy renewals
        NotificationManager.shared.checkTenancyRenewals()
        
        // Check if there are any active notifications
        checkActiveNotifications()
    }
    
    private func checkActiveNotifications() {
        let currentDate = Date()
        var hasActiveNotifications = false
        
        for tenancy in tenancies {
            // Check for overdue rent
            if let lastPayment = try? DatabaseManager.shared.getLatestRentPayment(forTenancyId: tenancy.id ?? 0) {
                let nextDueDate = Calendar.current.date(byAdding: .month, value: 1, to: lastPayment.paidOn) ?? currentDate
                if nextDueDate < currentDate {
                    hasActiveNotifications = true
                    break
                }
            } else {
                // No payments yet, check lease start
                let firstDueDate = Calendar.current.date(byAdding: .month, value: 1, to: tenancy.leaseStartDate) ?? currentDate
                if firstDueDate < currentDate {
                    hasActiveNotifications = true
                    break
                }
            }
            
            // Check for tenancy renewal
            let renewalDate = Calendar.current.date(byAdding: .month, value: 11, to: tenancy.agreementSignedDate) ?? currentDate
            if renewalDate <= currentDate {
                hasActiveNotifications = true
                break
            }
        }
        
        hasNotifications = hasActiveNotifications
    }
}
@available(iOS 17.0, *)
#Preview {
    ContentView()
}
