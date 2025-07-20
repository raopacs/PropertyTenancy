//
//  Item.swift
//  PropertyTenancy
//
//  Created by Prashanth Rao on 20/7/2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
