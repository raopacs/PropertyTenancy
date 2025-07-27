import SwiftUI
import SwiftData

@available(iOS 17.0, *)
public struct AddressView: View {
    @Bindable var address: AddressModel
    var onSave: () -> Void

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
            
            Button(action: onSave) {
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
    }
}

@available(iOS 17.0, *)
#Preview {
    // This preview requires a model container to work with @Bindable on a SwiftData model.
    let container = try! ModelContainer(for: AddressModel.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    AddressView(address: AddressModel(title: "Home Preview"), onSave: { print("Save tapped") })
        .padding()
        .modelContainer(container)
} 
