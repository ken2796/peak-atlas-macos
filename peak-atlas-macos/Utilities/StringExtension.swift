//
//  StringExtension.swift
//  peak-atlas-macos
//
//  Created by Christopher Sonny on 22/11/24.
//

import Foundation
import AppKit

extension String {
    static func fromBase64String(_ base64String: String) -> NSImage? {
        guard let imageData = Data(base64Encoded: base64String) else {
            return nil
        }
        return NSImage(data: imageData)
    }
}
