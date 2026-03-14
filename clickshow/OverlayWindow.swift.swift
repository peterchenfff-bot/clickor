//
//  OverlayWindow.swift.swift
//  clickshow
//
//  Created by Richard Lin on 2026/3/14.
//

import AppKit

class OverlayWindow: NSPanel {
    init(rect: NSRect) {
        super.init(
            contentRect: rect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        self.isOpaque = false
        self.backgroundColor = .clear
        self.level = .mainMenu + 1 // Keep it above other apps
        self.ignoresMouseEvents = true // The "Click-Through" magic
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.hasShadow = false
    }
}
