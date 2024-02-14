//
//  Item.swift
//  Reply Clipboard
//
//  Created by Andrew Forget on 2024-02-11.
//

import Foundation
import SwiftData

@Model
final class Item: Codable, Comparable, Identifiable {
    var id: UUID = UUID()
    var name: String = ""
    var text: String = ""
    
    init(name: String, text: String) {
        self.name = name
        self.text = text
    }

    init(id: UUID, name: String, text: String) {
        self.id = id
        self.name = name
        self.text = text
    }

    static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: Item, rhs: Item) -> Bool {
        return lhs.name < rhs.name
    }
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case text
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try container.decode(String.self, forKey: .name)
        text = try container.decode(String.self, forKey: .text)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(text, forKey: .text)
    }
}
