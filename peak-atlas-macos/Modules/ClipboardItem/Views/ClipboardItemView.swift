//
//  ClipboardItemView.swift
//  peak-atlas-macos
//
//  Created by Christopher Sonny on 03/11/24.
//

import SwiftUI
import HotKey
import UserNotifications

enum Field {
    case search
    case collectionName
}

enum SortType: String {
    case dateTime = "Date Time"
    case alphabet = "Alphabet"
}

struct ClipboardItemView: View {
    @StateObject private var viewModel = ClipboardItemViewModel()
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var focusedField: Field?
    @AppStorage("isDarkMode") private var isDarkMode = false

    var sortType: SortType = .dateTime
    
    @State private var appWidth: CGFloat = 0
    @State private var appHeight: CGFloat = 0
    @State private var showDeleteAlert = false
    
    var body: some View {
        let clipboardManager = viewModel.clipboardManager
        GeometryReader { geometry in
            HStack {
                
                //MainView
                VStack(spacing: 0) {
                    HeaderView(viewModel: Binding.constant(viewModel))
                    SearchBar(searchText: $viewModel.searchText, isAscending: $viewModel.isAscending) {
                        viewModel.toggleSort()
                    } showFilter: {
                        if viewModel.isShowFilter {
                            viewModel.hideAllSidebarTypes()
                        } else {
                            viewModel.isShowDetail = false
                            viewModel.isShowCollection = false
                            viewModel.isShowSetting = false
                            viewModel.isShowFilter = true
                            viewModel.isShowSidebar = true
                        }
                    }
                    CollectionView(itemCollections: $viewModel.itemCollections, selectedFontColor: $viewModel.selectedFontColor)
                    ListView(viewModel: Binding.constant(viewModel), clipboardManager: clipboardManager,
                             selectedFontColor: $viewModel.selectedFontColor,
                             filteredItems: $viewModel.filteredItems,
                             favoritedItems: $viewModel.favoritedItems,
                             isShortcutEnabled: $viewModel.isShortcutEnabled)
                }
                .frame(width: viewModel.isShowSidebar ? (appWidth*0.75) : appWidth, height: appHeight)
                .background(isDarkMode ? viewModel.selectedLeftColor.opacity(0.3) : viewModel.selectedFontColor.opacity(0.1))
                
                //Sidebar
                SidebarView(viewModel: Binding.constant(viewModel),
                            clipboardManager: clipboardManager,
                            appWidth: appWidth,
                            appHeight: appHeight,
                            isShowSetting: viewModel.isShowSetting,
                            isShowDetail: viewModel.isShowDetail,
                            isShowCollection: viewModel.isShowCollection,
                            isShowFilter: viewModel.isShowFilter,
                            selectedRightColor: viewModel.selectedRightColor)
            }
            .onAppear {
                appWidth = geometry.size.width
                appHeight = geometry.size.height
            }
            .onChange(of: geometry.size) { newSize in
                appWidth = newSize.width
                appHeight = newSize.height
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}

#Preview {
    ClipboardItemView()
}
