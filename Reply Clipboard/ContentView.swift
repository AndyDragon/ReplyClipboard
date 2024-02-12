//
//  ContentView.swift
//  Reply Clipboard
//
//  Created by Andrew Forget on 2024-02-11.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query var items: [Item]
    @State var selectedItem: Item?

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedItem) {
                ForEach(items/*.sorted { $0.name < $1.name }*/, id: \.self) { item in
                    NavigationLink(value: item) {
                        HStack {
                            Text("\(item.name)")
                            Spacer()
                            Button(action: {
                                copyToClipboard(item.text)
                            }) {
                                Image(systemName: "clipboard")
                            }
                        }
                    }
                }
            }
            .onDeleteCommand {
                if let item = selectedItem {
                    modelContext.delete(item)
                }
            }
            .navigationSplitViewColumnWidth(min: 280, ideal: 320)
            .toolbar {
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            NavigationStack {
                ZStack {
                    if let item = selectedItem {
                        ItemEditor(item: item) {
                            selectedItem = nil
                            modelContext.delete(item)
                        }
                    }
                }
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(name: "new item", text: "", timestamp: Date())
            modelContext.insert(newItem)
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
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
