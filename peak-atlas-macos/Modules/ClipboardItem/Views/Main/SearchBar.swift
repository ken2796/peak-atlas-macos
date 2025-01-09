//
//  SearchBar.swift
//  peak-atlas-macos
//
//  Created by Christopher Sonny on 02/12/24.
//

import SwiftUI

struct SearchBar: View {
    
    @Binding var searchText: String
    @Binding var isAscending: Bool
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    let toggleSort: (() -> Void)
    let showFilter: (() -> Void)
    
    var body: some View {
        HStack{
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search by names, tags or sources", text: $searchText)
                    .textFieldStyle(.plain)
                    .padding(.trailing)
                    .font(.interRegular(14))
            }
            .padding(.all, 8)
            .background(isDarkMode ? Color.init(hex: "#FFFFFF", opacity: 0.05) : .white.opacity(0.5))
            .cornerRadius(8)
            
            HStack {
                Button(action: {
                    toggleSort()
                }) {
                    if isAscending {
                        Image(systemName: "arrow.up.arrow.down")
                    } else {
                        Image(systemName: "arrow.up.arrow.down")
                            .foregroundColor(.gray)
                    }
                }.buttonStyle(BorderlessButtonStyle())
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showFilter()
                        }
                    }
                }) {
                    Image("Funnel", bundle: nil)
                        .foregroundColor(.gray)
                }.buttonStyle(BorderlessButtonStyle())
            }
        }.padding(.init(top: 0, leading: 12, bottom: 0, trailing: 12))
    }
}
