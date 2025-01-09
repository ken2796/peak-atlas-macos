//
//  ItemDetailView.swift
//  peak-atlas-macos
//
//  Created by Christopher Sonny on 01/12/24.
//

import SwiftUI

struct ItemDetailView: View {
    let item: ClipboardItem
    let selectedFontColor: Color
    let filteredItems: [ClipboardItem]
    let updateFavorite: (Int) -> Void
    let deleteItem: (String) -> Void
    let addToCollection: () -> Void
    
    init(item: ClipboardItem, selectedFontColor: Color, filteredItems: [ClipboardItem], updateFavorite: @escaping (Int) -> Void, deleteItem: @escaping (String) -> Void, addToCollection: @escaping () -> Void) {
        self.item = item
        self.selectedFontColor = selectedFontColor
        self.filteredItems = filteredItems
        self.updateFavorite = updateFavorite
        self.deleteItem = deleteItem
        self.addToCollection = addToCollection
    }
    
    var body: some View {
        VStack (spacing: 0) {
            HStack {
                if let icon = item.icon {
                    Image(nsImage: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .padding(.bottom, 4)
                }
                
                VStack {
                    HStack {
                        Text(item.source).padding(.leading, 0)
                        Spacer()
                        if item.isFavorite {
                            Button(action: {
                                if let index = filteredItems.firstIndex(where: { $0.content == item.content }) {
                                    updateFavorite(Int(index))
                                }
                            }) {
                                Image(systemName: "star.fill").foregroundColor(.yellow)
                            }
                        } else {
                            Button(action: {
                                if let index = filteredItems.firstIndex(where: { $0.content == item.content }) {
                                    updateFavorite(Int(index))
                                }
                            }) {
                                Image(systemName: "star").foregroundColor(.yellow)
                            }
                        }
                        
                    }
                    HStack {
                        Text(item.timestamp.singleUnitRelativeString())
                            .font(.interRegular(10))
                            .foregroundColor(selectedFontColor)
                        Spacer()
                    }
                }
                Spacer()
            }.padding(.bottom, 8)
            
            Text(item.content).padding(.trailing, 8).padding(.bottom, 8)
                .foregroundColor(selectedFontColor)
            Button("Delete") {
                deleteItem(item.content)
            }.padding(.vertical, 12).foregroundColor(selectedFontColor)
            
            Button("Add to Collection") {
               addToCollection()
            }.foregroundColor(selectedFontColor)
            Spacer()
        }.padding(.init(top: 20, leading: 8, bottom: 8, trailing: 8))
    }
}

