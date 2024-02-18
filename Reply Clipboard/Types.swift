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

struct VersionManifest: Codable {
    let macOS: VersionEntry
    //let windows: VersionEntry
}

struct VersionEntry: Codable {
    let current: String
    let link: String
    let vital: Bool
}

struct VersionCheckToast {
    var appVersion: String
    var currentVersion: String
    var linkToCurrentVersion: String
    
    init(appVersion: String = "unknown", currentVersion: String = "unknown", linkToCurrentVersion: String = "") {
        self.appVersion = appVersion
        self.currentVersion = currentVersion
        self.linkToCurrentVersion = linkToCurrentVersion
    }
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
