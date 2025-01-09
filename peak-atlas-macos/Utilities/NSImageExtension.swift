//
//  NSImageExtension.swift
//  peak-atlas-macos
//
//  Created by Christopher Sonny on 22/11/24.
//

import Foundation
import AppKit
import SwiftUI

extension NSImage {
    func toBase64String() -> String? {
        guard let tiffRepresentation = self.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffRepresentation),
              let pngData = bitmapImage.representation(using: .png, properties: [:]) else {
            return nil
        }
        
        return pngData.base64EncodedString()
    }
    
    func toSwiftUIImage() -> Image {
        let nsImage = self
        return Image(nsImage: nsImage)
    }
}
