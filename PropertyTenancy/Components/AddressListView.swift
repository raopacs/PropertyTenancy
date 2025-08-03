import SwiftUI

public struct AddressListView: View {
    @State private var addresses: [AddressModel] = []
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isLoading = true
    
    public init() {}
    
    @available(iOS 17.0, *)
    public var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading addresses...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if addresses.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "location.slash")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("No addresses found")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text("Add your first address to get started")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(addresses, id: \.id) { address in
                        AddressRowView(address: address) {
                            loadAddresses()
                        }
                    }
                }
            }
            .navigationTitle("Saved Addresses")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Refresh") {
                        loadAddresses()
                    }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
        .onAppear {
            loadAddresses()
        }
    }
    
    private func loadAddresses() {
        isLoading = true
        
        do {
            addresses = try DatabaseManager.shared.getAllAddresses()
        } catch {
            errorMessage = "Error loading addresses: \(error.localizedDescription)"
            showingError = true
        }
        
        isLoading = false
    }
}

@available(iOS 17.0, *)
struct AddressRowView: View {
    let address: AddressModel
    let onDelete: () -> Void
    @State private var showingDeleteAlert = false
    
    @available(iOS 17.0, *)
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if !address.title.isEmpty {
                        Text(address.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    
                    Text(address.line1)
                        .font(.body)
                    
                    if !address.line2.isEmpty {
                        Text(address.line2)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text(address.city)
                        if !address.state.isEmpty {
                            Text(", \(address.state)")
                        }
                        if !address.pinCode.isEmpty {
                            Text(" \(address.pinCode)")
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    showingDeleteAlert = true
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.vertical, 4)
        .alert("Delete Address", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteAddress()
            }
        } message: {
            Text("Are you sure you want to delete this address?")
        }
    }
    
    private func deleteAddress() {
        guard let id = address.id else { return }
        
        do {
            try DatabaseManager.shared.deleteAddress(id: id)
            onDelete()
        } catch {
            print("Error deleting address: \(error)")
        }
    }
}

#Preview {
    AddressListView()
} 
