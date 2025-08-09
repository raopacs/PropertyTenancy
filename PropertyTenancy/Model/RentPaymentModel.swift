import Foundation

@available(iOS 17.0, *)
public final class RentPaymentModel {
    public var id: Int64?
    public var tenancyId: Int64
    public var amount: Double
    public var paidOn: Date
    public var notes: String

    public init(
        id: Int64? = nil,
        tenancyId: Int64,
        amount: Double,
        paidOn: Date = Date(),
        notes: String = ""
    ) {
        self.id = id
        self.tenancyId = tenancyId
        self.amount = amount
        self.paidOn = paidOn
        self.notes = notes
    }
}