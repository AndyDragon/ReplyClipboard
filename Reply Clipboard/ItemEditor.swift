//
//  ItemEditor.swift
//  Reply Clipboard
//
//  Created by Andrew Forget on 2024-02-11.
//

import SwiftUI

class ItemWrapper {
    @Published var name: String = ""
    @Published var text: String = ""
}

struct ItemEditor: View {
    var item: Item
    var onClose: () -> Void
    var onDelete: () -> Void
    var wrapper = ItemWrapper()
    
    init(item: Item, onClose: (() -> Void)?, onDelete: @escaping () -> Void) {
        self.item = item
        self.onDelete = onDelete
        self.onClose = onClose ?? {}
        wrapper.name = item.name
        wrapper.text = item.text
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: onDelete) {
                    Image(systemName: "trash")
                }
                Button(action: onClose) {
                    Image(systemName: "xmark")
                }
            }.padding([.bottom], 12)
            HStack {
                let nameBinding = Binding<String>(
                    get: { wrapper.name },
                    set: { wrapper.name = $0 }
                )
                Text("Name:")
                    .frame(width: 60)
                TextField("Enter the name for the item", text: nameBinding)
            }
            HStack {
                let textBinding = Binding(
                    get: { wrapper.text },
                    set: { wrapper.text = $0 })
                Text("Text:")
                    .frame(width: 60)
                TextField("Enter the text for the item", text: textBinding)
            }
            HStack {
                Button(action: {
                    item.name = wrapper.name
                    item.text = wrapper.text
                }) {
                    Text("Save")
                }
            }
            Spacer()
        }
        .padding(20)
    }
}
