//
//  SudokuApp.swift
//  Sudoku
//
//  Created by Sean Sullivan on 3/5/25.
//

import SwiftUI

@main
struct SudokuApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 600, minHeight: 750)
                .onAppear {
                    setupAppearance()
                }
        }
        .windowStyle(HiddenTitleBarWindowStyle()) // This removes the default title bar
    }
    
    private func setupAppearance() {
        // Set window appearance properties
        #if os(macOS)
        // Make the title bar transparent if needed
        NSWindow.allowsAutomaticWindowTabbing = false
        
        if let window = NSApplication.shared.windows.first {
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
            window.styleMask.insert(.fullSizeContentView)
        }
        #endif
    }
}
