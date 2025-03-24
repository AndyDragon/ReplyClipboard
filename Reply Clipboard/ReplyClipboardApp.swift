//
//  ReplyClipboardApp.swift
//  Reply Clipboard
//
//  Created by Andrew Forget on 2024-02-11.
//

import LaunchAtLogin
import SwiftUI
import SwiftData

@main
struct ReplyClipboardApp: App {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

#if STANDALONE
    @State var checkingForUpdates = false
    @State var versionCheckResult: VersionCheckResult = .complete
    @State var versionCheckToast = VersionCheckToast()
#endif
    
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
#if STANDALONE
        let appState = VersionCheckAppState(
            isCheckingForUpdates: $checkingForUpdates,
            versionCheckResult: $versionCheckResult,
            versionCheckToast: $versionCheckToast,
            versionLocation: "https://vero.andydragon.com/static/data/replyclipboard/version.json")
#endif
        // Menu bar menu
        MenuBarExtra {
            MenuView(
                openWindow: {
                    dismissWindow(id: "main")
                    NSApplication.shared.activate(ignoringOtherApps: true)
                    openWindow(id: "main")
                },
                openAbout: {
                    dismissWindow(id: "about")
                    NSApplication.shared.activate(ignoringOtherApps: true)
                    openWindow(id: "about")
                }
            )
            .modelContainer(sharedModelContainer)
        } label: {
            Label("Reply Clipboard", systemImage: "list.bullet.clipboard.fill")
        }

        // Main view window with id "main"
        Window("Reply Clipboard", id: "main") {
#if STANDALONE
            ContentView(appState, loginItemService) {
                NSApplication.shared.activate(ignoringOtherApps: true)
                openWindow(id: "about")
            }
#else
            ContentView() {
                dismissWindow(id: "about")
                NSApplication.shared.activate(ignoringOtherApps: true)
                openWindow(id: "about")
            }
#if SCREENSHOT
            .frame(width: 1280, height: 748)
            .frame(minWidth: 1280, maxWidth: 1280, minHeight: 748, maxHeight: 748)
#endif
#endif
        }
        .modelContainer(sharedModelContainer)

        // About view window with id "about"
        Window("About \(Bundle.main.displayName ?? "Feature Tracker")", id: "about") {
            AboutView(packages: [
                "CloudKitSyncMonitor": [
                    "Grant Grueninger ([Github profile](https://github.com/ggruen))"
                ],
                "LaunchAtLogin": [
                    "Sindre Sorhus ([Github profile](https://github.com/sindresorhus))"
                ],
                "ToastView-SwiftUI": [
                    "Gaurav Tak ([Github profile](https://github.com/gauravtakroro))",
                    "modified by AndyDragon ([Github profile](https://github.com/AndyDragon))"
                ]
            ])
        }
        .defaultPosition(.center)
        .windowResizability(.contentSize)
    }
}
