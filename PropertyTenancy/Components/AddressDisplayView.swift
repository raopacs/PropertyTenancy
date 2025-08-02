import SwiftUI

@available(iOS 17.0, *)
public struct AddressDisplayView: View {
    let address: AddressModel

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !address.title.isEmpty {
                Text(address.title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }

            VStack(alignment: .leading, spacing: 3) {
                if !address.line1.isEmpty {
                    Text(address.line1)
                }
                if !address.line2.isEmpty {
                    Text(address.line2)
                }
                let cityState = [address.city, address.state]
                    .filter { !$0.isEmpty }
                    .joined(separator: ", ")
                if !cityState.isEmpty {
                    Text(cityState)
                }
                if !address.pinCode.isEmpty {
                    Text(address.pinCode)
                }
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

@available(iOS 17.0, *)
#Preview {
    let sampleAddress = AddressModel(
        title: "yellow", line1: "456 2nd mn, indira nagar", city: "bengaluru", state: "Ka", pinCode: "560043"
    )

    return AddressDisplayView(address: sampleAddress).padding()
}
