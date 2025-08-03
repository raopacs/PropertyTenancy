import Foundation

@available(iOS 17.0, *)
public final class TenancyModel {
    public var id: String?
    public var name: String
    public var contact: String
    public var address: AddressModel?
    public var leaseStartDate: Date
    public var leaseAgreementSigned: Bool
    public var advanceAmount: Double
    public var agreementSignedDate: Date
    public var comments: String

    public init(
                id: String? = nil,
                name: String = "",
                contact: String = "",
                address: AddressModel? = nil,
                leaseStartDate: Date = Date(),
                leaseAgreementSigned: Bool = false,
                advanceAmount: Double = 0.0,
                agreementSignedDate: Date = Date(),
                comments: String = "") {
        self.id = id
        self.name = name
        self.contact = contact
        self.address = address
        self.leaseStartDate = leaseStartDate
        self.leaseAgreementSigned = leaseAgreementSigned
        self.advanceAmount = advanceAmount
        self.agreementSignedDate = agreementSignedDate
        self.comments = comments
    }
}
