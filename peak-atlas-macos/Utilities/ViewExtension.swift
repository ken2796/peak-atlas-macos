//
//  ViewExtension.swift
//  peak-atlas-macos
//
//  Created by Christopher Sonny on 08/11/24.
//

import Foundation
import SwiftUI

extension View {
    func onDragGesture() -> some View {
        self.gesture(DragGesture()
            .onChanged { value in
                NSApp.mainWindow?.setFrameOrigin(
                    CGPoint(
                        x: NSApp.mainWindow!.frame.origin.x + value.translation.width,
                        y: NSApp.mainWindow!.frame.origin.y - value.translation.height
                    )
                )
            })
    }
}
