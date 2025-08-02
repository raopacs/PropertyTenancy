import SwiftUI

@available(iOS 17.0, *)
public struct TenancyDisplayView: View {
    let tenancy: TenancyModel

    private var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_IN") // Consistent with TenancyView
        return formatter
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Tenant Name and Contact
            VStack(alignment: .leading) {
                Text(tenancy.name)
                    .font(.title2)
                    .fontWeight(.bold)
                if !tenancy.contact.isEmpty {
                    Text(tenancy.contact)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            // Lease Details
            VStack(alignment: .leading, spacing: 8) {
                Text("Lease Details")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .padding(.bottom, 2)

                detailRow(label: "Lease Start", value: dateFormatter.string(from: tenancy.leaseStartDate))
                detailRow(label: "Agreement Signed", value: tenancy.leaseAgreementSigned ? "Yes" : "No")
                if tenancy.leaseAgreementSigned {
                    detailRow(label: "Signed On", value: dateFormatter.string(from: tenancy.agreementSignedDate))
                }
                if tenancy.advanceAmount > 0 {
                    detailRow(label: "Advance Paid", value: currencyFormatter.string(from: NSNumber(value: tenancy.advanceAmount)) ?? "")
                }
            }

            // Address
            if let address = tenancy.address {
                CollapsibleView(title: "Address") {
                    AddressDisplayView(address: address)
                }
            }

            // Comments
            if !tenancy.comments.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Comments")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Text(tenancy.comments)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }

    // Helper view for consistent key-value rows
    @ViewBuilder
    private func detailRow(label: String, value: String) -> some View {
        if !value.isEmpty {
            HStack {
                Text(label)
                    .font(.subheadline)
                Spacer()
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    let sampleAddress = AddressModel(title: "yellow", line1: "456 2nd mn, indira nagar", city: "bengaluru", state: "Ka", pinCode: "560043")
    let sampleTenancy = TenancyModel(name: "Raju Marimuthu", contact: "75038 94562", address: sampleAddress, leaseAgreementSigned: true, advanceAmount: 2.5, comments: "Tenant has a small, well-behaved dog.")

    ScrollView {
        TenancyDisplayView(tenancy: sampleTenancy).padding()
    }
    .background(Color(.systemGroupedBackground))
}
