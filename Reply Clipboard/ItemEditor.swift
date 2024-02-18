//
//  ItemEditor.swift
//  Reply Clipboard
//
//  Created by Andrew Forget on 2024-02-11.
//

import SwiftUI

struct ItemEditor: View {
    @Bindable var item: Item
    var onClose: () -> Void
    var onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Spacer()
                Button(action: onDelete) {
                    Image(systemName: "trash")
                }
                Button(action: onClose) {
                    Image(systemName: "xmark")
                }
            }
            HStack(spacing: 12) {
                Text("Name:")
                    .frame(alignment: .center)
                TextField("Enter the name for the item", text: $item.name)
                    .frame(alignment: .center)
            }
            HStack(spacing: 12) {
                Text("Text:")
                    .frame(alignment: .center)
                TextField("Enter the text for the item", text: $item.text)
                    .frame(alignment: .center)
            }
        }
        .padding()
    }
}
