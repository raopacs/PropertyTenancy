import SwiftUI

public struct AddressExampleView: View {
    @State private var showingAddressForm = false
    @State private var showingAddressList = false
    
    public init() {}
    
    @available(iOS 17.0, *)
    public var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "location.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Address Management")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("SQLite Database Example")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Action Buttons
                VStack(spacing: 16) {
                    Button(action: {
                        showingAddressForm = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add New Address")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        showingAddressList = true
                    }) {
                        HStack {
                            Image(systemName: "list.bullet")
                            Text("View All Addresses")
                        }
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Info Section
                VStack(spacing: 12) {
                    Text("Features")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        FeatureRow(icon: "checkmark.circle.fill", text: "Save addresses to SQLite database")
                        FeatureRow(icon: "checkmark.circle.fill", text: "Update existing addresses")
                        FeatureRow(icon: "checkmark.circle.fill", text: "Delete addresses")
                        FeatureRow(icon: "checkmark.circle.fill", text: "View all saved addresses")
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
            }
            .navigationTitle("Address Manager")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingAddressForm) {
            NavigationView {
                AddressView(address: AddressModel()) {
                    showingAddressForm = false
                }
                .navigationTitle("Add Address")
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
        .sheet(isPresented: $showingAddressList) {
            AddressListView()
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.green)
                .font(.system(size: 16, weight: .semibold))
            
            Text(text)
                .font(.subheadline)
            
            Spacer()
        }
    }
}

#Preview {
    AddressExampleView()
} 
