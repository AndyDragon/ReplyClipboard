//
//  ItemEditor.swift
//  Reply Clipboard
//
//  Created by Andrew Forget on 2024-02-11.
//

import SwiftUI

class ItemWrapper {
    @Published var name: String = ""
}

struct ItemEditor: View {
    var item: Item
    var onDelete: () -> Void
    var wrapper = ItemWrapper()
    
    init(item: Item, onDelete: @escaping () -> Void) {
        //debugPrint("Setting item \(item.name)...")
        self.item = item
        self.onDelete = onDelete
        wrapper.name = item.name
//        name = item.name
//        nameBinding = Binding(
//            get: { name },
//            set: { name = $0 }
//        )
        //self.text = item.text
    }
    
    var body: some View {
//        VStack {
//            HStack {
//                Spacer()
//                Button(action: onDelete) {
//                    Image(systemName: "trash")
//                }
//            }.padding([.bottom], 12)
//            HStack {
//                Text("Name:")
//                    .frame(width: 60)
//                TextField("Enter the name for the item", text: $item.name)
//            }
//            HStack {
//                Text("Text:")
//                    .frame(width: 60)
//                TextField("Enter the text for the item", text: $item.text)
//            }
//            Spacer()
//        }
//        .padding(20)
        VStack {
            HStack {
                Spacer()
                Button(action: onDelete) {
                    Image(systemName: "trash")
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
                let text = Binding(
                    get: { item.text },
                    set: { item.text = $0 })
                Text("Text:")
                    .frame(width: 60)
                TextField("Enter the text for the item", text: text)
            }
            HStack {
                Button(action: {
                    item.name = wrapper.name
                }) {
                    Text("Save")
                }
            }
            Spacer()
        }
        .padding(20)
    }
}
