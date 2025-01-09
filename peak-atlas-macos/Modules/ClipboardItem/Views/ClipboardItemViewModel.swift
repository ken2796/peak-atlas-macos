//
//  ClipboardItemViewModel.swift
//  peak-atlas-macos
//
//  Created by Christopher Sonny on 08/11/24.
//

import Foundation
import HotKey
import UserNotifications
import SwiftUI

class ClipboardItemViewModel: ObservableObject {
    @Published var clipboardManager = ClipboardManager()
    @Published var isShortcutEnabled = true
    @Published var isAscending = false
    @Published var isAToZ = false
    @Published var isShowSidebar = false
    @Published var isShowCollection = false
    @Published var isShowSetting = false
    @Published var isShowDetail = false
    @Published var isShowFilter = false
    
    @Published var showFavoritesOnly = false
    @Published var collectionName = ""
    @Published var selectedStartDate: Date?
    @Published var selectedEndDate: Date?
    @Published var selectedTypes: Set<Int>?
    
    @Published var filteredItems: [ClipboardItem] = []
    @Published var staticFilteredItems: [ClipboardItem] = []
    @Published var favoritedItems: [ClipboardItem] = []
    @Published var staticFavoritedItems: [ClipboardItem] = []
    @Published var itemCollections: [ItemCollectionWithColor] = []
    @Published var arraySource: [String: Color] = [:]
    @Published var arraySelectedSource: [String] = []
    @Published var selectedClearHistoryMethod: AutoClearMenuEnum = .none
    @Published var itemToShowDetail: ClipboardItem?
    
    @Published var searchText = "" {
        didSet {
            updateItem()
        }
    }
    
    @Published var selectedLeftColor: Color = .leftBackgroundColor {
        didSet {
            ColorSingleton.shared.saveColor(selectedColor: selectedLeftColor, colorType: .baseLeftColor)
        }
    }
    @Published var selectedRightColor: Color = .rightBackgroundColor {
        didSet {
            ColorSingleton.shared.saveColor(selectedColor: selectedRightColor, colorType: .baseRightColor)
        }
    }
    @Published var selectedFontColor: Color = .white {
        didSet {
            ColorSingleton.shared.saveColor(selectedColor: selectedFontColor, colorType: .fontColor)
        }
    }
    
    @Published var transparentBackground: Color = Color.transparent {
        didSet {
            ColorSingleton.shared.saveColor(selectedColor: transparentBackground, colorType: .fontColor)
        }
    }
    
    var sortType: SortType = .dateTime
    
    let arrayHotkey: [Int: HotKey] = [
        0: HotKey(key: .one, modifiers: [.command, .option]),
        1: HotKey(key: .two, modifiers: [.command, .option]),
        2: HotKey(key: .three, modifiers: [.command, .option]),
        3: HotKey(key: .four, modifiers: [.command, .option]),
        4: HotKey(key: .five, modifiers: [.command, .option]),
        5: HotKey(key: .six, modifiers: [.command, .option]),
        6: HotKey(key: .seven, modifiers: [.command, .option]),
        7: HotKey(key: .eight, modifiers: [.command, .option]),
        8: HotKey(key: .nine, modifiers: [.command, .option]),
        9: HotKey(key: .zero, modifiers: [.command, .option]),
    ]

    init() {
        setupHotkey()
        fetchAutoClearSetting()
        selectedLeftColor = ColorSingleton.shared.fetchColor(colorType: .baseLeftColor) ?? .leftBackgroundColor
        selectedRightColor = ColorSingleton.shared.fetchColor(colorType: .baseRightColor) ?? .rightBackgroundColor
        selectedFontColor = ColorSingleton.shared.fetchColor(colorType: .fontColor) ?? .white
        requestNotificationAuthorization()
        filteredItems = getFilteredItems()
        staticFilteredItems = getFilteredItems()
        favoritedItems = getFavoritedItems()
        staticFavoritedItems = getFavoritedItems()
        arraySource = getArraySource()
        itemCollections = getItemCollections()
        updateAutoClearSetting(setting: selectedClearHistoryMethod)
        clipboardManager.delegate = self
    }
    
    func toggleSort() {
        if sortType == .dateTime {
            isAscending.toggle()
        } else if sortType == .alphabet {
            isAToZ.toggle()
        }
        
        updateItem()
    }
    
    func deleteItem(content: String) {
        clipboardManager.deleteItem(content: content)
    }
    
    func saveToFile() {
        clipboardManager.saveToFile()
    }
    
    func importFromFile() {
        clipboardManager.importFromFile()
    }
    
    func getArraySource() -> [String: Color] {
        var uniqueSource: [String: Color] = ["All": Color.arrayColor[0]]
        
        var counter = 1
        for copiedItem in filteredItems {
            let randomColor = Color.arrayColor[counter]
            if !uniqueSource.keys.contains(copiedItem.source) {
                uniqueSource[copiedItem.source] = randomColor
                counter+=1
            }
        }
        
        return uniqueSource
    }
    
    func getItemCollections() -> [ItemCollectionWithColor] {
        var collections: [ItemCollectionWithColor] = []
        
        for collection in clipboardManager.itemCollections {
            collections.append(ItemCollectionWithColor(id: Int(collection.collectionId), collectionName: collection.collectionName ?? "", collectionColor: Color.arrayColor[collections.count]))
        }
        return collections
    }
    
    func insertSelectedSource(source: String) {
        if source == "All" {
            arraySelectedSource.removeAll()
        } else if !arraySelectedSource.contains(source) {
            arraySelectedSource.append(source)
        } else {
            arraySelectedSource.removeAll(where: { $0 == source })
        }
        refreshAllItems()
    }
    
    func refreshAllItems() {
        if !arraySelectedSource.isEmpty {
            filteredItems = staticFilteredItems.filter({ arraySelectedSource.contains($0.source) })
            favoritedItems = staticFavoritedItems.filter({ arraySelectedSource.contains($0.source) })
        } else {
            filteredItems = staticFilteredItems
            favoritedItems = staticFavoritedItems
        }
    }
    
    func getFilteredItems() -> [ClipboardItem] {
        return clipboardManager.items.filteredAndSorted(searchText: searchText, showFavoritesOnly: false, sortType: sortType, isAscending: isAscending, selectedTypes: selectedTypes ?? [], startDate: selectedStartDate, endDate: selectedEndDate)
    }
    
    func getFavoritedItems() -> [ClipboardItem] {
        return clipboardManager.items.filteredAndSorted(searchText: searchText, showFavoritesOnly: true, sortType: sortType, isAscending: isAscending, selectedTypes: selectedTypes ?? [], startDate: selectedStartDate, endDate: selectedEndDate)
    }
    
    func setupHotkey() {
        for hotkey in arrayHotkey {
            hotkey.value.keyDownHandler = {
                self.copyItem(index: hotkey.key)
                self.copiedMultipleTimes(index: hotkey.key)
            }
        }
    }
    
    func copyItem(index: Int) {
        guard clipboardManager.items.count > index, isShortcutEnabled else { return }
        scheduleNotification(index: index)
        
        copyItemToPasteboard(type: clipboardManager.items[index].type, content: clipboardManager.items[index].content, arrayContent: clipboardManager.items[index].arrayContents)
    }
    
    func copyItemToPasteboard(type: Int, content: String = "", arrayContent: [String] = [], isFromClicked: Bool = false) {
        if isFromClicked {
            scheduleNotification(isFromClicked: isFromClicked)
        }
        
        if type == 1 {
            setTextToPasteboard(text: content)
        } else {
            copyMultipleFilePaths(paths: arrayContent)
        }
    }
    
    func copyMultipleFilePaths(paths: [String]) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        
        // Convert paths to URLs
        let fileURLs = paths.compactMap { path -> NSURL? in
            // Handle both file paths and file URLs
            if path.lowercased().starts(with: "file://") {
                return NSURL(string: path)
            } else {
                return NSURL(fileURLWithPath: path)
            }
        }
        
        // Write file URLs to pasteboard
        if !fileURLs.isEmpty {
            // Write as file URLs
            pasteboard.writeObjects(fileURLs as [NSURL])
            
            // Also write as file paths string for compatibility
            let pathsString = paths.joined(separator: "\n")
            let pasteboardItem = NSPasteboardItem()
            pasteboardItem.setString(pathsString, forType: .string)
            pasteboard.writeObjects([pasteboardItem])
        }
    }
    
    func copiedMultipleTimes(index: Int) {
        clipboardManager.copiedMultipleTimes(index: index)
    }
    
    private func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
            } else {
                print("Notification authorization denied: \(error?.localizedDescription ?? "unknown error")")
            }
        }
    }
    
    private func setTextToPasteboard(text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
    
    private func scheduleNotification(index: Int = 0, isFromClicked: Bool = false) {
        let content = UNMutableNotificationContent()
        content.title = "Clipboard Manager"
        content.body = isFromClicked ? "Item Copied !" : "Item \(index+1) Copied !"
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error displaying notification: \(error)")
            }
        }
    }
    
    public func updateFavorite(index: Int) {
        clipboardManager.updateFavorite(index: index)
    }
    
    func getItemTypeImage(type: Int) -> Image {
        switch type {
        case 1:
            return Image.init("ic_text", bundle: nil)
        case 2, 3:
            return Image.init("ic_image", bundle: nil)
        case 4:
            return Image.init("ic_link", bundle: nil)
        default:
            return Image.init("ic_text", bundle: nil)
        }
    }
    
    func hideAllSidebarTypes() {
        isShowDetail = false
        isShowCollection = false
        isShowSidebar = false
        isShowSetting = false
        isShowFilter = false
    }
}

enum AutoClearMenuEnum: String {
    case none = "None"
    case oneDay = "24 Hours"
    case sevenDay = "7 Days"
}

extension ClipboardItemViewModel {
    func fetchAutoClearSetting() {
        let autoClear = UserDefaults.standard.string(forKey: "auto-clear") ?? "none"
        selectedClearHistoryMethod = AutoClearMenuEnum(rawValue: autoClear) ?? .none
    }
    
    func updateAutoClearSetting(setting: AutoClearMenuEnum) {
        selectedClearHistoryMethod = setting
        UserDefaults.standard.setValue(selectedClearHistoryMethod.rawValue, forKey: "auto-clear")
        if selectedClearHistoryMethod == .none {
            clipboardManager.fetchCopiedData()
        } else if selectedClearHistoryMethod == .oneDay {
            let deleteItem = clipboardManager.items.filter { item in
                item.timestamp < Calendar.current.date(byAdding: .day, value: -1, to: Date())!
            }
            clipboardManager.deleteMultipleItem(arrayItem: deleteItem)
        } else if selectedClearHistoryMethod == .sevenDay {
            let deleteItem = clipboardManager.items.filter { item in
                item.timestamp < Calendar.current.date(byAdding: .day, value: -1, to: Date())!
            }
            clipboardManager.deleteMultipleItem(arrayItem: deleteItem)
        }
    }
    
    func getItemToShowDetail() -> ClipboardItem {
        return self.itemToShowDetail ?? ClipboardItem(itemId: 0, content: "", timestamp: Date(), type: 1, arrayContents: [], source: "")
    }
    
    func addItemCollection() {
        guard !collectionName.isEmpty else { return }
        clipboardManager.addItemCollection(name: collectionName)
    }
    
    func addItemToCollection(collectionId: Int) {
        if let index = filteredItems.firstIndex(where: { $0.itemId == getItemToShowDetail().itemId }) {
            clipboardManager.addItemToCollection(index: index, collectionId: collectionId)
        }
    }
    
    func getCollectionColor(collectionId: Int) -> Color {
        if let index = getItemCollections().firstIndex(where: { $0.id == collectionId }) {
            return getItemCollections()[index].collectionColor
        }
        
        return .transparent
    }
}

extension ClipboardItemViewModel: ClipboardManagerDelegate {
    func updateItem() {
        filteredItems = getFilteredItems()
        staticFilteredItems = getFilteredItems()
        favoritedItems = getFavoritedItems()
        staticFavoritedItems = getFavoritedItems()
        arraySource = getArraySource()
        itemCollections = getItemCollections()
    }
}
