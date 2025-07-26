//
//  Item.swift
//  PropertyTenancy
//
//  Created by Prashanth Rao on 20/7/2025.
//

import Foundation
import SwiftData

@Model
public final class Item {
    var timestamp: Date
    
    public init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
