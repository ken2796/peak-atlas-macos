//
//  CollectionView.swift
//  peak-atlas-macos
//
//  Created by Christopher Sonny on 02/12/24.
//

import SwiftUI

struct CollectionView: View {
    
    @Binding var itemCollections: [ItemCollectionWithColor]
    @Binding var selectedFontColor: Color
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(itemCollections, id: \.self) { collection in
                    Circle()
                        .fill(collection.collectionColor)
                        .frame(width: 10, height: 10).padding(.trailing, 0)
                    Button(action: {
                        
                    }) {
                        Text(collection.collectionName ?? "")
                            .padding(.trailing, 14).foregroundColor(selectedFontColor)
                        
                    }.buttonStyle(PlainButtonStyle())
                }
            }
        }.padding(.init(top: 12, leading: 12, bottom: 20, trailing: 10))
    }
}
