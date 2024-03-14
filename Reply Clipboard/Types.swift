//
//  Types.swift
//  Reply Clipboard
//
//  Created by Andrew Forget on 2024-02-18.
//

import SwiftUI

struct CloudKitConfiguration {
#if CLOUDSYNC
    static var Enabled = true
#else
    static var Enabled = false
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
