//
//  ArrayWrapper.swift
//  peak-atlas-macos
//
//  Created by Christopher Sonny on 11/11/24.
//

import Foundation

class ArrayWrapper: NSObject, NSSecureCoding {
    static var supportsSecureCoding: Bool = true
    let array: [String]
    
    init(array: [String]) {
        self.array = array
        super.init()
    }
    
    required init?(coder: NSCoder) {
        array = coder.decodeObject(forKey: "array") as? [String] ?? []
        super.init()
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(array, forKey: "array")
    }
}

extension Array where Element == ClipboardItem {
    func filteredAndSorted(
        searchText: String = "",
        showFavoritesOnly: Bool = false,
        sortType: SortType = .dateTime,
        isAscending: Bool = true,
        selectedTypes: Set<Int> = [],
        startDate: Date? = nil,
        endDate: Date? = nil
    ) -> [ClipboardItem] {
        // Base filtering
        let filteredItems = self.filter { item in
            // Favorite filter
            let favoriteFilter = !showFavoritesOnly || item.isFavorite
            
            // Search filter
            let searchFilter = searchText.isEmpty ||
                item.content.contains(searchText) ||
                item.arrayContents.contains { $0.contains(searchText) }
            
            // Type filter
            let typeFilter = selectedTypes.isEmpty || selectedTypes.contains(item.type)
            
            // Date range filter
            let dateFilter = (startDate == nil || item.timestamp >= startDate!) &&
                             (endDate == nil || item.timestamp <= endDate!)
            
            return favoriteFilter && searchFilter && typeFilter && dateFilter
        }
        
        // Sorting logic
        switch (sortType, isAscending) {
        case (.dateTime, true):
            return filteredItems.sorted { $0.timestamp < $1.timestamp }
        case (.dateTime, false):
            return filteredItems.sorted { $0.timestamp > $1.timestamp }
        case (.alphabet, true):
            return filteredItems.sorted { $0.content < $1.content }
        case (.alphabet, false):
            return filteredItems.sorted { $0.content > $1.content }
        }
    }
    
    // Convenience method for favorited items
    func favoritedItems(
        searchText: String = "",
        sortType: SortType = .dateTime,
        isAscending: Bool = true,
        selectedTypes: Set<Int> = [],
        startDate: Date? = nil,
        endDate: Date? = nil
    ) -> [ClipboardItem] {
        filteredAndSorted(
            searchText: searchText,
            showFavoritesOnly: true,
            sortType: sortType,
            isAscending: isAscending,
            selectedTypes: selectedTypes,
            startDate: startDate,
            endDate: endDate
        )
    }
}
