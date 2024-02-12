//
//  Item.swift
//  Reply Clipboard
//
//  Created by Andrew Forget on 2024-02-11.
//

import Foundation
import SwiftData

@Model
final class Item: Codable {
    var name: String = ""
    var text: String = ""
    var timestamp: Date = Date.now
    
    init(name: String, text: String, timestamp: Date = .now) {
        self.name = name
        self.text = text
        self.timestamp = timestamp
    }
    
    enum CodingKeys: CodingKey {
        case name
        case text
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        text = try container.decode(String.self, forKey: .text)
        timestamp = .now
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(text, forKey: .text)
    }
}
