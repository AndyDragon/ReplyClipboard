//
//  MenuView.swift
//  Reply Clipboard
//
//  Created by Andrew Forget on 2025-03-15.
//

import SwiftData
import SwiftUI

struct MenuView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    private let openWindow: () -> Void
    private let openAbout: () -> Void

    init(
        openWindow: @escaping () -> Void,
        openAbout: @escaping () -> Void
    ) {
        self.openWindow = openWindow
        self.openAbout = openAbout
    }

    var body: some View {
        VStack {
            ForEach(items.sorted { $0.name < $1.name }, id: \.self) { item in
                Button {
                    copyToClipboard(item.text)
                } label: {
                    HStack {
                        Image(systemName: "pencil.and.list.clipboard")
                        Text(item.name)
                    }
                }
            }
            Divider()
            Button {
                openWindow()
            } label: {
                HStack {
                    Image(systemName: "macwindow")
                    Text("Open window...")
                }
            }
            Button{
                openAbout()
            } label: {
                HStack {
                    Image(systemName: "info.circle")
                    Text("About...")
                }
            }
            Divider()
            Button("Quit") {
                NSApplication.shared.terminate(nil)
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
