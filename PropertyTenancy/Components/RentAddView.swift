import SwiftUI

@available(iOS 17.0, *)
public struct RentAddView: View {
    let tenancies: [TenancyModel]
    var onSaved: () -> Void

    @State private var selectedTenancyId: Int64?
    @State private var amount: Double = 0.0
    @State private var amountText: String = ""
    @State private var paidOn: Date = Date()
    @State private var notes: String = ""

    @State private var showingAlert = false
    @State private var alertMessage = ""
    @Environment(\.dismiss) private var dismiss

    @FocusState private var isAmountFocused: Bool

    private var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_IN")
        return formatter
    }

    public init(tenancies: [TenancyModel], onSaved: @escaping () -> Void) {
        self.tenancies = tenancies
        self.onSaved = onSaved
        _selectedTenancyId = State(initialValue: tenancies.first?.id)
        
        // Set default due date to next month
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Add Rent Payment")
                .font(.headline)
                .fontWeight(.semibold)

            Picker("Tenant", selection: $selectedTenancyId) {
                ForEach(tenancies, id: \.id) { tenancy in
                    Text(tenancy.name).tag(tenancy.id)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: selectedTenancyId) { newTenancyId in
                if let tenancy = tenancies.first(where: { $0.id == newTenancyId }) {
                }
            }
            
            if let selectedTenancy = tenancies.first(where: { $0.id == selectedTenancyId }) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Agreed Rent:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("₹\(selectedTenancy.agreedRent, specifier: "%.2f")")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }

            HStack {
                Text("Amount")
                Spacer()
                TextField("0.00", text: $amountText)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 180)
                    .focused($isAmountFocused)
                    .onChange(of: isAmountFocused) { focused in
                        if focused {
                            if parseAmountText(amountText) == 0 { amountText = "" }
                        } else {
                            let parsed = parseAmountText(amountText)
                            amount = parsed
                            amountText = parsed > 0 ? (currencyFormatter.string(from: NSNumber(value: parsed)) ?? "") : ""
                        }
                    }
            }

            HStack {
                DatePicker("Paid On", selection: $paidOn, displayedComponents: .date)
                    .frame(maxWidth: .infinity)
                
            }

            VStack(alignment: .leading) {
                Text("Notes")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextEditor(text: $notes)
                    .frame(height: 80)
                    .padding(4)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2), lineWidth: 1))
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
            .disabled(selectedTenancyId == nil)
        }
        .padding()
        .onAppear {
            amountText = amount > 0 ? (currencyFormatter.string(from: NSNumber(value: amount)) ?? "") : ""
        }
        .alert("Rent Collection", isPresented: $showingAlert) {
            Button("OK") {}
        } message: {
            Text(alertMessage)
        }
    }

    private func savePayment() {
        guard let tenancyId = selectedTenancyId else {
            alertMessage = "Please select a tenant"
            showingAlert = true
            return
        }
        
        guard let selectedTenancy = tenancies.first(where: { $0.id == tenancyId }) else {
            alertMessage = "Selected tenancy not found"
            showingAlert = true
            return
        }
        
        // Sync latest text to numeric amount
        amount = parseAmountText(amountText)
        
        do {
            let payment = RentPaymentModel(tenancyId: tenancyId, amount: amount, paidOn: paidOn, notes: notes)
            _ = try DatabaseManager.shared.saveRentPayment(payment)
            
            // Clear overdue notifications for this tenancy since payment was made
            NotificationManager.shared.clearNotifications(for: tenancyId)
            
            // Schedule notification for next month's rent
            let nextMonthDueDate = calculateNextMonthDueDate(for: selectedTenancy, from: paidOn)
            NotificationManager.shared.scheduleRentPaymentReminder(for: selectedTenancy, dueDate: nextMonthDueDate)
            
            NotificationCenter.default.post(name: .rentPaymentSaved, object: nil, userInfo: ["tenancyId": tenancyId])
            alertMessage = "Payment saved. Next month reminder scheduled."
            showingAlert = true
            onSaved()
            dismiss()
        } catch {
            alertMessage = "Error: \(error.localizedDescription)"
            showingAlert = true
        }
    }
    
    private func calculateNextMonthDueDate(for tenancy: TenancyModel, from paymentDate: Date) -> Date {
        let calendar = Calendar.current
        let monthlyDueDay = tenancy.monthlyDueDate
        
        // Calculate next month's due date
        var nextDueDate = calendar.date(byAdding: .month, value: 1, to: paymentDate) ?? Date()
        
        // Adjust to the specific day of month
        let components = calendar.dateComponents([.year, .month], from: nextDueDate)
        nextDueDate = calendar.date(from: DateComponents(year: components.year, month: components.month, day: monthlyDueDay)) ?? nextDueDate
        
        return nextDueDate
    }

    private func parseAmountText(_ text: String) -> Double {
        let allowedCharacters = Set("0123456789.")
        let filtered = text.filter { allowedCharacters.contains($0) }
        return Double(filtered) ?? 0.0
    }
}

@available(iOS 17.0, *)
#Preview {
    let address = AddressModel(title: "Unit 2", line1: "456 Street", city: "City", state: "State", pinCode: "12345")
    let t1 = TenancyModel(id: 1, name: "John", contact: "123", address: address)
    let t2 = TenancyModel(id: 2, name: "Mary", contact: "456", address: address)
    return RentAddView(tenancies: [t1, t2], onSaved: {})
        .padding()
}
