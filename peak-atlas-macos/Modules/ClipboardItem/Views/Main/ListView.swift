//
//  ListView.swift
//  peak-atlas-macos
//
//  Created by Christopher Sonny on 05/12/24.
//

import SwiftUI

struct ListView: View {
    @Binding var viewModel: ClipboardItemViewModel
    let clipboardManager: ClipboardManager
    
    @Binding var selectedFontColor: Color
    @Binding var filteredItems: [ClipboardItem]
    @Binding var favoritedItems: [ClipboardItem]
    @Binding var isShortcutEnabled: Bool
    var body: some View {
        if viewModel.favoritedItems.count > 0 {
            ListItemView(title: "Favorites",
                         items: $favoritedItems,
                         selectedLeftColor: $viewModel.selectedLeftColor,
                         selectedFontColor: $selectedFontColor,
                         viewModel: Binding.constant(viewModel),
                         clipboardManager: clipboardManager,
                         isFavorite: true,
                         isShortcutEnabled: $isShortcutEnabled)
        }
        
        ListItemView(title: "Recent",
                     items: $filteredItems,
                     selectedLeftColor: $viewModel.selectedLeftColor,
                     selectedFontColor: $selectedFontColor,
                     viewModel: Binding.constant(viewModel),
                     clipboardManager: clipboardManager,
                     isFavorite: false,
                     isShortcutEnabled: $isShortcutEnabled)
    }
}
