//
//  ReplyClipboardApp.swift
//  Reply Clipboard
//
//  Created by Andrew Forget on 2024-02-11.
//

import SwiftUI
import SwiftData

@main
struct ReplyClipboardApp: App {
    @State var checkingForUpdates = false
    @State var isShowingVersionAvailableToast: Bool = false
    @State var isShowingVersionRequiredToast: Bool = false
    @State var versionCheckToast = VersionCheckToast()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: CloudKitConfiguration.Enabled ? .automatic : .none)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        let appState = VersionCheckAppState(
            isCheckingForUpdates: $checkingForUpdates,
            isShowingVersionAvailableToast: $isShowingVersionAvailableToast,
            isShowingVersionRequiredToast: $isShowingVersionRequiredToast,
            versionCheckToast: $versionCheckToast,
            versionLocation: "https://vero.andydragon.com/static/data/replyclipboard/version.json")
        WindowGroup {
            ContentView(appState)
        }
        .modelContainer(sharedModelContainer)
        .commands {
            CommandGroup(replacing: .appSettings, addition: {
                Button(action: {
                    appState.checkForUpdates()
                }, label: {
                    Text("Check for updates...")
                })
                .disabled(checkingForUpdates)
            })
        }
    }
}
