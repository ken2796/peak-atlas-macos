//
//  CollectionView.swift
//  peak-atlas-macos
//
//  Created by Christopher Sonny on 01/12/24.
//

import SwiftUI

struct AddCollectionView: View {
    let selectedFontColor: Color
    let itemCollections: [ItemCollectionWithColor]
    
    @State private var newCollectionName = ""
    
    let addNewCollection: (String) -> Void
    let addItemToCollection: (Int) -> Void
    let removeFromCollection: () -> Void
    
    
    init(selectedFontColor: Color, itemCollections: [ItemCollectionWithColor],
         addNewCollection: @escaping (String) -> Void,
         removeFromCollection: @escaping () -> Void, addItemToCollection: @escaping (Int) -> Void) {
        self.selectedFontColor = selectedFontColor
        self.itemCollections = itemCollections
        self.removeFromCollection = removeFromCollection
        self.addNewCollection = addNewCollection
        self.addItemToCollection = addItemToCollection
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Collection").font(.interRegular(14)).padding(.top, 20)
                .foregroundColor(selectedFontColor)
            if itemCollections.isEmpty {
                Text("You do not have any collection yet").padding(.init(top: 8, leading: 0, bottom: 8, trailing: 0))
                    .foregroundColor(selectedFontColor)
            } else {
                Text("Add to this collection").padding(.init(top: 16, leading: 0, bottom: 0, trailing: 0))
                    .foregroundColor(selectedFontColor)
                Menu ("Choose Collection to Add") {
                    ForEach(itemCollections, id: \.id) { collection in
                        Button(collection.collectionName) {
                            addItemToCollection(collection.id)
                        }
                    }
                    
                    Button("No Collection") {
                        removeFromCollection()
                    }
                }.padding()
            }
            
            HStack {
                TextField("Enter collection name", text: $newCollectionName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: 40).foregroundColor(selectedFontColor)
                Spacer()
            }.padding(.init(top: 16, leading: 8, bottom: 0, trailing: 8))
            
            HStack {
                Button(action: {
                    addNewCollection(newCollectionName)
                }) {
                    Text("Create collection").foregroundColor(selectedFontColor)
                }
            }.padding(.init(top: 0, leading: 8, bottom: 0, trailing: 8))
            
            Spacer()
        }.padding(.horizontal, 8)
    }
}
