import Foundation
import SwiftData

@Model
@available(iOS 17.0, *)
public final class AddressModel {
    public var title: String
    public var line1: String
    public var line2: String
    public var city: String
    public var state: String
    public var pinCode: String

    public init(title: String = "", line1: String = "", line2: String = "", city: String = "", state: String = "", pinCode: String = "") {
        self.title = title
        self.line1 = line1
        self.line2 = line2
        self.city = city
        self.state = state
        self.pinCode = pinCode
    }
}