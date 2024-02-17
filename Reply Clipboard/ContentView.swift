//
//  ContentView.swift
//  Reply Clipboard
//
//  Created by Andrew Forget on 2024-02-11.
//

import SwiftUI
import SwiftData
import AlertToast
import CloudKitSyncMonitor

enum BackupOperation: Int, Codable, CaseIterable {
    case none,
         backup,
         restore
}

struct ContentView: View {
    @Environment(\.openURL) var openURL
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State private var selectedItem: Item?
    @State private var exceptionError = ""
    @State private var backupOperation = BackupOperation.none
    @State private var showingBackupRestoreErrorAlert = false
    @State private var showSyncAccountStatus = false
    @State private var toastType: AlertToast.AlertType = .regular
    @State private var toastText = ""
    @State private var toastSubTitle = ""
    @State private var toastDuration = 3.0
    @State private var isShowingToast = false
    @State private var deleteAlertText = ""
    @State private var deleteAlertAction: (() -> Void)? = nil
    @State private var showDeleteAlert = false
    @ObservedObject private var syncMonitor = SyncMonitor.shared
    var appState: VersionCheckAppState
    private var isAnyToastShowing: Bool {
        isShowingToast || appState.isShowingVersionAvailableToast.wrappedValue || appState.isShowingVersionRequiredToast.wrappedValue
    }

    init(_ appState: VersionCheckAppState) {
        self.appState = appState
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack(alignment: .center) {
                    Spacer()
                }
                .frame(height: 1)
                .border(.black, edges: [.top], width: 1)
                NavigationSplitView {
                    VStack {
                        List(selection: $selectedItem) {
                            ForEach(items.sorted { $0.name < $1.name }, id: \.self) { item in
                                HStack {
                                    Text("\(item.name)")
                                    Spacer()
                                    Button(action: {
                                        copyToClipboard(item.text)
                                        showToast("Copied!", "Copied \(item.name) to the clipboard")
                                    }) {
                                        HStack {
                                            Image(systemName: "clipboard")
                                                .frame(alignment: .center)
                                            Text("Copy")
                                                .frame(alignment: .center)
                                        }
                                    }
                                }
                                .padding(4)
                                .onTapGesture {
                                    selectedItem = item
                                }
                            }
                        }
                        .listStyle(.sidebar)
                        .onDeleteCommand {
                            if let item = selectedItem {
                                modelContext.delete(item)
                            }
                        }
                        .navigationSplitViewColumnWidth(min: 280, ideal: 320)
                        .toolbar {
                            Button(action: addItem) {
                                Label("Add Item", systemImage: "plus")
                            }
                            .disabled(isAnyToastShowing)
                        }
                        .background(Color.gray.opacity(0.000001))
                        .border(.black, edges: [.bottom], width: 1)
                        .onTapGesture {
                            selectedItem = nil
                        }
                    }
                } detail: {
                    VStack {
                        if let item = selectedItem {
                            ItemEditor(item: item, onClose: { selectedItem = nil }) {
                                deleteAlertText = "Are you sure you want to delete this item?"
                                deleteAlertAction = {
                                    selectedItem = nil
                                    modelContext.delete(item)
                                    showToast("Deleted item!", "Removed the item", duration: 15.0)
                                }
                                showDeleteAlert.toggle()
                            }
                        } else {
                            HStack {
                                Spacer()
                                Text("Select item from the list to edit")
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                        }
                    }
                    .toolbar {
                        Menu("JSON", systemImage: "tray") {
                            Button("Backup to Clipboard", systemImage: "tray.and.arrow.down", action: backup)
                            Button("Restore from Clipboard", systemImage: "tray.and.arrow.up", action: restore)
                        }
                        .disabled(isAnyToastShowing)
                    }
                }
                .alert(
                    "Delete confirmation",
                    isPresented: $showDeleteAlert,
                    actions: {
                        Button(role: .destructive, action: deleteAlertAction ?? { }) {
                            Text("Yes")
                        }
                    },
                    message: {
                        Text(deleteAlertText)
                    }
                )
                .alert(
                    backupOperation == .backup ? "ERROR: Failed to backup" : "ERROR: Failed to restore",
                    isPresented: $showingBackupRestoreErrorAlert,
                    actions: {
                        Button(action: {
                            showingBackupRestoreErrorAlert.toggle()
                        }) {
                            Text("OK")
                        }
                    },
                    message: {
                        Text(backupOperation == .backup
                             ? "Could to backup to the clipboard: \(exceptionError)"
                             : "Could to restore from the clipboard: \(exceptionError)")
                        .accentColor(.red)
                    }
                )
                .padding([.bottom], CloudKitConfiguration.Enabled ? 0 : 14)
                if CloudKitConfiguration.Enabled {
                    HStack {
                        Image(systemName: syncMonitor.syncStateSummary.symbolName)
                            .foregroundColor(syncMonitor.syncStateSummary.symbolColor)
                            .help(syncMonitor.syncError
                                  ? (syncMonitor.syncStateSummary.description + " " + (syncMonitor.lastError?.localizedDescription ?? "unknown"))
                                  : syncMonitor.syncStateSummary.description)
                        if showSyncAccountStatus {
                            if case .accountNotAvailable = syncMonitor.syncStateSummary {
                                Text("Not logged into iCloud account, changes will not be synced to iCloud storage")
                            }
                        }
                        Spacer()
                    }
                    .padding([.top], 8)
                    .padding([.bottom, .leading], 12)
                    .task {
                        do {
                            try await Task.sleep(nanoseconds: 5_000_000_000)
                            showSyncAccountStatus = true
                        } catch {}
                    }
                }
            }
            //.padding([.top], 1) // Very important, do not remove of list will jump on toast...
            .allowsHitTesting(!isAnyToastShowing)
            if isAnyToastShowing {
                VStack {
                    Rectangle().opacity(0.0000001)
                }
                .onTapGesture {
                    if isShowingToast {
                        isShowingToast.toggle()
                    } else if appState.isShowingVersionAvailableToast.wrappedValue {
                        appState.isShowingVersionAvailableToast.wrappedValue.toggle()
                    }
                }
            }
        }
        .blur(radius: isAnyToastShowing ? 4 : 0)
        .toast(
            isPresenting: $isShowingToast,
            duration: 1,
            tapToDismiss: true,
            offsetY: 32,
            alert: {
                AlertToast(
                    displayMode: .hud,
                    type: toastType,
                    title: toastText,
                    subTitle: toastSubTitle)
            })
        .toast(
            isPresenting: appState.isShowingVersionAvailableToast,
            duration: 10,
            tapToDismiss: true,
            offsetY: 32,
            alert: {
                AlertToast(
                    displayMode: .hud,
                    type: .systemImage("exclamationmark.triangle.fill", .yellow),
                    title: "New version available",
                    subTitle: "You are using v\(appState.versionCheckToast.wrappedValue.appVersion) and v\(appState.versionCheckToast.wrappedValue.currentVersion) is available\(appState.versionCheckToast.wrappedValue.linkToCurrentVersion.isEmpty ? "" : ", click here to open your browser") (this will go away in 10 seconds)")
            },
            onTap: {
                if let url = URL(string: appState.versionCheckToast.wrappedValue.linkToCurrentVersion) {
                    openURL(url)
                }
            },
            completion: {
                appState.resetCheckingForUpdates()
            })
        .toast(
            isPresenting: appState.isShowingVersionRequiredToast,
            duration: 0,
            tapToDismiss: true,
            offsetY: 32,
            alert: {
                AlertToast(
                    displayMode: .hud,
                    type: .systemImage("xmark.octagon.fill", .red),
                    title: "New version required",
                    subTitle: "You are using v\(appState.versionCheckToast.wrappedValue.appVersion) and v\(appState.versionCheckToast.wrappedValue.currentVersion) is required\(appState.versionCheckToast.wrappedValue.linkToCurrentVersion.isEmpty ? "" : ", click here to open your browser") or ⌘ + Q to Quit")
            },
            onTap: {
                if let url = URL(string: appState.versionCheckToast.wrappedValue.linkToCurrentVersion) {
                    openURL(url)
                    NSApplication.shared.terminate(nil)
                }
            },
            completion: {
                appState.resetCheckingForUpdates()
            })
        .task {
            appState.checkForUpdates()
        }
    }
    
    func showToast(_ text: String, _ subTitle: String, duration: Double = 3.0) {
        toastType = .complete(.blue)
        toastText = text
        toastSubTitle = subTitle
        toastDuration = duration
        isShowingToast.toggle()
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(name: "new item", text: "")
            modelContext.insert(newItem)
            selectedItem = newItem
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }

    private func copyToClipboard(_ text: String) -> Void {
#if os(iOS)
        var clipText = String(text)
        if clipText.contains("%%CLIP%%") {
            let fromClipboard = UIPasteboard.general.string(forType: .string) ?? ""
            clipText = clipText.replacingOccurrences(of: "%%CLIP%%", with: fromClipboard)
        }
        UIPasteboard.general.string = clipText
#else
        var clipText = String(text)
        let pasteBoard = NSPasteboard.general
        if clipText.contains("%%CLIP%%") {
            let fromClipboard = pasteBoard.string(forType: .string) ?? ""
            clipText = clipText.replacingOccurrences(of: "%%CLIP%%", with: fromClipboard)
        }
        pasteBoard.clearContents()
        pasteBoard.writeObjects([clipText as NSString])
#endif
    }

    func copyToClipboardRaw(_ text: String) -> Void {
#if os(iOS)
        UIPasteboard.general.string = text
#else
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.writeObjects([text as NSString])
#endif
    }

    func backup() -> Void {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
            let json = try encoder.encode(items.sorted { $0.name < $1.name })
            copyToClipboardRaw(String(decoding: json, as: UTF8.self))
            showToast("Backed up!", "Copied a backup of the items to the clipboard")
        } catch {
            exceptionError = error.localizedDescription
            backupOperation = .backup
            showingBackupRestoreErrorAlert.toggle()
        }
    }

    func restore() -> Void {
        do {
            selectedItem = nil
            let pasteBoard = NSPasteboard.general
            let json = pasteBoard.string(forType: .string) ?? ""
            let loadedItems = try JSONDecoder().decode([Item].self, from: json.data(using: .utf8)!)
            if loadedItems.count != 0 {
                selectedItem = nil
                do {
                    try modelContext.delete(model: Item.self)
                } catch {
                    // do nothing
                }
                for item in loadedItems.sorted(by: { $0.name < $1.name }) {
                    modelContext.insert(item)
                }
                showToast("Restored!", "Restored the items from the clipboard")
            }
        } catch let DecodingError.dataCorrupted(context) {
            exceptionError = context.debugDescription
            backupOperation = .restore
            showingBackupRestoreErrorAlert.toggle()
        } catch let DecodingError.keyNotFound(key, context) {
            exceptionError = "Key '\(key)' not found:" + context.debugDescription
            backupOperation = .restore
            showingBackupRestoreErrorAlert.toggle()
        } catch let DecodingError.valueNotFound(value, context) {
            exceptionError = "Value '\(value)' not found:" + context.debugDescription
            backupOperation = .restore
            showingBackupRestoreErrorAlert.toggle()
        } catch let DecodingError.typeMismatch(type, context) {
            exceptionError = "Type '\(type)' mismatch:" + context.debugDescription
            backupOperation = .restore
            showingBackupRestoreErrorAlert.toggle()
        } catch {
            exceptionError = error.localizedDescription
            backupOperation = .restore
            showingBackupRestoreErrorAlert.toggle()
        }
    }
}
