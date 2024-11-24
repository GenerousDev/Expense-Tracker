//
//  Item.swift
//  ExpenseTracker
//
//  Created by Mac on 24/11/2024.
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
