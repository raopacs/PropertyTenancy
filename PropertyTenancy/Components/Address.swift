import SwiftUI

struct Address: View {
    @State private var line1: String = ""
    @State private var line2: String = ""
    @State private var city: String = ""
    @State private var state: String = ""
    @State private var pinCode: String = ""
    @State private var title: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Address")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 12) {
                TextField("Title (e.g. Home, Work)", text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Address Line 1", text: $line1)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Address Line 2", text: $line2)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                HStack(spacing: 12) {
                    TextField("City", text: $city)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("State", text: $state)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                HStack(spacing: 12) {
                    TextField("PIN Code", text: $pinCode)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    Address()
        .padding()
} 
