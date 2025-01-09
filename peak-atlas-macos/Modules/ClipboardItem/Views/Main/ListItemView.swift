//
//  ListItemView.swift
//  peak-atlas-macos
//
//  Created by Christopher Sonny on 02/12/24.
//

import SwiftUI

struct ListItemView: View {
    let title: String
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    @Binding var items: [ClipboardItem]
    @Binding var selectedLeftColor: Color
    @Binding var selectedFontColor: Color
    
    @Binding var viewModel: ClipboardItemViewModel
    
    var clipboardManager: ClipboardManager
    
    let isFavorite: Bool
    @Binding var isShortcutEnabled: Bool
    
    var body: some View {
        HStack {
            Text(title).font(.interRegular(12)).foregroundStyle(Color.init(hex: "#999999"))
            Spacer()
        }.padding(.horizontal).padding(.bottom, 8)
        
        List(items) { item in
            Button(action: {
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.viewModel.copyItemToPasteboard(type: item.type, content: item.content, arrayContent: item.arrayContents, isFromClicked: true)
                    if let index = clipboardManager.items.firstIndex(where: { $0.content == item.content }) {
                        self.viewModel.copiedMultipleTimes(index: index)
                    }
                }
            }) {
                HStack(spacing: 0){
                    VStack(spacing: 0) {
                        if let icon = item.icon {
                            Image(nsImage: icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                            
                            viewModel.getItemTypeImage(type: item.type)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 12, height: 12)
                        }
                    }.padding(.trailing, 4)
                    
                    VStack(alignment: .leading) {
                        Text(item.content)
                            .font(.interRegular(14))
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .foregroundColor(Color("TextColor"))
                        
                        HStack {
                            Text(item.timestamp.singleUnitRelativeString())
                                .font(.interRegular(10))
                                .foregroundColor(Color("SecondaryTextColor"))
                        }
                    }
                    
                    Spacer()
                    
                    if item.isFavorite {
                        Image(systemName: "star.fill").foregroundColor(.yellow).padding(.trailing, 8)
                    }
                    
                    if item.collectionId != 0 {
                        Circle()
                            .fill(viewModel.getCollectionColor(collectionId: item.collectionId ?? 0))
                            .frame(width: 10, height: 10).padding(.trailing, 0).padding(.trailing, 8)
                    }
                    
                    if let index = clipboardManager.items.firstIndex(where: { $0.content == item.content }) {
                        if isShortcutEnabled && index+1<9 {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(isDarkMode ? Color.init(hex: "#FFFFFF", opacity: 0.05) : .white.opacity(0.5))
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Text("⌘")
                                        .foregroundColor(Color.init(hex: "#999999"))
                                ).padding(.trailing, 4)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(isDarkMode ? Color.init(hex: "#FFFFFF", opacity: 0.05) : .white.opacity(0.5))
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Text("^")
                                        .foregroundColor(Color.init(hex: "#999999"))
                                ).padding(.trailing, 4)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(isDarkMode ? Color.init(hex: "#FFFFFF", opacity: 0.05) : .white.opacity(0.5))
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Text("\(index+1)")
                                        .foregroundColor(Color.init(hex: "#999999"))
                                )
                        }
                    }
                }.cornerRadius(8)
                    .frame(height: 60)
            }.buttonStyle(BorderlessButtonStyle())
                .contextMenu {
                    Button(action: {
                        if viewModel.isShowDetail {
                            viewModel.hideAllSidebarTypes()
                        } else {
                            viewModel.itemToShowDetail = item
                            viewModel.isShowDetail = true
                            viewModel.isShowSidebar = true
                            viewModel.isShowSetting = false
                            viewModel.isShowCollection = false
                        }
                    }) {
                        Text("Show Detail")
                    }
                }
        }.scrollContentBackground(.hidden)
            .listRowBackground(selectedLeftColor)
            .padding(.bottom, 16)
            .frame(
                minHeight: isFavorite ? 73 : nil,
                maxHeight: isFavorite ? (items.count < 4 ? (73*CGFloat(items.count)) : (73*3)) : nil
            )
    }
}
