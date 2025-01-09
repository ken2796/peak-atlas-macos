//
//  BlurredBackgroundView.swift
//  peak-atlas-macos
//
//  Created by Kenneth Francia on 1/10/25.
//


import SwiftUI

struct BlurredBackgroundView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let blurView = NSVisualEffectView()
        blurView.material = .underWindowBackground
        blurView.blendingMode = .withinWindow
        blurView.state = .active
        return blurView
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
