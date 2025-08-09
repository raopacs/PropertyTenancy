import SwiftUI

@available(iOS 17.0, *)
public struct RentCollectionView: View {
    let tenancy: TenancyModel
    var onSaved: () -> Void

    @State private var amount: Double = 0.0
    @State private var paidOn: Date = Date()
    @State private var notes: String = ""

    @State private var showingAlert = false
    @State private var alertMessage = ""
    @Environment(\.dismiss) private var dismiss

    private var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_IN")
        return formatter
    }

    public init(tenancy: TenancyModel, onSaved: @escaping () -> Void) {
        self.tenancy = tenancy
        self.onSaved = onSaved
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Collect Rent")
                .font(.headline)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Amount")
                    Spacer()
                    TextField("Amount", value: $amount, formatter: currencyFormatter)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 180)
                }

                DatePicker("Paid On", selection: $paidOn, displayedComponents: .date)

                VStack(alignment: .leading) {
                    Text("Notes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextEditor(text: $notes)
                        .frame(height: 80)
                        .padding(4)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                }
            }

            Button(action: savePayment) {
                Text("Save Payment")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .alert("Rent Collection", isPresented: $showingAlert) {
            Button("OK") {}
        } message: {
            Text(alertMessage)
        }
    }

    private func savePayment() {
        guard let tenancyId = tenancy.id else {
            alertMessage = "Cannot save payment: tenancy has no ID"
            showingAlert = true
            return
        }
        do {
            let payment = RentPaymentModel(tenancyId: tenancyId, amount: amount, paidOn: paidOn, notes: notes)
            _ = try DatabaseManager.shared.saveRentPayment(payment)
            NotificationCenter.default.post(name: .rentPaymentSaved, object: nil, userInfo: ["tenancyId": tenancyId])
            alertMessage = "Payment saved."
            showingAlert = true
            onSaved()
            dismiss()
        } catch {
            alertMessage = "Error: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    let address = AddressModel(title: "Unit 5", line1: "123 Street", city: "City", state: "State", pinCode: "12345")
    let tenancy = TenancyModel(id: 1, name: "John Doe", contact: "1234567890", address: address)
    return RentCollectionView(tenancy: tenancy, onSaved: {})
        .padding()
}
