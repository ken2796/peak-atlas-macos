//
//  peak_atlas_macosApp.swift
//  peak-atlas-macos
//
//  Created by Christopher Sonny on 03/11/24.
//

import SwiftUI

@main
struct peak_atlas_macosApp: App {
    let persistenceController = CoreDataManager.shared
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                BlurredBackgroundView()
                    .edgesIgnoringSafeArea(.all)
                    

                ClipboardItemView()
                    .frame(minWidth: 800, minHeight: 600)
                    .environment(\.managedObjectContext, persistenceController.context)
            }
            .onAppear {
                makeWindowTransparent()
            }
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .commands {
            CommandGroup(replacing: .windowSize) { }
        }
    }
    
    private func makeWindowTransparent() {
        if let window = NSApp.windows.first {
            window.isOpaque = false
            window.backgroundColor = .clear
        }
    }
}
