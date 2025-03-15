//
//  ContentView.swift
//  Reply Clipboard
//
//  Created by Andrew Forget on 2024-02-11.
//

import SwiftUI
import SwiftData
import CloudKitSyncMonitor

struct ContentView: View {
    @Environment(\.openURL) var openURL
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    @State private var viewModel = ViewModel()

    @State private var selectedItem: Item?
    @State private var exceptionError = ""
    @State private var backupOperation = BackupOperation.none
    @State private var showingBackupRestoreErrorAlert = false
    @State private var showSyncAccountStatus = false
    @State private var deleteAlertText = ""
    @State private var deleteAlertAction: (() -> Void)? = nil
    @State private var showDeleteAlert = false
    @ObservedObject private var syncMonitor = SyncMonitor.shared
#if STANDALONE
    var appState: VersionCheckAppState
#endif
    var openAbout: () -> Void

#if STANDALONE
    init(
        _ appState: VersionCheckAppState,
        _ openAbout: @escaping () -> Void
    ) {
        self.appState = appState
        self.openAbout = openAbout
    }
#else
    init(
        _ openAbout: @escaping () -> Void
    ) {
        self.openAbout = openAbout
    }
#endif

    var body: some View {
        NavigationSplitView {
            ZStack {
                VStack {
                    List(selection: $selectedItem) {
                        ForEach(items.sorted { $0.name < $1.name }, id: \.self) { item in
                            HStack {
                                Text("\(item.name)")
                                Spacer()
                                Button(action: {
                                    copyToClipboard(item.text)
                                    viewModel.showSuccessToast("Copied!", "Copied \(item.name) to the clipboard")
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
                        .onDelete(perform: deleteItems)
                    }
                    .listStyle(.sidebar)
                    .onDeleteCommand {
                        if let item = selectedItem {
                            deleteAlertText = "Are you sure you want to delete this item?"
                            deleteAlertAction = {
                                selectedItem = nil
                                modelContext.delete(item)
                                viewModel.showSuccessToast("Deleted item!", "Removed the item")
                            }
                            showDeleteAlert.toggle()
                        }
                    }
                    .toolbar {
                        Button(action: addItem) {
                            Label("Add Item", systemImage: "plus")
                        }
                        .disabled(viewModel.hasModalToasts)
                    }
                    .background(Color.gray.opacity(0.000001))
                    .onTapGesture {
                        selectedItem = nil
                    }
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
                        .padding([.top], 4)
                        .padding([.bottom], 16)
                        .padding([.leading], 20)
                        .task {
                            do {
                                try await Task.sleep(nanoseconds: 5_000_000_000)
                                showSyncAccountStatus = true
                            } catch {}
                        }
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 280, ideal: 320)
        } detail: {
            ZStack {
                VStack {
                    if let item = selectedItem {
                        ItemEditor(item: item, onClose: { selectedItem = nil }) {
                            deleteAlertText = "Are you sure you want to delete this item?"
                            deleteAlertAction = {
                                selectedItem = nil
                                modelContext.delete(item)
                                viewModel.showSuccessToast("Deleted item!", "Removed the item")
                            }
                            showDeleteAlert.toggle()
                        }
                    } else {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("Select item from the list to edit")
                                .foregroundColor(.gray)
                            Spacer()
                        }
                    }
                    Spacer()
                }
            }
            .toolbar {
                Menu("JSON", systemImage: "tray") {
                    Button("Backup to Clipboard", systemImage: "tray.and.arrow.down", action: backup)
                    Button("Restore from Clipboard", systemImage: "tray.and.arrow.up", action: restore)
                }
                .disabled(viewModel.hasModalToasts)
                Button(action: {
                    openAbout()
                }) {
                    Label("About", systemImage: "info.circle")
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
        .advancedToastView(toasts: $viewModel.toastViews)
#if STANDALONE
        .attachVersionCheckState(viewModel, appState) { url in
            openURL(url)
        }
        .task {
            appState.checkForUpdates()
        }
#endif
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
            var codableItems = [CodableItem]()
            codableItems.append(contentsOf: items.sorted(by: { $0.name < $1.name }).map({ item in
                return CodableItem(item)
            }))
            let json = try encoder.encode(codableItems)
            copyToClipboardRaw(String(decoding: json, as: UTF8.self))
            viewModel.showSuccessToast("Backed up!", "Copied a backup of the items to the clipboard")
        } catch {
            exceptionError = error.localizedDescription
            backupOperation = .backup
            showingBackupRestoreErrorAlert.toggle()
            debugPrint(error.localizedDescription)
        }
    }

    func restore() -> Void {
        do {
            selectedItem = nil
            let pasteBoard = NSPasteboard.general
            let json = pasteBoard.string(forType: .string) ?? ""
            let codableItems = try JSONDecoder().decode([CodableItem].self, from: json.data(using: .utf8)!)
            if codableItems.count != 0 {
                do {
                    try modelContext.delete(model: Item.self)
                } catch {
                    // do nothing
                    debugPrint(error.localizedDescription)
                }
                for codableItem in codableItems.sorted(by: { $0.name < $1.name }) {
                    modelContext.insert(codableItem.toItem())
                }
                viewModel.showSuccessToast("Restored!", "Restored the items from the clipboard")
            }
        } catch let DecodingError.dataCorrupted(context) {
            exceptionError = context.debugDescription
            backupOperation = .restore
            showingBackupRestoreErrorAlert.toggle()
            debugPrint(context.debugDescription)
        } catch let DecodingError.keyNotFound(key, context) {
            exceptionError = "Key '\(key)' not found:" + context.debugDescription
            backupOperation = .restore
            showingBackupRestoreErrorAlert.toggle()
            debugPrint(context.debugDescription)
        } catch let DecodingError.valueNotFound(value, context) {
            exceptionError = "Value '\(value)' not found:" + context.debugDescription
            backupOperation = .restore
            showingBackupRestoreErrorAlert.toggle()
            debugPrint(context.debugDescription)
        } catch let DecodingError.typeMismatch(type, context) {
            exceptionError = "Type '\(type)' mismatch:" + context.debugDescription
            backupOperation = .restore
            showingBackupRestoreErrorAlert.toggle()
            debugPrint(context.debugDescription)
        } catch {
            exceptionError = error.localizedDescription
            backupOperation = .restore
            showingBackupRestoreErrorAlert.toggle()
            debugPrint(error.localizedDescription)
        }
    }
}
