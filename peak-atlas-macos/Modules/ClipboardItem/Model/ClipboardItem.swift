//
//  ClipboardItem.swift
//  peak-atlas-macos
//
//  Created by Christopher Sonny on 03/11/24.
//

import Foundation
import AppKit
import SwiftUI

struct ClipboardItem: Identifiable {
    let id = UUID()
    let itemId: Int
    let content: String
    let timestamp: Date
    let type: Int
    let arrayContents: [String]
    var isFavorite: Bool = false
    var source: String 
    var icon: NSImage?
    var collectionId: Int?
    var copiedFrequency: Int?
}

struct ItemCollectionWithColor: Identifiable, Hashable {
    let id: Int
    let collectionName: String
    let collectionColor: Color
    
    // If all properties are already Hashable, this default implementation works
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(collectionName)
        hasher.combine(collectionColor)
    }
    
    // Implement == for Hashable conformance
    static func == (lhs: ItemCollectionWithColor, rhs: ItemCollectionWithColor) -> Bool {
        return lhs.id == rhs.id &&
        lhs.collectionName == rhs.collectionName &&
        lhs.collectionColor == rhs.collectionColor
    }
}
