//
//  ClipboardManager.swift
//  peak-atlas-macos
//
//  Created by Christopher Sonny on 03/11/24.
//

import AppKit
import SwiftUI
import Combine
import CoreData
import UniformTypeIdentifiers

protocol ClipboardManagerDelegate {
    func updateItem()
}

class ClipboardManager: ObservableObject {
    @Published var items: [ClipboardItem] = []
    @Published var copiedItems: [CopiedItem] = []
    @Published var itemCollections: [ItemCollection] = []
    private let separator = "|||"
    var arrayFilePath: [String] = []
    var delegate: ClipboardManagerDelegate?
    let coreDataManager = CoreDataManager.shared
    
    private var timer: Timer?
    
    init() {
        fetchCopiedData()
        fetchItemCollections()
        startListening()
    }
    
    func fetchCopiedData() {
        copiedItems = coreDataManager.fetchCopiedItem().reversed()
        items = []
        for item in copiedItems {
            let icon = String.fromBase64String(item.icon ?? "") ?? NSImage(named: "star")
            items.append(ClipboardItem(itemId: Int(item.itemId), content: item.content ?? "", timestamp: item.timestamp ?? Date(), type: Int(item.type), arrayContents: convertStringToArray(item.content ?? ""), isFavorite: item.isFavorite, source: item.source ?? "-", icon: icon, collectionId: Int(item.collectionId), copiedFrequency: Int(item.copiedFrequency)))
        }
    }
    
    func fetchItemCollections() {
        itemCollections = coreDataManager.fetchItemCollection()
    }
    
    func saveToFile() {
        coreDataManager.exportJSONToFile()
    }
    
    func importFromFile() {
        coreDataManager.importJSONUsingFileBrowser(completion: { [weak self] in
            guard let self else { return }
            self.fetchCopiedData()
            self.delegate?.updateItem()
        })
    }
    
    func startListening() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            self.checkClipboard()
        }
    }
    
    func updateFavorite(index: Int) {
        items[index].isFavorite.toggle()	
        coreDataManager.toggleFavorite(itemToUpdate: copiedItems[index])
        fetchCopiedData()
        delegate?.updateItem()
    }
    
    func copiedMultipleTimes(index: Int) {
        coreDataManager.copiedMultipleTimes(itemToUpdate: copiedItems[index])
        fetchCopiedData()
        delegate?.updateItem()
    }
    
    func deleteItem(content: String) {
        coreDataManager.deleteItem(content: content)
        fetchCopiedData()
        delegate?.updateItem()
    }
    
    func deleteMultipleItem(arrayItem: [ClipboardItem]) {
        for item in arrayItem {
            coreDataManager.deleteItem(content: item.content)
        }
        fetchCopiedData()
    }
    
    func clearAllData() {
        coreDataManager.clearAllData()
        fetchCopiedData()
        delegate?.updateItem()
    }
    
    private func checkClipboard() {
        let pasteBoardItems = NSPasteboard.general.pasteboardItems
        arrayFilePath.removeAll()
        var type = getPasteboardContentType()
        var content = ""
        if pasteBoardItems?.count ?? 0 > 1 {
            arrayFilePath = getFilePathsFromPasteboard()
            content = convertArrayToString(arrayFilePath)
            type = 2
        } else {
            if type == 3 {
                arrayFilePath = getFilePathsFromPasteboard()
                content = convertArrayToString(arrayFilePath)
            } else {
                content = NSPasteboard.general.string(forType: .string) ?? ""
            }
        }
        
        if !items.contains(where: { $0.content == content }) {
            let icon = getFrontmostApplicationIcon()
            let newItem = ClipboardItem(itemId: coreDataManager.fetchCopiedItem().count, content: content, timestamp: Date(), type: type, arrayContents: arrayFilePath, source: getFrontmostApplicationName() ?? "-", icon: icon)
            items.insert(newItem, at: 0)
            coreDataManager.addCopiedItem(id: UUID(), itemId: coreDataManager.fetchCopiedItem().count, content: content, arrayContent: convertArrayToString(arrayFilePath), type: type, isFavorite: false, timeStamp: Date(), source: getFrontmostApplicationName() ?? "-", icon: icon?.toBase64String() ?? "")
            fetchCopiedData()
            delegate?.updateItem()
        }
    }
    
    func getPasteboardContentType() -> Int {
        let pasteboard = NSPasteboard.general
        
        if let image = NSImage(pasteboard: pasteboard) {
            return 3
        } else if let url = pasteboard.string(forType: .URL) {
            return 4
        } else if let string = pasteboard.string(forType: .string) {
            return 1
        } else {
            return 5
        }
    }
    
    func getFrontmostApplicationName() -> String? {
        if let app = NSWorkspace.shared.frontmostApplication {
            return app.localizedName
        }
        return nil
    }
    
    func getFrontmostApplicationIcon() -> NSImage? {
        guard let frontmostApp = NSWorkspace.shared.frontmostApplication else {
            print("No frontmost application found")
            return nil
        }
        
        guard let url = frontmostApp.bundleURL else {
            print("Could not get bundle URL for frontmost application")
            return nil
        }
        
        return NSWorkspace.shared.icon(forFile: url.path)
    }
    
    func convertArrayToString(_ array: [String]) -> String {
        return array.joined(separator: separator)
    }
    
    func convertStringToArray(_ string: String) -> [String] {
        // Filter out empty strings that might occur if the string starts or ends with separator
        return string.components(separatedBy: separator).filter { !$0.isEmpty }
    }
    
    func getFilePathsFromPasteboard() -> [String] {
        let pasteboard = NSPasteboard.general
        
        // Check for files in pasteboard
        if let items = pasteboard.pasteboardItems {
            var filePaths: [String] = []
            
            for item in items {
                // Check for file URLs
                if let urlString = item.string(forType: .fileURL),
                   let url = URL(string: urlString) {
                    filePaths.append(url.path)
                }
                
                // Check for file names
                if let filenames = item.propertyList(forType: .fileURL) as? [String] {
                    filePaths.append(contentsOf: filenames)
                }
            }
            
            return filePaths
        }
        
        return []
    }
    
    func getButtonFavoriteTitle(_ item: ClipboardItem) -> String {
        if item.isFavorite {
            return "Remove from favorite"
        } else {
            return "Mark as favorite"
        }
    }
    
    func addItemCollection(name: String) {
        coreDataManager.addItemCollection(name: name)
        fetchItemCollections()
        delegate?.updateItem()
    }
    
    func addItemToCollection(index: Int, collectionId: Int) {
        coreDataManager.addItemToCollection(itemToUpdate: copiedItems[index], collectionId: collectionId)
        fetchCopiedData()
        delegate?.updateItem()
    }
}


