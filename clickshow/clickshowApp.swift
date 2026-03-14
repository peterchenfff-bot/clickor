import SwiftUI
import AppKit

@main
struct ClickShowApp: App {
    @StateObject private var manager = ClickManager()
    @State private var statusBar: StatusBarController?

    var body: some Scene {
        // This is the "ID" macOS looks for when you call showSettingsWindow
        Settings {
            SettingsView()
                .frame(width: 300, height: 250) // Force a size
        }
        .setupStatusBar(manager: manager, statusBar: $statusBar)
    }
}
// This helper class creates the actual icon in the menu bar
class StatusBarController {
    private var statusBar: NSStatusBar
    private var statusItem: NSStatusItem
    
    init(_ manager: ClickManager) {
        statusBar = NSStatusBar.system
        // This creates the item in the menu bar
        statusItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            // You can use a system icon like 'cursorarrow.rays'
            button.image = NSImage(systemSymbolName: "cursorarrow.rays", accessibilityDescription: "ClickShow")
        }
        
        constructMenu()
    }
    
    func constructMenu() {
        let menu = NSMenu()
        
        // 1. Create the item
        let settingsItem = NSMenuItem(
            title: "Settings...",
            action: #selector(openSettings),
            keyEquivalent: ","
        )
        
        // 2. THIS IS THE KEY: Tell the button to look inside this class for the 'openSettings' function
        settingsItem.target = self
        
        menu.addItem(settingsItem)
        menu.addItem(NSMenuItem.separator())
        
        // 3. Quit button (Target is usually nil for system actions like terminate)
        menu.addItem(NSMenuItem(
            title: "Quit ClickShow",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        ))
        
        statusItem.menu = menu
    }

    @objc func openSettings() {
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

// A helper to initialize the status bar when the app starts
extension Scene {
    func setupStatusBar(manager: ClickManager, statusBar: Binding<StatusBarController?>) -> some Scene {
        DispatchQueue.main.async {
            if statusBar.wrappedValue == nil {
                statusBar.wrappedValue = StatusBarController(manager)
            }
        }
        return self
    }
}
