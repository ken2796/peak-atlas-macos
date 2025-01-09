//
//  BorderlessWindowModifier.swift
//  peak-atlas-macos
//
//  Created by Christopher Sonny on 07/11/24.
//

import SwiftUI

struct BorderlessWindowModifier: ViewModifier {
    let cornerRadius: CGFloat
    func body(content: Content) -> some View {
        content
            .background(WindowAccessor { window in
                window?.titleVisibility = .hidden // Hide the title bar
                window?.styleMask = [.borderless] // Make the window borderless
                window?.isOpaque = false          // Allow transparency
                window?.backgroundColor = .clear  // Set a clear background for transparency
                
                // Apply rounded corners using a custom content view
                window?.contentView?.wantsLayer = true
                window?.contentView?.layer?.cornerRadius = cornerRadius
                window?.contentView?.layer?.masksToBounds = true
            })
    }
}

// Helper view to access the window
struct WindowAccessor: NSViewRepresentable {
    var callback: (NSWindow?) -> Void
    
    func makeNSView(context: Context) -> NSView {
        let nsView = NSView()
        DispatchQueue.main.async {
            self.callback(nsView.window)
        }
        return nsView
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
}

