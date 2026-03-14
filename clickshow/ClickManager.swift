import SwiftUI
import AppKit
import Combine

struct ClickData {
    let id: UUID
    let point: CGPoint
}

class ClickManager: ObservableObject {
    // Corrected: These now live INSIDE the class
    @AppStorage("rippleColor") var rippleColor: Color = .yellow
    @AppStorage("rippleSize") var rippleSize: Double = 40.0
    
    @Published var lastClick: ClickData?
    private var windows: [OverlayWindow] = []

    init() {
        checkAccessibility()
        setupWindows()
        startMonitoring()
    }

    private func checkAccessibility() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
    }

    private func setupWindows() {
        for screen in NSScreen.screens {
            let window = OverlayWindow(rect: screen.frame)
            let hostingView = NSHostingView(rootView: OverlayContentView(manager: self))
            window.contentView = hostingView
            window.makeKeyAndOrderFront(nil)
            windows.append(window)
        }
    }

    private func startMonitoring() {
        NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            let mouseLoc = NSEvent.mouseLocation
            if let screen = NSScreen.screens.first(where: { NSMouseInRect(mouseLoc, $0.frame, false) }) {
                // Coordinate math: macOS is bottom-up, SwiftUI is top-down
                let x = mouseLoc.x - screen.frame.origin.x
                let y = screen.frame.size.height - (mouseLoc.y - screen.frame.origin.y)
                
                DispatchQueue.main.async {
                    self?.lastClick = ClickData(id: UUID(), point: CGPoint(x: x, y: y))
                }
            }
        }
    }
}

// MANDATORY: This allows SwiftUI to save "Color" data to your disk
extension Color: RawRepresentable {
    public init?(rawValue: String) {
        guard let data = Data(base64Encoded: rawValue) else { return nil }
        do {
            let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data) ?? .yellow
            self = Color(color)
        } catch {
            return nil
        }
    }

    public var rawValue: String {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: NSColor(self), requiringSecureCoding: false)
            return data.base64EncodedString()
        } catch {
            return ""
        }
    }
}
