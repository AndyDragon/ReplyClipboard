//
//  Types.swift
//  Reply Clipboard
//
//  Created by Andrew Forget on 2024-02-18.
//

import SwiftUI

struct CloudKitConfiguration {
#if NONCLOUDSYNC
    static var Enabled = false
#else
    static var Enabled = true
#endif
}

enum BackupOperation: Int, Codable, CaseIterable {
    case none,
         backup,
         restore
}

class ItemWrapper {
    @Published var name: String = ""
    @Published var text: String = ""
}
