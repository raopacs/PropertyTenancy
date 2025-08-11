import SwiftUI

@available(iOS 17.0, *)
public struct TenancyView: View {
    @State var tenancy: TenancyModel
    @State private var showingSaveAlert = false
    @State private var alertMessage = ""
    var onSave: () -> Void

    @FocusState private var isAdvanceAmountFocused: Bool
    @FocusState private var isAgreedRentFocused: Bool
    @State private var advanceAmountText: String = ""
    @State private var agreedRentText: String = ""

    @State private var properties: [AddressModel] = []
    @State private var selectedAddressId: Int64?

    private var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        // In a real app, this might come from user's locale or settings
        formatter.locale = Locale(identifier: "en_IN")
        return formatter
    }

    @available(iOS 17.0, *)
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
                
                HStack {
                    Text("Property")
                    Spacer()
                    Picker("Property", selection: Binding(
                        get: { selectedAddressId ?? tenancy.address?.id },
                        set: { newValue in
                            selectedAddressId = newValue
                            if let id = newValue, let match = properties.first(where: { $0.id == id }) {
                                tenancy.address = match
                            }
                        }
                    )) {
                        Text("Select").tag(nil as Int64?)
                        ForEach(properties, id: \.id) { address in
                            Text(address.title.isEmpty ? (address.line1.isEmpty ? "Address #\(address.id ?? 0)" : address.line1) : address.title)
                                .tag(address.id)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(width: 220)
                }

                DatePicker("Lease Start Date", selection: $tenancy.leaseStartDate, displayedComponents: .date)

                Toggle("Lease Agreement Signed", isOn: $tenancy.leaseAgreementSigned)

                HStack {
                    Text("Advance Amount")
                    Spacer()
                    TextField("0.00", text: $advanceAmountText)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 150)
                        .focused($isAdvanceAmountFocused)
                        .onChange(of: isAdvanceAmountFocused) { focused in
                            if focused {
                                if parseAmountText(advanceAmountText) == 0 {
                                    advanceAmountText = ""
                                }
                            } else {
                                let parsed = parseAmountText(advanceAmountText)
                                tenancy.advanceAmount = parsed
                                advanceAmountText = parsed > 0 ? (currencyFormatter.string(from: NSNumber(value: parsed)) ?? "") : ""
                            }
                        }
                }

                HStack {
                    Text("Agreed Rent")
                    Spacer()
                    TextField("0.00", text: $agreedRentText)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 150)
                        .focused($isAgreedRentFocused)
                        .onChange(of: isAgreedRentFocused) { focused in
                            if focused {
                                if parseAmountText(agreedRentText) == 0 { agreedRentText = "" }
                            } else {
                                let parsed = parseAmountText(agreedRentText)
                                tenancy.agreedRent = parsed
                                agreedRentText = parsed > 0 ? (currencyFormatter.string(from: NSNumber(value: parsed)) ?? "") : ""
                            }
                        }
                }

                HStack {
                    Text("Monthly Rent Due Date")
                    Spacer()
                    Picker("Due Date", selection: $tenancy.monthlyDueDate) {
                        ForEach(1...28, id: \.self) { day in
                            Text("\(day)").tag(day)
                        }
                    }
                    .pickerStyle(.menu)
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

            Button(action: saveTenancy) {
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
        .onAppear {
            let adv = tenancy.advanceAmount
            advanceAmountText = adv > 0 ? (currencyFormatter.string(from: NSNumber(value: adv)) ?? "") : ""
            let rent = tenancy.agreedRent
            agreedRentText = rent > 0 ? (currencyFormatter.string(from: NSNumber(value: rent)) ?? "") : ""
            selectedAddressId = tenancy.address?.id
            // Load properties list
            if let list = try? DatabaseManager.shared.getAllAddresses() {
                properties = list
            }
        }
        .alert("Save Result", isPresented: $showingSaveAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func saveTenancy() {
        // Ensure latest text is synced to the numeric value
        tenancy.advanceAmount = parseAmountText(advanceAmountText)
        tenancy.agreedRent = parseAmountText(agreedRentText)
        if let id = selectedAddressId, let match = properties.first(where: { $0.id == id }) {
            tenancy.address = match
        }
        do {
            if let id = tenancy.id {
                // Update existing tenancy
                try DatabaseManager.shared.updateTenancy(tenancy)
                alertMessage = "Tenancy updated successfully!"
            } else {
                // Save new tenancy
                let savedId = try DatabaseManager.shared.saveTenancy(tenancy)
                tenancy.id = savedId
                alertMessage = "Tenancy saved successfully with ID: \(savedId)"
            }
            showingSaveAlert = true
            onSave()
        } catch {
            alertMessage = "Error saving tenancy: \(error.localizedDescription)"
            showingSaveAlert = true
        }
    }

    private func parseAmountText(_ text: String) -> Double {
        let allowedCharacters = Set("0123456789.")
        let filtered = text.filter { allowedCharacters.contains($0) }
        return Double(filtered) ?? 0.0
    }
}

@available(iOS 17.0, *)
#Preview {
    TenancyView(tenancy: TenancyModel(), onSave: { print("Save tapped") })
        .padding()
}
