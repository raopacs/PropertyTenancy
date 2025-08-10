import SwiftUI

@available(iOS 17.0, *)
public struct TenancyDisplayView: View {
    let tenancy: TenancyModel
    @State private var latestPayment: RentPaymentModel?
    @State private var showingRentSheet = false

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
        VStack(alignment: .leading, spacing: 8) {
            // Tenant Name and Contact
            VStack(alignment: .leading) {
                Text(tenancy.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                if !tenancy.contact.isEmpty {
                    Text(tenancy.contact)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Lease Details
            VStack(alignment: .leading, spacing: 4) {
                detailRow(label: "Lease Start", value: dateFormatter.string(from: tenancy.leaseStartDate))
                detailRow(label: "Agreement Signed", value: tenancy.leaseAgreementSigned ? "Yes" : "No")
                if tenancy.leaseAgreementSigned {
                    detailRow(label: "Signed On", value: dateFormatter.string(from: tenancy.agreementSignedDate))
                }
                if tenancy.advanceAmount > 0 {
                    detailRow(label: "Advance Paid", value: currencyFormatter.string(from: NSNumber(value: tenancy.advanceAmount)) ?? "")
                }
                if tenancy.agreedRent > 0 {
                    detailRow(label: "Agreed Rent", value: currencyFormatter.string(from: NSNumber(value: tenancy.agreedRent)) ?? "")
                }
            }

            // Address (compact inline)
            if let address = tenancy.address {
                let line = compactAddressLine(address)
                if !line.isEmpty {
                    detailRow(label: "Address", value: line)
                }
            }

            // Comments
            if !tenancy.comments.isEmpty {
                Text(tenancy.comments)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Latest Rent Payment (compact)
            detailRow(label: "Latest Rent Payment", value: "-")
            HStack(alignment: .firstTextBaseline) {
                if let payment = latestPayment {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(currencyFormatter.string(from: NSNumber(value: payment.amount)) ?? "")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(dateFormatter.string(from: payment.paidOn))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text("No rent collected yet")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button {
                    showingRentSheet = true
                } label: {
                    Label("Collect", systemImage: "indianrupeesign.circle")
                }
                .buttonStyle(.bordered)
                .tint(.green)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .onAppear(perform: loadLatestPayment)
        .sheet(isPresented: $showingRentSheet) {
            RentCollectionView(tenancy: tenancy) {
                loadLatestPayment()
            }
        }
    }

    private func loadLatestPayment() {
        guard let tenancyId = tenancy.id else {
            latestPayment = nil
            return
        }
        do {
            latestPayment = try DatabaseManager.shared.getLatestRentPayment(forTenancyId: tenancyId)
        } catch {
            latestPayment = nil
        }
    }

    // Helper view for consistent key-value rows
    @ViewBuilder
    private func detailRow(label: String, value: String) -> some View {
        if !value.isEmpty {
            HStack {
                Text(label)
                    .font(.caption)
                Spacer()
                Text(value)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
        }
    }

    private func compactAddressLine(_ address: AddressModel) -> String {
        var parts: [String] = []
        if !address.title.isEmpty { parts.append(address.title) }
        if !address.line1.isEmpty { parts.append(address.line1) }
        if !address.line2.isEmpty { parts.append(address.line2) }
        var cityState: [String] = []
        if !address.city.isEmpty { cityState.append(address.city) }
        if !address.state.isEmpty { cityState.append(address.state) }
        if !cityState.isEmpty { parts.append(cityState.joined(separator: ", ")) }
        if !address.pinCode.isEmpty { parts.append(address.pinCode) }
        return parts.joined(separator: ", ")
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
