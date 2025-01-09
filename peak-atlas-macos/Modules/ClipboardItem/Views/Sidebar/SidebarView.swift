//
//  SidebarView.swift
//  peak-atlas-macos
//
//  Created by Christopher Sonny on 04/12/24.
//

import SwiftUI

struct SidebarView: View {
    @Binding var viewModel: ClipboardItemViewModel
    @AppStorage("isDarkMode") private var isDarkMode = false
    let clipboardManager: ClipboardManager
    let appWidth: CGFloat
    let appHeight: CGFloat
    
    let isShowSetting: Bool
    let isShowDetail: Bool
    let isShowCollection: Bool
    let isShowFilter: Bool
    
    let selectedRightColor: Color
    
    var body: some View {
        HStack {
            if viewModel.isShowSetting {
                SettingView(sortType: viewModel.sortType,
                            selectedAutoClearType: viewModel.selectedClearHistoryMethod,
                            isShortcutEnabled: $viewModel.isShortcutEnabled,
                            showDeleteAlert: false,
                            selectedLeftColor: $viewModel.selectedLeftColor,
                            selectedRightColor: $viewModel.selectedRightColor,
                            selectedFontColor: $viewModel.selectedFontColor) { autoClear in
                    viewModel.updateAutoClearSetting(setting: autoClear)
                } updateItem: { sortType in
                    viewModel.sortType = sortType
                    viewModel.updateItem()
                } saveToFile: {
                    viewModel.saveToFile()
                } importFromFile: {
                    viewModel.importFromFile()
                } clearAllData: {
                    clipboardManager.clearAllData()
                } setShortcutEnabled: { enabled in
                    viewModel.isShortcutEnabled = enabled
                    viewModel.updateItem()
                }
                
            } else if viewModel.isShowDetail {
                ItemDetailView.init(item: viewModel.getItemToShowDetail(), selectedFontColor: viewModel.selectedFontColor, filteredItems: viewModel.filteredItems) { index in
                    viewModel.updateFavorite(index: index)
                } deleteItem: { content in
                    viewModel.deleteItem(content: content)
                    viewModel.hideAllSidebarTypes()
                } addToCollection: {
                    if viewModel.isShowCollection {
                        viewModel.hideAllSidebarTypes()
                    } else {
                        viewModel.isShowDetail = false
                        viewModel.isShowSetting = false
                        viewModel.isShowCollection = true
                        viewModel.isShowFilter = false
                        viewModel.isShowSidebar = true
                    }
                }
            } else if viewModel.isShowCollection {
                AddCollectionView(selectedFontColor: viewModel.selectedFontColor,
                                  itemCollections: viewModel.getItemCollections(),
                                  addNewCollection: { collectionName in
                    self.viewModel.collectionName = collectionName
                    self.viewModel.addItemCollection()
                },
                                  removeFromCollection: {
                    self.viewModel.addItemToCollection(collectionId: 0)
                    self.viewModel.hideAllSidebarTypes()
                },
                                  addItemToCollection: { collectionId in
                    self.viewModel.addItemToCollection(collectionId: collectionId)
                })
            } else if viewModel.isShowFilter {
                FilterView(applyFilter: { dateStart, dateEnd, type in
                    viewModel.selectedStartDate = dateStart
                    viewModel.selectedEndDate = dateEnd
                    viewModel.selectedTypes = type
                    viewModel.updateItem()
                })
            }
        }.background(isDarkMode ? viewModel.selectedLeftColor.opacity(0.5) : viewModel.selectedFontColor.opacity(0.5))
    }
}
