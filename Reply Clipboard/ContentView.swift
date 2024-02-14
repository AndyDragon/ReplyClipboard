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
    @State private var showToast = false
    @State private var deleteAlertText = ""
    @State private var deleteAlertAction: (() -> Void)? = nil
    @State private var showDeleteAlert = false
    @ObservedObject private var syncMonitor = SyncMonitor.shared
    
    var body: some View {
        VStack {
            NavigationSplitView {
                List(selection: $selectedItem) {
                    ForEach(items.sorted { $0.name < $1.name }, id: \.self) { item in
                        HStack {
                            Text("\(item.name)")
                            Spacer()
                            Button(action: {
                                copyToClipboard(item.text)
                                showToast("Copied!", "Copied \(item.name) to the clipboard")
                            }) {
                                Image(systemName: "clipboard")
                            }
                        }
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
                }
            } detail: {
                VStack {
                    if let item = selectedItem {
                        ItemEditor(item: item) {
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
                .toast(isPresenting: $showToast, duration: 2, tapToDismiss: true, alert: {
                    AlertToast(
                        displayMode: .hud,
                        type: toastType,
                        title: toastText,
                        subTitle: toastSubTitle)
                })
                .toolbar {
                    Menu("JSON", systemImage: "tray") {
                        Button("Backup to Clipboard", systemImage: "tray.and.arrow.down", action: backup)
                        Button("Restore from Clipboard", systemImage: "tray.and.arrow.up", action: restore)
                    }
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
            if CloudKitConfiguration.Enabled {
                HStack {
                    Image(systemName: syncMonitor.syncStateSummary.symbolName)
                        .foregroundColor(syncMonitor.syncStateSummary.symbolColor)
                        .help(syncMonitor.syncStateSummary.description)
                    if showSyncAccountStatus {
                        if case .accountNotAvailable = syncMonitor.syncStateSummary {
                            Text("Not logged into iCloud account, changes will not be synced to iCloud storage")
                        }
                    }
                    Spacer()
                }
                .padding([.top], 2)
                .padding([.bottom, .leading], 12)
                .task {
                    do {
                        try await Task.sleep(nanoseconds: 5_000_000_000)
                        showSyncAccountStatus = true
                    } catch {}
                }
            }
        }
    }
    
    func showToast(_ text: String, _ subTitle: String, duration: Double = 3.0) {
        toastType = .complete(.blue)
        toastText = text
        toastSubTitle = subTitle
        toastDuration = duration
        showToast.toggle()
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

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
