import Foundation
import SwiftData

@available(iOS 17.0, *)
@Model
public final class TenancyModel {
    public var name: String
    public var contact: String
    public var address: AddressModel?
    public var leaseStartDate: Date
    public var leaseAgreementSigned: Bool
    public var advanceAmount: Double
    public var agreementSignedDate: Date
    public var comments: String

    public init(name: String = "",
                contact: String = "",
                address: AddressModel? = nil,
                leaseStartDate: Date = .now,
                leaseAgreementSigned: Bool = false,
                advanceAmount: Double = 0.0,
                agreementSignedDate: Date = .now,
                comments: String = "") {
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
