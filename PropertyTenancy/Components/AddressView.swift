import SwiftUI

public struct AddressView: View {
    @State var address: AddressModel
    @State private var showingSaveAlert = false
    @State private var alertMessage = ""
    var onSave: () -> Void

    @available(iOS 17.0, *)
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Address")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 12) {
                TextField("Title (e.g. Home, Work)", text: $address.title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Address Line 1", text: $address.line1)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Address Line 2", text: $address.line2)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                HStack(spacing: 12) {
                    TextField("City", text: $address.city)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("State", text: $address.state)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                HStack(spacing: 12) {
                    TextField("PIN Code", text: $address.pinCode)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
            }
            
            Button(action: saveAddress) {
                Text("Save Address")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .alert("Save Result", isPresented: $showingSaveAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func saveAddress() {
        do {
            if address.id != nil {
                // Update existing address
                try DatabaseManager.shared.updateAddress(address)
                alertMessage = "Address updated successfully!"
            } else {
                // Save new address
                let savedId = try DatabaseManager.shared.saveAddress(address)
                address.id = savedId
                alertMessage = "Address saved successfully with ID: \(savedId)"
            }
            showingSaveAlert = true
            onSave()
        } catch {
            alertMessage = "Error saving address: \(error.localizedDescription)"
            showingSaveAlert = true
        }
    }
}

#Preview {
    AddressView(address: AddressModel(title: "Home Preview"), onSave: { print("Save tapped") })
        .padding()
} 
