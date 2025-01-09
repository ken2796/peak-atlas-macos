//
//  FontExtension.swift
//  peak-atlas-macos
//
//  Created by Christopher Sonny on 30/11/24.
//

import Foundation
import SwiftUI

extension Font {
    // Custom font weights for Inter
    enum Inter {
        // Regular weight variants
        static func regular(size: CGFloat) -> Font {
            return .custom("Inter-Regular", size: size)
        }
        
        // Bold weight variants
        static func bold(size: CGFloat) -> Font {
            return .custom("Inter-Bold", size: size)
        }
        
        // Medium weight variants
        static func medium(size: CGFloat) -> Font {
            return .custom("Inter-Medium", size: size)
        }
        
        // Semibold weight variants
        static func semiBold(size: CGFloat) -> Font {
            return .custom("Inter-SemiBold", size: size)
        }
    }
    
    // Additional convenience methods
    static func interRegular(_ size: CGFloat) -> Font {
        return Inter.regular(size: size)
    }
    
    static func interBold(_ size: CGFloat) -> Font {
        return Inter.bold(size: size)
    }
}

// Companion extension for Text to make font usage even easier
extension Text {
    func interRegular(size: CGFloat) -> Text {
        return self.font(.custom("Inter-Regular", size: size))
    }
    
    func interBold(size: CGFloat) -> Text {
        return self.font(.custom("Inter-Bold", size: size))
    }
}
