import SwiftUI

@available(iOS 17.0, *)
public struct TenancyView: View {
    @State var tenancy: TenancyModel
    var onSave: () -> Void

    private var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        // In a real app, this might come from user's locale or settings
        formatter.locale = Locale(identifier: "en_IN")
        return formatter
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tenancy")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 12) {
                TextField("Name", text: $tenancy.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Contact", text: $tenancy.contact)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                CollapsibleView(title: "Previous Address") {
                    AddressView(address: tenancy.address ?? AddressModel(), onSave: {})
                }

                DatePicker("Lease Start Date", selection: $tenancy.leaseStartDate, displayedComponents: .date)

                Toggle("Lease Agreement Signed", isOn: $tenancy.leaseAgreementSigned)

                HStack {
                    Text("Advance Amount")
                    Spacer()
                    TextField("Amount", value: $tenancy.advanceAmount, formatter: currencyFormatter)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 150)
                }

                DatePicker("Agreement Signed Date", selection: $tenancy.agreementSignedDate, displayedComponents: .date)

                VStack(alignment: .leading) {
                    Text("Comments")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextEditor(text: $tenancy.comments)
                        .frame(height: 80)
                        .padding(4)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                }
            }

            Button(action: onSave) {
                Text("Save Tenancy")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

@available(iOS 17.0, *)
#Preview {
    TenancyView(tenancy: TenancyModel(), onSave: { print("Save tapped") })
        .padding()
}
