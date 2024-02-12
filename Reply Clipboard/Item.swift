//
//  Item.swift
//  Reply Clipboard
//
//  Created by Andrew Forget on 2024-02-11.
//

import Foundation
import SwiftData

@Model
final class Item {
    var name: String = ""
    var text: String = ""
    var timestamp: Date = Date.now
    
    init(name: String, text: String, timestamp: Date = .now) {
        self.name = name
        self.text = text
        self.timestamp = timestamp
    }
}
