import SwiftUI

@available(iOS 17.0, *)
public struct RentHistoryView: View {
    let tenancy: TenancyModel

    @State private var payments: [RentPaymentModel] = []
    @State private var isLoading: Bool = true

    private var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_IN")
        return formatter
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }

    public init(tenancy: TenancyModel) {
        self.tenancy = tenancy
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(tenancy.name)
                    .font(.title3)
                    .fontWeight(.semibold)
                if let address = tenancy.address {
                    Text(address.title.isEmpty ? (address.line1.isEmpty ? "Address #\(address.id ?? 0)" : address.line1) : address.title)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Group {
                if isLoading {
                    ProgressView("Loading payments...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if payments.isEmpty {
                    ContentUnavailableView("No Payments", systemImage: "indianrupeesign.circle", description: Text("Collected rent for this tenancy will appear here."))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(Array(payments.enumerated()), id: \.offset) { _, payment in
                                HStack(alignment: .firstTextBaseline) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(currencyFormatter.string(from: NSNumber(value: payment.amount)) ?? "")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        if !payment.notes.isEmpty {
                                            Text(payment.notes)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    Spacer()
                                    Text(dateFormatter.string(from: payment.paidOn))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(Color(.secondarySystemGroupedBackground))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.top, 4)
                    }
                }
            }
        }
        .padding()
        .onAppear(perform: loadPayments)
    }

    private func loadPayments() {
        guard let tenancyId = tenancy.id else {
            isLoading = false
            payments = []
            return
        }
        if let list = try? DatabaseManager.shared.getRentPayments(forTenancyId: tenancyId) {
            payments = list
        } else {
            payments = []
        }
        isLoading = false
    }
}

@available(iOS 17.0, *)
#Preview {
    let address = AddressModel(title: "Unit 7", line1: "789 Street", city: "City", state: "State", pinCode: "98765")
    let tenancy = TenancyModel(id: 42, name: "Alice", contact: "999", address: address)
    return RentHistoryView(tenancy: tenancy)
        .padding()
}


